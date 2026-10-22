# ADR-0001: Tech Stack และขอบเขตสถาปัตยกรรมของ PROJECT AFTERFALL บน MacBook Pro M4 Pro (24 GB)

| ช่อง | ค่า |
|---|---|
| **สถานะ (Status)** | **Proposed — รอผล Technical Spike** (ร่างรอบที่ 1) |
| **วันที่ (Date)** | 2026-10-22 |
| **ผู้ตัดสินใจ** | ผู้ออกแบบ (Designer) โดยมี Technical Game Architect และ Platform Engineer เป็นผู้เสนอ |
| **ขอบเขต** | Engine และภาษา, ขอบเขตสถาปัตยกรรมที่ไม่ขึ้นกับ Engine, ระบบพิกัด, งบหน่วยความจำ 24 GB, แผน Technical Spike, ผลต่อ Repository การเซ็นโค้ด และการแจกจ่าย |
| **อ้างอิงสเปก** | [Master Prompt v3.1](../design/PROJECT_AFTERFALL_Master_Prompt_v3.1.md): 0.6, PART 22 (หัวข้อ 83–87), หัวข้อ 15, หัวข้อ 29–30, PART 25 (95–97), หัวข้อ 101–103, PART 28 (104–108) |
| **เอกสารรอบเดียวกัน** | [01 Vision & Pillars](../gdd/round-01/01-vision-and-pillars.md) · [02 System Map](../gdd/round-01/02-system-map.md) · [03 Rulings §114](../gdd/round-01/03-design-rulings-sec114.md) · [04 Roadmap](../gdd/round-01/04-phased-roadmap.md) · [05 GDD TOC](../gdd/round-01/05-gdd-table-of-contents.md) |
| **ADR ที่คาดว่าจะตามมา** | ADR-0002 การแจกจ่ายเกมผ่าน git และ Steam · ADR-0003 ผู้ให้บริการ LLM ของผู้ช่วยนายพล (หลังได้คำตอบ Q2 และ Spike 5) · ADR-0004 รูปแบบไฟล์ Tile และ Save (หลัง Spike 1) · ADR-0005 ระบบพิกัดและเส้นโครง (หลัง Spike 2) · ADR-0006 Simulation Core และ Determinism (หลัง Spike 3) · ADR-0007 ข้อความภาษาไทยใน UI (หลัง E1 / S7) — เลขชุดนี้ใช้ร่วมกับ [05 สารบัญ GDD](../gdd/round-01/05-gdd-table-of-contents.md) |

> **หมายเหตุเรื่องตัวเลข:** ตัวเลขด้านประสิทธิภาพ หน่วยความจำ และเกณฑ์ผ่านทั้งหมดในเอกสารนี้เป็น **ค่าตั้งต้นที่ต้องวัดและปรับจริง** ตามแนวทางของสเปก (หัวข้อ 106) ไม่ใช่ข้อกำหนดตายตัว
>
> **หมายเหตุเรื่องข้อเท็จจริง:** เวอร์ชันซอฟต์แวร์และสเปกฮาร์ดแวร์ตรวจสอบจากแหล่งข้อมูลออนไลน์ ณ วันที่ 2026-10-22 และแนบลิงก์ไว้ในบรรทัด ข้อใดยืนยันไม่ได้จะเขียนว่า **"ต้องตรวจสอบ"**

---

## 0. สรุปสำหรับผู้ออกแบบ (อ่านภายใน 1 นาที)

1. **สิ่งที่ล็อกแล้วและไม่นำมาถกใหม่ (0.6 / 108.1):** มุมมองแผนที่ Top-down ที่ซูมต่อเนื่องจากแผนที่โลกลงถึงยานพาหนะคันเดียว อาคารแบบ 2.5D ยกนูนเล็กน้อย ภายในอาคารเป็น Floor Plan Overlay ไม่มีกล้องระดับถนนหรือมุมบุคคลที่หนึ่ง ทำเฉพาะ macOS บน MacBook Pro M4 Pro RAM 24 GB และ Build แบบ Native ARM64 + Metal เท่านั้น
2. **ADR นี้แยกการตัดสินใจเป็นสองส่วน**
   - **ส่วนที่ล็อกได้ทันทีไม่ว่าเลือก Engine ใด** คือขอบเขตสถาปัตยกรรม 8 ข้อ (B1–B8 ในหัวข้อ 5.1) เช่น Simulation Core ที่ผลลัพธ์กำหนดได้ (Deterministic) แยกจากการวาดภาพ, Command API เส้นทางเดียวที่ทั้งผู้เล่นและผู้ช่วย AI ต้องใช้, ระบบพิกัด 64 บิต และ Save แบบแบ่ง Chunk
   - **ส่วนที่ขึ้นกับคำตอบ Q1 (ขนาดทีมและภาษา)** คือ Engine
3. **ข้อเสนอ Engine**
   - ทีมถนัด **C#** หรือ **ยังไม่มีทีม** → **Unity 6 LTS + Entities/Burst + Map Tiles ที่สร้างเอง** (ตรงกับข้อเสนอหลักของสเปก)
   - ทีมถนัด **TypeScript และ/หรือ Rust** → **Web Map Stack** (MapLibre GL JS / deck.gl ในแอป Tauri + ระบบจำลองเป็น Rust)
   - ทีมถนัด **Swift** → Swift + Metal + SwiftUI แบบมีเงื่อนไข (ต้องผ่าน Spike เทียบกับ Unity ก่อน)
   - **Unreal Engine 5 และ Bevy ไม่แนะนำเป็นตัวหลัก** (เหตุผลในหัวข้อ 4)
4. **คะแนนถ่วงน้ำหนักของ Unity (75.4) Web Map Stack (75.0) และ Godot (73.6) ห่างกันไม่ถึง 2 คะแนนจาก 100** ซึ่งเล็กกว่าความคลาดเคลื่อนของการให้คะแนนเอง ตารางจึงตัดสินแทนไม่ได้ ตัวชี้ขาดจริงคือ **ภาษาของทีม (Q1)** และ **ผล Technical Spike**
5. **เวอร์ชัน Unity:** ทำ Spike บน **Unity 6.3 LTS** ซึ่งยังเป็น LTS ล่าสุด ณ วันนี้ แล้ววางแผนย้ายไป **Unity 6.7 LTS** เมื่อออก เพราะช่วง 6.4–6.8 Unity กำลังเปลี่ยนแกน ECS และ Scripting Runtime ครั้งใหญ่ (หัวข้อ 5.3)
6. **แก้ตัวเลขในหัวข้อ 105.2:** float32 มีช่วงห่างระหว่างค่าที่เก็บได้ (ULP) **6.25 ซม. ที่ระยะ 1,000 กม.** และ **2 ม. ที่ระยะ 20,000 กม.** ส่วนความคลาดเคลื่อนสูงสุดจากการปัดเศษคือครึ่งหนึ่งของค่าเหล่านั้น (3.1 ซม. และ 1 ม.) สเปกเดิมใช้ตัวเลขคนละความหมายในสองจุด (รายละเอียดในหัวข้อ B2)
7. **คำถามถึงผู้ออกแบบมีเพียง 3 ข้อตามหัวข้อ 108.2** (หัวข้อ 11.1) ส่วนข้ออื่นที่ "ต้องตรวจสอบ" ทีมจะวัดหรือค้นเอง

---

## 1. บริบท (Context)

### 1.1 ข้อจำกัดที่ล็อกแล้ว

| เรื่อง | ค่าที่ล็อก | ที่มา |
|---|---|---|
| มุมมอง | Top-down ที่ซูมต่อเนื่องจากแผนที่โลกลงถึงยานพาหนะคันเดียว อาคาร 2.5D ภายในอาคารเป็น Floor Plan Overlay ไม่มีกล้องระดับถนน | 0.6, 105, 108.1 |
| แพลตฟอร์ม | macOS เท่านั้น ไม่ทำ Windows หรือคอนโซล | 0.6, 104, 108.1 |
| เครื่องเป้าหมาย | MacBook Pro ชิป M4 Pro, RAM 24 GB (เครื่องพัฒนาคือเครื่องเดียวกัน) | 104, 108.1 |
| Build | Native ARM64 + Metal ไม่รองรับ Mac รุ่น Intel | 104 |
| การจัดจำหน่าย | **ผ่าน `git clone` เท่านั้น** ตามที่ผู้ออกแบบสั่งโดยตรง (2026-10-22) · สเปก 104 ระบุ Steam สำหรับ Mac (ต้องเซ็นโค้ดและผ่าน Notarization) ซึ่งขัดกัน จึงรอผู้ออกแบบยืนยัน | คำสั่งผู้ออกแบบ, 104 |
| ขอบเขตงานรอบนี้ | ยังไม่เขียนโค้ดเกม | 118 |

**ข้อขัดแย้งเรื่องช่องทางแจกจ่าย (รอผู้ออกแบบยืนยัน):** ผู้ออกแบบสั่งโดยตรงว่าเกม "เล่นได้แค่บน Mac โดยโหลดผ่าน git เท่านั้น" และ README ของ Repository เขียนตามนั้น ADR นี้จึงถือ **`git clone` เป็นช่องทางเดียวในปัจจุบัน** ส่วน Steam ในสเปก 104 ยังไม่ตัดทิ้ง แต่จะไม่วางแผนงาน Steam จนกว่าผู้ออกแบบจะยืนยัน ระหว่างนี้ออกแบบให้เปลี่ยนไป Steam ได้ภายหลังโดยไม่รื้อ (เซ็นโค้ดและ Notarize ได้) วิธีแจกผ่าน git และวิธีส่งไฟล์ขนาดใหญ่ (เช่น ไฟล์โมเดล LLM) ตัดสินใน ADR-0002 (หัวข้อ 10.3)

### 1.2 ข้อเท็จจริงของเครื่องเป้าหมายและระบบปฏิบัติการ (ตรวจสอบ ต.ค. 2026)

| รายการ | ค่า | แหล่ง |
|---|---|---|
| CPU ของ M4 Pro | 12 คอร์ (8 Performance + 4 Efficiency) หรือ 14 คอร์ (10P + 4E) | [Apple: MBP 14" M4 Pro tech specs](https://support.apple.com/en-us/121553) |
| GPU ของ M4 Pro | 16 หรือ 20 คอร์ | [Apple 121553](https://support.apple.com/en-us/121553) |
| แบนด์วิดท์หน่วยความจำ | 273 GB/s | [Apple 121553](https://support.apple.com/en-us/121553) |
| RAM | 24 GB เป็นค่าเริ่มต้นของ M4 Pro | [Apple 121553](https://support.apple.com/en-us/121553), [Apple: MBP 16" 121554](https://support.apple.com/en-us/121554) |
| MBP 14" | จอ 3024 × 1964 (≈5.9 ล้านพิกเซล) ProMotion สูงสุด 120Hz | [Apple 121553](https://support.apple.com/en-us/121553) |
| MBP 16" | มีเฉพาะ M4 Pro 14 คอร์ CPU / 20 คอร์ GPU จอ 3456 × 2234 (≈7.7 ล้านพิกเซล มากกว่ารุ่น 14" ประมาณ 30%) | [Apple 121554](https://support.apple.com/en-us/121554) |
| High Power Mode | มีทั้งรุ่น 14" และ 16" ที่ใช้ M4 Pro | [MacTrast](https://www.mactrast.com/2024/11/high-power-mode-expands-to-macbook-pro-and-mac-mini-models-with-m4-pro-chip/) |
| macOS ปัจจุบัน | macOS 27 "Golden Gate" ออกเมื่อ 14 ก.ย. 2026 และรองรับเฉพาะ Mac ที่ใช้ Apple Silicon | [9to5Mac](https://9to5mac.com/2026/09/09/apple-confirms-macos-27-golden-gate-launch-date-september-14/), [Eclectic Light](https://eclecticlight.co/2026/09/14/apple-has-released-macos-golden-gate-and-security-updates-to-tahoe-26-7-sequoia-15-8/) |
| Rosetta 2 | ใช้งานทั่วไปได้ถึง macOS 27 หลังจากนั้นเหลือเพียงส่วนย่อยสำหรับเกมเก่า ยืนยันว่าการทำ Native ARM64 อย่างเดียวถูกทาง | [MacRumors](https://macrumors.com/2026/06/10/macos-golden-gate-last-to-support-intel-apps/) |
| Metal 4 | ต้องใช้ macOS Tahoe 26 ขึ้นไปบน Mac | [Apple: Metal support](https://support.apple.com/102894) |

**ผลต่อแผน:** สเปกระบุว่า M4 Pro มี "CPU 12 หรือ 14 คอร์ GPU 16 หรือ 20 คอร์" ซึ่งถูกต้อง แต่สองรุ่นนี้ต่างกันทั้งจำนวนคอร์และจำนวนพิกเซลที่ต้องวาด ผล Spike จึงต้องบันทึกรุ่นเครื่องที่ใช้วัด (ดูได้จาก System Information) และงบในเอกสารนี้ตั้งจาก **รุ่นที่อ่อนที่สุด** คือ 12 คอร์ CPU / 16 คอร์ GPU

### 1.3 สิ่งที่ทำให้โจทย์นี้ยาก

| ความเสี่ยง | ที่มา | ความหมายทางเทคนิค |
|---|---|---|
| ระบบวาดแผนที่หลายระดับซูม | 105.2 ข้อ 1, 85 | ต้องมี Map Tiles แบบหลายระดับ โหลดและปลดตามการซูมเหมือนแอปแผนที่ |
| ความแม่นยำของพิกัด | 105.2 ข้อ 2 | ภาพสั่นเมื่อซูมใกล้ในพื้นที่ที่อยู่ห่างจากจุดกำเนิด |
| เส้นโครงแผนที่ | 105.2 ข้อ 3 | Web Mercator บิดเบือนระยะทาง แต่ระบบจำลองต้องใช้ระยะจริง |
| หน่วยจำนวนมาก | 105.2 ข้อ 4, 106.2 | หน่วยละเอียดพร้อมกันหลักพันถึงหมื่น และประชากรแบบรวมกลุ่มหลักล้าน |
| โลกถาวร | 87 | ห้ามมีสิ่งปลูกสร้างหรือยานพาหนะซ้ำหลังโหลดพื้นที่ใหม่ ต้องมี Entity ID ถาวร |
| การตัดสินใจต้องกำหนดผลได้ | 15.1 | Game AI ต้อง Deterministic ส่วน LLM ทำเฉพาะงานภาษา |
| หน่วยความจำ 24 GB ที่ใช้ร่วมกัน | 104, 106.1 | macOS เกม GPU Editor และ LLM บนเครื่องแย่งหน่วยความจำก้อนเดียวกัน |
| ความร้อนของแล็ปท็อป | 104 | ต้องวัดแบบต่อเนื่อง 30–60 นาที |
| UI ภาษาไทย | 89 (Language Toggle), 97 (ฟอนต์ไทย) | ต้องจัดวางสระและวรรณยุกต์ถูกต้อง (Complex Script Shaping) และตัดบรรทัดภาษาไทยที่ไม่มีช่องว่างได้ |
| การแจกจ่ายผ่าน git | README ของ Repository | ไฟล์ Binary ขนาดใหญ่, โควตา Git LFS และลายเซ็นโค้ดที่ต้องไม่เสียระหว่าง clone |

### 1.4 สภาพ Repository ปัจจุบัน

| ไฟล์ | สถานะ | ผลต่อ ADR |
|---|---|---|
| `play.command` | ตรวจว่าเป็น macOS แล้วแจ้งว่ายังไม่มีตัวเกม (มี TODO ให้เรียกตัวเกม) | ต้องเรียก `.app` ที่ Build แล้ว (หัวข้อ 10.4) |
| `.gitattributes` | `* text=auto eol=lf` และบังคับ LF ให้ `*.command`, `*.sh` | ไฟล์ Binary และ `.app` ที่ Build แล้วต้องประกาศเป็น Binary หรือ LFS ไม่เช่นนั้นการแปลงปลายบรรทัดอาจทำให้ลายเซ็นโค้ดเสีย (หัวข้อ 10.2) |
| `.gitignore` | ไม่เก็บ `build/`, `dist/`, `bin/`, `obj/`, `*.app`, `*.dmg`, `*.zip` | ถ้าจะแจก `.app` ผ่าน git ต้องปรับกฎนี้ (หัวข้อ 10.3) |
| `README.md` | ให้ผู้เล่น `git clone` แล้วรัน `./play.command` อัปเดตด้วย `git pull` | วิธีอัปเดตอาจเปลี่ยนตามทางเลือกการแจกจ่าย (หัวข้อ 10.3) |

---

## 2. ปัจจัยในการตัดสินใจ (Decision Drivers) — เรียงตามความสำคัญ

น้ำหนักรวม 100 คะแนน ใช้กับตารางในหัวข้อ 4

| อันดับ | รหัส | ปัจจัย | น้ำหนัก | วัดอะไร | ที่มาในสเปก |
|---|---|---|---|---|---|
| 1 | D1 | **การจำลองหน่วยจำนวนมาก** | 15 | ECS หรือ Data-oriented, งานหลายเธรด, การทำ Determinism, จำนวนหน่วยหลักพันถึงหมื่น | 15, 105.2 ข้อ 4, 106.2 |
| 2 | D2 | **การวาด Map Tiles และซูมต่อเนื่อง** | 15 | ระบบ Tile หลายระดับ, Streaming, ความแม่นยำพิกัด, การซูม Z0→Z19 | 85, 86, 105.2 ข้อ 1–3, 105.3 |
| 3 | D3 | **ความพร้อมบน Mac / Metal / Apple Silicon** | 14 | Editor และ Player ที่เป็น Native, Metal ที่ใช้งานจริงแล้ว, เครื่องมือวัดผลบน Mac | 104 |
| 4 | D4 | **ความเร็วในการพัฒนาของทีมเล็ก** | 12 | Editor, Hot Reload, ความเสถียรของ API, ความถนัดภาษา (ปรับตาม Q1 ในหัวข้อ 4.4) | 108.2 Q1 |
| 5 | D5 | **เครื่องมือทำ UI สำหรับ Dashboard และแชท รวมภาษาไทย** | 11 | UI ที่มีข้อมูลหนาแน่น กราฟ ตาราง แชท และการแสดงผลภาษาไทยที่ถูกต้อง | PART 10, PART 24, 89, 97 |
| 6 | D6 | **คุณภาพภาพนีออนและเอฟเฟกต์** | 8 | เส้นบางคมที่ความละเอียดจริงของจอ, MSAA, Bloom, ควัน, ยานพาหนะโพลีกอนต่ำมุมบน | 95, 105.1, 105.3 |
| 7 | D7 | **หน่วยความจำที่เหลือบน 24 GB ขณะเปิด Editor** | 8 | ขนาด Editor และเครื่องมือระหว่างพัฒนา | 106.1 |
| 8 | D8 | **ความเสี่ยงระยะยาว** (5 = เสี่ยงต่ำ) | 8 | ความมั่นคงของผู้พัฒนา Engine, การเปลี่ยน API, ภาระดูแลโค้ดที่สร้างเอง, การหาคน | — |
| 9 | D9 | **Steam บน Mac + Notarization** | 5 | ไลบรารี Steamworks, ขั้นตอนเซ็นโค้ดและ Notarize | 104, 107.1 |
| 10 | D10 | **ค่าใช้จ่ายใบอนุญาต** (5 = ถูกที่สุด) | 4 | ค่า License, Royalty | — |

**เหตุผลของการเรียงลำดับ**

- D1 และ D2 อยู่บนสุดเพราะสเปกระบุว่าเป็น **ความเสี่ยงหลัก** ของมุมมองแผนที่ (105.2) และเป็นส่วนที่ Engine ช่วยหรือไม่ช่วยต่างกันมากที่สุด
- D3 สำคัญมาก แต่ทั้ง 6 ทางเลือกรันแบบ Native บน Apple Silicon ได้แล้ว จึงแยกความต่างได้น้อยกว่า D1–D2 อย่างไรก็ตามข้อนี้เป็น **ประตูคัดออก**: ทางเลือกที่ได้ 1 คะแนนใน D1, D2 หรือ D3 จะตกรอบทันที (ไม่มีทางเลือกใดตกรอบในร่างนี้)
- D4 ขึ้นกับคำตอบ Q1 จึงคำนวณสองแบบ คือแบบไม่ขึ้นกับภาษา (หัวข้อ 4.2) และแบบแยกตามภาษา (หัวข้อ 4.4)
- D9 และ D10 น้ำหนักต่ำ เพราะทุกทางเลือกทำได้ และทุกทางเลือกต้องจ่ายค่าสมาชิก Apple Developer Program 99 USD ต่อปีเท่ากันเพื่อ Notarize ([Apple](https://developer.apple.com/support/compare-memberships))

---

## 3. ทางเลือกที่พิจารณา (Considered Options)

### 3.1 ข้อเท็จจริงที่ตรวจสอบแล้ว (ต.ค. 2026)

| ทางเลือก | เวอร์ชันล่าสุด | ใบอนุญาต / ค่าใช้จ่าย | สถานะบน Mac | หมายเหตุสำคัญ |
|---|---|---|---|---|
| **A. Unity 6 LTS + Entities/Burst + Map Tiles ที่สร้างเอง** (C#) | **6.3 LTS** เป็น LTS ล่าสุด ซัพพอร์ตถึง ธ.ค. 2027 ([Unity](https://unity.com/releases/unity-6)); 6.6 เป็น Supported Update (ก.ย. 2026) ([Unity 6.6 Manual](https://docs.unity.com/en-us/engine/6000.6/manual)); **6.7 LTS อยู่ในช่วง Beta** ([Unity 6.7 Beta Manual](https://docs.unity.com/en-us/engine/6000.7/manual)) และมีรายงานว่าจะออกไตรมาส 4 ปี 2026 (ต้องตรวจสอบ) | Personal ฟรีเมื่อรายได้และเงินทุนต่ำกว่า 200K USD, Pro เริ่มที่ 2,310 USD ต่อปี ([Unity Pricing](https://unity.com/pricing)); Runtime Fee ถูกยกเลิกแล้วตั้งแต่ ก.ย. 2024 ([Unity](https://unity.com/blog/unity-is-canceling-the-runtime-fee)) | Editor รองรับ Apple Silicon ([System requirements](https://docs.unity3d.com/Manual/system-requirements.html)); Player แนะนำเป้าหมาย Apple silicon และการรองรับ Intel ของ Standalone Player ถูกประกาศเลิกใช้ ([macOS build settings](https://docs.unity.com/en-us/engine/6000.7/manual/platform-specific/apple-mac/macos-delivery/macosbuildsettings)) | แพ็กเกจ ECS ทั้งหมดเป็น Core Package แล้ว ([ECS status 6.6](https://discussions.unity.com/t/ecs-development-status-for-unity-6-6/1724480)); 6.7 LTS เป็นรุ่นสุดท้ายที่ใช้ Mono และ 6.8 จะเปลี่ยนไปใช้ CoreCLR ([CoreCLR & ECS status, มี.ค. 2026](https://discussions.unity.com/t/coreclr-scripting-and-ecs-status-update-march-2026/1711852)) |
| **B. Web Map Stack** — MapLibre GL JS / deck.gl ในแอป Tauri + ระบบจำลองเป็น Rust (TypeScript + Rust) | MapLibre GL JS v6.15.0 ([Releases](https://github.com/maplibre/maplibre-gl-js/releases)); deck.gl v9.4.0 ([Releases](https://github.com/visgl/deck.gl/releases)); Tauri 2.12.5 และมี 3.0 alpha ([Releases](https://github.com/tauri-apps/tauri/releases)) | MapLibre: BSD-3 ([repo](https://github.com/maplibre/maplibre-gl-js)); deck.gl: MIT ([repo](https://github.com/visgl/deck.gl)); Tauri: MIT / Apache-2.0 ([repo](https://github.com/tauri-apps/tauri)) | Tauri ใช้ WKWebView บน macOS ([repo](https://github.com/tauri-apps/tauri)); WebGPU เปิดเป็นค่าเริ่มต้นใน Safari บน macOS Tahoe 26 ([gpuweb wiki](https://github.com/gpuweb/gpuweb/wiki/Implementation-Status)) แต่ WKWebView ได้ WebGPU ด้วยหรือไม่ ต้องตรวจสอบ | deck.gl 9.4 รองรับ WebGPU ในทุก Layer ทางการ **แบบทดลอง** (Render Test ยืนยันว่าเท่า WebGL เฉพาะกรณีใช้งานทั่วไป บางฟีเจอร์ยังรองรับบางส่วน และยังไม่แนะนำสำหรับ Production) ([What's New 9.4](https://deck.gl/docs/whats-new)); Tauri รองรับการเซ็นและ Notarize ใน Bundler ([Tauri docs](https://v2.tauri.app/distribute/sign/macos/)) |
| **C. Bevy** (Rust) | 0.20 (8 ต.ค. 2026) ([Bevy news](https://bevy.org/news/)) | MIT หรือ Apache-2.0 ([repo](https://github.com/bevyengine/bevy)) | Renderer รันบน Metal ได้ (0.20 ระบุว่า Solari รันบน macOS ผ่าน Metal) ([Bevy 0.20](https://bevy.org/news/bevy-0-20/)) | ออกรุ่นที่มี Breaking Changes ประมาณทุก 3 เดือน ([repo](https://github.com/bevyengine/bevy)); ยังไม่มี Editor อย่างเป็นทางการ กำลังทยอยส่งชิ้นส่วนของ Editor ([Bevy 0.20](https://bevy.org/news/bevy-0-20/)) |
| **D. Swift + Metal + SwiftUI** | macOS 27 SDK, Metal 4 (macOS 26+) | ฟรี (เครื่องมือของ Apple) | ดีที่สุดเพราะเป็นของ Apple เอง | ต้องสร้างเครื่องมือเกมเองเกือบทั้งหมด; การเรียก Steamworks (C++) จาก Swift ต้องตรวจสอบ |
| **E. Unreal Engine 5** (C++ / Blueprint) | 5.8 (17 มิ.ย. 2026) ([GameFromScratch](https://gamefromscratch.com/unreal-engine-5-8-released/)) | Royalty 5% ของรายได้ส่วนที่เกิน 1M USD ต่อผลิตภัณฑ์ ([Unreal FAQ](https://www.unrealengine.com/en-US/faq)) | Editor แบบ Native บน Apple Silicon ตั้งแต่ 5.2 ([Epic](https://www.unrealengine.com/en-US/tech-blog/unreal-engine-5-2-brings-native-support-for-apple-silicon-and-other-developments-for-macos)); Epic เองระบุว่า TSR บน Apple Silicon ยังมีข้อจำกัดด้านต้นทุน ([Epic progress report](https://www.unrealengine.com/tech-blog/bringing-unreal-engine-on-macos-up-to-feature-parity-with-windowsprogress-report)) | Large World Coordinates ใช้ double บน CPU และจำลองความแม่นยำสูงบน GPU ด้วยคู่ float ([Epic LWC](https://dev.epicgames.com/documentation/en-us/unreal-engine/large-world-coordinates-in-unreal-engine-5)) |
| **F. Godot 4** (GDScript / C# / GDExtension) | 4.7.2 (18 ส.ค. 2026) และมี 4.8 beta 1 (15 ต.ค. 2026) ([Godot blog](https://godotengine.org/blog/)) | MIT ([repo](https://github.com/godotengine/godot)) | Metal เป็นไดรเวอร์ค่าเริ่มต้นบน Apple Silicon ตั้งแต่ 4.4 และยังเป็นค่าเริ่มต้นใน 4.7.2 (Mac รุ่น Intel ตกไปใช้ Vulkan ผ่าน MoltenVK) ([ProjectSettings 4.7.2](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/doc/classes/ProjectSettings.xml), [Godot 4.4 dev 1](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-1/)) | รองรับพิกัด double เมื่อคอมไพล์ Engine เองด้วย `precision=double` ([Godot docs](https://docs.godotengine.org/en/stable/tutorials/physics/large_world_coordinates.html)); ข้อความใช้ HarfBuzz + ICU ([TextServerAdvanced](https://docs.godotengine.org/en/4.6/classes/class_textserveradvanced.html)); มี Swift binding ([SwiftGodot](https://github.com/migueldeicaza/SwiftGodot)) |

### 3.2 จุดแข็งและจุดอ่อนต่อโปรเจกต์นี้

**A. Unity 6 LTS + Entities/Burst + Map Tiles ที่สร้างเอง**

- จุดแข็ง
  - Entities + Burst + Jobs ออกแบบมาเพื่อหน่วยจำนวนมากโดยตรง และ Burst มีโหมด `FloatMode.Deterministic` บนระบบ 64 บิต ([Unity Burst docs](https://docs.unity3d.com/Manual/burst/float-precision-determinism.html))
  - มี Editor, Profiler, Asset Pipeline, Shader Graph, VFX และ UI Toolkit ครบในที่เดียว ใช้ภาษาเดียว (C#) ทุกชั้น
  - URP บน Metal รองรับ Memoryless Render Target บน Apple Silicon ([Unity Metal optimize](https://docs.unity3d.com/Manual/metal-optimize.html)) เหมาะกับ MSAA ที่ความละเอียดจริงของจอ
  - วาดยานพาหนะโพลีกอนต่ำด้วยกล้องมุมบนตามหัวข้อ 105.3 ได้ทันที
- จุดอ่อน
  - ไม่มีระบบ Map Tiles และ Floating Origin ในตัว ต้องสร้างเอง (สเปกยอมรับไว้แล้วใน 107.1)
  - Transform ของ Engine เป็น float32 จึงต้องทำ Camera-relative Rendering เอง (หัวข้อ B2)
  - ช่วง 2026–2027 API เปลี่ยนมาก: ECS เป็น Core Package, `EntityId` ขยายเป็น 8 ไบต์, Managed Component ถูกประกาศเลิกใช้, Entities Journaling ถูกประกาศเลิกใช้ (Deprecated) ใน 6.5 และจะย้ายไป CoreCLR ใน 6.8 ([ECS 6.6](https://discussions.unity.com/t/ecs-development-status-for-unity-6-6/1724480), [มี.ค. 2026](https://discussions.unity.com/t/coreclr-scripting-and-ecs-status-update-march-2026/1711852)) และหน้าคู่มือแสดงว่ามีเวอร์ชัน 7000.0 Alpha แล้ว ([Unity 6.7 Beta Manual](https://docs.unity.com/en-us/engine/6000.7/manual))
  - ภาษาไทยใน UI Toolkit ต้องใช้ Advanced Text Generator ที่ใช้ HarfBuzz + ICU ([Unity ATG](https://docs.unity3d.com/6/Documentation/Manual/UIE-advanced-text-generator.html)) แต่เอกสารไม่ได้ระบุว่าทดสอบภาษาไทยแล้ว **ต้องตรวจสอบ**
  - Editor กินหน่วยความจำหลาย GB ระหว่างพัฒนา

**B. Web Map Stack (MapLibre / deck.gl ใน Tauri + Rust)**

- จุดแข็ง
  - ระบบแผนที่เว็บถูกสร้างมาเพื่อ Vector Tiles และซูมต่อเนื่องอยู่แล้ว ลดความเสี่ยงอันดับ 1 ของหัวข้อ 105.2 ได้มากที่สุด
  - UI แบบเว็บดีที่สุดสำหรับ Dashboard กราฟ ตาราง และแชท และ WebKit แสดงภาษาไทยได้ถูกต้อง
  - Rust เหมาะกับระบบจำลองหลายเธรดที่กำหนดผลได้ ใบอนุญาตทั้งหมดเป็นโอเพนซอร์ส
- จุดอ่อน
  - ต้องใช้สองภาษาและมีรอยต่อระหว่างระบบจำลองกับหน้าเว็บ (IPC) ที่ต้องส่งสถานะทุก Tick ซึ่งสเปกระบุว่าเป็นคอขวด (107.2)
  - เอฟเฟกต์แบบเกม เสียง Bloom และยานพาหนะ 3D มุมบนต้องทำเองมากกว่า
  - วัดผลยากกว่า เพราะ WebKit แยกงานวาดภาพไปอยู่ในโปรเซสอื่น; รองรับ 120 fps ใน WKWebView หรือไม่ **ต้องตรวจสอบ**
  - Steam Overlay บน macOS กับแอปที่ใช้ WKWebView มีรายงานว่าใช้ไม่ได้ ([Construct forum](https://construct.net/en/comments/62775)) — เป็นข้อมูลจากผู้ใช้ **ต้องตรวจสอบ** (Overlay ไม่ใช่ข้อบังคับของเกมนี้)
  - พฤติกรรมของ WKWebView เปลี่ยนตามการอัปเดต macOS ซึ่งทีมควบคุมไม่ได้

**C. Bevy (Rust)**

- จุดแข็ง: ECS ที่เร็วและควบคุมได้ทั้งหมด ใบอนุญาตเปิด
- จุดอ่อน: Breaking Changes ทุกประมาณ 3 เดือน ยังไม่มี Editor อย่างเป็นทางการ UI ยังใหม่ ต้องสร้างระบบ Tiles เอง และการตัดบรรทัดภาษาไทยของระบบข้อความ **ต้องตรวจสอบ**
- ใช้ประโยชน์ได้อีกทาง: ถ้าทีมเลือกทางเลือก B อาจใช้ `bevy_ecs` เป็นไลบรารีภายในระบบจำลอง Rust โดยไม่ใช้ส่วนอื่นของ Bevy (ต้องตรวจสอบความเหมาะสม)

**D. Swift + Metal + SwiftUI**

- จุดแข็ง: เข้าถึง Metal และเครื่องมือของ Apple ได้เต็มที่ SwiftUI ทำ Dashboard และแชทได้ดีมาก และระบบข้อความของ macOS แสดงภาษาไทยได้ถูกต้อง
- จุดอ่อน: ต้องสร้างทุกอย่างเอง ทั้ง Renderer, ระบบ Tiles, ECS, Asset Pipeline, Profiler ของเกม และเครื่องมือออกแบบ งานส่วนนี้มากที่สุดในทุกทางเลือก ความเสี่ยงระยะยาวคือภาระดูแล Engine ที่ทีมสร้างเอง

**E. Unreal Engine 5**

- จุดแข็ง: Large World Coordinates (double) แก้ปัญหาความแม่นยำได้ในตัว มี Mass Entity สำหรับ Agent จำนวนมาก มี Steam ในตัว
- จุดอ่อน: จุดเด่นด้านภาพ 3D สมจริงแทบไม่ได้ใช้ในมุมมองแผนที่ (สเปก 107.2) Editor หนักมากบน 24 GB Temporal Upscaling ทำให้เส้นบางเบลอ และ Epic เองยอมรับว่า TSR บน Apple Silicon ยังมีต้นทุนสูง ภาษา C++ ไม่ตรงกับภาษาที่สเปกถามถึงเลย

**F. Godot 4**

- จุดแข็ง: Editor เบามาก เรียนง่าย ใบอนุญาต MIT มีระบบข้อความ HarfBuzz + ICU และมีตัวเลือกพิกัด double
- จุดอ่อน: ระบบจำลองขนาดใหญ่ต้องเขียนด้วย C# หรือ GDExtension (C++ / Rust / Swift) เพราะ GDScript ช้าเกินไปสำหรับงานนี้ Metal backend ยังใหม่กว่าของ Unity ต้องสร้างระบบ Tiles เอง และพิกัด double ต้องคอมไพล์ Engine เอง

---

## 4. การให้คะแนนแบบถ่วงน้ำหนัก

### 4.1 ความหมายของคะแนน

| คะแนน | ความหมาย |
|---|---|
| 5 | Engine มีสิ่งนี้ในตัวหรือเหมาะที่สุด แทบไม่ต้องสร้างเอง |
| 4 | ทำได้ดี มีงานสร้างเพิ่มเล็กน้อย |
| 3 | ทำได้ แต่ต้องสร้างเองพอสมควร หรือมีข้อจำกัดที่ต้องพิสูจน์ |
| 2 | ต้องสร้างเองเกือบทั้งหมด หรือมีความเสี่ยงชัดเจน |
| 1 | ไม่เหมาะ หรือเป็นอุปสรรคสำคัญ |

### 4.2 ตารางคะแนนแบบไม่ขึ้นกับภาษาของทีม

D4 ในตารางนี้วัดเฉพาะความเร็วของเครื่องมือ ยังไม่รวมความถนัดภาษา

| ปัจจัย | น้ำหนัก | A Unity | B Web Stack | C Bevy | D Swift+Metal | E Unreal 5 | F Godot 4 |
|---|---|---|---|---|---|---|---|
| D1 การจำลองหน่วยจำนวนมาก | 15 | 5 | 5 | 5 | 3 | 4 | 3 |
| D2 Map Tiles / ซูมต่อเนื่อง | 15 | 3 | 4 | 2 | 2 | 3 | 3 |
| D3 Mac / Metal / Apple Silicon | 14 | 4 | 3 | 3 | 5 | 3 | 3 |
| D4 ความเร็วของเครื่องมือ | 12 | 4 | 3 | 2 | 2 | 2 | 4 |
| D5 UI Dashboard / แชท / ภาษาไทย | 11 | 3 | 5 | 2 | 5 | 3 | 4 |
| D6 ภาพนีออนและเอฟเฟกต์ | 8 | 5 | 3 | 4 | 4 | 4 | 4 |
| D7 หน่วยความจำขณะเปิด Editor | 8 | 3 | 4 | 4 | 4 | 1 | 5 |
| D8 ความเสี่ยงระยะยาว | 8 | 3 | 2 | 2 | 3 | 4 | 4 |
| D9 Steam + Notarization | 5 | 4 | 3 | 3 | 4 | 4 | 4 |
| D10 ค่าใบอนุญาต | 4 | 3 | 5 | 5 | 5 | 4 | 5 |
| **ผลรวมถ่วงน้ำหนัก (เต็ม 500)** | 100 | **377** | **375** | 308 | 352 | 312 | **368** |
| **คิดเป็นคะแนนเต็ม 100** | | **75.4** | **75.0** | 61.6 | 70.4 | 62.4 | **73.6** |

### 4.3 เหตุผลของคะแนนที่สำคัญ

| ปัจจัย | เหตุผลโดยย่อ |
|---|---|
| D1 | A มี Entities + Burst + Jobs และโหมด Deterministic; B และ C ใช้ Rust แบบ Native หลายเธรด; E มี Mass Entity แต่หนักกว่า; D ไม่มี ECS ให้ ต้องสร้างเอง; F ต้องย้ายงานหนักไป C# หรือ GDExtension |
| D2 | B เป็นทางเดียวที่มีระบบ Vector Tiles และซูมต่อเนื่องพร้อมใช้ (หัก 1 คะแนนเพราะต้องส่งสถานะหน่วยข้าม IPC); A, E, F ต้องสร้างระบบ Tiles เอง แต่มีโครงสร้างการวาดภาพของ Engine ช่วย และ E, F มีตัวเลือกพิกัด double; C และ D ต้องสร้างแทบทั้งหมด |
| D3 | D เป็นของ Apple เอง; A มี Editor และ Player แบบ Native และ Metal ที่ใช้มานาน; B ผ่าน WKWebView และวัดผลยาก; C ใช้ Metal ผ่าน wgpu แต่มีเกมบน Mac ที่วางขายจริงน้อย; E ยังตาม Windows ในบางฟีเจอร์; F มี Metal backend ที่อายุน้อยกว่า |
| D4 | A และ F มี Editor ที่ดี; B ต้องใช้สองภาษาและดูแลรอยต่อ IPC; C ไม่มี Editor และ API เปลี่ยนบ่อย; D ต้องสร้างเครื่องมือเอง; E Editor หนักและคอมไพล์ C++ ช้า |
| D5 | B (เว็บ) และ D (SwiftUI) ดีที่สุดและแสดงภาษาไทยถูกต้อง; F มี Control และข้อความแบบ HarfBuzz + ICU; A มี UI Toolkit แต่ภาษาไทยต้องพิสูจน์; E ใช้ UMG ที่ไม่สะดวกกับ Dashboard ข้อมูลหนาแน่น; C ระบบ UI ยังใหม่ |
| D6 | A มี URP, Shader Graph และ VFX และรองรับ MSAA บน Metal; B วาดเส้นได้ดีแต่ Bloom และโมเดล 3D ต้องทำเอง; E เอฟเฟกต์ดีแต่การ Upscale ทำให้เส้นบางเบลอ |
| D7 | F Editor เบาที่สุด; E Editor หนักที่สุด; A ปานกลาง; B, C, D ไม่มี Editor ของเกมแต่มี Language Server และการคอมไพล์ที่กินหน่วยความจำ |
| D8 | E และ F มีผู้ดูแลมั่นคง; A มีประวัติเปลี่ยนนโยบายราคาและกำลังเปลี่ยน API ครั้งใหญ่; B ประกอบจากหลายโครงการและขึ้นกับ WKWebView; C ยังไม่ถึง 1.0; D มีภาระดูแล Engine ที่สร้างเอง |
| D9 | A มี Steamworks.NET (รุ่นล่าสุดอ้างอิง Steamworks SDK 1.64) ([Releases](https://github.com/rlabrecque/Steamworks.NET/releases)); E มี Steam ในตัว; F มี GodotSteam; B และ C ใช้ Crate ของ Rust และ Overlay อาจใช้ไม่ได้; D ต้องเชื่อม C++ เอง |
| D10 | A ต้องจ่าย Unity Pro 2,310 USD ต่อปีต่อที่นั่งเมื่อรายได้หรือเงินทุนเกิน 200K USD; E จ่าย Royalty 5% ส่วนที่เกิน 1M USD; ที่เหลือฟรี |

### 4.4 ความไวต่อคำตอบ Q1 (ภาษาและขนาดทีม)

**วิธีคำนวณ:** แทนคะแนน D4 ด้วยค่าเฉลี่ยของ "ความเร็วของเครื่องมือ" (จากตาราง 4.2) กับ "ความถนัดภาษาของทีม" (ตารางด้านล่าง) แล้วคำนวณสองแบบ คือน้ำหนัก D4 = 12 (ทีม 3 คนขึ้นไป) และ D4 = 20 (ทีม 1–2 คน ซึ่งความถนัดภาษามีผลมากขึ้น) จากนั้นปรับให้เต็ม 100

**ความถนัดภาษาต่อทางเลือก (1–5)**

| ทางเลือก | ทีม C# | ทีม TypeScript | ทีม Rust | ทีม Swift | ทีม TypeScript + Rust | ยังไม่มีทีม / เริ่มเรียน |
|---|---|---|---|---|---|---|
| A Unity (C#) | 5 | 3 | 2 | 2 | 3 | 4 |
| B Web Stack (TS + Rust) | 1 | 3 | 3 | 1 | 5 | 2 |
| C Bevy (Rust) | 1 | 1 | 5 | 1 | 3 | 1 |
| D Swift + Metal | 1 | 1 | 2 | 5 | 1 | 2 |
| E Unreal (C++) | 2 | 1 | 2 | 2 | 1 | 1 |
| F Godot (C# / GDScript / gdext / SwiftGodot) | 4 | 2 | 3 | 3 | 2 | 5 |

**ผลคะแนน (เต็ม 100) แยกตามโปรไฟล์ทีม**

| โปรไฟล์ทีม | อันดับ 1 | อันดับ 2 | อันดับ 3 | ทีม 1–2 คน (D4 = 20) |
|---|---|---|---|---|
| C# | **A Unity 76.6** | F Godot 73.6 | B Web 72.6 | A 77.6 > F 74.1 > B 70.2 |
| TypeScript อย่างเดียว | **B Web 75.0** | A Unity 74.2 | F Godot 71.2 | B 73.9 = A 73.9 (เสมอ) |
| TypeScript + Rust | **B Web 77.4** | A Unity 74.2 | F Godot 71.2 | B 77.6 > A 73.9 > F 70.4 |
| Rust | **B Web 75.0** | A Unity 73.0 | F Godot 72.4 (Bevy 65.2) | B 73.9 > F 72.2 > A 72.0 |
| Swift | **D Swift 74.0** | A Unity 73.0 | B Web 72.6 | D 73.7 > F 72.2 > A 72.0 |
| ยังไม่มีทีม / เริ่มเรียน | **A Unity 75.4** | F Godot 74.8 | B Web 73.8 | F 75.9 ≈ A 75.7 (เสมอ) |

**ข้อสังเกต**

- Bevy ได้คะแนนต่ำแม้ทีมถนัด Rust (65.2) เพราะ D2 และ D5 ต้องสร้างเองเกือบทั้งหมด ทีม Rust จึงควรใช้ Rust ในระบบจำลองของทางเลือก B แทน
- Unreal อยู่ท้ายตารางทุกโปรไฟล์ เพราะ D7 (Editor หนักบน 24 GB) และ D4 (C++) และจุดแข็งของมันไม่ตรงกับมุมมองแผนที่
- ทุกกรณีที่ผลต่างน้อยกว่า 2 คะแนน ให้ถือว่า **เสมอ** และตัดสินด้วย Spike แบบเทียบสองทางเลือก (Bake-off) ในหัวข้อ 9.3
- **ข้อยกเว้นของกติกาเสมอ:** ถ้ายังไม่มีทีม หรือไม่ได้รับคำตอบ Q1 ก่อนเริ่ม Spike (เช่น Unity 75.4 กับ Godot 74.8 หรือกับ Web 75.0) ให้ใช้ข้อเสนอหลักของสเปก (107.1) เป็นตัวตัดสินเสมอ และ **ไม่ทำ Bake-off** เพราะยังไม่มีข้อมูลภาษาของทีมที่จะทำให้ผลต่างเปลี่ยน ทางเลือกอื่นกลับมาพิจารณาได้เมื่อได้คำตอบ Q1 หรือเมื่อ Spike ของ Unity ไม่ผ่าน

### 4.5 ผลต่อการตัดสินใจตามคำตอบ Q1

| คำตอบ Q1 | Engine ที่เสนอ | ตัวสำรอง | ต้องทำ Bake-off ไหม |
|---|---|---|---|
| C# (ทุกขนาดทีม) | **A Unity 6 LTS** | F Godot + C# | ไม่ต้อง ทำ Spike 1–6 บน A |
| TypeScript + Rust | **B Web Map Stack** | A Unity | ไม่ต้อง ทำ Spike 1–6 บน B |
| TypeScript อย่างเดียว | **B Web Map Stack** (เสมอกับ A) | A Unity | ต้องทำ Spike 1, 3, 4 บน B และ A แล้วเลือก |
| Rust | **B Web Map Stack** (ระบบจำลอง Rust) | F Godot + godot-rust (ระบบจำลอง Rust ตัวเดียวกัน) | ต้องทำ Spike 1 และ 4 บน B และ F |
| Swift | **D Swift + Metal + SwiftUI** (นำเล็กน้อย) | A Unity | ต้องทำ Spike 1, 2, 4 บน D และ A เพราะ D ต้องสร้าง Renderer แผนที่เองทั้งหมด |
| ยังไม่มีทีม / เริ่มเรียน | **A Unity 6 LTS** (ค่าเริ่มต้นตามสเปก 0.6) | F Godot | ถ้า Spike 3 บน Godot + C# ผ่าน ให้พิจารณา F อีกครั้ง |
| ไม่ได้รับคำตอบภายในวันเริ่ม Spike | **A Unity 6 LTS** | — | ใช้ค่าเริ่มต้นนี้ตามข้อเสนอหลักของสเปก (107.1) |

---

## 5. การตัดสินใจที่เสนอ (Decision — Proposed)

### 5.1 ส่วนที่ 1: ขอบเขตสถาปัตยกรรมที่ล็อก ไม่ว่าเลือก Engine ใด

ส่วนนี้มีผลทันทีที่ ADR ได้รับการยอมรับ และช่วยให้ถ้าต้องเปลี่ยน Engine ภายหลัง ส่วนที่ต้องเขียนใหม่จำกัดอยู่ที่ชั้น Presentation

```text
┌─────────────────────────── macOS 27 · Apple Silicon (ARM64) · Metal ───────────────────────────┐
│                                                                                                 │
│  PRESENTATION (Engine)                                    PLATFORM LAYER (B8)                   │
│   ├─ Map Renderer: Render Tiles, camera-relative, MSAA    ├─ thermalState / memory pressure     │
│   ├─ Unit & FX Renderer: instancing, zoom bands (105.3)   ├─ Keychain (API keys)                │
│   ├─ UI: Dashboard · Aide Chat · Dossier · Radio Panel    ├─ QoS (P-cores / E-cores)            │
│   └─ Audio · Input · TH/EN text                           ├─ Display link (60/120 Hz)           │
│        ▲ read-only snapshots (double buffer)              └─ Steamworks (later)                 │
│        │                          │ commands                                                    │
│        │                          ▼                                                             │
│        │      ┌───────────── COMMAND GATEWAY (B4) ◄──── AIDE TOOL API ◄── LLM PROVIDER (B6)     │
│        │      │ schema → authority → law-of-war flags →   (query_state, forecast,   cloud /     │
│        │      │ feasibility → Command Log → C2 route &      propose/issue_orders,   local /     │
│        │      │ delay (16) → queue at effective tick        ▲ delegate_task)        template)   │
│        │      └──────────────┬───────────────────           │ KnowledgeView (fog of war)        │
│        │                     ▼                              │                                   │
│  SIMULATION CORE (B1) — deterministic, runs headless ───────┘                                   │
│   Strategic ◄► Regional ◄► Local ◄► Tactical   (multi-rate ticks, int64 time, int64 positions) │
│   Faction / Commander / Unit / Civilian / Convoy AI · Economy · Population · Logistics · C2    │
│        ▲ Sim Chunks + Feature Registry                   │ Save chunks (B5) · Command log      │
│        │                                                 ▼                                      │
│  WORLD DATA (versioned) ◄── OSM OFFLINE PIPELINE (B3, outside the game)   ~/Library/App Support │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### B1. Simulation Core ที่ผลลัพธ์กำหนดได้ แยกจากการวาดภาพ

**การตัดสินใจ:** ระบบจำลองทั้งหมดอยู่ในชั้นเดียวชื่อ Simulation Core ซึ่ง **ไม่เรียก API การวาดภาพ เสียง หรือ UI เลย** และรันแบบไม่มีหน้าจอ (Headless) ได้ เพื่อใช้ทดสอบอัตโนมัติ เล่นซ้ำ และพยากรณ์ (`forecast`)

กติกา

| ข้อ | กติกา | เหตุผล |
|---|---|---|
| 1 | Presentation อ่านสถานะจาก **Snapshot แบบอ่านอย่างเดียว** ที่ระบบจำลองเผยแพร่ทุก Tick (เก็บสองชุดสลับกัน) และประมาณค่าระหว่าง Tick ให้ภาพลื่น | แยกอัตราเฟรมออกจากอัตรา Tick (106.2) |
| 2 | **ทุกการเปลี่ยนสถานะโลกต้องผ่าน Command Gateway (B4)** ไม่มีทางลัดจาก UI หรือ LLM | ความยุติธรรมของผู้ช่วย (29.3) และการเล่นซ้ำ |
| 3 | เวลาในเกมเป็น **int64** หน่วยมิลลิวินาทีนับจากเริ่มแคมเปญ ห้ามใช้ float เก็บเวลา | float32 ที่ 30 วันมีความละเอียดเพียง 0.25 วินาที และที่ 1 ปีเหลือ 2 วินาที |
| 4 | Tick หลายอัตรา ก้าวคงที่เป็นมิลลิวินาทีเต็ม: ยุทธวิธี 20 Hz = 50 ms (สำรอง 10 Hz = 100 ms) / ท้องถิ่น 2 Hz = 500 ms / ภูมิภาค 60,000 ms (1 นาทีในเกม) / โลก 3,600,000 ms (1 ชั่วโมงในเกม) แต่ละชั้นซ้อนกันพอดี (ก้าวท้องถิ่นหนึ่งก้าว = 10 ก้าวยุทธวิธี หรือ 5 ก้าวเมื่อใช้ 10 Hz) ถ้าเครื่องไม่ทัน ความเร็วเกมลดลงแทนการขยายก้าว | ค่าตั้งต้นจาก 106.2 และตรงกับ [02 System Map](../gdd/round-01/02-system-map.md) หัวข้อ 6 |
| 5 | การสุ่มใช้ RNG ที่มี Seed แยกสายตามระบบและ Entity ห้ามใช้ RNG ส่วนกลางที่ลำดับการเรียกขึ้นกับเธรด | Determinism |
| 6 | ห้ามอ่านนาฬิกาจริง, ห้ามวนลูปตามลำดับของ Hash Map, งานคู่ขนานต้องเขียนผลลงช่องของตนเอง และรวมผล (Reduction) ตามลำดับ Entity ID | ลำดับงานของเธรดไม่คงที่ |
| 7 | ค่าที่เก็บถาวร (ตำแหน่ง ทรัพยากร จำนวนคน) เป็นจำนวนเต็มหรือ Fixed-point; ใช้ float ได้ในการคำนวณระหว่างทาง แล้วปัดเป็นจำนวนเต็มก่อนเขียนกลับ | ทำให้ Hash ของสถานะเทียบกันได้ |
| 8 | ทุก N Tick คำนวณ **State Hash** และเก็บคู่กับ Command Log เพื่อทดสอบ Determinism | Spike 3 และ CI |
| 9 | งานภายนอก (LLM, I/O, Streaming) ส่งผลกลับเป็น Command หรือ Event ที่มีหมายเลข Tick เท่านั้น | ผลที่มาไม่ตรงเวลาต้องไม่ทำให้ผลจำลองต่างกัน |

เครื่องเดียวและ Build เดียวช่วยให้ทำ Determinism ได้ง่ายกว่าเกมข้ามแพลตฟอร์ม แต่ยังต้องระวังการเปลี่ยนเวอร์ชันคอมไพเลอร์ ซึ่งอาจทำให้ Save และ Replay เก่าให้ผลต่างออกไป จึงกำหนดว่า Replay ผูกกับเวอร์ชันเกม ส่วน Save ต้องโหลดข้ามเวอร์ชันได้ (B5)

#### B2. ระบบพิกัด เส้นโครงแผนที่ และ Floating Origin

**B2.1 ตรวจตัวเลข float32 ในหัวข้อ 105.2 ใหม่**

float32 มี Mantissa 24 บิต ช่วงห่างระหว่างค่าที่เก็บได้ (ULP) ที่ค่า x คือ 2^(floor(log2 x) − 23) ส่วนความคลาดเคลื่อนสูงสุดจากการปัดเศษหนึ่งครั้งคือครึ่ง ULP (คำนวณด้วย `numpy.spacing`)

| ระยะจากจุดกำเนิด | ULP ของ float32 | คลาดเคลื่อนสูงสุดจากการปัด | ULP ของ float64 |
|---|---|---|---|
| 1 กม. | 0.061 มม. | 0.031 มม. | ≈1×10⁻¹³ ม. |
| 10 กม. | 0.98 มม. | 0.49 มม. | ≈2×10⁻¹² ม. |
| 100 กม. | 7.8 มม. | 3.9 มม. | ≈1.5×10⁻¹¹ ม. |
| 500 กม. | 3.1 ซม. | 1.6 ซม. | ≈6×10⁻¹¹ ม. |
| **1,000 กม.** | **6.25 ซม.** | **3.1 ซม.** | ≈1.2×10⁻¹⁰ ม. |
| 5,000 กม. | 50 ซม. | 25 ซม. | ≈9×10⁻¹⁰ ม. |
| 10,000 กม. | 1 ม. | 0.5 ม. | ≈1.9×10⁻⁹ ม. |
| **20,000 กม.** (ใกล้ขอบ Web Mercator ±20,037.5 กม.) | **2 ม.** | **1 ม.** | ≈3.7×10⁻⁹ ม. |

**ข้อแก้ไข:** สเปกเขียนว่า "ประมาณ 6 ซม. ที่ 1,000 กม." (ซึ่งเป็นค่า ULP) และ "ประมาณ 1 ม. ที่ 20,000 กม." (ซึ่งเป็นค่าคลาดเคลื่อนสูงสุด ไม่ใช่ ULP) ให้แก้เป็น **"ULP 6.25 ซม. ที่ 1,000 กม. และ 2 ม. ที่ 20,000 กม. (คลาดเคลื่อนสูงสุดจากการปัด 3.1 ซม. และ 1 ม. ตามลำดับ)"** ข้อสรุปของสเปกยังถูกต้อง และในทางปฏิบัติภาพสั่นมากกว่าตัวเลขในตาราง เพราะการคูณ Matrix หลายชั้นสะสมความคลาดเคลื่อนหลาย ULP และการลบตำแหน่งขนาดใหญ่สองค่าบน GPU ทำให้เสียความแม่นยำมาก

**ความละเอียดที่ต้องการจริง** (Web Mercator, Tile 256 px, จอ Retina 2×)

| ระดับซูม | เมตรต่อพิกเซลจริงของจอ ที่เส้นศูนย์สูตร | ที่ละติจูด 14° | ที่ละติจูด 50° |
|---|---|---|---|
| Z14 | 4.78 ม. | 4.64 ม. | 3.07 ม. |
| Z17 | 0.60 ม. | 0.58 ม. | 0.38 ม. |
| Z19 | 0.149 ม. | 0.145 ม. | 0.096 ม. |
| Z21 (ขอบเผื่อสำหรับทดสอบความแม่นยำใน Spike 2 เท่านั้น ไม่ใช่ระดับซูมของเกม) | 0.037 ม. | 0.036 ม. | 0.024 ม. |

ระดับซูมใกล้สุดของเกมคือ **Z19** ตามตาราง 105.3 (ป้ายความเสียหายรายชิ้นส่วนอยู่ในช่วง Z17–19) ที่ Z19 หนึ่งพิกเซลของจอประมาณ 15 ซม. และที่ขอบเผื่อ Z21 เล็กกว่า 4 ซม. ดังนั้นถ้าใช้ float32 แบบมีจุดกำเนิดคงที่ ภาพจะสั่นหลายพิกเซลตั้งแต่ระยะไม่กี่ร้อยกิโลเมตรจากจุดกำเนิด ข้อสรุปคือ **ห้ามมีตำแหน่งขนาดใหญ่ในรูป float32 ที่ใดเลย** การทดสอบถึง Z21 ใน Spike 2 มีไว้เผื่อความแม่นยำ 2 ระดับซูม ถ้าผู้ออกแบบต้องการเปิด Z20–21 ในเกมภายหลัง ระบบพิกัดจะไม่ต้องเปลี่ยน

**B2.2 พื้นที่พิกัด (Coordinate Spaces) ที่กำหนด**

| พื้นที่พิกัด | ใช้ทำอะไร | ชนิดข้อมูล | หน่วย | เจ้าของ |
|---|---|---|---|---|
| **GeoRef** (WGS84 ละติจูด/ลองจิจูด) | นำเข้า OSM และ DEM, ระยะทางระดับยุทธศาสตร์ (Geodesic), การส่งต่อระหว่าง Theater | float64 | องศา | OSM Pipeline, ระบบจำลองระดับยุทธศาสตร์ |
| **SimFrame** (Transverse Mercator ต่อ Theater) | ตำแหน่งทุกอย่างในระบบจำลองระดับยุทธวิธี ท้องถิ่น และภูมิภาค, ระยะยิง, ความเร็ว, แนวสายตา | **int64 Fixed-point, 1 หน่วย = 1 มม.** | มม. บนพื้นผิวจริง | Simulation Core |
| **SimCell** | แบ่งพื้นที่สำหรับ Simulation LOD, Streaming และ Chunk ของ Save | int32 คู่ (cx, cy) บนกริด 1 × 1 กม. ใน SimFrame (ค่าตั้งต้น) | — | Simulation Core, Save |
| **RenderFrame** (Web Mercator EPSG:3857) | Map Tiles, ตำแหน่งกล้อง, ระดับซูมต่อเนื่อง Z0–Z19 (Spike 2 ทดสอบเผื่อถึง Z21) | float64 บน CPU | เมตร Mercator | Presentation |
| **Tile-local** | Vertex ของแต่ละ Tile | จำนวนเต็มที่ Quantize แล้ว แปลงเป็น float32 บน GPU | 1/extent ของ Tile | Presentation |
| **Camera-relative** | ทุกตำแหน่งที่ส่งเข้า GPU | float32 | เมตร Mercator นับจากจุดศูนย์กลางกล้อง | Presentation |

**Theater** คือพื้นที่จำลองหนึ่งชุด เช่น ประเทศใน Scenario แบบ National Fracture (หัวข้อ 4) ช่วง Prototype ถึง Vertical Slice มี Theater เดียวตามคำตอบ Q3 ส่วน Full Vision มีหลาย Theater และระดับยุทธศาสตร์เชื่อมระหว่างกัน

**B2.3 แบบจำลองระยะทาง (ตอบหัวข้อ 105.2 ข้อ 3)**

- **ระบบจำลอง** ใช้ SimFrame ซึ่งเป็นเส้นโครง Transverse Mercator ที่มีเส้นเมริเดียนกลางผ่านกลาง Theater ระยะทางแบบ Euclidean ในกรอบนี้ใกล้เคียงระยะจริงบนพื้นผิวโลก ความคลาดเคลื่อนของมาตราส่วนประมาณ x²/(2R²) เมื่อ x คือระยะจากเส้นเมริเดียนกลาง

| ระยะจากเส้นเมริเดียนกลาง | ความคลาดเคลื่อนของมาตราส่วนโดยประมาณ |
|---|---|
| 100 กม. | 0.012% |
| 200 กม. | 0.05% |
| 400 กม. | 0.20% |
| 500 กม. | 0.31% |
| 800 กม. | 0.79% |

  ความคลาดเคลื่อนไม่เกิน 0.2% ในรัศมี 400 กม. ถือว่ายอมรับได้ตามหลัก "Authentic, not Exhaustive" (100) ถ้า Theater กว้างกว่านั้นมาก ให้แบ่งเป็นหลาย Theater **ค่านี้เป็นเกณฑ์เดียวที่ใช้ทุกไฟล์** (Spike 2 ในหัวข้อ 9.2, [04 Roadmap S2](../gdd/round-01/04-phased-roadmap.md) และกติกาพิกัดใน [03 R-01](../gdd/round-01/03-design-rulings-sec114.md)) ถ้าต้องการ 0.1% ต้องจำกัดครึ่งความกว้างของ Theater ไว้ประมาณ 285 กม.

- **ระยะไกลระดับยุทธศาสตร์** เช่น พิสัยอากาศยาน ขีปนาวุธ และวงโคจร (PART 14, 21) ใช้ระยะ Geodesic บนทรงรี WGS84 แบบ float64 ที่เขียนให้ผลกำหนดได้
- **Web Mercator ใช้เฉพาะการแสดงผล** ซึ่งรักษารูปทรงในพื้นที่เล็ก (Conformal) แต่ขยายขนาดด้วยตัวคูณ sec(ละติจูด) เช่น 1.03 ที่ละติจูด 14° และ 1.56 ที่ละติจูด 50° การวาดหน่วยต้องแปลงผ่านเส้นโครงเดียวกับอาคาร ขนาดจึงสัมพันธ์กันเอง
- **การแปลง SimFrame → RenderFrame:** หน่วยที่อยู่ในจอเมื่อซูมตั้งแต่ Z15 ขึ้นไปแปลงแบบแม่นยำ (Inverse TM → WGS84 → Mercator ด้วย float64) ซึ่งที่ซูมใกล้มีหน่วยในจอไม่มาก ส่วนเมื่อซูมไกลอนุญาตให้ใช้การแปลงแบบ Affine ต่อ Tile ถ้าความคลาดเคลื่อนต่ำกว่า 0.25 พิกเซลของจอ (Spike 2 ตรวจ)
- **ทางเลือกที่ Spike 2 ต้องเทียบ:** ให้ระบบจำลองใช้พิกัด Web Mercator แบบจำนวนเต็มโดยตรง และคูณ cos(ละติจูด) ทุกครั้งที่คำนวณระยะหรือความเร็ว ข้อดีคือไม่ต้องแปลงพิกัดตอนวาด ข้อเสียคือโค้ดเกมทุกจุดต้องจำไว้ว่าต้องแก้มาตราส่วน ซึ่งเกิดบั๊กได้ง่าย ADR นี้เลือก SimFrame แบบ TM เป็นค่าเริ่มต้นเพราะโปรแกรมเมอร์เกมทำงานกับ "เมตรจริง" ได้ตรง ๆ

**B2.4 Floating Origin และการวาดภาพแบบอ้างอิงกล้อง**

- กล้องเก็บจุดศูนย์กลางเป็น float64 ใน RenderFrame และระดับซูมเป็น float64 แบบต่อเนื่อง
- ทุกเฟรมคำนวณ `(จุดกำเนิดของ Tile − จุดศูนย์กลางกล้อง)` และ `(ตำแหน่งหน่วย − จุดศูนย์กลางกล้อง)` ด้วย float64 บน CPU แล้วจึงแปลงเป็น float32 ส่งเข้า GPU ทำให้ค่าที่ GPU เห็นมีขนาดเล็กเสมอ
- ถ้า Engine บังคับให้มีตำแหน่งในโลก (World Position) แบบ float32 ให้ใช้วิธีย้ายจุดกำเนิด (Rebase) เมื่อกล้องเคลื่อนเกินระยะที่กำหนด (ค่าตั้งต้น 1 กม.) Spike 2 จะเลือกระหว่างวิธีอ้างอิงกล้องทุกเฟรมกับวิธี Rebase
- **ข้อกำหนดของ Tile:** ความละเอียดของพิกัดภายใน Tile ต้องไม่หยาบกว่า **5 ซม. บนพื้น** ที่ระดับข้อมูลละเอียดที่สุด ตัวอย่างที่ผ่านเกณฑ์คือ Tile Z14 ที่มี extent 65,536 (≈3.7 ซม. ที่เส้นศูนย์สูตร) หรือ Tile Z16 ที่มี extent 16,384 (≈3.7 ซม.) ส่วน extent 4,096 แบบ MVT มาตรฐานที่ Z14 ให้ความละเอียดเพียง ≈60 ซม. ซึ่งไม่พอ

#### B3. OSM Offline Pipeline ที่สร้าง Tile แบบไบนารีที่มีเวอร์ชัน

**การตัดสินใจ:** ข้อมูลแผนที่ทั้งหมดถูกประมวลผล **นอกเกม** ด้วยเครื่องมือที่แยกจากตัวเกม (ภาษา Python หรือ Rust ร่วมกับ osmium และ GDAL ตามสเปก 107.1) ตัวเกมโหลดเฉพาะผลลัพธ์ที่มีเวอร์ชันเท่านั้น และไม่แปลง OSM ระหว่างเล่น

```text
 OSM PBF extract (Q3 area) ──┐
 DEM (e.g. Copernicus GLO-30) ┤
 Manual overrides / fixes ────┤
                              ▼
 [1] Clip & filter (osmium)          → only needed tags, Theater boundary
 [2] Normalize & tag mapping (§84)   → building function, capacity, strength,
                                        strategic value, protected sites
 [3] Heuristic fill (§85)            → missing height/levels/population
                                        every value tagged: REAL | ESTIMATED | GENERATED
 [4] Graph build                     → road / rail / river / power / comms networks
 [5] Project                         → SimFrame (TM per Theater) + RenderFrame (Web Mercator)
 [6] Bake                            → precomputed visibility per tile (§102), combat-cell seeds,
                                        terrain shading from DEM
                              ▼
 OUTPUTS (all stamped with mapdata_version = hash(inputs + pipeline version))
  ├─ Render Tiles   : Web Mercator, baked Z0–Z16, over-zoomed to Z19, quantized tile-local, large archives
  ├─ Sim Chunks     : SimFrame int coords: road graph, footprints, gameplay attributes, nav data
  ├─ Feature Registry: stable FeatureId ↔ OSM (type, id, part) + remap table between versions
  └─ Provenance & Attribution manifest: data sources, licences, REAL/ESTIMATED/GENERATED counts
```

กติกา

| ข้อ | กติกา | เหตุผล |
|---|---|---|
| 1 | Pipeline ต้อง **ทำซ้ำได้** คืออินพุตเดิมได้ผลลัพธ์เดิมทุกไบต์ | ตรวจสอบได้ และ Save อ้างอิงเวอร์ชันแผนที่ได้แน่นอน |
| 2 | แยก **Render Tiles** (สำหรับวาดภาพ) ออกจาก **Sim Chunks** (สำหรับระบบจำลอง) แต่ใช้ FeatureId ชุดเดียวกัน | ระบบจำลองไม่ต้องพึ่งเส้นโครงของการแสดงผล |
| 3 | รูปแบบ Render Tiles เลือกตาม Engine: ทางเลือก B ใช้ Vector Tiles มาตรฐานที่ MapLibre อ่านได้ (ต้องปรับ extent ให้ผ่านเกณฑ์ 5 ซม.) ส่วน A, D, F ใช้รูปแบบไบนารีของเกม (Header + ตาราง Layer + พิกัดจำนวนเต็มแบบ delta/varint + บีบอัด) ADR-0004 จะสรุปหลัง Spike 1 | ใช้จุดแข็งของแต่ละ Engine |
| 4 | **รวม Tile เป็นไฟล์ Archive ขนาดใหญ่ต่อภูมิภาค** แทนไฟล์เล็กจำนวนหลายแสนไฟล์ | git และ Git LFS ทำงานช้ามากกับไฟล์เล็กจำนวนมาก |
| 5 | ทุก Feature มีธงที่มาของข้อมูล REAL / ESTIMATED / GENERATED | สเปก 85 ให้แยกข้อมูลจริง ข้อมูลประมาณ และข้อมูลที่เกมสร้าง |
| 6 | ข้อมูลทหารใช้เฉพาะแผนที่สาธารณะ เนื้อหาภายในฐานเป็นข้อมูลที่เกมสร้าง และไม่มีรหัสลับจริงหรือข้อมูลทางทหารที่ไม่เปิดเผยต่อสาธารณะในข้อมูลใด ๆ ของเกม | สเปก 84 และ 101 |
| 7 | แสดง "© OpenStreetMap contributors" บนแผนที่ตลอดเวลา **และ** ลิงก์หรือข้อความระบุว่าข้อมูลอยู่ภายใต้ Open Database License (เช่น openstreetmap.org/copyright) ในหน้า About/Credits ที่เปิดได้จากแผนที่ ([OSM copyright](https://www.openstreetmap.org/copyright), [OSMF Attribution Guidelines](https://osmfoundation.org/wiki/Licence/Attribution_Guidelines)) และแสดงที่มาของ DEM ในหน้า Credits | ODbL (85) และใบอนุญาต DEM |
| 8 | Tile ที่แจกไปพร้อมเกมน่าจะนับเป็น Derivative Database ตาม ODbL ซึ่งมีเงื่อนไข Share-Alike — **ต้องตรวจสอบกับผู้รู้ด้านกฎหมาย** ก่อนแจกจ่ายต่อสาธารณะ | สเปก 85 |
| 9 | Copernicus DEM GLO-30 ใช้ได้ฟรีภายใต้ใบอนุญาตของโครงการ และต้องแสดงข้อความระบุที่มา ถ้าดัดแปลงข้อมูลต้องใช้ข้อความแบบ "produced using Copernicus WorldDEM-30 ..." นอกจากนี้เมื่อเกมแจกข้อมูลที่ได้จาก DEM (เช่น เงาภูมิประเทศ หรือผล Bake แนวสายตา) ต้อง (ก) ใส่ประโยค "The organisations in charge of the Copernicus programme by law or by delegation do not incur any liability for any use of the Copernicus WorldDEM-30" ใน EULA หรือหน้า Credits (ข้อ 6(c)) (ข) ไม่ใช้ถ้อยคำที่ทำให้เข้าใจว่า Copernicus หรือ ESA รับรองเกม (ข้อ 6(d)) (ค) ส่งต่อข้อผูกพันเหล่านี้ไปยังผู้เล่นและผู้ทำ Mod ในใบอนุญาตของเกม (ข้อ 6(e)) ทั้งหมดบันทึกใน Attribution Manifest ([License PDF](https://documentation.dataspace.copernicus.eu/APIs/SentinelHub/Data/DEM/resources/license/License-COPDEM-30.pdf)) | สเปก 107.4 ให้ตรวจเงื่อนไข |

ภาษาของ Pipeline: ถ้าทีมใช้ Rust อยู่แล้ว (ทางเลือก B หรือ C) ให้เขียนด้วย Rust เพื่อใช้โค้ดแปลงพิกัดชุดเดียวกับระบบจำลอง กรณีอื่นใช้ Python ซึ่งมีไลบรารีภูมิศาสตร์ครบกว่าและเขียนเร็วกว่า

#### B4. Command API เส้นทางเดียว และ Tool API ของผู้ช่วยนายพล

**การตัดสินใจ:** ผู้เล่น (ผ่าน UI), ผู้ช่วยนายพล (ผ่าน Tool API), กฎอัตโนมัติใน Policy Dashboard และ Faction AI ทุกฝ่าย **ส่งคำสั่งผ่าน Command Gateway เดียวกัน** และอ่านข้อมูลผ่าน **KnowledgeView** ของฝ่ายตนเอง ซึ่งผ่าน Fog of War และความคลาดเคลื่อนของข่าวกรองแล้ว ไม่มีผู้ใดอ่านสถานะจริงของโลกได้นอกจาก Simulation Core

โครงสร้างข้อมูลของคำสั่ง (ระดับแนวคิด)

| ฟิลด์ | ความหมาย |
|---|---|
| `command_id` | รหัสไม่ซ้ำ ใช้ยกเลิกคำสั่งและอ้างอิงใน Action Log |
| `issuer` | PLAYER / AIDE(ระดับอำนาจ 0–3) / POLICY_RULE(rule_id) / FACTION_AI(faction_id) / REPLAY |
| `faction_id` | ฝ่ายที่ออกคำสั่ง |
| `targets` | Entity ID ถาวรของหน่วย ฐาน อาคาร หรือนโยบายที่ถูกสั่ง |
| `verb` + `params` | ชนิดคำสั่งและพารามิเตอร์ที่ตรวจสอบตาม Schema |
| `issued_at_tick` | Tick ที่ออกคำสั่ง |
| `comms_route` | เส้นทางสื่อสารที่โมดูล 16 C2 คำนวณให้หลังคำสั่งผ่านการตรวจ ซึ่งกำหนดความหน่วงและโอกาสถูกรบกวนหรือดักฟัง (PART 11) |
| `effective_tick` | Tick ที่คำสั่งมีผลจริงหลังรวมความหน่วงแล้ว (16 C2 เป็นผู้กำหนด) |
| `reason` | เหตุผลแบบข้อความ บังคับสำหรับคำสั่งจากผู้ช่วย ใช้แสดงใน Action Log (29.2) |
| `status` | QUEUED / IN_TRANSIT / EXECUTED / REJECTED(เหตุผล) / CANCELLED |

ขั้นตอนตรวจสอบใน Gateway (ลำดับเดียวกับ [02 System Map](../gdd/round-01/02-system-map.md) หัวข้อ 2.5): **Schema → สิทธิ์และระดับอำนาจ → ROE และธงด้านกฎการสงคราม (รวมการอนุมัติตามบันไดยกระดับการยิง) → ต้นทุนและความเป็นไปได้ (ทรัพยากร ระยะ เส้นทาง) → บันทึก Command Log / Action Log → ส่งให้ 16 C2 คำนวณเส้นทาง ความหน่วง และการรบกวน → เข้าคิวที่ Tick ที่มีผล** Gateway เป็นผู้ตรวจ ส่วนความหน่วงเป็นของ 16 C2 ตามการแบ่งเจ้าของข้อมูลใน 02 การตรวจกฎการสงครามมาก่อนต้นทุน เพื่อให้คำสั่งที่ถูกธงถูกคัดค้านก่อนเสียเวลาคำนวณส่วนอื่น คำสั่งยกเลิกได้ถ้ายังไม่มีผล (29.2) แต่คำสั่งยกเลิกต้องเดินทางตามความหน่วงของการสื่อสารเช่นกัน

ธงด้านกฎการสงคราม (สเปก 101): ผู้เล่นออกคำสั่งที่ละเมิดได้และต้องรับผลเชิงระบบ แต่ **ผู้ช่วยนายพลจะไม่ส่งคำสั่งที่ถูกธงนี้เอง** ระบบจะคืนผลเป็นการคัดค้านหรือปฏิเสธตามบุคลิกที่กำหนด การตรวจนี้ทำโดยกฎของเกม ไม่ได้พึ่งให้ LLM ตัดสินเอง

**การผูก Tool API (หัวข้อ 30.2) เข้ากับ Command/Query API**

| Tool ของผู้ช่วย | เรียกส่วนใดของเกม | ข้อกำหนด |
|---|---|---|
| `query_state` | KnowledgeView ของฝ่ายผู้เล่น | อ่านอย่างเดียว ผ่าน Fog of War แล้ว จำกัดขนาดผลลัพธ์ |
| `get_reports` | คลังรายงาน SITREP, SPOTREP, LOGSTAT | ได้เฉพาะรายงานที่ฝ่ายผู้เล่นได้รับจริง |
| `forecast` | **Forecast Sandbox**: คัดลอก Snapshot ของ KnowledgeView แล้วจำลองต่อแบบความละเอียดต่ำบนเธรดพื้นหลัง | ไม่แก้โลกจริง จำกัดเวลา คืนผลเป็นช่วงความไม่แน่นอน ใช้สิ่งที่ฝ่ายผู้เล่นรู้เท่านั้นจึงไม่โกง |
| `propose_orders` | สร้าง CommandDraft ที่ยังไม่ส่ง | แสดงเป็นการ์ดแผนพร้อมปุ่ม อนุมัติ / แก้ไข / ปฏิเสธ (30.1) |
| `issue_orders` | Command Gateway โดย `issuer = AIDE(level)` | ระดับอำนาจ 2–3 มีความหน่วงและต้นทุนเหมือนคำสั่งผู้เล่น (29.3) คำสั่งที่ถูกธงกฎการสงครามถูกปฏิเสธเสมอเมื่อผู้ออกคือผู้ช่วย |
| `delegate_task` | Command Gateway → ภารกิจมอบหมายแบบมีโครงสร้างให้ Commander AI แบบ Deterministic (โมดูล 03) | ระดับอำนาจ 3 เท่านั้น ภายในสัญญามอบอำนาจ ([03 R-14](../gdd/round-01/03-design-rulings-sec114.md)) Commander AI ปฏิบัติทุก Tick จึงทำงานได้แม้ไม่มี LLM ข้อเสนอเพิ่มจากรายการตัวอย่างใน 30.2 รายละเอียดอยู่ในภาคผนวก L |
| `set_policy` / `create_rule` | Command Gateway ไปยังระบบนโยบายของ Dashboard | กฎที่ผู้ช่วยสร้างต้องแสดงให้ผู้เล่นเห็นและปิดได้ |

ทุกผลลัพธ์จาก LLM ต้องเป็น **Structured Output ตาม JSON Schema** ถ้าไม่ผ่าน Schema ให้ลองใหม่หนึ่งครั้ง แล้วจึงตกไปใช้โหมด Template (B6)

#### B5. รูปแบบ Save: แบ่ง Chunk, Entity ID ถาวร, Schema มีเวอร์ชัน

| หัวข้อ | การตัดสินใจ |
|---|---|
| ที่เก็บไฟล์ | `~/Library/Application Support/AFTERFALL/Saves/` **ไม่เก็บในโฟลเดอร์ Repository** เพราะ `git pull` หรือการอัปเดตแบบ reset อาจชนหรือลบไฟล์ |
| โครงสร้าง | Save หนึ่งชุดเป็นโฟลเดอร์แบบ Package ประกอบด้วย `manifest` (เวอร์ชัน Schema, เวอร์ชันเกม, `mapdata_version`, Seed, Tick, Checksum), `global/` (กลุ่มอำนาจ, บุคคลและ Social Graph, ORBAT, เศรษฐกิจรวม, นโยบาย, ความจำย่อของผู้ช่วย), `chunks/<theater>/<cx>_<cy>` และ `commandlog/` (เปิดได้เพื่อดีบักและ Replay) |
| สิ่งที่ Chunk เก็บ | เก็บเฉพาะ **ส่วนที่ต่างจากข้อมูลแผนที่ฐาน** เช่น Damage Map รายอาคาร เจ้าของพื้นที่ สิ่งที่สร้าง ซากที่ปิดถนน UXO หน่วยและประชากรในพื้นที่ (87) ข้อมูล OSM ที่ไม่เปลี่ยนไม่ถูกเขียนซ้ำ |
| Entity ID | **u64 ที่ไม่นำกลับมาใช้ซ้ำ** ออกโดยตัวนับของโลก และมีตารางแปลงเป็น Handle ของ ECS ขณะรัน ซึ่งเปลี่ยนได้ทุกครั้งที่โหลด |
| Feature ID ของแผนที่ | อ้างอิง Feature Registry ของ `mapdata_version` ที่ Save สร้างขึ้น ถ้าอัปเดตข้อมูลแผนที่ต้องมี Remap Table |
| การเข้ารหัส | ไบนารีที่มี Schema (ตัวเลือก: FlatBuffers, Cap'n Proto หรือรูปแบบของเกมเอง เลือกใน ADR-0004) บีบอัดราย Chunk และมี Checksum ราย Chunk |
| ความปลอดภัยของไฟล์ | เขียนไฟล์ชั่วคราวแล้วเปลี่ยนชื่อแบบ Atomic, เก็บ Autosave หมุนเวียนหลายชุด, ถ่าย Snapshot แบบ Copy-on-write แล้วเขียนบนเธรดพื้นหลังเพื่อไม่ให้เฟรมกระตุก |
| Schema | ทุกชนิดเรคคอร์ดมีเวอร์ชัน และมีฟังก์ชันย้ายเวอร์ชัน (Migration) จาก vN ไป vN+1 แบบต่อกันเป็นสาย ห้ามลบฟิลด์ ให้ประกาศเลิกใช้แทน และเก็บ Save ตัวอย่างของทุกเวอร์ชันไว้ทดสอบอัตโนมัติ |
| Mod | ข้อมูลแบบ Data-driven อ้างอิงด้วย ID แบบข้อความ เช่น `equip.ifv.bmp2` แล้วแปลงเป็นตัวเลขตอนโหลด Save เก็บตารางข้อความนี้ไว้ด้วย |
| เป้าหมายตั้งต้น | Autosave ไม่ทำให้เฟรมยาวเกิน 2 มิลลิวินาที และเขียนเสร็จภายใน 5 วินาทีสำหรับขนาด MVP (ต้องวัด) |

#### B6. Abstraction ของผู้ให้บริการ LLM

**การตัดสินใจ:** ผู้ช่วยนายพลคุยกับ LLM ผ่าน Interface กลางเพียงชุดเดียว (เรียกในเอกสารนี้ว่า `AideBrain`) ที่รายงานความสามารถของตัวเอง (Structured Output, Tool Calling, ภาษาไทย/อังกฤษ, ความยาวบริบท, ใช้งานออฟไลน์ได้หรือไม่) ตัวเกมไม่รู้ว่าข้างหลังเป็นผู้ให้บริการใด ตามสเปก 107.3

| ผู้ให้บริการ | รายละเอียด | ใช้งานออฟไลน์ | สถานะ |
|---|---|---|---|
| **Cloud** | เรียกผ่าน HTTPS เก็บ API Key ใน Keychain ของ macOS ส่งเฉพาะข้อมูลเกมที่สรุปแล้ว ไม่ส่งข้อมูลส่วนบุคคล มีเพดานค่าใช้จ่าย | ไม่ได้ | ตัวเลือกคุณภาพสูงสุด |
| **Local: llama.cpp server** | โปรเซสลูกที่เกมเปิดและปิดเอง ผูกกับ Loopback เท่านั้น รองรับ Apple Silicon ผ่าน Metal, API แบบเดียวกับ OpenAI, JSON Schema และ Function Calling ([llama.cpp](https://github.com/ggml-org/llama.cpp), [server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)); มี Binary สำหรับ macOS arm64 ([Releases](https://github.com/ggml-org/llama.cpp/releases)) | ได้ | ตัวเลือกหลักของโหมดบนเครื่อง |
| **Local: MLX (`mlx_lm.server`)** | API คล้าย OpenAI แต่เอกสารของโครงการเองระบุว่า **ไม่แนะนำสำหรับ Production** ([SERVER.md](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md)) | ได้ | ใช้ทดลองช่วงพัฒนาเท่านั้น |
| **Local: Apple Foundation Models** | โมเดลบนเครื่องของ Apple เรียกผ่าน Swift API รองรับ Guided Generation และ Tool Calling บน macOS 26 ขึ้นไป ทำงานบนโมเดลของ Apple Intelligence จึงใช้ได้เฉพาะเมื่อผู้เล่นเปิด Apple Intelligence ด้วยภาษาที่รองรับ ([Apple](https://developer.apple.com/foundation-models-framework/), [Developer Forums](https://developer.apple.com/forums/thread/805378)) ไม่ต้องแจกไฟล์โมเดลเอง | ได้ | **ไม่รองรับภาษาไทย** (Apple Intelligence ณ ก.ย. 2026 รองรับ 15 ภาษา ไม่มีภาษาไทย [Apple 121115](https://support.apple.com/en-us/121115)) ใช้ได้เฉพาะโหมดภาษาอังกฤษ จึงไม่ใช่ทางเลี่ยงการแจกไฟล์โมเดลสำหรับผู้ช่วยภาษาไทย |
| **Template (ไม่ใช้ LLM)** | สร้างข้อความจากข้อมูลระบบจำลองด้วยแม่แบบภาษาไทยและอังกฤษ ผลกำหนดได้ | ได้ | **มีเสมอ** (30.3, 107.3) และเป็นทางสำรองเมื่อผู้ให้บริการอื่นล้มเหลว |

กติกาที่ใช้กับทุกผู้ให้บริการ

1. LLM ได้รับเฉพาะข้อมูลจาก KnowledgeView ไม่เคยเห็นสถานะจริงของโลก
2. LLM ทำหน้าที่เรียบเรียงภาษาและเลือก Tool ส่วนตัวเลขและการพยากรณ์ทั้งหมดมาจากระบบจำลอง (107.3)
3. ผลลัพธ์ต้องผ่าน Schema ก่อนถึง Command Gateway และ Gateway ตรวจซ้ำอีกชั้น
4. บุคลิกผู้ช่วยเป็นตัวละครในโลกเกม ไม่ใช้ใบหน้า เสียง หรือตัวตนของบุคคลจริง (101) ภาพหน้าเป็น 2D ที่ทีมสร้างหรือมีสิทธิ์ใช้ (30.3)
5. การตัดสินใจว่าต้องใช้งานออฟไลน์แบบมี LLM หรือไม่รอคำตอบ **Q2** ถ้าต้องการ LLM ภาษาไทยบนเครื่อง ต้องส่งไฟล์โมเดล GGUF ขนาดประมาณ 2–5 GB แยกจากตัวเกมและเป็นทางเลือก ฉบับ Steam ใช้ Depot แยกหรือดาวน์โหลดตอนเปิดใช้ครั้งแรก ส่วน Build ทดสอบที่ยังแจกผ่าน git ต้องใช้ Git LFS ซึ่งกระทบโควตา (หัวข้อ 10.3) วิธีส่งตัดสินใน ADR-0002 (Apple Foundation Models ไม่ใช่ทางเลี่ยง เพราะไม่รองรับภาษาไทย)

#### B7. นโยบายการวาดภาพ (ไม่ขึ้นกับ Engine)

| หัวข้อ | การตัดสินใจ | เหตุผล |
|---|---|---|
| ความละเอียด | วาดที่ความละเอียดจริงของจอ **ไม่ใช้ Upscaling** กับชั้นแผนที่และเส้นนีออน | 105.1: การ Upscale ทำให้เส้นบางเบลอ |
| Anti-aliasing | MSAA 4× สำหรับขอบ Polygon และวาดเส้นแบบ Analytic/SDF (ความกว้างจริงเป็นพิกเซล คำนวณความโปร่งจากระยะถึงขอบ) | MSAA อย่างเดียวไม่ช่วยเส้นที่สร้างใน Shader |
| Apple GPU | ใช้ Memoryless Render Target เมื่อทำได้ ([Unity Metal](https://docs.unity3d.com/Manual/metal-optimize.html)); หมายเหตุ: โหมด Tile-Only ของ URP ระบุว่าควรเลี่ยง MSAA ([URP On-tile](https://docs.unity.com/en-us/engine/6000.6/manual/analysis/graphics-performance-profiling/in-urp/on-tile-rendering)) จึงต้องวัดใน Spike 1 ว่า MSAA บนเส้นทางนี้แพงเท่าใด | ลดแบนด์วิดท์หน่วยความจำ |
| Bloom / Glow | ปรับความแรงได้ และมีโหมดลดแสง (97) | การเข้าถึงได้ |
| ระดับซูม | แบ่งช่วงตามตาราง 105.3 การเปลี่ยนรูปแบบ (Counter → ไอคอน → ภาพมุมบน) ใช้ Cross-fade และ Hysteresis เพื่อไม่ให้กระพริบเมื่อซูมไปมา | Spike 4 |
| หน่วยและยานพาหนะ | Instancing เสมอ ยานพาหนะใกล้มากเป็นโมเดลโพลีกอนต่ำวาดด้วยกล้องมุมบน (105.3) | หมุนตัวรถและป้อมปืนได้ |
| สี | สีทั้งหมดอ่านจากไฟล์ Color Token ตาม PART 25 โหมดบอดสีและ APP-6 คือการสลับไฟล์ Token | เปลี่ยนชุดสีได้โดยไม่แก้ Shader |
| ภายในอาคาร | Floor Plan Overlay แบบ 2D บนอาคาร ไม่มีโมเดลภายใน 3D | 0.6 |

#### B8. Platform Layer ของ macOS

| บริการ | การใช้งาน |
|---|---|
| Thermal State | ฟัง `thermalStateDidChangeNotification` และอ่าน `ProcessInfo.thermalState` (Nominal / Fair / Serious / Critical) ([Apple](https://developer.apple.com/documentation/xcode/responding-to-power-notifications)) เมื่อเป็น Serious ให้ลดเอฟเฟกต์ เพดานเฟรม และหยุด LLM บนเครื่อง |
| Memory Pressure | เมื่อระบบแจ้งแรงกดดันหน่วยความจำ ให้ปลด Cache ของ Tile ปิด LLM บนเครื่อง และลดคุณภาพ Texture |
| QoS ของเธรด | macOS ไม่เปิดให้ผูกเธรดกับคอร์โดยตรง แต่ใช้ระดับ QoS เลือกว่าจะรันบน P-core หรือ E-core ([Eclectic Light](https://eclecticlight.co/2024/12/17/tune-for-performance-core-types/)) งานเฟรมและระบบจำลองใช้ QoS สูง งาน Streaming การบันทึก และ I/O ของ LLM ใช้ QoS ระดับ Utility หรือ Background |
| Display | รองรับ ProMotion 60/120 Hz ค่าเริ่มต้น 60 fps และมีตัวเลือก 120 fps (106.2) |
| Keychain | เก็บ API Key ของ LLM บนคลาวด์ (ดูผลต่อการเซ็นโค้ดในหัวข้อ 10.5) |
| App Sandbox | **ไม่ใช้** เพราะ Steam ระบุว่าไม่รองรับ Entitlement นี้ ([Steamworks](https://partner.steamgames.com/doc/store/application/platforms)) |
| GPU Working Set | อ่าน `recommendedMaxWorkingSetSize` ของ Metal บนเครื่องจริงเพื่อตั้งเพดานหน่วยความจำ GPU ([Apple](https://developer.apple.com/documentation/metal/mtldevice/recommendedmaxworkingsetsize)) ค่าบนเครื่อง 24 GB **ต้องตรวจสอบ** |

### 5.2 ส่วนที่ 2: Engine (ขึ้นกับ Q1)

ตามตาราง 4.5 ค่าเริ่มต้นคือ **ทางเลือก A: Unity 6 LTS + Entities/Burst + Map Tiles ที่สร้างเอง** เมื่อทีมถนัด C#, ยังไม่มีทีม หรือยังไม่ได้รับคำตอบ ถ้าคำตอบ Q1 เป็น TypeScript/Rust ให้เปลี่ยนเป็นทางเลือก B และถ้าเป็น Swift ให้ทำ Bake-off ระหว่าง D กับ A

### 5.3 ถ้าเลือก Unity (ทางเลือก A): รายละเอียดที่ล็อก

| หัวข้อ | การตัดสินใจ | เหตุผล |
|---|---|---|
| เวอร์ชันสำหรับ Spike | **Unity 6.3 LTS (6000.3)** | LTS ล่าสุด ซัพพอร์ตถึง ธ.ค. 2027 ([Unity](https://unity.com/releases/unity-6)) |
| เวอร์ชันสำหรับ Production | ย้ายไป **Unity 6.7 LTS** เมื่อออก แล้วทำ Spike 3 ซ้ำ | ใน 6.3 Entities ยังเป็นแพ็กเกจแยก ส่วนตั้งแต่ 6.4 Entities, Collections, Mathematics และ Entities Graphics เป็น Core Package ที่ล็อกเวอร์ชันกับ Editor ([ECS ธ.ค. 2025](https://discussions.unity.com/t/ecs-development-status-december-2025/1699284/1), [ECS 6.6](https://discussions.unity.com/t/ecs-development-status-for-unity-6-6/1724480)) |
| รุ่น Update (เช่น 6.6) | ใช้ทดลองได้ ไม่ใช้กับ Production | ซัพพอร์ตเพียงจนถึงรุ่นถัดไป |
| กติกาเพื่อรองรับการย้ายเวอร์ชัน | ไม่ใช้ Managed Component (ประกาศเลิกใช้แล้ว), ไม่ใช้ InstanceID (เกิด Obsolete Error ตั้งแต่ 6.5), ไม่พึ่ง Entities Journaling (ประกาศเลิกใช้ใน 6.5), แยกโค้ดระบบจำลองให้พึ่ง API ของ Unity น้อยที่สุด | ลดงานตอนย้ายไป 6.7 LTS, CoreCLR ใน 6.8 และ 7000.x |
| Scripting Backend | IL2CPP สำหรับ Build ที่แจกจ่าย และ Mono ใน Editor | 6.7 LTS เป็นรุ่นสุดท้ายที่ใช้ Mono ([มี.ค. 2026](https://discussions.unity.com/t/coreclr-scripting-and-ecs-status-update-march-2026/1711852)); IL2CPP ไม่ต้องใช้ JIT ใน Hardened Runtime (Entitlement ที่ Mono ต้องใช้ ต้องตรวจสอบกับเอกสาร Unity) |
| Determinism | โค้ดระบบจำลองที่คอมไพล์ด้วย Burst ใช้ `FloatMode.Deterministic` ([Unity Burst](https://docs.unity3d.com/Manual/burst/float-precision-determinism.html)) | โหมดนี้รองรับเฉพาะ 64 บิตและครอบคลุมเฉพาะโค้ด Burst จึงยังต้องใช้กติกา B1 |
| โครงสร้าง World | แยก ECS World ของระบบจำลองออกจาก World ของการแสดงผล ระบบจำลองเขียน Snapshot และฝั่งแสดงผลอ่านอย่างเดียว | B1 |
| การวาดภาพ | URP + กล้อง Orthographic มุมบน + Shader นีออนที่เขียนเอง + MSAA บน Metal | 107.1, B7 |
| Map Tiles | ระบบ Streaming ของเกมเองที่สร้าง Mesh ต่อ Tile จาก Render Tiles และวางแบบอ้างอิงกล้อง (B2.4) | 107.1 |
| UI | UI Toolkit + Advanced Text Generator สำหรับภาษาไทย (ต้องผ่านการตรวจ E1 ในหัวข้อ 9.4) | 107.1, 97 |
| Build | เป้าหมาย Apple silicon เท่านั้น | Unity แนะนำ Apple silicon และเลิกรองรับ Intel ใน Standalone Player ([Unity](https://docs.unity.com/en-us/engine/6000.7/manual/platform-specific/apple-mac/macos-delivery/macosbuildsettings)) |
| Steam | Steamworks.NET (ตรวจว่าไลบรารี macOS มีสถาปัตยกรรม arm64 ด้วย `lipo -info` — ต้องตรวจสอบ) | 107.1 |

### 5.4 ถ้าเลือก Web Map Stack (ทางเลือก B): รายละเอียดที่ล็อก

| หัวข้อ | การตัดสินใจ |
|---|---|
| โครงสร้าง | Rust Simulation Core รันในโปรเซสหลักของแอป Tauri บนเธรดของตัวเอง หน้าเว็บมีเฉพาะการแสดงผลและ UI |
| การส่งข้อมูล | ส่ง Snapshot แบบไบนารีต่อ Tick (ไม่ใช้ JSON) เฉพาะ Entity ที่อยู่ในกรอบกล้องและระดับซูมปัจจุบัน ประมาณค่าระหว่าง Tick ฝั่งหน้าเว็บ ความเร็วของช่องทางไบนารีใน Tauri ต้องตรวจสอบใน Spike 3–4 |
| แผนที่ | MapLibre GL JS สำหรับชั้นแผนที่ deck.gl สำหรับหน่วยจำนวนมากและเอฟเฟกต์ |
| กราฟิก | WebGL2 เป็นฐาน และทดสอบ WebGPU ถ้า WKWebView เปิดให้ใช้บน macOS 26+ (ต้องตรวจสอบ) |
| การวัดผล | Safari Web Inspector + Instruments ทั้งโปรเซสแอปและโปรเซสของ WebKit |
| การเซ็นโค้ด | ใช้ระบบเซ็นและ Notarize ใน Bundler ของ Tauri ([Tauri](https://v2.tauri.app/distribute/sign/macos/)) |

### 5.5 สิ่งที่ ADR นี้เปลี่ยนหรือเพิ่มจากสเปก

| ข้อ | สเปกเดิม | ADR นี้ | เหตุผล |
|---|---|---|---|
| 1 | float32 คลาดเคลื่อน "≈6 ซม. ที่ 1,000 กม. และ ≈1 ม. ที่ 20,000 กม." (105.2) | ULP 6.25 ซม. และ 2 ม. (คลาดเคลื่อนสูงสุด 3.1 ซม. และ 1 ม.) | สเปกใช้ตัวเลขคนละความหมายในสองจุด |
| 2 | "ตำแหน่ง 64 บิตหรือพิกัดภายใน Tile" (107.1) | ระบุชัด: SimFrame int64 หน่วยมิลลิเมตร + Tile-local สำหรับการวาด + Camera-relative บน GPU | ต้องมีคำตอบเดียวที่ทุกระบบใช้ร่วมกัน |
| 3 | ไม่ได้ระบุชนิดข้อมูลของเวลา | เวลาในเกมเป็น int64 มิลลิวินาที | float32 ไม่พอสำหรับแคมเปญยาว |
| 4 | Unity 6 LTS "ล่าสุดที่ยืนยันได้คือ 6.3 LTS" (107.1) | ยังถูกต้อง ณ 2026-10-22 และเพิ่มแผนย้ายไป 6.7 LTS | ECS เป็น Core Package และ Runtime กำลังเปลี่ยนเป็น CoreCLR |
| 5 | Map Tiles ชุดเดียว | แยก Render Tiles กับ Sim Chunks ที่ใช้ FeatureId เดียวกัน | ระบบจำลองไม่ต้องพึ่งเส้นโครงของการแสดงผล |
| 6 | llama.cpp หรือ MLX (107.1) | llama.cpp server เป็นตัวหลักของโหมดบนเครื่อง ส่วน MLX ใช้ช่วงพัฒนา Apple Foundation Models ใช้ได้เฉพาะโหมดภาษาอังกฤษ | เอกสาร MLX server ไม่แนะนำสำหรับ Production และ Apple Intelligence ยังไม่รองรับภาษาไทย |
| 7 | งบหน่วยความจำแบบเดียว (106.1) | เพิ่มงบช่วงพัฒนา เพิ่มแถว Render Target และ Engine Overhead แล้ว **ลดขอบบนของ 3 บรรทัดเดิม (ระบบจำลอง Tile ภาพและเสียง) ลงบรรทัดละ 0.25 GB** ให้ผลรวมขอบบนของบรรทัดย่อยไม่เกิน 8 GB, ปรับขนาด LLM ตามบริบทจริง (เล็ก ≈3–4 GB, กลาง ≈5.5–6.5 GB) และเพิ่มกติกาการรัน LLM บนเครื่อง | งบเดิมรวมได้ 21–24 GB เมื่อมี LLM ซึ่งชนเพดานพอดี และเมื่อเพิ่มสองบรรทัดใหม่ ผลรวมขอบบนของตัวเกมจะเป็น 8.5 GB ซึ่งเกินเพดานของตัวเอง |
| 8 | ไม่มีปัจจัยเรื่องภาษาไทย | เพิ่มเป็นส่วนหนึ่งของ D5 และเพิ่มการตรวจ E1 | เกมมีโหมดภาษาไทยเป็นหลัก (89, 97) |
| 9 | กล่าวถึงเฉพาะการจำหน่ายผ่าน Steam (104) | ถือ `git clone` เป็นช่องทางเดียวตามคำสั่งผู้ออกแบบ และเก็บทางไป Steam ไว้รอผู้ออกแบบยืนยัน | ผู้ออกแบบสั่งให้โหลดผ่าน git เท่านั้น จึงต้องรู้ผลต่อ LFS และลายเซ็นโค้ด |
| 10 | เกณฑ์ผ่านของ Spike เป็นข้อความกว้าง (108.3) | กำหนดเป็นตัวเลขที่วัดได้ เพิ่มการตรวจ E1–E5 และให้หัวข้อ 9.2 เป็น **แหล่งเดียวของเกณฑ์ผ่าน Spike** ที่ไฟล์ 03 และ 04 อ้างถึง | ให้ตัดสินได้ชัดเจนว่าผ่านหรือไม่ และไม่มีเกณฑ์สองชุดสำหรับการวัดเดียวกัน |
| 11 | ไม่ได้ระบุที่เก็บ Save | เก็บใน Application Support นอก Repository | ป้องกันการชนกับ `git pull` |
| 12 | ช่วงซูม Z0–19 (105.3, Spike 1 ใน 108.3) | คงระดับซูมของเกมไว้ที่ Z0–Z19 อบ Render Tiles ถึง Z16 แล้วขยายต่อ (Over-zoom) ถึง Z19 และให้ Spike 2 ทดสอบความแม่นยำเผื่อถึง Z21 | Z16 ที่ extent 16,384 ละเอียดพอตามเกณฑ์ 5 ซม. (B2.4) จึงไม่ต้องอบ Z17–19 และการทดสอบเผื่อ 2 ระดับทำให้เปิด Z20–21 ได้ภายหลังถ้าผู้ออกแบบต้องการ โดยไม่ต้องเปลี่ยนระบบพิกัด |
| 13 | ไม่ได้ระบุลำดับการตรวจคำสั่ง | Schema → สิทธิ์ → ROE/กฎการสงคราม → ต้นทุน → Log → 16 C2 คิดความหน่วง และเพิ่ม Tool `delegate_task` สำหรับระดับอำนาจ 3 (B4) | ใช้ลำดับและการแบ่งเจ้าของเดียวกับ 02 System Map |
| 14 | Tick ยุทธวิธี 10–20 ครั้งต่อวินาที (106.2) | 20 Hz = 50 ms (สำรอง 10 Hz) และก้าวทุกชั้นเป็นมิลลิวินาทีเต็มที่ซ้อนกันพอดี (B1) | เวลาในเกมเป็น int64 มิลลิวินาที จึงต้องเลือกก้าวที่เป็นมิลลิวินาทีเต็ม |

---

## 6. งบหน่วยความจำบน 24 GB (ขยายจากหัวข้อ 106.1)

### 6.1 ขณะเล่นจริง (Runtime)

| ส่วน | สเปกเดิม | งบตาม ADR นี้ | หมายเหตุ |
|---|---|---|---|
| macOS และโปรแกรมเบื้องหลัง | 5–6 GB | 5–6 GB | วัดจริงโดยปิดแอปอื่น |
| **ตัวเกมทั้งหมด** | ≤8 GB | **≤8 GB (เป้าหมายใช้งานปกติ 7 GB)** | ผลรวมขอบบนของบรรทัดย่อยด้านล่าง = 7.75 GB จึงไม่เกินเพดานแม้ทุกบรรทัดอยู่ที่ขอบบนพร้อมกัน |
| — ระบบจำลอง | 1.5–2.5 GB | 1.5–2.25 GB | รวม Sim Chunks ที่โหลด, Social Graph Tier A/B/C, Command Log ในหน่วยความจำ |
| — Map Tiles ที่โหลดอยู่ | 1–2 GB | 1–1.75 GB | Cache แบบ LRU ปลดได้เมื่อมีแรงกดดันหน่วยความจำ |
| — ภาพหน่วย เอฟเฟกต์ เสียง UI | 1.5–2.5 GB | 1.5–2.25 GB | รวมฟอนต์ไทยและอังกฤษ |
| — Render Target และ GPU Buffer | (ไม่ได้แยก) | 0.2–0.5 GB | ประมาณ: 5.9 ล้านพิกเซล × MSAA 4× × 12 ไบต์ต่อ Sample ≈ 0.29 GB (14") และ ≈ 0.37 GB (16") ถ้าใช้ Memoryless ได้จะลดลงมาก |
| — Engine / Runtime Overhead | (ไม่ได้แยก) | 0.5–1 GB | โค้ด, Heap ของ Runtime, Driver |
| LLM บนเครื่อง (ถ้าใช้) | 4–6 GB | **ขนาดเล็ก (3–4B, 4-bit, บริบท 8k, โมเดลแบบ GQA): ≈3–4 GB** / ขนาดกลาง (7–8B, 4-bit): ≈5.5 GB ที่บริบท 4k หรือ ≈6–6.5 GB ที่บริบท 8k | ประมาณจากขนาด Q4_K_M จริงบวก KV Cache แบบ fp16 (2 × จำนวนชั้น × KV heads × head_dim × 2 ไบต์ ต่อ Token) และ Compute Buffer ประมาณ 0.3 GB เช่น 3B ≈2.0 GB + 0.9 GB ที่ 8k ≈3 GB, 4B ≈2.5 GB + 1.1 GB ≈3.7–4 GB, 8B ≈4.9–5.0 GB + 1.0–1.1 GB ≈6–6.5 GB ([Qwen3-8B GGUF](https://huggingface.co/bartowski/Qwen_Qwen3-8B-GGUF), [Qwen3-4B config](https://huggingface.co/Qwen/Qwen3-4B/blob/main/config.json), [Llama-3.1-8B GGUF](https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF), [Llama-3.2-3B GGUF](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF)) โมเดลที่ไม่ใช้ GQA (เช่น 32 KV heads) ใช้ KV Cache มากกว่าหลายเท่า จึงไม่ใช้กับงบนี้ (ต้องวัด) |
| เผื่อไว้ | ≈4 GB | **ไม่น้อยกว่า 4 GB เสมอ** | ถ้าต่ำกว่านี้ macOS จะเริ่มบีบอัดหน่วยความจำและ Swap ซึ่งทำให้เฟรมกระตุก |

ผลรวมกรณีเลวร้ายที่สุด

| กรณี | macOS | เกม | LLM | รวม | เหลือ |
|---|---|---|---|---|---|
| ไม่ใช้ LLM บนเครื่อง | 6 | 8 | 0 | 14 GB | 10 GB |
| LLM ขนาดเล็ก (4B, บริบท 8k) | 6 | 8 | 4 | 18 GB | 6 GB |
| LLM ขนาดกลาง (8B, บริบท 4k หรือ KV Cache แบบ q8_0) | 6 | 8 | 5.5 | 19.5 GB | 4.5 GB |
| LLM ขนาดกลาง (8B, บริบท 8k) | 6 | 8 | 6.5 | 20.5 GB | **3.5 GB (ต่ำกว่าเพดานเผื่อ)** |
| LLM ขนาดกลาง (8B, บริบท 8k) เมื่อเกม ≤7 GB | 6 | 7 | 6.5 | 19.5 GB | 4.5 GB |

ข้อสรุป: **LLM ขนาดกลางใช้บริบท 4k (หรือ KV Cache แบบ q8_0) เป็นค่าเริ่มต้น** ถ้าจะใช้บริบท 8k ต้องให้เกมใช้หน่วยความจำไม่เกิน 7 GB และระบบอยู่ในสถานะแรงกดดันหน่วยความจำปกติ (กติกา 6.3 ข้อ 3)

### 6.2 ระหว่างพัฒนา (เปิด Editor)

งบนี้ตั้งให้ **ขอบบนรวมไม่เกิน 20 GB** เพื่อเหลือเผื่ออย่างน้อย 4 GB ตามกติกาเดียวกับ 6.1 ร่างแรกของ ADR นี้มีขอบบน 24–24.5 GB ซึ่งเกินหน่วยความจำจริงและไม่เหลือเผื่อ จึงลดตามรายการด้านล่าง

| ส่วน | Unity (ทางเลือก A) | Web Stack (ทางเลือก B) | หมายเหตุ |
|---|---|---|---|
| macOS และโปรแกรมเบื้องหลัง | 5–6 GB | 5–6 GB | |
| Editor ของ Engine (เปิดโปรเจกต์ ไม่ได้รันเกม) | 3–5 GB | — | ต้องวัด |
| เกมขณะรันใน Editor / Dev Build | 2–3 GB | 2–3.5 GB (Rust + WebKit) | ฉากทดสอบ 2 × 2 กม. เท่านั้น (กติกาข้อ 3) งบ 8 GB เต็มวัดจาก Build นอก Editor |
| IDE + Language Server | 1.5–3 GB | 2–4 GB (รวม rust-analyzer) | |
| การคอมไพล์ | รวมใน Editor | 0–4 GB ชั่วคราวขณะ `cargo build` | |
| เบราว์เซอร์ เอกสาร แชท | 1–2 GB | 1–2 GB | |
| เครื่องมือวัดผล (Instruments, Memory Profiler, Web Inspector) | 0 GB ขณะทำงานปกติ | 0 GB ขณะทำงานปกติ | เปิดเฉพาะตอนวัด และตอนวัดให้ปิด Editor แล้ววัดจาก Build (กติกาข้อ 2) จึงใช้งบ 6.1 + เครื่องมือวัด 0.5–2 GB แทน |
| LLM | 0 GB (คลาวด์หรือ Template) | 0 GB (คลาวด์หรือ Template) | โมเดลเล็กมาก (≤1.5B, ≤1.5 GB) ใช้ได้เฉพาะเมื่อปิดโปรแกรมอื่นจนผลรวมยังไม่เกิน 20 GB |
| **รวม (ขอบบน)** | **≤19 GB** | **≤19.5 GB** (ขณะคอมไพล์) | ไม่เกิน 20 GB |
| **เผื่อไว้** | **≥5 GB** | **≥4.5 GB** | ไม่น้อยกว่า 4 GB เสมอ |

กติกาช่วงพัฒนา

1. **ห้ามรัน LLM บนเครื่องขนาด 3B ขึ้นไปขณะเปิด Editor** ใช้คลาวด์หรือโหมด Template (สเปก 106.1 แนะนำไว้แล้ว) โมเดลเล็กมากใช้ได้เฉพาะเมื่อผลรวมยังเหลือเผื่อ ≥4 GB
2. วัดหน่วยความจำและประสิทธิภาพจาก **Build ที่รันนอก Editor** เท่านั้น ตัวเลขใน Editor ใช้ดูแนวโน้มเท่านั้น
3. ฉากทดสอบใน Editor ใช้พื้นที่เล็ก (2 × 2 กม.) และเกมใน Editor ต้องไม่เกิน 3 GB ส่วนพื้นที่ 5 × 5 กม. ของ Spike 1 ทดสอบผ่าน Build
4. ปิด Memory Profiler และ Instruments เมื่อไม่ได้วัด

งบช่วงพัฒนาของ [03 R-18](../gdd/round-01/03-design-rulings-sec114.md) ใช้ตัวเลขชุดเดียวกับคอลัมน์ Unity ด้านบน

### 6.3 กติกาว่าเมื่อใด LLM บนเครื่องได้รับอนุญาตให้รัน

LLM บนเครื่องจะรันได้เมื่อ **ทุกเงื่อนไขเป็นจริง**

| ข้อ | เงื่อนไข | ค่าตั้งต้น |
|---|---|---|
| 1 | คำตอบ Q2 ต้องการ LLM บนเครื่อง และผู้เล่นเลือกผู้ให้บริการแบบบนเครื่องในการตั้งค่า | — |
| 2 | ไม่ได้รันอยู่ใน Editor ของ Engine (กรณีโมเดล 3B ขึ้นไป) | — |
| 3 | หน่วยความจำที่เหลือ ≥ ขนาดโมเดล + KV Cache + 4 GB และสถานะแรงกดดันหน่วยความจำเป็นปกติ | โมเดลขนาดกลางใช้บริบท 4k หรือ KV Cache แบบ q8_0 เป็นค่าเริ่มต้น บริบท 8k ได้เมื่อเกม ≤7 GB (6.1) |
| 4 | Thermal State เป็น Nominal หรือ Fair | — |
| 5 | เกมหยุดชั่วคราว หรือความเร็วเวลา ≤ 1× และเวลาเฟรม p95 ในช่วง 2 วินาทีล่าสุดไม่เกิน 80% ของงบเฟรม | 80% ของ 16.7 มิลลิวินาที |
| 6 | ใช้ไฟจากอะแดปเตอร์ หรือผู้เล่นอนุญาตให้รันขณะใช้แบตเตอรี่ | ค่าเริ่มต้น: ไม่รันขณะใช้แบตเตอรี่ |

ระหว่างรัน: จำกัดความเร็วการสร้าง Token, ใช้ QoS ต่ำกว่าเธรดเฟรม, **หยุดการสร้างทันที** ถ้าเฟรมช้ากว่างบ 3 เฟรมติดกันหรือ Thermal State เป็น Serious (และปลดโมเดลเมื่อ Serious ต่อเนื่อง), และปลดโมเดลออกจากหน่วยความจำเมื่อไม่ได้ใช้ 5 นาที ถ้าเงื่อนไขไม่ครบ ให้ใช้คลาวด์ (ถ้าออนไลน์และผู้เล่นอนุญาต) หรือโหมด Template

**หัวข้อนี้เป็นกติกาเดียวว่า LLM บนเครื่องรันได้เมื่อใด** [03 R-13, R-16](../gdd/round-01/03-design-rulings-sec114.md) และ [02 System Map หัวข้อ 7.4](../gdd/round-01/02-system-map.md) อ้างถึงกติกานี้ ไม่ตั้งกติกาแยก

---

## 7. งบเวลาต่อเฟรมและต่อ Tick (ค่าตั้งต้น)

| งาน | 60 fps (16.7 ms) | ตัวเลือก 120 fps (8.3 ms) | หมายเหตุ |
|---|---|---|---|
| Main Thread: Input, UI, รับ Snapshot, ส่งคำสั่ง | ≤4 ms | ≤2.5 ms | |
| Render CPU: Culling, Batching, Encode คำสั่ง Metal | ≤5 ms | ≤3 ms | |
| GPU: แผนที่ + หน่วย + เอฟเฟกต์ + Bloom + UI ที่ความละเอียดจริงพร้อม MSAA | ≤10 ms | ≤6.5 ms | โหมด 120 fps ลดเอฟเฟกต์ได้ |
| Tactical Tick 20 Hz (ทุก 50 ms) บน Worker Threads | ใช้เวลาคำนวณ ≤25 ms ต่อ Tick | เหมือนกัน | เหลือเวลาครึ่งหนึ่งไว้เร่งเวลา |
| Local Tick 2 Hz (ทุก 500 ms) | ≤5 ms ต่อ Tick บน Worker | เหมือนกัน | เฉพาะ LOCAL Bubble รอบพื้นที่ที่ผู้เล่นดู |
| Regional Tick (ก้าว 1 นาทีในเกม) | ≤10 ms เวลาจริงต่อ Tick สำหรับทั้ง Theater บน Worker หลายเธรด | เหมือนกัน | ที่ S6 (2,880×) ต้องรัน 48 Tick ต่อวินาทีจริง ≈ 0.48 วินาทีของ Worker ต่อวินาที จึงยังเหลือครึ่งหนึ่ง ที่ S5 (720×) 12 Tick ≈ 0.12 วินาที |
| Global Tick (ก้าว 1 ชั่วโมงในเกม) | ≤150 ms งานรวมต่อ Tick แบ่งเป็นชิ้นไม่เกิน 4 ms ต่อเฟรมบน Worker ห้ามทำให้เกิดเฟรมยาว | เหมือนกัน | ที่ S6 เกิด 0.8 Tick ต่อวินาทีจริง |
| Streaming, Save, ถอดรหัส Tile, I/O ของ LLM | QoS ระดับ Utility หรือ Background | เหมือนกัน | macOS มักจัดงาน QoS ต่ำลง E-core |

งบ Regional และ Global ใช้คู่กับขั้นความเร็ว S0–S6 ของ [03 R-07](../gdd/round-01/03-design-rulings-sec114.md) วัดในฉาก "ยุทธศาสตร์ความเร็ว S6" ของ R-16 และใน Spike 6 ถ้าเกินงบ Speed Governor ลดเพดานเป็น S5 (หรือต่ำกว่า) แทนการขยายก้าว Tick

จำนวนเธรดของระบบจำลองตั้งจากรุ่นที่อ่อนที่สุด (8 P-core): ใช้ Worker ของระบบจำลองที่ QoS สูงไม่เกิน 6 เธรด เหลือไว้ให้ Main Thread และ Render Thread (macOS ไม่ให้ผูกเธรดกับคอร์โดยตรง แต่จัดงาน QoS สูงลง P-core เป็นหลัก ตาม B8)

---

## 8. ผลที่ตามมา (Consequences)

### 8.1 ด้านบวก

- ขอบเขต B1–B8 ทำให้การเปลี่ยน Engine ภายหลังกระทบเฉพาะชั้น Presentation และ UI ส่วนระบบจำลอง Pipeline และ Save ยังใช้ต่อได้ (ถ้าเขียนด้วยภาษาที่ Engine ใหม่เรียกใช้ได้)
- ระบบจำลองที่กำหนดผลได้รองรับ Replay การทดสอบอัตโนมัติ การหาบั๊ก และ `forecast` ของผู้ช่วยโดยตรง
- ผู้ช่วยนายพลยุติธรรมโดยโครงสร้าง เพราะใช้ KnowledgeView และ Command Gateway เดียวกับผู้เล่น (29.3)
- ตำแหน่ง int64 และ Camera-relative Rendering แก้ปัญหาภาพสั่นได้ทั่วโลกโดยไม่ขึ้นกับ Engine
- Save แบบเก็บเฉพาะส่วนที่ต่างจากแผนที่ฐานทำให้ไฟล์เล็ก และรองรับโลกถาวรและ Mod

### 8.2 ด้านลบ

- งานสถาปัตยกรรมช่วงต้นมากขึ้นก่อนจะเห็นภาพแรก
- ต้องดูแลข้อมูลแผนที่สองชุด (Render Tiles และ Sim Chunks) และการแปลงพิกัดระหว่าง SimFrame กับ RenderFrame
- UI ทุกจุดต้องส่งคำสั่งผ่าน Gateway จึงไม่มีทางลัดสำหรับเครื่องมือดีบัก (ต้องทำเป็นคำสั่งพิเศษที่ปิดได้ใน Release)
- ถ้าเลือก Unity ต้องผ่านการย้ายเวอร์ชันใหญ่ (6.3 → 6.7 LTS → CoreCLR) ระหว่างพัฒนา

### 8.3 ความเสี่ยง

| รหัส | ความเสี่ยง | โอกาส | ผลกระทบ | วิธีลด | ตรวจด้วย |
|---|---|---|---|---|---|
| R1 | ระบบ Map Tiles ที่สร้างเองใช้เวลานานกว่าแผน (A, D, F) | สูง | สูง | กำหนดกรอบเวลาของ Spike 1 ถ้าไม่ผ่านให้พิจารณาทางเลือก B | Spike 1 |
| R2 | API ของ Unity ECS และ Runtime เปลี่ยนมาก | สูง | กลาง | กติกาในหัวข้อ 5.3 และแยกโค้ดระบบจำลองออกจาก API ของ Engine | Spike 3 ซ้ำบน 6.7 LTS |
| R3 | การแสดงผลภาษาไทยผิด (สระลอย วรรณยุกต์ซ้อน ตัดบรรทัดผิด) | กลาง | สูง | ตรวจ E1 ถ้า Engine ตัดคำไทยไม่ได้ ให้ Pipeline ตัดคำล่วงหน้าแล้วแทรก Zero-width Space ในข้อความแม่แบบ | E1 |
| R4 | Determinism เสียจากลำดับงานคู่ขนาน | กลาง | สูง | กติกา B1 และทดสอบ State Hash อัตโนมัติ | Spike 3, E4 |
| R5 | หน่วยความจำเกิน 24 GB ระหว่างพัฒนาแล้วเกิด Swap | กลาง | กลาง | กติกาในหัวข้อ 6.2 | วัดตลอด |
| R6 | ความร้อนทำให้ประสิทธิภาพตกเมื่อเล่นนาน | กลาง | สูง | ปรับคุณภาพตาม Thermal State และเพดานเฟรม | Spike 6 |
| R7 | LLM บนเครื่องภาษาไทยคุณภาพต่ำ | สูง | กลาง | LLM ทำเฉพาะการเรียบเรียง ตัวเลขมาจากระบบจำลอง และมี Template กับคลาวด์เป็นทางสำรอง | Spike 5 |
| R8 | การแจกจ่ายผ่าน git: โควตา LFS, ขนาด clone, ลายเซ็นเสีย | สูง | กลาง | หัวข้อ 10 และ ADR-0002 | E2 |
| R9 | เงื่อนไข Share-Alike ของ ODbL สำหรับ Tile ที่แจกจ่าย | กลาง | กลาง | ตรวจกับผู้รู้ด้านกฎหมาย ใส่ใบอนุญาตและที่มากับข้อมูล | ก่อนแจกจ่ายสาธารณะ |
| R10 | ข้อมูล OSM ในพื้นที่ Prototype ไม่ครบ | กลาง | กลาง | Heuristics + ธงที่มาของข้อมูล + ระบบให้ผู้เล่นรายงาน (85) | Spike 1 |
| R11 | Steamworks หรือ Steam Overlay บน arm64 มีปัญหา | กลาง | ต่ำ | ตรวจด้วย `lipo` และไม่ทำให้ Overlay เป็นข้อบังคับ | E3 |
| R12 | นโยบายราคาของ Unity เปลี่ยนอีก | ต่ำ–กลาง | กลาง | ขอบเขต B1–B8 ลดการผูกกับ Engine | — |
| R13 | ประสิทธิภาพของ WKWebView และ 120 Hz (เฉพาะทางเลือก B) | กลาง | กลาง | วัดก่อนตัดสิน | Spike 1, 6 บน B |

---

## 9. แผนพิสูจน์ (Validation Plan): Technical Spike

### 9.1 ระเบียบการวัดที่ใช้กับทุก Spike

| หัวข้อ | กติกา |
|---|---|
| เครื่อง | บันทึกรุ่น (14" หรือ 16"), จำนวนคอร์ CPU/GPU และ RAM จาก System Information |
| ระบบ | macOS 27.x (บันทึกเลขเวอร์ชัน) |
| ไฟ | วัดทั้งเสียบอะแดปเตอร์และใช้แบตเตอรี่, ปิด Low Power Mode, วัดหลักที่โหมดพลังงานอัตโนมัติ และวัดเสริมหนึ่งรอบที่ High Power Mode |
| จอ | ความละเอียดจริงของจอ (ไม่ใช้ Scaled) วัดทั้ง 60 Hz และ 120 Hz |
| Build | Build ที่รันนอก Editor แบบ Release หรือ Development ที่เปิด Profiler |
| สภาพแวดล้อม | ปิดแอปอื่นยกเว้นเครื่องมือวัด บันทึกอุณหภูมิห้องโดยประมาณ |
| การทำซ้ำ | วัดอย่างน้อย 3 รอบ รายงานค่า p50, p95, p99 |
| เครื่องมือ | Xcode Instruments (Time Profiler, Allocations, Metal System Trace) และ `xctrace` สำหรับบันทึกยาว; Metal Frame Capture ใน Xcode; Metal Performance HUD ผ่าน `MTL_HUD_ENABLED=1` ([Apple](https://developer.apple.com/documentation/xcode/gaining-performance-insights-with-metal-performance-hud)); Profiler ของ Engine (Unity Profiler และ Memory Profiler, Safari Web Inspector, Godot Profiler หรือ Tracy สำหรับ Rust); `powermetrics` (ต้องใช้ sudo) สำหรับพลังงาน CPU/GPU และแรงกดดันความร้อน; การบันทึก `ProcessInfo.thermalState`; `footprint`, `vmmap`, `memory_pressure` และ Activity Monitor สำหรับหน่วยความจำ |
| ผลลัพธ์ | บันทึกผลลงตารางในหัวข้อ 9.5 พร้อมไฟล์ Trace |

### 9.2 Spike ทั้ง 6 รายการ (จากหัวข้อ 108.3)

**หัวข้อนี้เป็นแหล่งเดียวของเกณฑ์ผ่าน Spike** [04 Roadmap ส่วนที่ 2.3](../gdd/round-01/04-phased-roadmap.md) และ [03 R-13, R-16, R-17](../gdd/round-01/03-design-rulings-sec114.md) อ้างถึงเกณฑ์ในหัวข้อนี้ ส่วนตัวเลขอื่นในไฟล์เหล่านั้นเป็น **เป้าหมายประสบการณ์ (UX Target) หรือประตูคุณภาพของระยะ** ซึ่งติดป้ายไว้ชัดเจน ถ้าจะเปลี่ยนเกณฑ์ ให้แก้ที่นี่ที่เดียว

#### Spike 1 — OSM เป็น Tile หลายระดับ แล้ววาดแบบนีออน

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | Pipeline (B3) แปลง OSM พื้นที่ 5 × 5 กม. เป็น Render Tiles ได้ และ Engine ที่เลือกวาดได้ลื่นตั้งแต่ Z8 ถึง Z19 ที่ความละเอียดจริงพร้อม MSAA 4× |
| การตั้งค่า | **พื้นที่ทดสอบขึ้นกับคำตอบ Q3** ควรมีย่านเมืองหนาแน่น แม่น้ำ สะพาน ทางรถไฟ และอาคารที่มีข้อมูลความสูง ถ้ายังไม่ได้คำตอบเมื่อเริ่ม Spike ให้ใช้ย่าน Vinohrady กรุงปราก (จากคลิปอ้างอิง Redline District) **เป็นพื้นที่ทดสอบทางเทคนิคเท่านั้น** ไม่ใช่ฉากของเกม และยังช่วยทดสอบละติจูด 50° ที่ Mercator ขยายขนาด 1.56 เท่า; ใช้ชุดสีจาก PART 25; กล้องซูมอัตโนมัติไปกลับ Z8 ↔ Z19 ด้วยความเร็วคงที่ 20 รอบ |
| วิธีวัด | Metal Performance HUD และ Metal System Trace สำหรับเวลาเฟรมและ GPU; Profiler ของ Engine สำหรับเวลาโหลด Tile; `footprint` สำหรับหน่วยความจำของ Tile; Metal Frame Capture ตรวจจำนวน Draw Call และต้นทุน MSAA; ภาพหน้าจอที่ Z12, Z16, Z19 สำหรับตรวจความคมของเส้น |
| เกณฑ์ผ่าน | เวลาเฟรม p99 ≤16.7 ms ระหว่างซูม และไม่มีเฟรมใดเกิน 33 ms; ไม่เห็นช่องว่างของ Tile นานเกิน 200 ms หลังข้ามระดับ; หน่วยความจำของ Tile สำหรับพื้นที่ 5 × 5 กม. ≤1 GB (งบ Tile รวมทั้งจังหวัดคือ 1–1.75 GB ตาม 6.1 จึงต้องเหลือที่ให้พื้นที่ที่ใหญ่กว่า); เส้นนีออนกว้าง 1 พิกเซลคมโดยไม่ Upscale และไม่กระพริบเมื่อเลื่อนกล้อง (ตรวจด้วยตาตาม Checklist); Pipeline ประมวลผลพื้นที่ 5 × 5 กม. เสร็จภายใน 10 นาทีและผลลัพธ์เหมือนเดิมทุกไบต์เมื่อรันซ้ำ |
| ยืนยันหรือล้ม | ผ่าน: ยืนยัน B3, B7 และการเลือก Engine ด้าน D2 / ไม่ผ่านบน A, D หรือ F: พิจารณาทางเลือก B หรือลดเอฟเฟกต์ / ไม่ผ่านเรื่อง MSAA: เปลี่ยนเป็นการวาดเส้นแบบ Analytic อย่างเดียว |
| กรอบเวลา (ตั้งต้น) | 2–3 สัปดาห์ |

#### Spike 2 — Floating Origin และพิกัด 64 บิต

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | การใช้ SimFrame แบบ int64 ร่วมกับการวาดแบบอ้างอิงกล้อง (B2) ทำให้ไม่มีภาพสั่นแม้อยู่ห่างจุดกำเนิดหลายร้อยถึงหลายพันกิโลเมตร |
| การตั้งค่า | จุดกำเนิดของ Theater อยู่กลางพื้นที่ทดสอบ วางหน่วยทดสอบที่ระยะ 0, 300, 800 กม. และที่ตำแหน่ง Mercator ใกล้ ±20,000 กม. (ใกล้เส้นแบ่งวันสากล) ซูมถึง Z19 (ระดับใกล้สุดของเกม) และทดสอบเผื่อถึง Z21 หน่วยเคลื่อนที่ 1 ม./วินาที รถหมุนป้อมปืน และกล้องติดตามหน่วย; เทียบวิธีอ้างอิงกล้องทุกเฟรมกับวิธี Rebase ทุก 1 กม. และเทียบกับทางเลือก "Mercator + cos(ละติจูด)" (B2.3) |
| วิธีวัด | อ่านตำแหน่งบนจอของจุดอ้างอิงคงที่ทุกเฟรมแล้วคำนวณการสั่น (ค่าเบี่ยงเบนสูงสุดเป็นพิกเซล); ตรวจการแปลงไปกลับ SimFrame → WGS84 → Mercator → SimFrame; **เทียบระยะทางใน SimFrame กับระยะ Geodesic บนทรงรี WGS84** ระหว่างคู่จุดที่ตำแหน่ง 0 และ 300 กม.; ตรวจ State Hash หลังจำลอง 1 ชั่วโมงในเกมที่ 20 Hz |
| เกณฑ์ผ่าน | การสั่นสูงสุด ≤0.25 พิกเซลจริงของจอที่ทุกตำแหน่งทดสอบจนถึง Z21; การแปลงไปกลับคลาดไม่เกิน 1 ซม.; ระยะทางใน SimFrame คลาดจากระยะ Geodesic ไม่เกิน 0.2% ภายในรัศมี 400 กม. จากเส้นเมริเดียนกลาง (ตำแหน่ง 800 กม. ใช้ยืนยันว่าต้องแบ่ง Theater ตาม B2.3 ไม่ใช่เกณฑ์ผ่าน); State Hash เหมือนกันทั้ง 3 รอบ; Affine ต่อ Tile ใช้ได้ในระดับซูมที่ความคลาดเคลื่อน < 0.25 พิกเซล |
| ยืนยันหรือล้ม | ผ่าน: ยืนยัน B2 / ไม่ผ่าน: เปลี่ยนวิธี Floating Origin หรือย้ายไปใช้ทางเลือก Mercator + cos(ละติจูด) และแก้ B2 |
| กรอบเวลา (ตั้งต้น) | 1 สัปดาห์ (ทำก่อน Spike 1 ได้) |

#### Spike 3 — ECS จำลองหน่วย 5,000–10,000 หน่วย พร้อมหาเส้นทางบนถนน OSM

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | Simulation Core ของ Engine ที่เลือกรันหน่วยละเอียด 5,000–10,000 หน่วยได้ที่ 20 Hz อย่างคงที่ ภายในงบหน่วยความจำ และกำหนดผลได้ |
| การตั้งค่า | ใช้ Road Graph จาก Sim Chunks ของ Spike 1 (หรือพื้นที่ใหญ่กว่า) หน่วยมีพฤติกรรมพื้นฐาน (เคลื่อนที่ตามคำสั่ง ตรวจจับ ยิงแบบง่าย) ใช้ Flow Field + Hierarchical Pathfinding (15.2) ส่งคำสั่งแบบสุ่มที่มี Seed ผ่าน Command Gateway; ทดสอบที่ 5,000 และ 10,000 หน่วย และที่ความเร็วเวลา 1×, 2×, 4× |
| วิธีวัด | Profiler ของ Engine สำหรับเวลาต่อ Tick และการกระจายงานบนเธรด; Instruments Time Profiler; `footprint` สำหรับหน่วยความจำ; State Hash ทุก 100 Tick |
| เกณฑ์ผ่าน | ที่ 20 Hz และ 10,000 หน่วย: เวลาคำนวณต่อ Tick p95 ≤25 ms และ p99 ≤40 ms (คาบ 50 ms) และ Tick ครบตามรอบอย่างน้อย 99%; หน่วยความจำของหน่วยละเอียดในระบบจำลอง ≤1 GB ที่ 10,000 หน่วย (เหลืองบส่วนที่เหลือของ 1.5–2.25 GB ให้ประชากร เศรษฐกิจ และ Social Graph); ภาพยัง 60 fps ระหว่างจำลอง; State Hash เหมือนกัน 100% ทุกรอบเมื่อใช้ Save และ Command Log เดียวกันบน Build เดียวกัน; เร่งเวลา 4× ได้ที่ 5,000 หน่วย |
| ยืนยันหรือล้ม | ผ่าน: ยืนยัน B1 และคะแนน D1 / ไม่ผ่าน: ลดเกณฑ์จำนวนหน่วยละเอียดผ่าน Simulation LOD (86), ใช้ Tick 10 Hz หรือย้ายระบบจำลองไปเป็นไลบรารี Native; ถ้าทำบน Unity 6.3 LTS ต้องทำซ้ำบน 6.7 LTS |
| กรอบเวลา (ตั้งต้น) | 2–3 สัปดาห์ |

#### Spike 4 — การแสดงผลตามระดับซูม: Counter → ไอคอน → ภาพมุมบน

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | การเปลี่ยนรูปแบบการแสดงหน่วยตามตาราง 105.3 ทำได้โดยไม่กระตุกและผู้เล่นไม่สับสน |
| การตั้งค่า | หน่วยจาก Spike 3 บนแผนที่จาก Spike 1 ใช้ Counter แบบ NATO (Z5–8), ไอคอนพร้อมป้ายเช่น "BMP-2 (8/10)" (Z9–12), ภาพมุมบนจากโมเดลโพลีกอนต่ำพร้อมป้ายความเสียหาย (Z17–19) ใช้ Cross-fade และ Hysteresis ใช้ภาษาสีและรูปทรงกรอบตาม PART 25 |
| วิธีวัด | เวลาเฟรมระหว่างซูมผ่านจุดเปลี่ยนรูปแบบไปกลับ 50 รอบ; ทดสอบกับผู้ทดสอบอย่างน้อย 5 คน 2 งาน: (ก) หลังซูมผ่านจุดเปลี่ยน ให้ชี้หน่วยเดิมที่ติดตามอยู่ (ข) สุ่มสิ่งบนแผนที่ แล้วให้บอกเจ้าของ สถานะ และความอันตราย |
| เกณฑ์ผ่าน | ไม่มีเฟรมเกิน 25 ms ระหว่างเปลี่ยนรูปแบบ; ไม่มีการกระพริบเมื่อหยุดซูมใกล้จุดเปลี่ยน; ตัวชี้วัด Pillar 9 "Readable at a Glance" สองตัวที่ใช้ทุกไฟล์: **(ก) หาหน่วยเดิมเจอหลังเปลี่ยนช่วงซูมภายใน 2 วินาที อย่างน้อย 90%** (ตรงกับ R-17) และ **(ข) อ่านเจ้าของ สถานะ และความอันตรายของสิ่งบนแผนที่ได้ภายใน 3 วินาที อย่างน้อย 90%** (ตรงกับ VP4 ในไฟล์ 01 และประตู 3.4 ในไฟล์ 04); ทั้งสองข้อต้องผ่านในชุดสีปกติ ชุด Signal-CB และภาพจำลองการมองเห็นแบบ Protan / Deutan / Tritan (การทดสอบดูภาพ 1.5 วินาทีของ R-10 และ R-11 เป็นการทดสอบการจำสีฝ่ายแยกต่างหาก) |
| ยืนยันหรือล้ม | ผ่าน: ยืนยัน B7 / ไม่ผ่าน: ปรับจุดเปลี่ยนและ Hysteresis หรือเพิ่มระดับกลาง |
| กรอบเวลา (ตั้งต้น) | 1–2 สัปดาห์ |

#### Spike 5 — ผู้ช่วย AI เรียก Tool API ทั้งแบบคลาวด์และบนเครื่อง

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | ผู้ช่วยอ่านสถานะและเสนอคำสั่งผ่าน Tool API (B4) ได้ภายในไม่กี่วินาทีทั้งแบบคลาวด์และบนเครื่อง โดย Frame Rate ไม่ตก |
| การตั้งค่า | เรียก `query_state`, `get_reports`, `forecast`, `propose_orders` ด้วยคำถามมาตรฐาน 20 ข้อ (ไทย 10 ข้อ อังกฤษ 10 ข้อ) เช่น "สรุปสถานการณ์" "ฐานไหนเสี่ยงที่สุด" "เสนอแผนป้องกัน" (30.1); ผู้ให้บริการ: คลาวด์ 1 ราย, llama.cpp server กับโมเดล 3–4B แบบ 4-bit, ถ้าหน่วยความจำพอทดสอบโมเดล 7–8B (บริบท 4k), และโหมด Template; Apple Foundation Models ทดสอบได้เฉพาะชุดคำถามภาษาอังกฤษ |
| วิธีวัด | เวลาถึง Token แรกและเวลาจนได้แผนครบ; อัตราผ่าน JSON Schema; Metal Performance HUD และ Instruments ระหว่างที่ LLM ทำงาน; `footprint` ของโปรเซส LLM; ผู้ตรวจภาษาไทยให้คะแนนความถูกต้องและความเป็นธรรมชาติ; ชุดคำถามที่คำตอบอยู่หลัง Fog of War; ชุดคำสั่งที่ผิด Schema ผิดสิทธิ์ และละเมิดกฎการสงคราม |
| เกณฑ์ผ่าน | คลาวด์: Token แรก ≤2 วินาที และแผนครบ ≤8 วินาที; บนเครื่องขณะหยุดเกม: แผนครบ ≤15 วินาที; ผลลัพธ์ผ่าน Schema หรือตกไปใช้ Template ได้ทุกครั้ง (ไม่มีกรณีค้าง); ขณะ LLM บนเครื่องทำงานที่ความเร็วเวลา 1× ตามกติกา 6.3 เวลาเฟรม p99 ≤16.7 ms; หน่วยความจำรวมอยู่ในงบหัวข้อ 6.1 และเหลือเผื่อ ≥4 GB; คำสั่งที่ผิด Schema หรือผิดสิทธิ์ถูกปฏิเสธ 100% พร้อมเหตุผล ไม่มีคำสั่งใดเข้าระบบจำลองโดยไม่ผ่าน Gateway; ไม่เปิดเผยข้อมูลหลัง Fog of War ในชุดทดสอบ; ผู้ช่วยปฏิเสธคำสั่งที่ละเมิดกฎการสงครามได้ 100%; โหมด Template ตอบคำถามชุดเดียวกันได้ครบ (เป้าหมายเวลาตอบสั้นของ R-13 คือ Token แรก 1.5 / 2.5 วินาที และคำตอบสั้นครบ ≤6 วินาที เป็น UX Target ไม่ใช่เกณฑ์ผ่าน Spike) |
| ยืนยันหรือล้ม | ผ่าน: ยืนยัน B4, B6 และกติกา 6.3 / ไม่ผ่านบนเครื่อง: จำกัด LLM บนเครื่องให้ทำงานเฉพาะตอนหยุดเกม หรือใช้คลาวด์ร่วมกับ Template เท่านั้น (ADR-0003) |
| กรอบเวลา (ตั้งต้น) | 1–2 สัปดาห์ |

#### Spike 6 — เปิดเกมต่อเนื่อง 60 นาทีบน M4 Pro

| หัวข้อ | รายละเอียด |
|---|---|
| สมมติฐาน | Build ที่รวม Spike 1, 3 และ 4 รันต่อเนื่อง 60 นาทีได้โดยไม่ลดความเร็วเพราะความร้อนจนเล่นไม่ได้ |
| การตั้งค่า | ฉากการรบที่มีหน่วย 5,000 หน่วย กล้องเคลื่อนตามสคริปต์ผสมการซูม รัน 4 แบบ: อะแดปเตอร์ 60 Hz / อะแดปเตอร์ 120 Hz / แบตเตอรี่ 60 Hz / อะแดปเตอร์ 60 Hz ที่ High Power Mode และรอบเสริมที่รันพร้อม LLM บนเครื่องจาก Spike 5 ตามกติกา 6.3 (เกณฑ์ผ่านวัดจากรอบอะแดปเตอร์ 60 Hz ส่วนรอบอื่นเก็บเป็นข้อมูล) |
| วิธีวัด | `xctrace` บันทึกตลอด 60 นาที; `powermetrics` บันทึกพลังงาน CPU/GPU และแรงกดดันความร้อนทุก 5 วินาที; บันทึก `ProcessInfo.thermalState` ทุกครั้งที่เปลี่ยน; `footprint` ทุก 5 นาที; บันทึกเปอร์เซ็นต์แบตเตอรี่ที่ลดลงต่อชั่วโมง |
| เกณฑ์ผ่าน | **ชุดเกณฑ์เฟรมเดียวที่ใช้ทั้ง Spike 6 และประตูคุณภาพทุกระยะ** (ตัด 5 นาทีแรกเป็นช่วงอุ่นเครื่อง วัดที่โหมด 60 Hz): เวลาเฟรม p95 ≤16.7 ms และ p99 ≤20 ms; ค่าเฉลี่ยตลอดชั่วโมง ≥58 fps; fps เฉลี่ยของ 10 นาทีสุดท้าย ≥95% ของ 10 นาทีแรก; Thermal State ไม่เคยเป็น Critical และเป็น Serious ไม่เกิน 5% ของเวลา และไม่ต่อเนื่องเกิน 5 นาที; หน่วยความจำหลังนาทีที่ 10 เพิ่มขึ้นไม่เกิน 5% (ไม่มี Leak) และ Swap เพิ่มไม่เกิน 1 GB; Tick ยุทธวิธีตกหล่นไม่เกิน 1%; บันไดปรับคุณภาพอัตโนมัติทำงานเมื่อ Thermal State เปลี่ยน (เฉพาะส่วนการแสดงผลและเพดานความเร็ว ตาม R-16) |
| ยืนยันหรือล้ม | ผ่าน: ยืนยันงบในหัวข้อ 6–7 / ไม่ผ่าน: ตั้งค่าเริ่มต้นเป็นเพดาน 60 fps พร้อมคุณภาพที่ปรับตามความร้อน และลดงบ GPU ใหม่ |
| กรอบเวลา (ตั้งต้น) | 1 สัปดาห์ (ทำหลัง Spike 1, 3, 4) |

### 9.3 ลำดับการทำและ Bake-off

```text
 Q1, Q3 answered? ──► choose engine (table 4.5) ──► Spike 2 (1 wk) ──► Spike 1 (2–3 wk)
                                                        │                   │
                                                        └──► Spike 3 (2–3 wk, parallel)
                                                                            ▼
                                  Spike 4 (1–2 wk) ──► Spike 5 (1–2 wk) ──► Spike 6 (1 wk)
                                                                            ▼
                                                     Update this ADR → Accepted / Revised
 If Q1 gives a tie (table 4.5): run Spikes 1, 3, 4 on BOTH candidates (bake-off), then decide.
```

### 9.4 การตรวจเพิ่มเติม (ข้อเสนอของ ADR นี้ นอกเหนือจาก 108.3)

| รหัส | สิ่งที่ตรวจ | เกณฑ์ผ่าน |
|---|---|---|
| E1 | ข้อความภาษาไทยใน UI ของ Engine ที่เลือก (Dashboard, แชท, Dossier) ด้วยฟอนต์ IBM Plex Sans Thai หรือ Noto Sans Thai (97) | สระบน สระล่าง และวรรณยุกต์วางถูกตำแหน่ง ไม่มีสระลอย ตัดบรรทัดตรงขอบคำ ผ่านชุดประโยคทดสอบ 50 ประโยค |
| E2 | การแจกจ่ายผ่าน git: `git clone` ใหม่บนบัญชีผู้ใช้อื่นของเครื่อง แล้วรัน `play.command`; ยืนยันว่า Unity 6.3 เซ็นแบบไม่ระบุตัวผู้พัฒนาให้อัตโนมัติ; ทดลองแก้ไฟล์ Resource หนึ่งไฟล์ในบันเดิลแล้วดูผล | เกมเปิดได้, `codesign --verify` ผ่าน, ไม่มี Quarantine, ขนาด clone และเวลา clone อยู่ในเกณฑ์ที่ ADR-0002 กำหนด; กรณีแก้ Resource: `play.command` ตรวจพบว่าลายเซ็นเสียและแจ้งผู้เล่น |
| E3 | Steamworks บน arm64 | `lipo -info` ของไลบรารี Steam แสดง arm64 และเรียก Init ได้ (เมื่อมี App ID ทดสอบ) |
| E4 | Replay | โหลด Save + Command Log แล้วเล่นซ้ำ 1 ชั่วโมงในเกมได้ State Hash ตรงกันทุกจุด |
| E5 | Save ข้ามเวอร์ชัน Schema | Save ของ Schema vN โหลดในเกมที่ใช้ vN+1 ได้ผ่าน Migration โดยข้อมูลไม่หาย |

### 9.5 ตารางบันทึกผล (กรอกหลังทำ Spike)

| Spike | วันที่ | เครื่อง | ผล | ข้อมูลสำคัญ | ผลต่อ ADR |
|---|---|---|---|---|---|
| 1 | — | — | รอผล | — | — |
| 2 | — | — | รอผล | — | — |
| 3 | — | — | รอผล | — | — |
| 4 | — | — | รอผล | — | — |
| 5 | — | — | รอผล | — | — |
| 6 | — | — | รอผล | — | — |
| E1–E5 | — | — | รอผล | — | — |

**เงื่อนไขเปลี่ยนสถานะเป็น Accepted:** ได้คำตอบ Q1 และ Spike 1–6 ผ่าน หรือข้อที่ไม่ผ่านมีการแก้ ADR นี้ตามช่อง "ยืนยันหรือล้ม" แล้ว

---

## 10. ผลต่อ Repository เครื่องมือ และการเซ็นโค้ด

### 10.1 Git และ Git LFS

| ข้อเท็จจริง | ผล |
|---|---|
| GitHub บล็อกไฟล์ที่ใหญ่กว่า 100 MiB และแนะนำให้ Repository เล็กกว่า 1 GB (ไม่ควรเกิน 5 GB) ([GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)) | ไฟล์ Binary ขนาดใหญ่ต้องใช้ Git LFS หรือแบ่งเป็นหลายไฟล์ |
| บัญชี GitHub Free มีโควตา Git LFS 10 GiB สำหรับพื้นที่และ 10 GiB ต่อเดือนสำหรับการดาวน์โหลด **และการดาวน์โหลดของทุกคนที่ clone นับเข้าโควตาของเจ้าของ Repository**; ถ้าเกินโดยไม่มีวิธีชำระเงิน LFS จะถูกปิดจนถึงเดือนถัดไป ([GitHub](https://docs.github.com/en/billing/concepts/product-billing/git-lfs)) | ถ้าเกมมีไฟล์ LFS 2 GB ผู้เล่นเพียง 5 คนต่อเดือนก็ใช้โควตาฟรีหมด |
| ขนาดไฟล์สูงสุดของ Git LFS บน GitHub Free/Pro คือ 2 GB ([GitHub](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage)) | ไฟล์โมเดล LLM หรือ Archive ของ Tile ต้องไม่เกินขนาดนี้ |
| git ใน Command Line Tools ของ Apple ไม่มี git-lfs มาให้ ต้องติดตั้งเพิ่ม เช่นผ่าน Homebrew (ข้อมูลจากผู้ใช้ [MacPorts](https://trac.macports.org/ticket/64044) — **ต้องตรวจสอบ** ด้วย `git lfs version` บนเครื่องที่ติดตั้งใหม่) | ถ้าผู้เล่นต้องใช้ LFS ขั้นตอนติดตั้งจะยากขึ้น |

### 10.2 กฎ `.gitattributes` และ `.gitignore` ที่จะเพิ่มเมื่อเลือก Engine แล้ว

`.gitattributes` ปัจจุบันมี `* text=auto eol=lf` ซึ่ง git จะเดาว่าไฟล์ใดเป็นข้อความแล้วแปลงปลายบรรทัด กฎที่เพิ่มต้อง **อยู่ใต้บรรทัดนี้** เพราะกฎที่อยู่ล่างกว่าจะมีผลเหนือกว่า และไฟล์ Binary ทุกชนิดต้องถูกประกาศชัดเจน

ส่วนที่ใช้กับทุก Engine (ข้อเสนอ ยังไม่เพิ่มในรอบนี้)

```text
# --- Binary assets (Git LFS) ---
*.png   filter=lfs diff=lfs merge=lfs -text
*.jpg   filter=lfs diff=lfs merge=lfs -text
*.psd   filter=lfs diff=lfs merge=lfs -text
*.fbx   filter=lfs diff=lfs merge=lfs -text
*.glb   filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text
*.wav   filter=lfs diff=lfs merge=lfs -text
*.ogg   filter=lfs diff=lfs merge=lfs -text
*.ttf   filter=lfs diff=lfs merge=lfs -text
*.otf   filter=lfs diff=lfs merge=lfs -text
# --- Map data from the OSM pipeline (extensions decided in ADR-0004) ---
*.afpack filter=lfs diff=lfs merge=lfs -text
*.tif    filter=lfs diff=lfs merge=lfs -text
*.pbf    filter=lfs diff=lfs merge=lfs -text
# --- On-device LLM weights: only if Q2 requires bundling a model ---
*.gguf        filter=lfs diff=lfs merge=lfs -text
*.safetensors filter=lfs diff=lfs merge=lfs -text
# --- Built game: never touch line endings inside a signed bundle ---
Build/**      -text
```

ส่วนเพิ่มเฉพาะ Engine

| Engine | `.gitattributes` | `.gitignore` |
|---|---|---|
| Unity | ไฟล์ YAML (`*.unity`, `*.prefab`, `*.asset`, `*.mat`, `*.anim`, `*.controller`) เป็นข้อความ ใช้ `merge=unityyamlmerge eol=lf` (ต้องตั้งค่า Smart Merge ใน git config ของนักพัฒนา); ตั้ง Asset Serialization เป็น Force Text | `Library/`, `Temp/`, `Logs/`, `UserSettings/`, `obj/`, `MemoryCaptures/`, `*.csproj`, `*.sln` |
| Web Stack | — | `node_modules/`, `dist/`, `src-tauri/target/` |
| Bevy / Rust | — | `target/` |
| Swift | — | `DerivedData/`, `*.xcuserstate`, `xcuserdata/` |
| Godot | — | `.godot/` |

ต้องระวัง: `.gitignore` ปัจจุบันไม่เก็บ `*.app` และ `build/` ซึ่งถูกต้องสำหรับไฟล์ที่นักพัฒนา Build เอง แต่ถ้าเลือกแจก `.app` ผ่าน git (หัวข้อ 10.3) ต้องเก็บไว้ในตำแหน่งที่กำหนดเท่านั้น และปรับกฎให้สอดคล้อง

### 10.3 ทางเลือกการแจกจ่ายผ่าน `git clone` (ตัดสินใน ADR-0002)

| ทางเลือก | วิธี | ข้อดี | ข้อเสีย |
|---|---|---|---|
| G1 | Commit `.app` ที่ Build แล้วผ่าน Git LFS | ผู้เล่นได้เกมทันที | ผู้เล่นต้องติดตั้ง git-lfs, ทุก clone กินโควตาดาวน์โหลดของเจ้าของ Repository, ต้องซื้อโควตาเพิ่มเมื่อมีผู้เล่นมากขึ้น |
| G2 | Branch แยกสำหรับแจกจ่าย (เช่น `release/mac`) เก็บ `.app` เป็นไฟล์ git ปกติ (ทุกไฟล์ต้องเล็กกว่า 100 MiB) มีเพียง Commit ล่าสุด และให้ผู้เล่น clone แบบ `--depth 1` | ไม่ต้องใช้ LFS, ไม่มีโควตา LFS | ต้องเขียนประวัติ Branch ทับทุกครั้ง ทำให้ `git pull` ธรรมดาใช้ไม่ได้ ต้องให้ `play.command` อัปเดตแบบ fetch แล้ว reset ซึ่งต้องแก้วิธีอัปเดตใน README; Repository หลักควรอยู่ใต้ 1–5 GB |
| G3 | ผู้เล่น Build เองจากซอร์สหลัง clone | ไม่ต้องเก็บไฟล์ Build ใน git | ใช้ไม่ได้กับ Unity, Unreal และ Godot (ผู้เล่นไม่มี Editor) ใช้ได้กับ Rust หรือ Swift แต่ผู้เล่นต้องติดตั้ง Toolchain ขนาดใหญ่ และ Build ครั้งแรกนาน |

**ข้อเสนอสำหรับการแจกผ่าน git (ช่องทางปัจจุบัน):** ช่วง Prototype ใช้ G2 ถ้าขนาดเกมรวมเล็กกว่าประมาณ 1 GB ถ้าใหญ่กว่านั้นใช้ G1 และกำหนดงบค่าโควตา LFS ส่วนไฟล์โมเดล LLM (ถ้า Q2 ต้องการ) เป็นไฟล์ทางเลือกแยกจากตัวเกม ขนาด 2–5 GB ใน Build ทดสอบผ่าน git จะต้องใช้ G1 (LFS) สำหรับไฟล์นี้ ส่วนฉบับ Steam ส่งเป็น Depot แยกหรือดาวน์โหลดตอนเปิดใช้ครั้งแรก จึงไม่กระทบโควตา LFS

### 10.4 สิ่งที่ `play.command` ต้องทำเมื่อมีตัวเกมแล้ว (อธิบายขั้นตอน ยังไม่เขียนโค้ด)

1. ตรวจว่าเป็น macOS (มีอยู่แล้ว)
2. ตรวจว่าเครื่องเป็น Apple Silicon (`uname -m` ต้องเป็น `arm64`) และ macOS ไม่ต่ำกว่าเวอร์ชันขั้นต่ำที่ ADR-0002 กำหนด ถ้าไม่ผ่านให้แสดงข้อความภาษาไทย
3. หา `.app` ในตำแหน่งที่ตกลงไว้ (เช่น `Build/AFTERFALL.app`) ถ้าไม่พบให้แนะนำวิธีแก้ (เช่น ยังไม่ได้ติดตั้ง git-lfs ในกรณี G1)
4. ตรวจลายเซ็นด้วย `codesign --verify --strict` ถ้าไม่ผ่านให้แจ้งว่าไฟล์เสียหรือถูกแก้ไข และแนะนำให้อัปเดตใหม่
5. ตรวจว่ามี Quarantine หรือไม่ ถ้ามี (เช่น ผู้ใช้ดาวน์โหลดเป็น ZIP จากเว็บ) ให้ **แจ้งผู้ใช้และอธิบายวิธีที่ถูกต้อง ไม่ลบ Quarantine ให้อัตโนมัติ**
6. เปิดเกมผ่าน `open` (ผ่าน LaunchServices) หรือรันไฟล์ในบันเดิลโดยตรงเมื่อต้องการเห็น Log
7. (เฉพาะ G2) มีคำสั่งอัปเดตที่ fetch Branch แจกจ่ายแล้ว reset ไปที่ Commit ล่าสุด เพราะ `git pull` ใช้ไม่ได้

### 10.5 การเซ็นโค้ดและ Notarization

**กรณีแจกผ่าน `git clone` (ปัจจุบัน)**

| ข้อเท็จจริง | ผลต่อโปรเจกต์ |
|---|---|
| git บน macOS ไม่ใส่ Quarantine ให้ไฟล์ที่ clone มา วิศวกรของ Apple ยืนยันว่า Xcode และ `git` บน Command Line ไม่ใส่ ([Apple Developer Forums](https://developer.apple.com/forums/thread/773965)) | Gatekeeper จึงไม่ตรวจ Notarization ตอนเปิดครั้งแรก เกมที่ไม่ได้ Notarize เปิดได้ |
| บน Apple Silicon โค้ด arm64 ทุกไฟล์ต้องมีลายเซ็นที่ถูกต้อง ลายเซ็นแบบ Ad-hoc ก็พอ และ Linker ของ Apple เซ็นแบบ Ad-hoc ให้อัตโนมัติเมื่อ Build บนเครื่อง ([Apple release notes](https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-universal-apps-release-notes), [Eclectic Light](https://eclecticlight.co/2020/08/22/apple-silicon-macs-will-require-signed-code/)) | `.app` ที่ Build บนเครื่องรันได้ทันที แต่ **ถ้าโค้ดที่เซ็นแล้วถูกแก้ Kernel จะปิดเกมทันที ถ้าไฟล์ Resource ถูกแก้ ลายเซ็นของบันเดิลจะเสีย** (`codesign --verify` ไม่ผ่าน และ Gatekeeper จะแจ้งว่าแอปเสียเมื่อมีการตรวจ เช่น แอปที่ติด Quarantine หรือแอปที่ Notarize แล้วบน Ventura ขึ้นไป) ([Eclectic Light](https://eclecticlight.co/2019/06/24/damaged-apps-can-run-normally-signature-checks-are-complex/) — ข้อมูลปี 2019 ต้องทดสอบซ้ำใน E2) จึงต้องตั้ง `Build/** -text` ห้ามรัน strip หรือแก้ไบนารีหลังเซ็น และต้องเซ็นจากชั้นในออกมาข้างนอก |
| Unity Build บน Apple Silicon เซ็นให้อัตโนมัติหรือไม่ | เอกสาร Unity ระบุว่า Unity เซ็นแอป macOS ทุกตัวที่ Build ให้อัตโนมัติ แต่ไม่ใส่ตัวตนผู้พัฒนา (เพียงพอสำหรับรันบนเครื่อง ไม่พอสำหรับ Notarize) ([Unity 2022.1 Manual](https://docs.unity3d.com/2022.1/Documentation/Manual/macos-building.html)) ต้องยืนยันซ้ำบน 6.3 ใน E2 |
| ตั้งแต่ macOS Ventura แอปที่ Notarize แล้วถูกตรวจลายเซ็นทุกครั้งที่เปิด ([Eclectic Light](https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/)) | ถ้าในอนาคตแจกแอปที่ Notarize ผ่าน git แล้ว git แปลงปลายบรรทัดในบันเดิล แอปจะถูกมองว่าเสียหาย ยิ่งยืนยันว่าต้องใช้ `-text` |
| Item ใน Keychain ผูกกับตัวตนของลายเซ็นโค้ด ลายเซ็นแบบ Ad-hoc เปลี่ยนทุกครั้งที่ Build (ผลเชิงปฏิบัติ ต้องตรวจสอบ) | ผู้เล่นอาจถูกถามสิทธิ์ Keychain ใหม่ทุกครั้งที่อัปเดต เพื่ออ่าน API Key ของ LLM บนคลาวด์ ข้อเสนอคือเซ็นด้วย Developer ID เมื่อมีบัญชี Apple Developer แม้จะแจกผ่าน git |
| ถ้าผู้ใช้ดาวน์โหลด Repository เป็น ZIP ผ่านเบราว์เซอร์ ไฟล์จะติด Quarantine และตั้งแต่ macOS 15 การคลิกขวาแล้วเลือก Open เพื่อข้าม Gatekeeper ถูกเอาออก ต้องไปกด "Open Anyway" ใน Privacy & Security ([Macworld](https://www.macworld.com/article/2457844/what-to-do-when-you-cant-open-an-app-you-just-installed-in-macos-sequoia.html)) | README ควรย้ำให้ใช้ `git clone` เท่านั้น ซึ่งตรงกับข้อความปัจจุบัน |

**กรณีวางขายบน Steam (อนาคต)**

| ข้อกำหนด | รายละเอียด |
|---|---|
| ใบรับรอง | Developer ID Application ต้องเป็นสมาชิก Apple Developer Program ราคา 99 USD ต่อปี ([Apple](https://developer.apple.com/support/compare-memberships)) |
| การเซ็น | เปิด Hardened Runtime และ Secure Timestamp |
| Notarize | ใช้ `notarytool` เท่านั้น เพราะ Apple หยุดรับงานจาก `altool` ตั้งแต่ 1 พ.ย. 2023 ([TN3147](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool)) แล้ว Staple ผลกลับเข้าแอป |
| เงื่อนไขของ Steam | Steam กำหนดให้แอป macOS ใหม่ต้องเป็น 64 บิตและผ่าน Notarization, แนะนำ Entitlement `com.apple.security.cs.disable-library-validation` และ `com.apple.security.cs.allow-dyld-environment-variables` สำหรับไลบรารีและ Overlay ของ Steam และไม่รองรับ App Sandbox ([Steamworks](https://partner.steamgames.com/doc/store/application/platforms)) |
| Unity | ใช้ IL2CPP สำหรับ Build ที่แจกจ่าย เพื่อเลี่ยง Entitlement ด้าน JIT ที่ Mono อาจต้องใช้ (ต้องตรวจสอบกับหน้าย่อยเรื่อง Entitlement ของคู่มือ Unity ก่อนอ้างอิง) ขั้นตอน Notarize ดูหน้าภาพรวม ([Unity](https://docs.unity3d.com/Manual/macos-building-notarization.html)) |
| LLM บนเครื่อง | ถ้าเกมเปิด llama.cpp server เป็นโปรเซสลูก ไฟล์นั้นต้องถูกเซ็นด้วยทีมเดียวกันและรวมอยู่ใน Notarization ด้วย |

---

## 11. คำถามที่ยังเปิดอยู่ (Open Questions)

### 11.1 คำถามถึงผู้ออกแบบ (เฉพาะหัวข้อ 108.2)

**Q1. ขนาดทีมและภาษาที่ถนัด**

- ขอข้อมูล: มีผู้เขียนโปรแกรมกี่คน (0 / 1 / 2–3 / 4 คนขึ้นไป) และแต่ละคนถนัดภาษาใดใน C#, TypeScript, Rust, Swift (หรือภาษาอื่น เช่น C++ หรือ Python)
- ผลต่อ ADR: เลือก Engine ตามตาราง 4.5, ภาษาของ OSM Pipeline (B3) และว่าต้องทำ Bake-off หรือไม่
- ถ้ายังไม่ตอบ: ใช้ Unity 6 LTS เป็นค่าเริ่มต้นตามสเปก

**Q2. ผู้ช่วย AI ต้องเล่นแบบออฟไลน์ได้หรือไม่**

- ตัวเลือกคำตอบ
  - (ก) ไม่จำเป็น: ใช้ LLM บนคลาวด์ และเมื่อออฟไลน์ใช้โหมด Template (ซึ่งมีอยู่แล้วตาม 30.3)
  - (ข) ต้องเล่นออฟไลน์ได้ แต่ยอมให้ผู้ช่วยตอนออฟไลน์เป็นโหมด Template
  - (ค) ต้องคุยแบบ LLM ได้แม้ออฟไลน์
- ผลต่อ ADR: (ค) ต้องส่งไฟล์โมเดล GGUF ขนาด 2–5 GB แยกจากตัวเกมเป็นทางเลือก (ฉบับ Steam ใช้ Depot แยกหรือดาวน์โหลดตอนเปิดใช้ครั้งแรก ส่วน Build ทดสอบผ่าน git จะกระทบโควตา Git LFS ในหัวข้อ 10.3) และใช้งบหน่วยความจำกับกติกาในหัวข้อ 6.1 และ 6.3 Apple Foundation Models ช่วยไม่ได้ เพราะไม่รองรับภาษาไทย; (ก) และ (ข) ไม่ต้องส่งไฟล์โมเดล

**Q3. ประเทศหรือพื้นที่ที่จะใช้ทำ Prototype**

- ผลต่อ ADR: พื้นที่ทดสอบของ Spike 1, เส้นเมริเดียนกลางของ SimFrame (B2), ความครบถ้วนของข้อมูล OSM, ภาษาของชื่อสถานที่ และละติจูดที่กำหนดอัตราขยายของ Mercator
- ถ้ายังไม่ตอบเมื่อเริ่ม Spike 1: ใช้ย่าน Vinohrady กรุงปราก เป็นพื้นที่ทดสอบทางเทคนิคชั่วคราว

### 11.2 สิ่งที่ทีมต้องตรวจสอบเอง (ไม่ใช่คำถามถึงผู้ออกแบบ)

| เรื่อง | วิธีตรวจ |
|---|---|
| Unity Advanced Text Generator แสดงภาษาไทยและตัดบรรทัดได้ถูกต้อง | E1 |
| Unity 6.7 LTS วันออกจริง | ติดตามประกาศของ Unity |
| ยืนยันซ้ำบน Unity 6.3 ว่าเซ็นอัตโนมัติแบบไม่ระบุตัวผู้พัฒนาเหมือนเอกสาร 2022.1 และ Entitlement ที่ Mono ต้องใช้ | E2 และหน้าย่อยเรื่อง Entitlement ในเอกสาร Unity |
| ค่า `recommendedMaxWorkingSetSize` บนเครื่อง 24 GB | อ่านค่าจาก Metal บนเครื่องจริง |
| MSAA กับ Memoryless / Tile-Only ของ URP บน Apple GPU | Spike 1 (Metal Frame Capture) |
| Steamworks.NET และ Steamworks SDK บน arm64 | E3 |
| Steam Overlay บน Metal และใน WKWebView | ทดสอบเมื่อมี App ID |
| WKWebView รองรับ WebGPU และ 120 Hz หรือไม่ (เฉพาะทางเลือก B) | Spike 1 และ 6 บนทางเลือก B |
| ความเร็วช่องทางไบนารีของ Tauri สำหรับ Snapshot ต่อ Tick | Spike 3–4 บนทางเลือก B |
| การตัดบรรทัดภาษาไทยของ Bevy และ Godot | E1 ถ้าเลือกทางเลือกนั้น |
| Apple เพิ่มภาษาไทยใน Apple Intelligence เมื่อใด (ตอนนี้ยังไม่รองรับ จึงใช้ Foundation Models ได้เฉพาะโหมดอังกฤษ) | ติดตามหน้า [Apple 121115](https://support.apple.com/en-us/121115) |
| การเรียก Steamworks (C++) จาก Swift | เฉพาะทางเลือก D |
| เงื่อนไข ODbL ของ Tile ที่แจกพร้อมเกม | ปรึกษาผู้รู้ด้านกฎหมาย |
| git-lfs ไม่มาพร้อม Command Line Tools ของ Apple | `git lfs version` บนเครื่องที่ติดตั้งใหม่ |
| Keychain ถามสิทธิ์ใหม่เมื่อลายเซ็น Ad-hoc เปลี่ยน | E2 |

---

## 12. แหล่งอ้างอิง

**ฮาร์ดแวร์และระบบปฏิบัติการ**

- [Apple: MacBook Pro 14" M4 Pro/Max (2024) tech specs](https://support.apple.com/en-us/121553) · [MacBook Pro 16" (2024)](https://support.apple.com/en-us/121554)
- [MacTrast: High Power Mode on M4 Pro](https://www.mactrast.com/2024/11/high-power-mode-expands-to-macbook-pro-and-mac-mini-models-with-m4-pro-chip/)
- [9to5Mac: macOS 27 launch date](https://9to5mac.com/2026/09/09/apple-confirms-macos-27-golden-gate-launch-date-september-14/) · [Eclectic Light: macOS Golden Gate released](https://eclecticlight.co/2026/09/14/apple-has-released-macos-golden-gate-and-security-updates-to-tahoe-26-7-sequoia-15-8/)
- [MacRumors: Rosetta through macOS 27](https://macrumors.com/2026/06/10/macos-golden-gate-last-to-support-intel-apps/) · [Apple: Metal support](https://support.apple.com/102894)
- [Apple: Responding to power notifications (thermal state)](https://developer.apple.com/documentation/xcode/responding-to-power-notifications) · [Apple: Metal Performance HUD](https://developer.apple.com/documentation/xcode/gaining-performance-insights-with-metal-performance-hud) · [Apple: recommendedMaxWorkingSetSize](https://developer.apple.com/documentation/metal/mtldevice/recommendedmaxworkingsetsize)
- [Eclectic Light: QoS and core types](https://eclecticlight.co/2024/12/17/tune-for-performance-core-types/) · [Eclectic Light: damaged apps and signature checks](https://eclecticlight.co/2019/06/24/damaged-apps-can-run-normally-signature-checks-are-complex/)

**Engine และไลบรารี**

- Unity: [Unity 6 releases](https://unity.com/releases/unity-6) · [Unity 6.5 available](https://discussions.unity.com/t/unity-6-5-is-now-available/1723176) · [Unity 6.6 Manual](https://docs.unity.com/en-us/engine/6000.6/manual) · [Unity 6.7 Beta Manual](https://docs.unity.com/en-us/engine/6000.7/manual) · [CoreCLR & ECS status (Mar 2026)](https://discussions.unity.com/t/coreclr-scripting-and-ecs-status-update-march-2026/1711852) · [ECS status (Dec 2025)](https://discussions.unity.com/t/ecs-development-status-december-2025/1699284/1) · [ECS status for 6.6](https://discussions.unity.com/t/ecs-development-status-for-unity-6-6/1724480) · [Burst float determinism](https://docs.unity3d.com/Manual/burst/float-precision-determinism.html) · [Pricing](https://unity.com/pricing) · [Runtime Fee cancelled](https://unity.com/blog/unity-is-canceling-the-runtime-fee) · [System requirements](https://docs.unity3d.com/Manual/system-requirements.html) · [macOS build settings](https://docs.unity.com/en-us/engine/6000.7/manual/platform-specific/apple-mac/macos-delivery/macosbuildsettings) · [Advanced Text Generator](https://docs.unity3d.com/6/Documentation/Manual/UIE-advanced-text-generator.html) · [Metal optimize / memoryless](https://docs.unity3d.com/Manual/metal-optimize.html) · [URP on-tile rendering](https://docs.unity.com/en-us/engine/6000.6/manual/analysis/graphics-performance-profiling/in-urp/on-tile-rendering) · [macOS notarization](https://docs.unity3d.com/Manual/macos-building-notarization.html) · [macOS building 2022.1 (automatic signing)](https://docs.unity3d.com/2022.1/Documentation/Manual/macos-building.html) · [Steamworks.NET releases](https://github.com/rlabrecque/Steamworks.NET/releases)
- Web Stack: [MapLibre GL JS](https://github.com/maplibre/maplibre-gl-js) · [Releases](https://github.com/maplibre/maplibre-gl-js/releases) · [deck.gl](https://github.com/visgl/deck.gl) · [Releases](https://github.com/visgl/deck.gl/releases) · [deck.gl What's New](https://deck.gl/docs/whats-new) · [Tauri](https://github.com/tauri-apps/tauri) · [Releases](https://github.com/tauri-apps/tauri/releases) · [Tauri macOS signing](https://v2.tauri.app/distribute/sign/macos/) · [WebGPU implementation status](https://github.com/gpuweb/gpuweb/wiki/Implementation-Status) · [Construct forum (Steam Overlay, WKWebView)](https://construct.net/en/comments/62775)
- Bevy: [News](https://bevy.org/news/) · [Bevy 0.20](https://bevy.org/news/bevy-0-20/) · [Repository](https://github.com/bevyengine/bevy)
- Godot: [Blog](https://godotengine.org/blog/) · [4.4 dev 1 (Metal)](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-1/) · [ProjectSettings 4.7.2 (driver.macos = metal)](https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/doc/classes/ProjectSettings.xml) · [Large world coordinates](https://docs.godotengine.org/en/stable/tutorials/physics/large_world_coordinates.html) · [TextServerAdvanced](https://docs.godotengine.org/en/4.6/classes/class_textserveradvanced.html) · [Repository](https://github.com/godotengine/godot) · [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot)
- Unreal: [UE 5.8 released (GameFromScratch)](https://gamefromscratch.com/unreal-engine-5-8-released/) · [Large World Coordinates](https://dev.epicgames.com/documentation/en-us/unreal-engine/large-world-coordinates-in-unreal-engine-5) · [UE 5.2 Apple Silicon](https://www.unrealengine.com/en-US/tech-blog/unreal-engine-5-2-brings-native-support-for-apple-silicon-and-other-developments-for-macos) · [macOS parity progress report](https://www.unrealengine.com/tech-blog/bringing-unreal-engine-on-macos-up-to-feature-parity-with-windowsprogress-report) · [Unreal FAQ (royalty)](https://www.unrealengine.com/en-US/faq)

**LLM**

- [llama.cpp](https://github.com/ggml-org/llama.cpp) · [llama-server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) · [Releases](https://github.com/ggml-org/llama.cpp/releases)
- [mlx-lm](https://github.com/ml-explore/mlx-lm) · [mlx_lm.server](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md)
- [Apple Foundation Models framework](https://developer.apple.com/foundation-models-framework/) · [Apple Intelligence supported languages (121115)](https://support.apple.com/en-us/121115) · [Developer Forums: Foundation Models requires Apple Intelligence](https://developer.apple.com/forums/thread/805378)
- ขนาดโมเดลและ KV Cache: [Qwen3-8B GGUF](https://huggingface.co/bartowski/Qwen_Qwen3-8B-GGUF) · [Qwen3-4B config](https://huggingface.co/Qwen/Qwen3-4B/blob/main/config.json) · [Llama-3.1-8B GGUF](https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF) · [Llama-3.2-3B GGUF](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF)

**การแจกจ่าย การเซ็นโค้ด และข้อมูล**

- [GitHub: Git LFS billing](https://docs.github.com/en/billing/concepts/product-billing/git-lfs) · [About large files](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github) · [About Git LFS](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-git-large-file-storage) · [MacPorts ticket (git-lfs)](https://trac.macports.org/ticket/64044)
- [Apple Developer Forums: git does not quarantine](https://developer.apple.com/forums/thread/773965) · [Big Sur universal apps release notes (signing on Apple silicon)](https://developer.apple.com/documentation/macos-release-notes/macos-big-sur-11_0_1-universal-apps-release-notes) · [Eclectic Light: Apple Silicon requires signed code](https://eclecticlight.co/2020/08/22/apple-silicon-macs-will-require-signed-code/) · [Eclectic Light: Ventura app security](https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/) · [Macworld: Sequoia Gatekeeper](https://www.macworld.com/article/2457844/what-to-do-when-you-cant-open-an-app-you-just-installed-in-macos-sequoia.html) · [TN3147 notarytool](https://developer.apple.com/documentation/technotes/tn3147-migrating-to-the-latest-notarization-tool) · [Apple memberships](https://developer.apple.com/support/compare-memberships)
- [Steamworks: platforms (macOS notarization & entitlements)](https://partner.steamgames.com/doc/store/application/platforms)
- [Copernicus DEM GLO-30 licence](https://documentation.dataspace.copernicus.eu/APIs/SentinelHub/Data/DEM/resources/license/License-COPDEM-30.pdf) · [OpenStreetMap copyright](https://www.openstreetmap.org/copyright) · [OSMF Attribution Guidelines](https://osmfoundation.org/wiki/Licence/Attribution_Guidelines)

---

## 13. ประวัติการแก้ไขของ ADR นี้

| วันที่ | เวอร์ชัน | การเปลี่ยนแปลง |
|---|---|---|
| 2026-10-22 | 0.1 (Round 1) | ร่างแรก: ประเมิน 6 ทางเลือกแบบถ่วงน้ำหนัก, ความไวต่อ Q1, ขอบเขตสถาปัตยกรรม B1–B8, แก้ตัวเลข float32, งบหน่วยความจำแบบ Runtime และช่วงพัฒนา, แผน Spike 1–6 พร้อมเกณฑ์ที่วัดได้และการตรวจ E1–E5, ผลต่อ Repository และการเซ็นโค้ด |
| 2026-10-22 | 0.2 (Round 1 หลังตรวจทาน) | ทำให้ 9.2 เป็นแหล่งเดียวของเกณฑ์ผ่าน Spike; Tick ยุทธวิธี 50 ms ซ้อนในก้าวท้องถิ่น 500 ms; ระดับซูมของเกม Z0–Z19 (ทดสอบเผื่อ Z21); ปรับงบ 6.1 ให้ผลรวมไม่เกิน 8 GB และขนาด LLM ตามบริบทจริง; ปรับงบ 6.2 ให้เหลือเผื่อ ≥4 GB; เพิ่มงบ Tick ภูมิภาคและโลก; Steam เป็นช่องทางจำหน่ายที่ล็อก ส่วน git เป็นช่องทางชั่วคราว; Apple Foundation Models ไม่รองรับภาษาไทย; Godot ใช้ Metal เป็นค่าเริ่มต้น; ลำดับ Gateway และ `delegate_task`; เงื่อนไข ODbL และ Copernicus ครบ; แก้คะแนนแถว TypeScript + Rust และข้อยกเว้นกติกาเสมอ |
