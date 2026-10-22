# 02 — แผนผังความเชื่อมโยงของระบบ (System Map)

> **PROJECT AFTERFALL — THE FRACTURED EARTH · GDD รอบที่ 1**
>
> - **สถานะ:** ร่างรอบที่ 1 ให้ผู้ออกแบบตรวจ
> - **เอกสารต้นทาง:** `docs/design/PROJECT_AFTERFALL_Master_Prompt_v3.1.md` (ต่อไปเรียกว่า **spec**)
> - **ขอบเขต:** หัวข้อ 118 รอบที่ 1 "แผนผังความเชื่อมโยงของระบบทั้งหมด (เขียนเป็นแผนภาพข้อความ)" และงานข้อ 113.3 "ความสัมพันธ์และผลกระทบระหว่างระบบ"
> - **ไฟล์ในรอบเดียวกัน:** [01 Vision & Pillars](01-vision-and-pillars.md) · [03 คำตัดสินประเด็นหัวข้อ 114](03-design-rulings-sec114.md) · [04 แผนพัฒนาเป็นระยะ](04-phased-roadmap.md) · [05 สารบัญ GDD](05-gdd-table-of-contents.md) · [ADR-0001 Tech Stack](../../adr/ADR-0001-tech-stack.md)

**ข้อตกลงของเอกสารนี้**

- เป็นการออกแบบเชิงแนวคิด **ไม่มีโค้ดเกม** โครงสร้างข้อมูลทั้งหมดเป็นระดับแนวคิด (ตามหัวข้อ 118 "ยังไม่ต้องเขียนโค้ด")
- **ตัวเลขทุกค่า** เช่น ความถี่ของ Tick เกณฑ์ และสัดส่วน เป็น **ค่าตั้งต้นที่ต้องวัดและปรับ** เหมือนที่ spec ใช้
- แผนภาพใช้ป้ายภาษาอังกฤษสั้น ๆ เพราะสระและวรรณยุกต์ไทยทำให้คอลัมน์ในฟอนต์ Monospace เพี้ยน คำอธิบายภาษาไทยอยู่ใต้แผนภาพเสมอ
- ยึดข้อที่ล็อกแล้วในหัวข้อ 0.6 และ 108.1: **มุมมองแผนที่ Top-down ที่ซูมต่อเนื่อง** (โลก → ยานพาหนะคันเดียว อาคาร 2.5D ภายในอาคารเป็น Floor Plan Overlay ไม่มีกล้องระดับถนนหรือมุมมองบุคคลที่หนึ่ง) และ **macOS เท่านั้น บน MacBook Pro M4 Pro RAM 24 GB แบบ Native ARM64 + Metal**
- แผนผังนี้ **ไม่ผูกกับเอนจิน** ใช้ได้กับข้อเสนอหลัก (Unity 6 LTS + Entities/Burst) และทางเลือกในหัวข้อ 107.2 การเลือกเอนจินอยู่ใน ADR-0001

---

## 0. ภาพรวมและวิธีอ่าน

### 0.1 เอกสารนี้ตอบคำถามอะไร

| คำถาม | อยู่ในหัวข้อ |
|---|---|
| 34 โมดูลในหัวข้อ 103 อยู่ชั้นไหนของสถาปัตยกรรม และใครพึ่งใคร | 1 |
| ข้อมูลอะไรไหลจากระบบไหนไประบบไหน (คน สิ่งอุปกรณ์ เชื้อเพลิง ความชอบธรรม Command Coverage ฯลฯ) | 2 |
| วงจรป้อนกลับที่ทำให้โลก "มีชีวิต" และอะไรกันไม่ให้มันวิ่งเลยเถิด | 3 |
| ระบบหนึ่งกระทบอีกระบบอย่างไร (งานข้อ 113.3) | 4 |
| ใครเป็นเจ้าของข้อมูลหลักแต่ละชิ้น และกฎ Echelon Handoff ทำงานอย่างไรบน State ร่วม | 5 |
| แต่ละโมดูลอัปเดตถี่แค่ไหน | 6 |
| LLM แตะระบบได้ตรงไหน และตรงไหนต้องเป็น Game AI | 7 |
| Interface กลาง และ Invariant ที่ต้องทดสอบ | 8, 9 |
| ประเด็นเปิดสำหรับรอบถัดไป และผลของคำถามข้อ 108.2 ต่อแผนผังนี้ | 10 |

### 0.2 สัญลักษณ์ในแผนภาพ

```text
[08 CMB]            module number 08 + short tag (full list in table 1.3)
A --x--> B          data "x" flows from A to B (B reads or receives x)
A ==x==> B          write through an official interface (Command API / Ledger / Event Bus / Lease)
(+) (-)             same-direction / opposite-direction influence (loop diagrams)
R  /  B             Reinforcing loop / Balancing loop
GLOBAL REGIONAL LOCAL TACTICAL FRAME ASYNC     cadence tiers (section 6)

01 OSM    World Data & OSM Pipeline        18 BASE   Fortification & Base Design
02 GSIM   Global Simulation (kernel)       19 MPT    Manpower & Training
03 FAI    Faction AI (Game AI)             20 EQDB   Equipment Database
04 POP    Population & Settlement Sim      21 MED    Medical System
05 GOV    Diplomacy & Governance           22 INTEL  Intelligence
06 ECON   Economy & Production             23 MERC   Mercenary Contracts
07 LOG    Logistics & Transport            24 CODEX  Military Codex & Localization TH/EN
08 CMB    Military & Tactical Combat       25 ECH    Echelon Resolution & Handoff
09 CITY   City Building                    26 AIR    Air Operations
10 TECH   Technology & Research            27 NAV    Naval Operations
11 ORB    Orbital Systems                  28 IND    Industry & Maintenance
12 UICMD  UI & Command System              29 WORK   Workforce: Employment, Conscription, People Mgmt
13 SAVE   Persistent Save & World State    30 SVC    City Services & Administration
14 PPL    Personnel, Lineage & Social Graph 31 POL   Policy Dashboard & Automation Rules
15 ORG    Military Organization            32 AIDE   AI Aide: LLM Integration & Tool API
16 C2     Command & Control, Signal & EW   33 STYLE  Visual Style & Color Token System
17 CAP    Building Capture & Conversion    34 PLAT   Platform Layer: macOS / Metal / Apple Silicon
```

### 0.3 การตัดสินใจหลักในเอกสารนี้ (สรุป)

ตารางนี้รวมทุกจุดที่เอกสารนี้ **ตัดสินหรือขยาย** จาก spec พร้อมเหตุผล รายละเอียดอยู่ในหัวข้อที่อ้างถึง

| # | การตัดสินใจ | เหตุผล | อ้าง spec | หัวข้อ |
|---|---|---|---|---|
| D1 | จัด 34 โมดูลเป็น 6 ชั้น: Platform → Data & World → Simulation Core → Domain (24 โมดูลใน 6 กลุ่ม รวม 25 ECH และส่วนจำลองของ 31 POL) → AI (Game AI กับ Assistant แยกกัน) → Presentation & UI การพึ่งพาวิ่งลงล่างเท่านั้น | ทดสอบและเปลี่ยนชิ้นส่วนได้โดยไม่รื้อ และทำให้ LLM อยู่นอกระบบจำลองตามหลัก 15.1 | 103, 15.1 | 1 |
| D2 | **Single-Writer:** ข้อมูลทุกส่วน (Component) มีเจ้าของเดียว โมดูลอื่นเปลี่ยนค่าได้โดยส่ง Event หรือคำขอไปให้เจ้าของเท่านั้น | ตอบโจทย์ "ใช้ State ร่วมกัน + Deterministic Resolution" ของการซูมข้าม Echelon และทำให้ Save/Replay ตรวจสอบได้ | 16.1, 102, 15.1 | 5.1 |
| D3 | ใช้ **สมุดบัญชีการไหล (Flow Ledger) 3 เล่ม**: สิ่งของแบบเหมา ไม่รวมยุทโธปกรณ์ Class VII รายชิ้น (เจ้าของ 07 LOG) เงิน (06 ECON) แรงงาน (29 WORK) และ **ทะเบียน (Registry) 2 ชุด**: การย้อนที่มาของคน (04 POP + 14 PPL) และยุทโธปกรณ์รายชิ้นที่มีหมายเลข (28 IND) โดย 07 เก็บเฉพาะตำแหน่งและผู้ครอบครองของยุทโธปกรณ์รายชิ้น ทุกคนในกองทัพต้องย้อนกลับไปหาประชากรหรือบุคคลจริงได้ | ทำให้กฎ "ห้ามสร้างจากความว่างเปล่า" เป็นสิ่งที่ตรวจด้วยเครื่องได้ และสมุดแรงงานเล่มเดียวทำให้ "ทหารทุกคนคือแรงงานที่หายไปจากเศรษฐกิจ" เกิดขึ้นเองตามโครงสร้าง | 11, 0.3 เสาหลัก 5, 62 | 5.3 |
| D4 | ให้ **25 ECH เป็นเจ้าของ Zone Field** (Rear/Support/Close/Deep/Contested/Buffer/พิเศษ) แนวหน้า และทะเบียนการรบ (Engagement) — ขยายขอบเขตของโมดูล 25 จากชื่อเดิม และวาง 25 ไว้ในชั้น Domain (L3 กลุ่ม E) | โซนเป็นค่าที่ถูกอ่านมากที่สุด (ดัดแปลงอาคาร ก่อสร้าง ผลิต พลเรือน ส่งกำลัง) และต้องคำนวณจากตัวแปรชุดเดียวกับ Operational Resolution ตามหลัก Resolution Consistency spec จัดหัวข้อ 16–17 ไว้ใน PART เดียวกันอยู่แล้ว | 16.1, 17 | 2.4, 5.4 |
| D5 | **Lease Protocol:** ข้อมูลที่เปลี่ยนเร็วในการรบ (ตำแหน่ง กำลัง ขวัญ กระสุนในมือ ความเสียหายราย Cell) ถูก "ให้เช่าสิทธิ์เขียน" กับตัวคำนวณได้ทีละตัวเท่านั้น (Tactical หรือ Operational) ส่งต่อกันที่ขอบ Tick และใช้ระเบียบเดียวกันกับ Simulation LOD อื่น เช่น ขบวนรถแบบกายภาพเมื่อผู้เล่นดู Protocol นี้เป็นของ Kernel (02 GSIM) ส่วนผู้ถือ Lease ฝั่งยุทธการของการรบคือ 25 ECH | ไม่มีสองระบบเขียนค่าเดียวกันพร้อมกัน สลับระดับได้โดยไม่เสียสถานะ | 16.1 Handoff, 102 | 5.4 |
| D6 | **ความจริง (Truth) แยกจากความรู้ (Knowledge):** ทุกผู้ตัดสินใจ ได้แก่ UI ของผู้เล่น ผู้ช่วย AI Faction AI Commander AI KPI ของ Dashboard และการพยากรณ์ อ่านเฉพาะ Knowledge View ของฝ่ายตน (เจ้าของ 22 INTEL) มีเพียง Unit AI ระดับยุทธวิธีที่รับรู้ความจริงเฉพาะที่ผ่านเซนเซอร์และแนวสายตา | ความยุติธรรมของผู้ช่วย (29.3) AI ต้องรู้ผ่านรายงานที่มีความหน่วง (หัวข้อ 12) และป้องกันไม่ให้การพยากรณ์รั่วข้อมูลที่ฝ่ายเราไม่ควรรู้ | 12, 29.3, 32 | 5.1, 7 |
| D7 | **Command API เป็นประตูเดียว** สำหรับทุกผู้สั่งการ: ผู้เล่น กฎอัตโนมัติ ผู้ช่วย AI และ Game AI ของทุกกลุ่ม คำสั่งทั้งหมดถูกบันทึกใน Command Log | ความหน่วง ต้นทุน และสิทธิ์เท่ากันทุกฝ่าย และ Command Log คือสิ่งที่ทำให้ Replay ได้โดยไม่ต้องเรียก LLM ซ้ำ | 15.3, 29.3 | 2.5, 7 |
| D8 | 03 FAI เป็นที่อยู่ของ **ชุดเครื่องมือ Game AI กลาง** (Utility, HTN, Behavior Tree, Influence Map, ตัวจัดตาราง AI LOD) พร้อม Faction AI และ Commander AI ส่วนพฤติกรรมระดับ Agent (Unit, Civilian, Convoy, Mercenary, Economy AI) อยู่ในโมดูลโดเมนของตนแต่ใช้ชุดเครื่องมือนี้ | Agent ต้องอยู่ใกล้ข้อมูลของโดเมนเพื่อประสิทธิภาพแบบ ECS ส่วนการวางแผนข้ามโดเมนและ AI LOD ต้องมีที่เดียว | 12, 15.2 | 1.4 |
| D9 | ขนาดก้าวเวลาของแต่ละชั้นคงที่ในเวลาเกม (ค่าตั้งต้น: TACTICAL 50 ms = 20 Hz (สำรอง 100 ms = 10 Hz), LOCAL 500 ms, REGIONAL 60,000 ms, GLOBAL 3,600,000 ms) แต่ละชั้นซ้อนกันพอดีเป็นจำนวนเต็ม ความเร็วเกม = จำนวนก้าวต่อวินาทีจริง ถ้าเครื่องไม่ทัน ความเร็วจริงจะลดลงแทนการขยายก้าว | ผลลัพธ์เหมือนเดิมเมื่อสถานะเหมือนเดิม (Deterministic) ไม่ว่าเล่นเร็วหรือช้า 20 Hz อยู่ในช่วง 10–20 Hz ของ spec ซ้อนเข้าก้าว LOCAL ได้พอดี 10 ก้าว (5 ก้าวเมื่อใช้ 10 Hz) และทุกก้าวเป็นมิลลิวินาทีเต็มบนฐานเวลา int64 มิลลิวินาทีของ [ADR-0001 B1](../../adr/ADR-0001-tech-stack.md) จึงไม่มีความคลาดเคลื่อนจากการปัดเศษ (ร่างแรกใช้ 1/16 วินาที = 62.5 ms ซึ่งเก็บเป็นมิลลิวินาทีเต็มไม่ได้ และไม่ตรงกับ Spike 2–3 ที่วัดที่ 20 Hz) | 106.2, 15.1, 90 | 6 |
| D10 | งานแบบ Async (LLM, การโหลด Tile, การเขียน Save) เข้าสู่ระบบจำลองได้เฉพาะที่ขอบ Tick และการสลับ LOD ที่เกิดจากกล้อง (เช่น ซูมเข้าการรบ) ถูกบันทึกเป็นเหตุการณ์ใน Command Log | Replay ได้ตรงทุกครั้งแม้ผลการสลับระดับขึ้นกับว่าผู้เล่นมองตรงไหน | 15.1, 16.1 | 6.4 |
| D11 | Map Tile ที่ได้จาก OSM **ไม่ถูกแก้ระหว่างเล่น** การเปลี่ยนแปลงของโลก (ความเสียหาย การควบคุม โซน ป้อม) เป็น Overlay ที่ 13 SAVE เก็บแบบส่วนต่าง และข้อมูลแผนที่ที่ระบบจำลองต้องใช้ต้องไม่ขึ้นกับว่าฝั่งภาพโหลด Tile ไหนอยู่ | ไฟล์ Save เล็ก แยกงาน Pipeline ออกจากเกม และผลการจำลองไม่ขึ้นกับตำแหน่งกล้อง | 87, 102, 105.2 | 5.2, 8 |
| D12 | **Forecast Service เดียว** (เจ้าของ 02 GSIM) จำลองแบบแยกสาขา (Fork) ความละเอียดต่ำบน Knowledge Snapshot ใช้ร่วมกันโดย Dashboard ผู้ช่วย AI และตัววางแผนฝ่ายอำนวยการ | ตัวเลขพยากรณ์ตรงกันทุกหน้าจอ และไม่รั่วข้อมูลจริง | 93.4, 30.2, 107.3 | 7, 8 |
| D13 | แผน A/B/C สร้างโดย **ตัววางแผนฝ่ายอำนวยการของ Game AI** (03 FAI โหมดให้คำแนะนำ) ไม่ใช่ LLM การคัดค้านคำสั่งที่ผิด ROE หรือกฎการสงครามตัดสินโดย **ตัวตรวจกฎใน Command API** แล้ว LLM แค่เรียบเรียงคำพูดตามบุคลิก อำนาจระดับ 3 ส่งงานต่อให้ Commander AI แบบ Deterministic และกฎอัตโนมัติต้องให้ผู้เล่นเปิดใช้เองทุกกรณี | ทำตามหลัก "ระบบจำลองคำนวณ LLM เรียบเรียง" ใช้งานได้แม้ไม่มี LLM และรักษาเสาหลักข้อ 10 | 15, 29, 93.3, 107.3, 101 | 7 |
| D14 | เหตุการณ์โลก (PART 20) History Generation (2.2) และการประเมินเป้าหมายของ Scenario (99) อยู่ใน 02 GSIM ไม่แยกเป็นโมดูลใหม่ | ใช้กฎชุดเดียวกับเกมจริง ประวัติศาสตร์ก่อนเริ่มเกมจึงสอดคล้องกับโลกที่ผู้เล่นเจอ | 2.2, 78, 99 | 1.3 |
| D15 | กำหนดเส้นแบ่งความรับผิดชอบของโมดูลที่ทับซ้อน เช่น 06/28, 09/30/04, 19/29, 17/18, 15/08, 16/22 | ทีมพัฒนาแยกงานคู่ขนานได้โดยไม่เขียนข้อมูลชนกัน | 103 | 1.4 |

---

## 1. สถาปัตยกรรมแบบชั้น (Layered Architecture)

### 1.1 แผนภาพชั้น

```text
+====================================================================================================+
| L5  PRESENTATION & UI      cadence: FRAME 60/120 fps  -- reads Render Snapshot, never writes state |
|     [12 UICMD] views, panels, Radio Order Panel, Unit Card, Policy Dashboard view of [31]          |
|                + COMMAND GATEWAY (validates at the tick edge, then hands orders to [16 C2])        |
|     [33 STYLE] color tokens, zoom-band display rules, accessibility modes                          |
+====================================================================================================+
| L4  AI                                                                                             |
|  4b ASSISTANT  (outside the sim, ASYNC, optional) |  4a GAME AI  (inside the sim, deterministic)   |
|     [32 AIDE] LLM chat + Tool API + no-LLM mode   |     [03 FAI] Faction AI, Commander AI,         |
|     language only; acts ONLY through Tool API     |     AI toolkit: Utility/HTN/BT/InfluenceMap,   |
|                                                   |     AI-LOD scheduler, staff planner (advisory) |
+===== COMMAND API  (down; gateway owned by 12)  ||  QUERY API = KNOWLEDGE VIEW  (up; owned by 22) ==+
| L3  DOMAIN SIMULATION  -- 24 modules in 6 clusters                                                 |
|  A  Society & Governance    [04 POP]  [14 PPL]  [05 GOV]  [09 CITY]  [30 SVC]  [31 POL]            |
|  B  People & Forces         [29 WORK] [19 MPT]  [15 ORG]  [23 MERC]                                |
|  C  Economy & Sustainment   [06 ECON] [28 IND]  [07 LOG]  [10 TECH]                                |
|  D  Territory & Structures  [17 CAP]  [18 BASE]                                                    |
|  E  Warfare                 [08 CMB]  [25 ECH]  [21 MED]  [26 AIR]  [27 NAV]                       |
|  F  Command, Info & Space   [16 C2]   [22 INTEL] [11 ORB]                                          |
|     [31 POL] = policy state + deterministic rule engine (rules emit commands for the next tick)    |
|     [25 ECH] = engagement registry, OCR, ZONE FIELD, frontline; holds the OCR lease                |
+===== EVENT BUS  ||  LEDGERS: goods (07), money (06), labor (29)  ||  REGISTRIES  ||  LEASES (02) ==+
| L2  SIMULATION CORE (kernel)                                                                       |
|     [02 GSIM] clocks & tick tiers, Sim-LOD, event bus, seeded RNG streams, world events,           |
|               history generation, scenario objectives, Forecast Service (sandbox fork),            |
|               lease protocol + promote/demote scheduling at LOCAL tick edges                       |
+====================================================================================================+
| L1  DATA & WORLD FOUNDATION                                                                        |
|     [01 OSM]   render tiles baked Z0-Z16 (shown to Z19), road/rail/river graphs, footprints,       |
|                admin cells, game tags (built offline, immutable at runtime)                        |
|     [20 EQDB]  taxonomy, archetypes, variants, ammo families (data-driven, mod-ready)              |
|     [24 CODEX] prowords, brevity, reports, symbology, TH/EN strings, fictional code generator      |
|     [13 SAVE]  persistent entity IDs, chunked saves, versioned schema, damage map, command log     |
+====================================================================================================+
| L0  PLATFORM                                                                                       |
|     [34 PLAT]  macOS ARM64 native, Metal + MSAA, job threads at high QoS (scheduled mostly on      |
|                P-cores), memory & thermal governor (24 GB budget), input, audio, file IO,          |
|                Steamworks, local-LLM sidecar host                                                  |
+====================================================================================================+
```

**อ่านแผนภาพอย่างไร**

- **L0 Platform** ห่อทุกอย่างที่ผูกกับ macOS / Metal / Apple Silicon ไว้ที่เดียว ชั้นบนไม่เรียก API ของระบบปฏิบัติการตรง ๆ ส่วน **Governor** ของหน่วยความจำและความร้อนเป็นตัวตัดสินว่ารัศมี Simulation LOD จำนวนการรบระดับยุทธวิธี และการรันโมเดล AI บนเครื่องทำได้แค่ไหน (หัวข้อ 104, 106)
- **L1 Data & World** เป็นข้อมูลอ้างอิงที่อ่านอย่างเดียวระหว่างเล่น ยกเว้น 13 SAVE ที่เขียนไฟล์ และทะเบียนรุ่นยุทโธปกรณ์ใน 20 EQDB ที่รับรุ่นใหม่จาก 10 TECH ผ่าน Event
- **L2 Simulation Core** คือ "หัวใจ" ที่ทุกระบบต้องผ่าน ได้แก่ นาฬิกา ตาราง Tick การสลับความละเอียด เหตุการณ์โลก การพยากรณ์ และ **Lease Protocol ทั่วไป** ที่ใช้สลับผู้ถือสิทธิ์เขียนทั้งในการรบ ขบวนรถ และพลเรือนรายคน (02) Kernel ไม่รู้กติกาของโดเมนใด จึงไม่อ่านข้อมูลของชั้นบน
- **L3 Domain** คือระบบเกมทั้งหมดที่ผู้เล่นสัมผัส แบ่ง 6 กลุ่มตามสิ่งที่ไหลผ่าน: คนกับการปกครอง (A) การระดมคน (B) ของกับเงิน (C) พื้นที่และสิ่งก่อสร้าง (D) การรบ (E) คำสั่งกับข้อมูล (F) **25 ECH อยู่ในกลุ่ม E** เพราะการตัดสินผลนอกจอ (OCR) และ Zone Field อ่านกำลัง ขวัญ กระสุน Coverage และการสนับสนุนของประชาชนจากโมดูลโดเมนอื่นในชั้นเดียวกัน **31 POL อยู่ในกลุ่ม A** ในฐานะสถานะนโยบายและเอนจินกฎอัตโนมัติแบบ Deterministic ซึ่งโมดูลโดเมนอื่นอ่านค่านโยบายได้ และกฎส่งคำสั่งขึ้นไปเข้าคิวของ Gateway ใน Tick ถัดไป (ข้อมูลขึ้นข้างบนผ่าน Event ตามกฎ 1.2 ข้อ 1)
- **L4 AI** แบ่งสองซีกชัดเจน: **4a Game AI** อยู่ในระบบจำลองและตัดสินใจทุกอย่างที่เปลี่ยนโลก **4b Assistant** (ผู้ช่วยนายพล) อยู่นอกระบบจำลอง ทำงานด้านภาษา และแตะโลกได้ผ่าน Tool API เท่านั้น
- **L5 Presentation & UI** วาดภาพจาก Snapshot (รวมมุมมอง Policy Dashboard ของ 31) และส่งคำสั่งผ่าน Command API ไม่แก้ State เอง
- **ที่เปลี่ยนจากร่างแรก:** ร่างแรกวาง 25 ECH ไว้ใน L2 และ 31 POL ไว้ใน L5 ซึ่งขัดกฎ 1.2 ข้อ 1 (ชั้นล่างอ่านข้อมูลของชั้นบน) และข้อที่ว่า L5 ไม่เขียน State จึงย้ายส่วนที่เป็นการจำลองของทั้งสองโมดูลลง L3 ส่วนแผนภาพลำดับการสร้างใน [04 หัวข้อ 9.1](04-phased-roadmap.md) แสดง Build Order ไม่ใช่ชั้นขณะรัน

### 1.2 กฎการพึ่งพาระหว่างชั้น

1. **เรียกลงล่างเท่านั้น** ชั้นล่างไม่รู้จักชั้นบน ข้อมูลขึ้นข้างบนได้ทาง Snapshot ที่เผยแพร่ (Publish) หรือ Event เท่านั้น
2. **โมดูลโดเมนใน L3 คุยกันผ่าน 3 ช่องทาง** คือ อ่าน Component ที่เผยแพร่แล้ว (อ่านอย่างเดียว) ส่ง Event ไปให้เจ้าของข้อมูล และทำรายการผ่าน Ledger ไม่มีการแก้ข้อมูลของโมดูลอื่นตรง ๆ
3. **ไม่มีอะไรเหนือเส้น Command API แก้โลกได้โดยตรง** ผู้เล่น กฎอัตโนมัติ ผู้ช่วย และ Game AI เปลี่ยนโลกได้ด้วย "คำสั่ง" ที่ผ่านการตรวจสิทธิ์ ROE ต้นทุน และความหน่วงเท่านั้น
4. **32 AIDE เรียก Query API หรือ Command API ตรงไม่ได้** ต้องผ่าน Tool API ซึ่งกรองข้อมูลตาม Fog of War และความสามารถของนายทหารฝ่ายอำนวยการ และบังคับระดับอำนาจ 0–3
5. **ข้อมูลใน L1 อ่านอย่างเดียวระหว่างเล่น** ยกเว้นที่ระบุในข้อ 1.1
6. **Unit AI รับรู้ความจริงเฉพาะที่ผ่านเซนเซอร์** (แนวสายตา เสียง ความร้อน) ภายใน Tactical Bubble ส่วนผู้ตัดสินใจระดับสูงกว่าอ่าน Knowledge View เท่านั้น (D6)

### 1.3 ตารางตรวจสอบ: ครบทั้ง 34 โมดูล

ทุกโมดูลในหัวข้อ 103 ปรากฏ **หนึ่งครั้ง** ในแผนภาพ 1.1

| # | โมดูล (ตามหัวข้อ 103) | Tag | ชั้น | กลุ่ม | หัวข้อเจ้าของใน spec | บทบาทในแผนผังนี้ |
|---|---|---|---|---|---|---|
| 1 | World Data & OSM Pipeline | OSM | L1 | — | PART 22 (83–85), 105.2–105.3, 107.4 | Tile หลายระดับซูม กราฟถนน ราง แม่น้ำ รูปอาคาร เซลล์การปกครองเดิม และแท็กเชิงเกม สร้างนอกเกม ไม่แก้ระหว่างเล่น |
| 2 | Global Simulation | GSIM | L2 | — | 86, 106.2, 18, 90, PART 20 (78), 2.2, 99 | นาฬิกาและชั้น Tick, Simulation LOD, Event Bus, RNG แบบมี Seed, เหตุการณ์โลก, History Generation, เป้าหมาย Scenario, Forecast Service, Lease Protocol และการจัดตาราง Promote/Demote |
| 3 | Faction AI | FAI | L4a | — | PART 5 (11–15) | ชุดเครื่องมือ Game AI กลาง, Faction AI, Commander AI, ตัวจัดตาราง AI LOD, ตัววางแผนฝ่ายอำนวยการ (ให้แผน A/B/C แก่ผู้ช่วย) |
| 4 | Population & Settlement Simulation | POP | L3 | A | 65, 66, 10.1 (Tier C) | ประชากรแบบกลุ่ม (Pops) ความต้องการ ความพอใจ การย้ายถิ่น Civilian AI |
| 5 | Diplomacy & Governance | GOV | L3 | A | 3, 14, 18, 19, 9.15 | ตัวตนของกลุ่ม ความชอบธรรม ชื่อเสียง ความสัมพันธ์ สนธิสัญญา สถานะการควบคุมทางการเมือง (หัวข้อ 19) |
| 6 | Economy & Production | ECON | L3 | C | 69–71 | เงินตรา ราคา ตลาด การค้า ภาษี คลังเงิน ภาคการผลิตขั้นปฐม (ฟาร์ม เหมือง เก็บกู้) Economy AI สมุดบัญชีเงิน |
| 7 | Logistics & Transport | LOG | L3 | C | 72–73, 20.1 | **สมุดบัญชีสิ่งของ** (คลังทุกจุด + ของระหว่างขนส่ง + ของติดตัวหน่วย) ขบวนรถ Convoy AI Push/Pull Days of Supply |
| 8 | Military & Tactical Combat | CMB | L3 | E | PART 12 (34–38) | การรบละเอียดใน Tactical Bubble ภายใต้ Lease, Unit AI, การยิงสนับสนุน, ป้องกันภัยทางอากาศภาคพื้น, การรบในเมือง |
| 9 | City Building | CITY | L3 | A | 64, 66 | ผังเมือง Zoning District งานก่อสร้างและฟื้นฟูฝั่งพลเรือน |
| 10 | Technology & Research | TECH | L3 | C | PART 19 (76–77) | ระดับเทคโนโลยี สายพัฒนา Salvage → Mass Production, Blueprint, ส่งรุ่นใหม่ให้ 20 EQDB |
| 11 | Orbital Systems | ORB | L3 | F | PART 21 (79–82), 9.13 | สถานีอวกาศ ช่วงเวลาติดต่อ ดาวเทียมสื่อสาร IMINT การค้าอวกาศ (ในระดับ National Fracture ปรากฏเป็นสัญญาณและข้อมูลดาวเทียมเท่านั้น) |
| 12 | UI & Command System | UICMD | L5 | — | PART 23 (88–91), 27, 27.1, 15.3 | มุมมองและแผงทั้งหมด + **Command Gateway** ที่ตรวจคำสั่งและบันทึก Command Log |
| 13 | Persistent Save & World State | SAVE | L1 | — | 87, 107.1 (Save) | Entity ID ถาวร ไฟล์แบ่ง Chunk Schema มีเวอร์ชัน แผนที่ความเสียหายรายอาคาร Command Log สำหรับ Replay |
| 14 | Personnel, Lineage & Social Graph | PPL | L3 | A | PART 4 (10), 98 | Personnel Record Tier A/B, Story Promotion, Social Graph, Unit Lineage, Faction Chronicle |
| 15 | Military Organization — ORBAT, TO&E, Ranks, Staff | ORG | L3 | B | PART 9 (21–26) | หน่วยคือใคร สังกัดไหน TO&E ยศ ตำแหน่ง ฝ่ายอำนวยการ HQ Command Span สายการบังคับบัญชา |
| 16 | Command & Control, Signal & EW | C2 | L3 | F | 27.2, 31, 33.12 (การใช้รหัส) | Network Graph, Command Coverage, ความหน่วงของคำสั่ง, PACE, การรบกวน การหาทิศ การดักฟัง, การขนส่งข้อความและรายงาน |
| 17 | Building Capture & Conversion | CAP | L3 | D | 48–50, 54 | วงจรการยึดอาคาร ผู้ครอบครอง หน้าที่ของอาคาร Conversion Matrix สูตรเวลาดัดแปลง |
| 18 | Fortification & Base Design | BASE | L3 | D | 51–53, 55–57 | โครงสร้างอาคาร (ความเสียหายราย Combat Cell) โมดูลในตึก ป้อม กำแพง ฐาน 6 ระดับ Blueprint คิวก่อสร้าง |
| 19 | Manpower & Training | MPT | L3 | B | 58–60 | กฎหมายกำลังพลและนโยบายรับสมัคร, EligibleManpower, สายการฝึก, ระดับการฝึก, การพัฒนาผู้นำ, การบริหารกำลังพลทหาร |
| 20 | Equipment Database | EQDB | L1 | — | PART 13 (40–41) | Taxonomy, Archetype, Variant, ตระกูลกระสุน, ข้อกำหนดโรงงานและอะไหล่ |
| 21 | Medical System | MED | L3 | E | 39 | สถานะผู้บาดเจ็บ, สายการส่งกลับ CCP → Role 1–4, RTD, Class VIII |
| 22 | Intelligence | INTEL | L3 | F | 32, 10.7, 91 | **Knowledge View ของแต่ละฝ่าย**, Admiralty A–F/1–6, อายุข้อมูล, ขั้นการระบุตัวตน, การลวง |
| 23 | Mercenary Contracts | MERC | L3 | B | 9.14, 54 | สัญญา ตลาดทหารรับจ้าง การจ่ายเงิน ความภักดี การกักอาคาร Mercenary AI |
| 24 | Military Codex & Localization TH/EN | CODEX | L1 | — | 33 | คลังศัพท์ทหาร ข้อความไทย/อังกฤษ โหมดภาษาทหาร ↔ ภาษาธรรมดา ตัวสร้างรหัสสมมติ |
| 25 | Echelon Resolution & Handoff | ECH | L3 | E | PART 6 (16–17), 102 | ทะเบียนการรบ, Operational Combat Resolution, **Zone Field และแนวหน้า** (D4), เงื่อนไข Promote/Demote ของการรบ, ผู้ถือ Lease ฝั่งยุทธการ (ตัว Protocol อยู่ที่ 02) |
| 26 | Air Operations | AIR | L3 | E | 42–45, 37.4–37.6 | ชั้นรันเวย์ ลานจอด Sortie Generation ภารกิจทางอากาศ สถานะน่านฟ้า IADS |
| 27 | Naval Operations | NAV | L3 | E | 46–47 | ท่าเรือ อู่ต่อเรือและอู่แห้งตามขนาด ปฏิบัติการลำน้ำ ปิดล้อม ยกพลขึ้นบก |
| 28 | Industry & Maintenance | IND | L3 | C | 74–75, 41.2 | โรงงาน สายการผลิต กะงาน คุณภาพ Retooling และการซ่อมบำรุงทุกสิ่ง ความพร้อมใช้งาน |
| 29 | Workforce — Employment, Conscription, People Management | WORK | L3 | B | 61–63 | **สมุดบัญชีแรงงาน** ตลาดแรงงาน การจ้างงาน กลไกเกณฑ์ (ทะเบียน โควตา จับสลาก ยกเว้น หลีกเลี่ยง) Roster และการมอบหมายงาน |
| 30 | City Services & Administration | SVC | L3 | A | 67–68 | สาธารณูปโภคแบบไหลจริง บริการ รัศมีบริการ งบเมือง ผู้ว่าการ **ขีดความสามารถการบริหาร** กฎหมายระดับพื้นที่ ยุติธรรม |
| 31 | Policy Dashboard & Automation Rules | POL | L3 (มุมมองใน L5) | A | PART 24 (92–94) | ส่วนจำลองใน L3: สถานะนโยบาย กฎอัตโนมัติแบบ ถ้า–แล้ว ที่ประเมินแบบ Deterministic และบันทึกการทำงานของกฎ · มุมมองใน L5 (วาดโดย 12): Widget, KPI, แสดงผลพยากรณ์ |
| 32 | AI Aide — LLM Integration & Tool API | AIDE | L4b | — | PART 10 (28–30), 107.3 | แชท, Tool API, Persona, ระดับอำนาจ 0–3, Action Log, ความจำแคมเปญ, โหมดไม่ใช้ LLM |
| 33 | Visual Style & Color Token System | STYLE | L5 | — | PART 25 (95–97), 105.3 | Color Token, การแสดงผลตามช่วงซูม, โหมดบอดสีและ High Contrast, ชุดภาพหน้าสมมติของผู้ช่วย |
| 34 | Platform Layer — macOS / Metal / Apple Silicon | PLAT | L0 | — | PART 28 (104–108) | Metal, ARM64, Thread, Governor หน่วยความจำและความร้อน, Steam, โฮสต์เซิร์ฟเวอร์ LLM บนเครื่อง |

**นับรวม (ตามชั้นหลักของแต่ละโมดูล):** L0 = 1 · L1 = 4 · L2 = 1 · L3 = 24 (A 6 · B 4 · C 4 · D 2 · E 5 · F 3) · L4 = 2 · L5 = 2 → **รวม 34 โมดูล ไม่ซ้ำ ไม่ขาด** (31 POL นับที่ L3 ส่วนมุมมอง Dashboard วาดโดย 12 ใน L5)

> **หมายเหตุ:** ระบบที่ spec กล่าวถึงแต่ไม่มีหมายเลขโมดูลของตัวเอง ถูกวางไว้ในโมดูลที่ใกล้ที่สุดดังนี้ — Battlefield Zones และแนวหน้า (17) → 25 ECH, เหตุการณ์โลก (PART 20) History Generation (2.2) และเป้าหมายชัยชนะ (99) → 02 GSIM, Fire Support และ Air Defense ภาคพื้น (37) → 08 CMB, IADS และสถานะน่านฟ้า (44.3, 45) → 26 AIR, Faction Chronicle และ Commander's Memoir (10.6, 98) → 14 PPL (ข้อเท็จจริง) + 32 AIDE (ร้อยแก้ว), Onboarding (91) → 12 UICMD

### 1.4 เส้นแบ่งความรับผิดชอบของโมดูลที่ทับซ้อนกัน

| คู่โมดูล | ฝั่งแรกดูแล | ฝั่งที่สองดูแล | จุดส่งต่อ |
|---|---|---|---|
| 06 ECON / 28 IND | มูลค่า: เงิน ราคา ตลาด การค้า ภาษี งบ และ **ภาคปฐม** (ฟาร์ม เหมือง จุดเก็บกู้) รวมถึง Economy AI ที่จัดสรรวัตถุดิบ แรงงาน และพลังงาน | การแปรรูป: โรงงาน สายการผลิต กะงาน คุณภาพ Retooling และ **การซ่อมบำรุงทุกสิ่ง** | ลำดับความสำคัญการผลิตจาก 31 POL / 06 ECON → 28 IND ส่วนของจริงเข้าออกผ่านสมุดบัญชีสิ่งของของ 07 LOG |
| 09 CITY / 30 SVC / 04 POP | 09: เมือง "ทางกายภาพ" — ผังเมือง Zoning District โครงการก่อสร้างและฟื้นฟูฝั่งพลเรือน | 30: เมือง "ทำงาน" — โครงข่ายไหลจริง บริการ งบเมือง ผู้ว่าการ ขีดความสามารถการบริหาร กฎหมายระดับพื้นที่ / 04: "คน" — ความต้องการ ความพอใจ การย้ายถิ่น ประชากรศาสตร์ | 09 สร้างอาคารบริการ → 30 เปิดบริการและคิดงบ → 04 ได้รับบริการและเปลี่ยนความพอใจ |
| 19 MPT / 29 WORK | กฎหมายกำลังพลและนโยบายรับสมัคร (58.2) การคำนวณ EligibleManpower สายการฝึก โรงเรียน การพัฒนาผู้นำ การหมุนเวียนและลาพักของทหาร | สมุดบัญชีแรงงาน ตลาดแรงงาน การจ้างงาน กลไกเกณฑ์ (61) และ Roster/การมอบหมายงานของทุกคน (63) | 19 ส่ง "ความต้องการกำลังพลตามบทบาท" → 29 คัดคนจากแรงงานตามโควตาและข้อยกเว้น → ส่งผู้รับสมัครกลับเข้าสายการฝึกของ 19 |
| 17 CAP / 18 BASE | อาคาร "เป็นของใครและทำหน้าที่อะไร": ผู้ครอบครอง สถานะการยึด หน้าที่ การดัดแปลง | อาคาร "ทางกายภาพ": โครงสร้าง ความเสียหายราย Combat Cell โมดูลในตึก ป้อม กำแพง ฐาน คิวก่อสร้าง | 17 สั่งงานดัดแปลง → 18 จัดคิวทหารช่างและวัสดุ → เสร็จแล้ว 17 เปลี่ยนหน้าที่ของอาคาร |
| 15 ORG / 08 CMB | หน่วย "คือใคร": ตัวตน สังกัด TO&E ยศ ตำแหน่ง ฝ่ายอำนวยการ HQ | หน่วย "ทำอะไรในสนาม": ตำแหน่ง การยิง การกดดัน ขวัญระหว่างรบ Unit AI | 15 ส่งโครงสร้างและ SOP/ROE ให้ 08 ส่วน 08 ส่งความสูญเสียและเหตุการณ์กลับเป็น Event |
| 16 C2 / 22 INTEL | "ท่อ": เครือข่าย ความหน่วง การรบกวน การส่งข้อความ ข้อความดิบที่ดักได้ | "ความรู้": ประเมินความน่าเชื่อถือ หลอมข้อมูล อายุข้อมูล การระบุตัวตน Knowledge View | ข้อความที่ 16 ส่งถึงหรือดักได้ → 22 แปลงเป็นข้อมูลข่าวกรองพร้อมเกรด |
| 05 GOV / 30 SVC | ระดับกลุ่ม: การเมือง การทูต ความชอบธรรม ชื่อเสียง สถานะการควบคุมพื้นที่ (19) | ระดับพื้นที่: การบริหาร ผู้ว่าการ ขีดความสามารถการบริหาร (68) | 30 ส่งขีดความสามารถการบริหารและคุณภาพบริการ → 05 ใช้คำนวณความชอบธรรมและการเปลี่ยนสถานะควบคุม |
| 25 ECH / 08 CMB | ความละเอียดของการรบ: ตัดสินผลนอกจอ (OCR) โซน แนวหน้า การสลับระดับ | การรบละเอียดในจอภายใต้ Lease | Promote/Demote ที่ขอบ Tick (หัวข้อ 5.4) |
| 12 UICMD / 31 POL | มุมมอง แผง Radio Order Panel และ Command Gateway | Dashboard นโยบาย KPI กฎอัตโนมัติ | ทั้งสองส่งคำสั่งผ่าน Command Gateway ตัวเดียวกัน |
| 26 AIR, 27 NAV / 08 CMB | ฐาน รันเวย์ อู่ อัตราออกปฏิบัติการ น่านฟ้า IADS การวางภารกิจ | เมื่ออากาศยานหรือเรืออยู่ใน Tactical Bubble การยิงและความเสียหายจำลองโดย 08 ภายใต้ Lease เหมือนหน่วยภาคพื้น | 26/27 ส่งภารกิจ (เช่น CAS) เข้า Bubble และรับผลกลับเมื่อ Demote |
| 03 FAI / Agent AI ในโดเมน | ชุดเครื่องมือ AI กลาง Faction AI Commander AI และ AI LOD | Unit AI (08) Civilian AI (04) Convoy AI (07) Mercenary AI (23) Economy AI (06) | Agent ใช้ชุดเครื่องมือของ 03 และรับตารางความถี่การคิดจาก AI LOD ของ 03 |

## 2. แผนภาพการไหลของข้อมูลระหว่างระบบโดเมน

หัวข้อนี้ตอบว่า **อะไรไหลจากไหนไปไหน** เริ่มจากภาพรวมระดับกลุ่ม แล้วแตกเป็น 4 "สายหลัก" ตามสิ่งที่ไหล ได้แก่ คน (P) วัตถุ (M) พื้นที่และโซน (Z) คำสั่งและความรู้ (K — ใช้ K แทน C เพื่อไม่ให้สับสนกับโมดูล 16 C2) และปิดท้ายด้วยสายการปกครองและความชอบธรรม (G) ในตารางรายการลูกศร (2.6) รหัสลูกศรในแผนภาพย่อยตรงกับรหัสในตาราง

### 2.1 ภาพรวมระดับกลุ่ม

```text
                 [01 OSM] static world: roads, rails, rivers, footprints, admin cells, game tags
                                     | read-only input for every module
                                     v
+-------------------------------- A. SOCIETY & GOVERNANCE --------------------------------+
| [04 POP]  pops, needs, satisfaction, migration  [14 PPL] persons, social graph, lineage |
| [09 CITY] zoning, civil works  [30 SVC] utility flow, services, admin capacity, budget  |
| [05 GOV]  legitimacy, reputation, political control status, diplomacy, treaties         |
+-----------------------------------------------------------------------------------------+
   | manpower pool,        ^ RTD, disabled,          ^ legitimacy deltas  | power, water,
   | labor by skill        | DDR, wages,             | (services, ROE,    | admin capacity,
   v                       | war losses              | draft fairness)    v job slots, budget
+------- B. PEOPLE & FORCES --------+   workers   +------- C. ECONOMY & SUSTAINMENT ------+
| [29 WORK] labor ledger, draft     |------------>| [06 ECON] money, prices, trade, taxes |
| [19 MPT]  recruit law, training   |   wages     | [28 IND]  factories, maintenance      |
| [15 ORG]  units, ranks, HQ, staff |<------------| [07 LOG]  GOODS LEDGER, convoys       |
| [23 MERC] contracts               | equipment,  | [10 TECH] research -> [20 EQDB]       |
+-----------------------------------+ readiness   +---------------------------------------+
   | units: strength,                                  |                          |
   | cohesion, training,          supply I, III, V,    |                          | Class IV
   | ROE / SOP                    VIII, IX (push/pull) |                          | materials
   |          +----------------------------------------+                          |
   v          v                                                                   v
+------------- E. WARFARE --------------+  capture, damage +------- D. TERRITORY & STRUCTURES ------+
| [08 CMB] combat under lease           |----------------->| [17 CAP]  capture, conversion          |
| [21 MED] evacuation chain             |                  | [18 BASE] structures, forts, walls,    |
| [26 AIR] airbases, sorties, IADS      |<-----------------|           bases, runways (engineers)   |
| [27 NAV] ports, riverine, blockade    |  cover, forts,   +----------------------------------------+
+---------------------------------------+  HQ sites,                                  ^ zone factor
   ^ orders               | reports,       runways                                    |
   | (delayed)            v contacts, emissions                                       |
+------------ F. COMMAND, INFORMATION & SPACE -------------+  coverage  +-------------------------------+
| [16 C2]    network graph, coverage, delay, EW, transport |----------->| [25 ECH] ZONE FIELD,          |
| [22 INTEL] knowledge view, grading, aging, ID stages     |  threat    | frontline, engagements, OCR,  |
| [11 ORB]   satellite links, IMINT, orbital trade         |----------->| leases. Also reads: presence  |
+----------------------------------------------------------+            | (E), supply links (C),        |
                                                                        | popular support (A)           |
                                                                        +-------------------------------+
```

**ใจความของภาพรวม**

- **A → B:** สังคมให้ "คน" แก่ระบบ (Manpower Pool และแรงงานตามทักษะ) ส่วน B คืนผู้ที่กลับเข้าปฏิบัติหน้าที่ ผู้พิการ ผู้ปลดประจำการ และค่าจ้างกลับไปสู่สังคม
- **B ↔ C:** คนกลายเป็นแรงงานของโรงงานและเมือง เงินกลายเป็นค่าจ้าง และโรงงานกับงานซ่อมบำรุงส่งยุทโธปกรณ์และ **ความพร้อมใช้งาน** กลับให้หน่วย
- **C → E, D:** สมุดบัญชีสิ่งของของ 07 LOG ป้อนกองทัพด้วย Class I, III, V, VIII, IX และป้อนงานก่อสร้างด้วย Class IV ตามเสาหลัก **Logistics Is Command**
- **E ↔ D:** การรบเปลี่ยนเจ้าของและความเสียหายของอาคาร ส่วนสิ่งก่อสร้างให้ที่กำบัง ป้อม ที่ตั้ง HQ และรันเวย์แก่การรบ ตามเสาหลัก **Infrastructure Is the Prize**
- **E ↔ F:** คำสั่งลงไปถึงหน่วยด้วยความหน่วง รายงานและการแพร่คลื่นขึ้นมาด้วยความหน่วงและความคลาดเคลื่อน
- **25 ECH เป็นศูนย์กลางของพื้นที่:** รวมกำลังที่ประจำ (E) Coverage (F) เส้นทางส่งกำลัง (C) และการสนับสนุนของประชาชน (A) แล้วคำนวณ Zone Field ที่ D, C, A และ B ใช้ต่อ
- **ลูกศร "legitimacy deltas"** เข้า A จากเกือบทุกกลุ่ม เพราะความชอบธรรมเป็นผลรวมของพฤติกรรมทั้งหมดของกลุ่ม (หัวข้อ 101) ไม่ใช่ค่าที่ระบบใดระบบหนึ่งกำหนด

### 2.2 สายคน (People Spine)

คนไหลจากประชากร → แรงงาน → ทหาร → ผู้บาดเจ็บ → กลับสู่หน่วยหรือสังคม **ไม่มีจุดใดที่ทหารเกิดขึ้นเองจากความว่างเปล่า** (หัวข้อ 11, 9.14)

```text
[04 POP] Tier C pops: origin, former job, skills, loyalty tags
   |
   | P1 EligibleManpower = pop x age/health share x willingness    (derived by 19, GLOBAL)
   | P2 labor supply by skill and place                             (GLOBAL)
   v
[29 WORK] LABOR LEDGER  (one ledger for civil jobs AND military service)
   |
   +-- P3 workers by skill / shift --> [28 IND] [06 ECON] [30 SVC] [18 BASE] [07 LOG]
   |
   | P4 draftees + volunteers  (adults only; quotas, lottery, exemptions, evasion)
   v
[19 MPT] TRAINING PIPELINE: basic -> branch school -> unit -> field / combined arms
   |      uses Class V range ammo + Class III fuel from [07 LOG]; instructors from [14] / [21]
   |
   | P5 trained personnel (Untrained .. Elite, role skills)
   v
[15 ORG] UNITS: TO&E slots, ranks, appointments, HQ & staff  <-- P10 merc units under contract
   |                                                               from [23 MERC] (real pops /
   | P6 strength, cohesion, experience, SOP / ROE                  former units, never spawned)
   v
[08 CMB] tactical  or  OCR in [25 ECH] --P7 casualties by triage--> [21 MED] CCP > Role 1 > 2 > 3 > 4
                                                                      |          |          |
                    [15 ORG] <------------ P8 RTD --------------------+          |          |
                    [14 PPL] <------------ deaths, wounds, honors ---------------+          |
                    [19 MPT] / [29 WORK] <-- P9 disabled: instructors / civil labor --------+

[14 PPL] Tier A/B records + social graph
   +-- P11 modifiers --> [19] [15] [29] [22] [05]: recruit with neighbours, follow old commander,
                         desertion near home, cohesion, defection with contacts
[15 ORG] --P12 discharge / DDR--> [29 WORK]   (labor returns to the economy)
```

- **สมุดบัญชีแรงงานเล่มเดียว (D3):** คนหนึ่งคนอยู่ในช่องงานพลเรือน ในกองทัพ หรือว่างงาน ได้ทีละสถานะเท่านั้น การเกณฑ์จึง "ถอน" คนออกจากโรงงานโดยอัตโนมัติ ซึ่งเป็นแกนของ Scenario B ข้อ 10 และ Scenario D ข้อ 5
- **ข้อห้ามตายตัว:** ตัวคัดเลือกของ 29 WORK และ 19 MPT กรองเฉพาะผู้ใหญ่ ไม่มีกลไกเกณฑ์ผู้เยาว์หรือแรงงานเด็กในทุกนโยบาย (58.2, 61, 62, 101) ข้อนี้เป็น Invariant ที่ทดสอบด้วยเครื่อง (หัวข้อ 9)
- **Tier A/B/C:** การไหลข้างบนเกิดในระดับกลุ่ม (Pops) เป็นหลัก บุคคล Tier A/B ถูกติดตามรายคนใน 14 PPL และ Tier C ถูกยกระดับเป็น Tier B เมื่อเกิด Story Promotion (P13)

### 2.3 สายวัตถุ (Material Spine)

```text
SOURCES  (nothing appears from nothing)
  [06 ECON] farms, mines, wells, salvage yards, trade-in, taxes in kind
  [08 CMB]  battlefield recovery, captured depots         [11 ORB] orbital trade (rare)
      |
      | M1 goods in (by Supply Class or raw type)
      v
+=============================== [07 LOG] GOODS LEDGER =================================+
|  stock at nodes: depots, warehouses, bases, ports, airbases, hospitals                |
|  + cargo in transit: convoys, trains, river boats, airlift   + unit basic loads       |
+=======================================================================================+
   | M2 raw materials, parts         ^ M3 finished goods: Class II, V, IX, consumer goods
   |                                 |    (Class VII serial items -> [28] equipment registry;
   v                                 |     07 tracks only their location and custody)
[28 IND] production lines, shifts, quality, retooling, maintenance depots
   ^   ^   ^   |
   |   |   |   +-- M6 readiness % ------------------------> [15 ORG] [26 AIR] [27 NAV]
   |   |   +------ M7 maintenance jobs <-- wear, battle damage -- [08] [26] [27] [18]
   |   +---------- M4 power & water <-- [30 SVC] utility flow      (blackout stops lines)
   +-------------- M5 skilled workers, shifts <-- [29 WORK]
[10 TECH] --M8 blueprints, production rights--> [28 IND]
[10 TECH] --M9 new variants--> [20 EQDB] --M10 stats, ammo families, parts lists--> [08] [07] [28] [26] [27]

LEDGER --M11 push / pull Class I, III, V, VIII, IX--> units [15]/[08], air [26], naval [27], medical [21]
LEDGER --M12 Class IV--> [18 BASE] forts, walls, runways, conversions (with engineers)
LEDGER --M13 Class I + consumer goods--> [30 SVC] markets, ration centres --> [04 POP] needs
[06 ECON] prices, currency, treasury --> wages [29], contract payments [23], city budgets [30]
```

- **สมุดบัญชีสิ่งของ (D3)** ของ 07 LOG เป็นที่เดียวที่รู้ว่าของแบบเหมา (กระสุน เชื้อเพลิง อาหาร วัสดุ อะไหล่) อยู่ที่ไหน ทั้งในคลัง ระหว่างขนส่ง และติดตัวหน่วย การผลิต การใช้ การเน่าเสีย การถูกทำลาย และการค้า เป็น "รายการ" ในสมุดเล่มนี้ทั้งหมด จึงตรวจได้ว่าไม่มีของงอกขึ้นมาเอง ส่วนยุทโธปกรณ์ Class VII รายชิ้น (รถถังคันหนึ่ง ปืนใหญ่กระบอกหนึ่ง) มีเจ้าของคือ **ทะเบียนยุทโธปกรณ์ของ 28 IND** และ 07 เก็บเฉพาะตำแหน่งและผู้ครอบครองระหว่างขนส่ง จึงไม่มีผู้เขียนสองรายต่อข้อมูลเดียว (S1)
- **ภาคปฐม (06) กับการแปรรูป (28)** แยกกันตาม 1.4 ส่วน **ไฟฟ้าและน้ำ** ไม่ใช่ของในคลัง แต่เป็นการไหลในโครงข่ายของ 30 SVC (67.1) จึงเข้าโรงงานเป็น M4 แทนที่จะผ่านสมุดบัญชี
- **การผลิตอาวุธแสดงแบบนามธรรม** (101) โมดูลโรงงานเป็นหมวดงาน เช่น งานประกอบ งานเคมี ไม่มีขั้นตอนผลิตจริง

### 2.4 สายพื้นที่และโซน (Territory Spine)

```text
INPUTS (REGIONAL tick)                                 [25 ECH] ZONE FIELD per area cell
  presence, HQ radius   [15 ORG] / [08 CMB] ---\         Rear | Support | Close | Deep |
  command coverage      [16 C2] ----------------+----->  Contested | Buffer | Special (NFA, corridor)
  supply connectivity   [07 LOG] ---------------+        + frontline (clash of two ZoC)
  popular support       [04 POP] / [05 GOV] ----+        + engagement registry
  known threat          [22 INTEL] ------------/
                                                          |
     +-------------+-------------+-------------+----------+---+-------------+-------------+
     v             v             v             v              v             v             v
 [17 CAP]      [18 BASE]     [28 IND]      [04 POP]       [07 LOG]      [19 MPT]      [05 GOV]
 Z2 convert:   Z3 build:     Z4 output:    Z5 civilians:  Z6 convoys:   Z7 training:  Z8 political
 Rear full,    100% / ~75% / full /        normal /       safe /        field drills  control moves
 Support part, forts only /  reduced /     partial evac / ambush risk / in Rear or    slower in
 Close none    none          none          flee or hide   escort req.   Support only  Close / Deep
```

วงจรการยึดอาคาร (หัวข้อ 49) ผูกกับโซนและระบบอื่นดังนี้

```text
Unknown -> Scouted -> {Abandoned | Neutral | Enemy-held | Civilian-occupied} -> Contested -> Occupied
  -> Secured
  -> Claimed      needs: inside own ZoC (25)
  -> Converted    needs: Rear or Support zone (25), power (30), workforce (29), Class IV (07), engineers (15)
  -> Integrated   needs: utilities (30), supply link (07), staff (29)
lose garrison OR supply OR zone link  ==>  back to Contested  (+ sabotage risk from former owner's loyalists)
```

- **สถานภาพการรบ (โซน) แยกจากสถานะการควบคุมทางการเมือง** ตามหัวข้อ 19 โซนเป็นของ 25 ECH ส่วนสถานะการควบคุม (Unclaimed … Fully Integrated) เป็นของ 05 GOV แต่ 05 ใช้โซนเป็นปัจจัยของความเร็วในการเปลี่ยนสถานะ (Z8)
- **ตัวเลขในแผนภาพ** (100% / ~75% / เฉพาะป้อม) มาจากตารางหัวข้อ 17 และเป็นค่าตั้งต้น การปรับสมดุลความเร็วการดัดแปลงอยู่ในเอกสาร 03 (ประเด็นหัวข้อ 114)

### 2.5 สายคำสั่งและข้อมูล (Command & Information Spine)

```text
 Player via [12 UICMD] ------\
 Rules in   [31 POL] ---------+               COMMAND GATEWAY (owner 12)
 Aide via   [32 AIDE] --------+==intent==>    1 schema, then authority: rank & HQ (15), aide level 0-3 (32)
 Faction/Commander AI [03] --/               2 ROE & law-of-war check, escalation ladder approval (37.1)
                                              3 cost & feasibility: stocks (07), money (06), units (15)
                                              4 append to Command Log (13)
                                                    |
                                                    | K2 validated order becomes a message
                                                    v
 [16 C2] route over network graph: PACE path, relays, jamming, intercept risk
         delay = f(echelon gap, comms quality, distance to HQ, staff quality, jamming, training, fatigue)
                                                    |
                                                    | K3 delivered order (or lost / garbled)
                                                    v
 executors: [15]/[08] units, [07] convoys, [26] sorties, [27] ships, [18] build crews, [28] factories
                                                    |
                                                    | K4 SITREP, LACE, LOGSTAT, SPOTREP, sensor contacts, emissions
                                                    v
 [16 C2] transport upward: delay, loss, enemy direction-finding / intercept of our emissions
                                                    |
                                                    | K5 received reports, intercepts, DF bearings
                                                    v
 [22 INTEL] KNOWLEDGE VIEW per faction: grade A-F / 1-6, age, ID stage, deception flags
                                                    |
                                                    | K6 published every tick (read-only)
                                                    v
 readers: [12 UICMD] fog-of-war map, [31 POL] KPIs & rule conditions, [32 AIDE] query_state,
          [03 FAI] faction & commander planners      (own-side data = last report + its age)
```

- **ทุกผู้สั่งการใช้ประตูเดียวกัน (D7)** คำสั่งของผู้เล่น ผู้ช่วย กฎอัตโนมัติ และ AI ของทุกกลุ่ม จึงมีความหน่วงและต้นทุนแบบเดียวกัน ตรงกับกติกาความยุติธรรมข้อ 29.3 และการไหลของข้อมูลในข้อ 16.1
- **การยกระดับอำนาจการยิง** (37.1) ต้องได้รับอนุมัติจากผู้บังคับบัญชาระดับสูงขึ้น จึงตรวจในขั้นที่ 1–2 ของ Gateway โดยอ่านยศและ HQ จาก 15 ORG
- **ข้อมูลฝ่ายเราก็มีอายุ:** เมื่อ HQ ขาดการติดต่อ ตัวเลขใน Dashboard ของพื้นที่นั้นคือ "รายงานล่าสุด" พร้อมป้ายอายุข้อมูล ไม่ใช่ค่าจริงแบบสด

### 2.6 ตารางรายการลูกศร (Flow Catalogue)

ชั้นความถี่ดูความหมายในหัวข้อ 6 · "Event" = ส่งเมื่อเกิดเหตุ และเจ้าของนำไปใช้ในขั้น Commit ของ Tick ถัดไป

| ID | จาก → ถึง | สิ่งที่ไหล | ความถี่ | อ้าง spec |
|---|---|---|---|---|
| P1 | 04 POP → 19 MPT | EligibleManpower = ประชากร × สัดส่วนวัยและสุขภาพ × ความเต็มใจ (19 คำนวณ โดยอ่านจาก 04) | GLOBAL | 58.1 |
| P2 | 04 POP → 29 WORK | อุปทานแรงงานตามทักษะและที่อยู่ | GLOBAL | 62 |
| P3 | 29 WORK → 28, 06, 30, 18, 07 | คนงานตามทักษะและกะ ลงช่องงานในอาคาร | GLOBAL (จัดสรร) · REGIONAL (กะ) | 62, 74.2 |
| P4 | 29 WORK → 19 MPT | ผู้ถูกเกณฑ์และอาสาสมัคร (ผู้ใหญ่เท่านั้น ผ่านโควตา จับสลาก ข้อยกเว้น) | GLOBAL | 58.2, 61 |
| P5 | 19 MPT → 15 ORG | กำลังพลที่ฝึกแล้ว พร้อมระดับการฝึกและทักษะตามบทบาท | GLOBAL | 59 |
| P6 | 15 ORG → 08 CMB / 25 ECH | หน่วย: กำลังจริงเทียบอัตรา ความเป็นปึกแผ่น ประสบการณ์ SOP ROE | เมื่อ Promote · REGIONAL | 21–27 |
| P7 | 08 CMB / 25 ECH → 21 MED | ผู้บาดเจ็บตามการคัดแยก KIA MIA POW | TACTICAL · REGIONAL | 39.1 |
| P8 | 21 MED → 15 ORG | กำลังพลที่กลับเข้าปฏิบัติหน้าที่ (RTD) | REGIONAL | 39.4 |
| P9 | 21 MED → 19 MPT, 29 WORK | ผู้พิการถาวร: เป็นครูฝึก หรือกลับเป็นแรงงานพลเรือน | GLOBAL | 39.4, 59.3 |
| P10 | 23 MERC → 15 ORG | หน่วยทหารรับจ้างเข้าการบังคับบัญชาตามสัญญา (มาจากประชากรหรืออดีตหน่วยจริง) | Event | 9.14 |
| P11 | 14 PPL → 19, 15, 29, 22, 05 | ตัวปรับจาก Social Graph: ชวนกันสมัคร ตามผู้บังคับบัญชาเดิม หนีทัพเมื่อรบที่บ้านเกิด Cohesion การแปรพักตร์ | GLOBAL | 10.4 |
| P12 | 15 ORG → 29 WORK | ปลดประจำการและ DDR คืนแรงงานสู่เศรษฐกิจ | GLOBAL | 60, 38 |
| P13 | 08, 21, 15 → 14 PPL | เหตุการณ์เด่น → Story Promotion, Battle Honors, บาดแผล, การเสียชีวิต | Event | 10.1, 10.5 |
| P14 | 04 POP → 23 MERC | บริษัททหารรับจ้างรับคนจากประชากรจริง | GLOBAL | 9.14 |
| M1 | 06 ECON, 08 CMB, 11 ORB → 07 LOG | ของเข้าสมุดบัญชี: ผลผลิตขั้นปฐม ของกู้จากสนามรบ คลังที่ยึดได้ การค้า | REGIONAL | 70, 41.1, 81 |
| M2 | 07 LOG → 28 IND | วัตถุดิบและชิ้นส่วน | REGIONAL | 74.2 |
| M3 | 28 IND → 07 LOG | สินค้าสำเร็จแบบเหมา: Class II, V, IX และสินค้าอุปโภค เข้าสมุดบัญชีสิ่งของ · ยุทโธปกรณ์ Class VII รายชิ้นลงทะเบียนยุทโธปกรณ์ของ 28 แล้ว 07 รับเฉพาะตำแหน่งและผู้ครอบครองเพื่อขนส่ง | REGIONAL | 74 |
| M4 | 30 SVC → 28 IND | ไฟฟ้าและน้ำ (ไฟดับหยุดสายการผลิต) | REGIONAL | 67.1, 74.4 |
| M5 | 29 WORK → 28 IND | แรงงานทักษะและกะงาน | REGIONAL | 74.2 |
| M6 | 28 IND → 15, 26, 27 | อัตราความพร้อมใช้งานของยุทโธปกรณ์ | REGIONAL | 75.1 |
| M7 | 08, 26, 27, 18 → 28 IND | การสึกหรอและความเสียหายจากการรบ → งานซ่อม | Event · REGIONAL | 75 |
| M8 | 10 TECH → 28 IND | Blueprint สิทธิ์การผลิต และระดับระบบอัตโนมัติ | Event | 74.2, 77 |
| M9 | 10 TECH → 20 EQDB | Variant ใหม่ที่ผ่าน Trials | Event | 77.2 |
| M10 | 20 EQDB → 08, 07, 28, 26, 27 | ค่าสถานะ ตระกูลกระสุน รายการอะไหล่ ข้อกำหนดโรงงาน | อ่านอย่างเดียว | 40.3 |
| M11 | 07 LOG → หน่วย (15/08), 26, 27, 21 | ส่งกำลังแบบ Push/Pull: Class I, III, V, VIII, IX และ Days of Supply | REGIONAL (+ Commit ทุก LOCAL จาก Tactical) | 72 |
| M12 | 07 LOG → 18 BASE | Class IV สำหรับป้อม กำแพง รันเวย์ และการดัดแปลง | REGIONAL | 42.3, 52, 53 |
| M13 | 07 LOG → 30 SVC → 04 POP | Class I และสินค้าอุปโภคเข้าตลาดและศูนย์ปันส่วน → Food Security | REGIONAL → GLOBAL | 67.3 |
| M14 | 06 ECON → 29, 23, 30 | ค่าจ้าง ค่าสัญญา งบเมือง (สมุดบัญชีเงิน) | GLOBAL | 62, 9.14, 67.4 |
| M15 | 30 SVC → 06 ECON | ภาษีและค่าบริการ | GLOBAL | 67.4 |
| M16 | 07 LOG → 06 ECON | ต้นทุนขนส่ง → ราคา | GLOBAL | 66 |
| M17 | 06 ECON ↔ 04 POP | ราคา ↔ อุปสงค์ ราคาสูงลดความพอใจ | GLOBAL | 66 |
| Z1 | 15/08, 16, 07, 04/05, 22 → 25 ECH | ปัจจัยของโซน: กำลังที่ประจำและรัศมี HQ, Command Coverage, การเชื่อมเส้นทางส่งกำลัง, การสนับสนุนของประชาชน, ภัยคุกคามที่รู้ | REGIONAL | 17 |
| Z2 | 25 ECH → 17 CAP | ZoneFactor ของสูตรดัดแปลง | REGIONAL | 50.1–50.2 |
| Z3 | 25 ECH → 18 BASE | สิทธิ์ก่อสร้าง: 100% / ~75% / เฉพาะป้อมสนาม / ไม่ได้ | REGIONAL | 17 |
| Z4 | 25 ECH → 28 IND | ประสิทธิภาพการผลิตตามโซน | REGIONAL | 17 |
| Z5 | 25 ECH → 04 POP | สภาพชีวิตพลเรือน: ปกติ / อพยพบางส่วน / อันตราย / หนีหรือหลบซ่อน | REGIONAL | 17 |
| Z6 | 25 ECH → 07 LOG | ความเสี่ยงของขบวนรถ และต้องมีการคุ้มกันหรือไม่ | REGIONAL | 17, 72 |
| Z7 | 25 ECH → 19 MPT | สถานที่ฝึกที่ใช้ได้ | REGIONAL | 17 |
| Z8 | 25 ECH → 05 GOV | ความเร็วในการเปลี่ยนสถานะการควบคุมทางการเมือง | GLOBAL | 19 |
| Z9 | 08 CMB → 17 CAP | ผลการเข้าประจำและเคลียร์อาคาร → วงจรการยึด | TACTICAL · REGIONAL | 36, 49 |
| Z10 | 08 CMB → 18 BASE | ความเสียหายราย Combat Cell (Commit ทุก LOCAL และตอน Demote) | TACTICAL | 36.5 |
| Z11 | 17 CAP → 28, 21, 15, 07, 26, 27 | หน้าที่ใหม่ของอาคาร: โรงงาน คลัง โรงพยาบาล HQ ฐานบิน ท่าเรือ | Event | 50.3 |
| Z12 | 29, 07, 30 → 17 CAP | ปัจจัยของสูตรดัดแปลง: แรงงาน วัสดุ ไฟฟ้า | REGIONAL | 50.1 |
| Z13 | 18 BASE → 16 C2 | เสาอากาศ สถานีถ่ายทอด และความสูงอาคาร → Node ของเครือข่าย | Event | 31.3 |
| Z14 | 18 BASE → 08 CMB | ค่าที่กำบัง ป้อม กำแพงที่บังสายตา ซากปรักหักพัง | ตอน Promote | 36, 57 |
| Z15 | 18 BASE → 07 LOG, 04 POP | กำแพงหรือซากอาคารที่ปิดถนน → เส้นทางขนส่งและการเดินทางของพลเรือน | Event | 36.5, 57.3 |
| Z16 | 30 SVC → 18 BASE, 05 GOV | ขีดความสามารถการบริหาร → ขีดจำกัดการขยายฐานและเสถียรภาพการควบคุม | GLOBAL | 56.1, 68.2 |
| Z17 | 23 MERC → 17 CAP | การโอนกรรมสิทธิ์อาคารที่ทหารรับจ้างยึด หรือการกักไว้ต่อรอง | Event | 9.14, 54 |
| K1 | ผู้เล่น (12), 31, 32, 03 → Gateway (12) | เจตนาในรูปคำสั่ง | ทุก Tick | 15.3, 29.3 |
| K2 | 12 UICMD → 16 C2 | คำสั่งที่ผ่านการตรวจ → ข้อความพร้อมเส้นทางตาม PACE | ทุก Tick | 27, 31.2 |
| K3 | 16 C2 → ผู้ปฏิบัติ (15/08, 07, 26, 27, 18, 28) | คำสั่งที่ส่งถึงหลังความหน่วง (หรือหาย/ผิดเพี้ยน) | ตามชั้นของผู้รับ | 27.2 |
| K4 | ผู้ปฏิบัติ → 16 C2 | รายงาน SITREP, LACE, LOGSTAT, SPOTREP และการแพร่คลื่น (Signature) | ตามชั้นของผู้ส่ง | 33.4 |
| K5 | 16 C2 → 22 INTEL | รายงานที่ได้รับ ข้อความที่ดักได้ ทิศจากการหาทิศ | REGIONAL | 31.4, 32 |
| K6 | 22 INTEL → 12, 31, 32, 03 | Knowledge View (อ่านอย่างเดียว) | Publish ทุก Tick | 12, 29.3 |
| K7 | 16 C2 → 25 ECH | Command Coverage ในฐานะปัจจัยของโซน | REGIONAL | 31.3 |
| K8 | 15, 19, 08 → 16 C2 | ปัจจัยความหน่วง: คุณภาพฝ่ายอำนวยการ ค่าสถานะ HQ การฝึก ความเหนื่อยล้า | REGIONAL | 26, 27.2 |
| K9 | 26 AIR, 11 ORB → 22 INTEL | IMINT จากการลาดตระเวนทางอากาศและดาวเทียม | REGIONAL · GLOBAL | 32, 81 |
| K10 | 14 PPL → 22 INTEL | HUMINT จากคนรู้จักใน Social Graph (ข่าวจากผู้ลี้ภัย พ่อค้า และชุมชนย้ายไปลูกศร K18 ที่เสนอในบทที่ 3 · ปรับในรอบที่ 2) | GLOBAL | 10.4, 32 |
| K11 | 22 INTEL → 07 LOG | ภัยบนเส้นทาง → Convoy AI คิดต้นทุนความเสี่ยงในการเลือกเส้นทาง | REGIONAL | 15.2, 73 |
| K12 | 26 AIR ↔ 08 CMB | คำขอ CAS และ MEDEVAC อากาศยานที่อยู่ในพื้นที่ สถานะน่านฟ้า | REGIONAL · TACTICAL | 37.3, 44.3 |
| K13 | 11 ORB → 16 C2 | ลิงก์ดาวเทียมเมื่อติดต่อสถานีสำเร็จ | GLOBAL | 31.1, 81 |
| K14 | 22 INTEL → 14 PPL | การค้นพบที่มาของหน่วยข้าศึก (Lineage) | Event | 10.7, 32 |
| K15 | 24 CODEX → 16, 12, 32 | Prowords นามเรียกขาน รหัสสมมติประจำรอบ ข้อความไทย/อังกฤษ | อ่านอย่างเดียว · GLOBAL (หมุนรหัส) | 33 |
| G1 | 08, 23, 29, 30, 17, 21, 18 → 05 GOV | ส่วนต่างความชอบธรรมและชื่อเสียง: การละเมิดกฎการสงคราม ทหารรับจ้างทำผิด ความเป็นธรรมของการเกณฑ์ การบังคับใช้แรงงาน คุณภาพบริการ การยึดทรัพย์พลเรือน การรักษาเชลยและพลเรือน การทำลายสถานที่ประวัติศาสตร์ | Event → GLOBAL | 101, 36.5–36.6, 49, 53, 61 |
| G2 | 05 GOV → 04 POP | กฎหมาย เคอร์ฟิว สิทธิพลเมือง การปันส่วน → ความพอใจ | GLOBAL | 68.3 |
| G3 | 05 GOV, 04 POP → 19 MPT | ความชอบธรรมและการสนับสนุน → ความเต็มใจ | GLOBAL | 58.1 |
| G4 | 05 GOV → 06, 23, 26, 27 | ความสัมพันธ์ระหว่างกลุ่ม → การค้า ราคาสัญญา สิทธิใช้น่านฟ้าและท่าเรือ การปิดล้อม | GLOBAL | 14 |
| G5 | 29 WORK → 04 POP | สถานะการจ้างงาน → ความต้องการ อาชญากรรม การเข้าร่วมกลุ่มติดอาวุธ | GLOBAL | 62 |
| G6 | 30 SVC → 04 POP | บริการ สาธารณูปโภค และรัศมีบริการ → สุขภาพและความพอใจ | REGIONAL · GLOBAL | 67 |
| G7 | 04 POP → 05 GOV | ความพอใจ → การสนับสนุน การประท้วง การแยกตัว | GLOBAL | 19, 65 |
| G8 | 14 PPL → 05 GOV | Personal Ties ระหว่างบุคคลสำคัญ → ความสัมพันธ์ระหว่างกลุ่ม | GLOBAL | 14 |
| G9 | 31 POL → (ผ่าน Gateway 12) โมดูลที่เกี่ยว | นโยบาย: ภาษี ค่าจ้าง ปันส่วน กะงาน เกณฑ์และโควตา ROE เริ่มต้น เคอร์ฟิว ลำดับการผลิต การซ่อมบำรุง การก่อสร้าง พลังงาน ผู้ลี้ภัย เชลยศึก ข่าวสาร | มีผลที่ขอบ GLOBAL | 93.2 |
| G10 | 31 POL → (ผ่าน Gateway 12) | การกระทำของกฎอัตโนมัติ | REGIONAL | 93.3 |
| G11 | 02 GSIM (Forecast) → 31, 32, 03 | ผลพยากรณ์พร้อมช่วงความไม่แน่นอน | ASYNC | 30.2, 93.4 |

**ลูกศรที่เสนอเพิ่มในรอบที่ 2 (ยังไม่รวมในตารางนี้ จองรหัสไว้ไม่ให้ซ้ำ):** H1–H13 (ส่งผล History Generation), PF1–PF7 (การเลื่อนขั้นวง), X1–X9 (การไหลข้ามแดน) ใน[บทที่ 2](../chapters/02-world-lore-national-fracture.md) · Z18–Z21 (Presence จุดยึด ZoC ภาระการบริหารจากการอ้างสิทธิ์), K17–K18 (ข่าวการค้นพบ และ HUMINT จากคาราวาน ผู้ลี้ภัย ชุมชน), W1 และ W3 (ฤดูกาล และการรบจบ → PlaceHistory) ใน[บทที่ 3](../chapters/03-open-world-unclaimed-land.md) · รหัส K16 และ W2 ว่างไว้ (ร่างแรกของบทที่ 3 ซ้ำกับ H9 และ H3/H5/H6)

---

## 3. วงจรป้อนกลับ (Feedback Loops)

วงจรป้อนกลับคือสิ่งที่ทำให้โลก "ดำเนินไปเอง" ตามเสาหลักข้อ 5 และทำให้ผลการตัดสินใจ "คงอยู่และส่งผลต่อเนื่อง" ตามเสาหลักข้อ 6

- **R (Reinforcing)** — วงจรเสริมตัวเอง ยิ่งหมุนยิ่งแรง อาจเป็นวงจรดี (ได้เปรียบสะสม) หรือวงจรร้าย (เกลียวล่มสลาย) **ทุกวงจร R ต้องมีตัวเบรก** ไม่เช่นนั้นเกมจะจบเร็วหรือกลายเป็นก้อนหิมะที่ไม่มีใครหยุดได้
- **B (Balancing)** — วงจรที่ดึงระบบกลับสู่สมดุล เป็นที่มาของ "ข้อจำกัดเชิงระบบแทนเพดานตายตัว" (หัวข้อ 56.1)
- ทุกวงจรต้องมี **สัญญาณเตือน** ที่ผู้เล่นเห็นได้ก่อนสาย ผ่าน KPI และการแจ้งเตือนของ Dashboard (31 POL) และผู้ช่วย (32 AIDE) ตามเสาหลักข้อ 7 Authentic but Playable

### 3.1 ตารางสรุปวงจร

| ID | วงจร | ชนิด | โมดูลหลัก | สิ่งที่กันไม่ให้วิ่งเลยเถิด (ตัวเบรก) | สัญญาณเตือนใน Dashboard |
|---|---|---|---|---|---|
| L1 | เกลียวเกณฑ์ทหารล้น | R (วงจรร้าย) | 19, 29, 28, 06, 07, 08, 25, 04 | ข้อยกเว้นแรงงานจำเป็นเป็นพื้นขั้นต่ำ (61) · ความเต็มใจที่ลดลงทำให้เกณฑ์ได้น้อยลงเอง · Forecast ก่อนยืนยันนโยบาย (93.4) · ทางเลือกอื่น: แรงงานผู้ลี้ภัย ระบบอัตโนมัติ ทหารรับจ้าง · Utility ของ Faction AI มีตัวแปรความเสี่ยงเศรษฐกิจพัง | อัตราการเติมคนในสายการผลิต · Days of Supply ของ Class I และ V · Manpower Pool เทียบโควตา |
| L2 | บริการดี → ความชอบธรรม → คนและภาษี | R (วงจรดี) | 30, 09, 04, 05, 19, 29, 06 | ขีดความสามารถการบริหาร (68.2) · ค่าบำรุงรักษาโครงสร้างพื้นฐานโตตามขนาด (75.6) · ที่อยู่อาศัยจำกัดการเติบโต · เมืองที่รุ่งเรืองกลายเป็นเป้าของข้าศึก (เสาหลักข้อ 2) | ขีดความสามารถการบริหารที่ใช้ไป · งบเมืองขาดดุล |
| L3 | จุดสุดขีดของการรุก | B | 07, 08, 25, 15 | เกิดเองตามธรรมชาติ (20.4) · วาล์วปลด: จุดส่งกำลังส่วนหน้า Railhead การส่งทางอากาศ และการเปลี่ยน Support → Rear เมื่อมีกำลังรักษาความปลอดภัยพอ | สัญญาณเตือน Culmination · Days of Supply ของหน่วยหน้าสุด |
| L4 | ฐานใหญ่เกินกำลังบริหาร | B | 18, 30, 07, 28, 05 | ไม่มีเพดานตายตัว (เสาหลักข้อ 8) แต่ต้นทุนส่วนเพิ่มสูงขึ้นเรื่อย ๆ (56.1) · ขยายขีดจำกัดได้ด้วยศูนย์บริหาร ข้าราชการเดิม การตรวจสอบบัญชี (68.7) และ Base Network (56.2) | Admin Load · อัตราการทุจริต · Logistics Throughput ที่ใช้ไป |
| L5 | ยึดแล้วดัดแปลง (Snowball) | R (ได้เปรียบสะสม) | 17, 25, 28, 07, 08 | ต้องมีแรงงาน ไฟฟ้า Class IV และผู้เชี่ยวชาญ (50.1) · โซนเปลี่ยนช้าและต้องมีกำลังรักษาความปลอดภัย (17) · วินาศกรรมจากผู้ภักดีต่อเจ้าของเดิม (49) · ต้นทุนความชอบธรรมเมื่อยึดทรัพย์พลเรือน (49) · Game AI ฝ่ายตรงข้ามให้คะแนนสูงกับการตีโต้แหล่งอุตสาหกรรม | เวลาดัดแปลงที่เหลือ · ความเสี่ยงวินาศกรรม · กำลังรักษาความปลอดภัยต่อเซลล์ |
| L6 | ช่วงการบังคับบัญชาและ Command Coverage | B | 15, 16, 18 | Command Span 3–5 หน่วยรอง (22) · HQ เสาอากาศ และฝ่ายอำนวยการมีต้นทุนและ Signature | ความหน่วงเฉลี่ยของคำสั่ง · หน่วยที่อยู่นอก Coverage |
| L7 | แผ่คลื่น → ถูกหาทิศ | B | 16, 22, 08 | ผู้เล่นต้องแลกความเร็วของคำสั่งกับความปลอดภัย: EMCON, PACE, พลนำสาร, โทรศัพท์สนาม | Signature ของ HQ · เหตุการณ์ถูกหาทิศ |
| L8 | ชื่อเสียงพังจากการละเมิดกฎการสงคราม | R (วงจรร้าย) | 08, 05, 04, 22, 15, 23 | ทหารสารวัตรและกฎหมายทหาร (23) · ROE เริ่มต้น · ผู้ช่วยคัดค้าน (29.1) · MOOTW และ DDR เพิ่มความชอบธรรม (38) · **กฎการออกแบบ: ผลเสียต้องมากกว่าผลได้ระยะสั้นเสมอ** (101) | ความชอบธรรม · ชื่อเสียง · เหตุละเมิดล่าสุด |
| L9 | จ่ายทหารรับจ้างช้า → กักอาคาร | R (วงจรร้าย) | 23, 06, 17, 05 | การพยากรณ์เงินสด · นโยบายลำดับการจ่าย · ทางเลือกเกณฑ์และฝึกเอง · ทหารรับจ้างเสียชื่อเสียงเองเมื่อผิดสัญญา | จำนวนวันที่เงินสดพอจ่าย · สัญญาค้างจ่าย · ความภักดีของทหารรับจ้าง |
| L10 | ตลาดทหารรับจ้างมีจำกัด | B | 23, 04, 05 | บริษัทมีจำนวนจำกัดเพราะมาจากประชากรจริง (9.14) ราคาจึงขึ้นเองเมื่อความต้องการสูง | ราคาสัญญาเฉลี่ย · บริษัทว่างในตลาด |
| L11 | กินชิ้นส่วนกันเอง (Cannibalization) | R (วงจรร้าย) | 28, 07, 15 | นโยบายซ่อมบำรุง (75.5) · ความจุโรงซ่อมระดับ Depot · การผลิต Class IX · การเลือกใช้มาตรฐานเดียว (41.2) · การกู้ซาก | Readiness Rate · งานซ่อมค้าง · Days of Supply ของ Class IX |
| L12 | เวชกรรมดีรักษาทหารผ่านศึก | R (วงจรดี) | 21, 15, 19, 14, 07 | ความจุโรงพยาบาล · ระยะทางเทียบ Golden Hour · Class VIII · ความเครียดจากการรบสะสม และความจำเป็นต้องหมุนเวียนกำลัง (39.1, 60) | อัตรา RTD · ผู้ป่วยรอส่งกลับ |
| L13 | ราคาดึงสินค้า | B | 06, 07, 04, 22 | เส้นทางอันตราย ด่านเก็บค่าผ่านทาง ตลาดมืด และการปิดล้อม ทำให้กลไกนี้ช้าลงจนเกิดความขาดแคลนจริงได้ | ราคาเทียบค่าเฉลี่ยภูมิภาค |
| L14 | ว่างงาน → กองกำลังติดอาวุธ | R (วงจรร้าย) | 29, 04, 22, 25, 06 | การรับสมัครดูดซับคนว่างงาน · งานโยธาสาธารณะ · โรงเรียนอาชีวะ (62) · DDR (38) | อัตราว่างงาน · อัตราอาชญากรรม |
| L15 | ฝูงโดรนกินกระสุนของวันพรุ่งนี้ | R (วงจรร้าย) | 26, 08, 07, 18, 16 | ป้องกันแบบเป็นชั้น (ปืนราคาถูกเป็นแนวสุดท้าย) · EW ต่อต้านโดรน · กระจายและพรางที่ตั้ง · กฎอัตโนมัติแบบ Scenario D (112) | Days of Supply ของกระสุนสกัดกั้น · อัตราที่หลุดผ่าน |
| L16 | อ้างสิทธิ์กว้างเกินดูแล | B | 25, 05, 15, 07 | พื้นที่ที่ไม่ได้ดูแลหลุดกลับเป็น Unclaimed (5.3) ผู้เล่นต้องเลือกระหว่างขยายกว้างกับยึดให้แน่น | เซลล์ที่กำลังหลุด |
| L17 | Governor ของเครื่อง | B | 34, 02, 25, 32 | Governor ลดความหนาแน่นของการจำลองเมื่อร้อนหรือหน่วยความจำตึง (104, 106) โดยบันทึกการตัดสินใจไว้เพื่อ Replay และต้องไม่เปลี่ยนผลเกินกรอบ Resolution Consistency | Frame Time · Tick Overrun · สถานะความร้อนของเครื่อง |

### 3.2 แผนภาพรายวงจร

#### L1 — เกลียวเกณฑ์ทหารล้น (R)

```text
 draft quota (up) ------> civil workers (down) ------> farm & factory output (down)
        ^                                                        |
        |                                                        v
 pressure to draft (up)                         food (I) & ammo (V) stocks (down)
        ^                                                        |
        |                                                        v
 manpower base (down) <--- territory & pops (down) <--- combat power (down), defeats (up)
```

ตรงกับตัวอย่างในโจทย์ "เกณฑ์ทหาร → แรงงานลด → ผลผลิตลด → กระสุนลด → แพ้ → พื้นที่ลด → Manpower ลด" และหัวข้อ 100 "การเกณฑ์ทหารมากเกินไปทำให้เศรษฐกิจพัง" วงจรนี้เกิดจากสมุดบัญชีแรงงานเล่มเดียว (D3) โดยไม่ต้องเขียนกฎพิเศษ

#### L2 — บริการดี → ความชอบธรรม → คนและภาษี (R วงจรดี)

```text
 services & utilities (up) ------> satisfaction & health (up) ------> legitimacy (up)
        ^                                                                 |
        |                                                                 v
 city budget & staff (up) <--- tax, workers, recruits (up) <--- willingness & compliance (up)
```

นี่คือ "ชั้นการบริหารเมืองที่ส่งผลผลิต กำลังพล และความชอบธรรมขึ้นไประดับยุทธศาสตร์" ตามหัวข้อ 16 และหัวข้อ 65 ที่ว่าเมืองที่บริหารดีเป็นแหล่ง Manpower หลัก

#### L3 — จุดสุดขีดของการรุก (B)

```text
 advance distance (up) ------> supply line length & exposure (up) ------> delivered supply (down)
        ^                                                                       |
        | slows / halts                                                         v
 tempo (down) <------------ combat power (down), fatigue (up) <------- Days of Supply (down)
```

ตามหัวข้อ 20.4 ระบบต้องแสดงสัญญาณเตือนก่อนถึงจุดนี้ ค่าที่ใช้เตือนคือ Days of Supply ของหน่วยหน้าสุดและความยาวเส้นทางส่งกำลังเทียบ Throughput

#### L4 — ฐานใหญ่เกินกำลังบริหาร (B)

```text
 base size (up) ------> admin load, upkeep, power & water, throughput demand, signature (up)
        ^                                                   |
        | growth slows                                      v
 net growth rate (down) <--- efficiency (down), corruption & delays (up), enemy attention (up)
```

ทำให้ "ขยายฐานได้ไม่สิ้นสุด" (หัวข้อ 56) เป็นจริงโดยไม่มีเพดาน แต่การเติบโตช้าลงเองตามข้อจำกัดเชิงระบบ

#### L5 — ยึดแล้วดัดแปลง (R ได้เปรียบสะสม)

```text
 factories captured in Rear/Support (up) ------> conversions finished (20-60% of new-build time)
        ^                                                          |
        |                                                          v
 cells turning Support -> Rear (up) <--- front pushed out <--- equipment & ammo output (up)
```

เป็นหัวใจของเสาหลัก Infrastructure Is the Prize และเป็นวงจรที่เสี่ยงทำให้ "ยึดง่ายเกินไป" ตามประเด็นในหัวข้อ 114 ตัวเบรกทั้งหมดในตาราง 3.1 ต้องทำงานพร้อมกัน ตัวเลขสมดุลดูเอกสาร 03

#### L6 — ช่วงการบังคับบัญชาและ Command Coverage (B)

```text
 units & frontage (up) ---> HQ span exceeded, coverage gaps ---> command delay (up)
                                                                       |
        +--------------------------------------------------------------+
        v
 build HQs, staff, antennas; re-organize  (cost: officers, power, Class IV, signature)
        |
        +---> span capacity & coverage (up) ---> command delay (down)
```

ตามหัวข้อ 16.1 Command Capacity และหัวข้อ 22 Command Span การขยายกองทัพจึงต้องลงทุนใน HQ ฝ่ายอำนวยการ และเครือข่ายสื่อสารไปพร้อมกัน

#### L7 — แผ่คลื่น → ถูกหาทิศ (B)

```text
 radio traffic & HQ emissions (up) ------> enemy DF / SIGINT detection (up)
        ^                                            |
        | need for speed                             v
 EMCON, couriers, landline, move Mobile HQ <--- HQ shelled, traffic intercepted
   => emissions (down) but command delay (up)
```

มาจาก Scenario B ข้อ 6 และเหตุการณ์ในหัวข้อ 78 "ข้าศึกหาทิศสัญญาณจนพบ HQ แล้วยิงปืนใหญ่ใส่"

#### L8 — ชื่อเสียงพังจากการละเมิดกฎการสงคราม (R วงจรร้าย)

```text
 civilian harm, human shields, forced labor (up) ------> legitimacy & reputation (down)
        ^                                                          |
        |                                                          v
 harsher security ops among hostile pops <--- resistance, insurgency, defection (up), allies leave
```

กฎการสงครามเป็นระบบของเกม (หัวข้อ 101) วงจรนี้ทำให้การละเมิด "ไม่คุ้ม" เชิงระบบเสมอ เกมไม่มีกลไกทรมาน ไม่มีทหารเด็ก และไม่ยกย่องการทารุณกรรม สิ่งเหล่านี้ไม่ใช่ทางเลือกในเกมเลย วงจรนี้ครอบคลุมเฉพาะการกระทำที่เป็นไปได้ในเกม เช่น ยิงใส่อาคารที่มีพลเรือน ใช้สถานที่คุ้มครองเป็นที่ตั้งทางทหาร หรือบังคับใช้แรงงาน

#### L9 — จ่ายทหารรับจ้างช้า → กักอาคาร (R วงจรร้าย)

```text
 merc share of force (up) ------> cash burn (up) ------> late payments (up)
        ^                                                     |
        |                                                     v
        |                                            merc loyalty (down)
        |                                                     |
        |                                                     v
 security gap: hire more mercs <--- buildings held hostage, contracts broken, defections
```

มาจาก Scenario B ข้อ 5 และหัวข้อ 100 "การพึ่งทหารรับจ้างมากเกินไปทำให้ความมั่นคงขึ้นกับเงิน"

#### L10 — ตลาดทหารรับจ้างมีจำกัด (B)

```text
 demand for mercs (up) ------> free companies on market (down) ------> contract price (up)
        ^                                                                   |
        +------------------------- demand (down) <--------------------------+
```

แก้ประเด็นในหัวข้อ 114 "ทหารรับจ้างกับกฎห้ามสร้างจากความว่างเปล่า" ด้วยกลไกตลาด เพราะอุปทานเป็น Entity จริงที่มีจำนวนจำกัด

#### L11 — กินชิ้นส่วนกันเอง (R วงจรร้าย)

```text
 Class IX shortage (up) ------> cannibalize parts ------> usable fleet (down)
        ^                                                       |
        |                                                       v
 Class IX demand (up) <--- breakdowns (up) <--- wear on remaining vehicles (up)
```

ตามหัวข้อ 75.3 การถอดชิ้นส่วน "ได้ผลเร็วแต่ลดจำนวนที่ใช้ได้ในระยะยาว" และหัวข้อ 75.5 "การเลื่อนการซ่อมสะสมความเสี่ยงที่จะเสียหนักในจังหวะสำคัญ"

#### L12 — เวชกรรมดีรักษาทหารผ่านศึก (R วงจรดี)

```text
 evac chain & Class VIII (up) ------> RTD (up) ------> veterans & cohesion kept (up)
        ^                                                       |
        |                                                       v
 medical load (down) <--- casualties per fight (down) <--- experience (up)
```

ตามหัวข้อ 39.4 RTD ช่วยรักษาทหารผ่านศึกไว้ในหน่วย และเชื่อมกับเสาหลักข้อ 4 Every Soldier Comes From Somewhere

#### L13 — ราคาดึงสินค้า (B)

```text
 local shortage ------> local price (up) ------> trader convoys re-route here (Convoy AI)
        ^                                                       |
        +---------------- shortage (down) <--- supply (up) <----+
```

กลไกตลาดที่ Convoy AI ใช้ตัดสินใจเอง (หัวข้อ 73) ทำให้กลุ่มขนส่งอิสระมีบทบาทจริงในโลก

#### L14 — ว่างงาน → กองกำลังติดอาวุธ (R วงจรร้าย)

```text
 unemployment (up) ------> crime, joining armed groups (up) ------> insecurity (up)
        ^                                                                |
        +---- jobs (down) <--- business & commuting (down) <-------------+
```

ตามหัวข้อ 62 "การว่างงานเพิ่มอาชญากรรม ความไม่สงบ และทำให้คนเข้าร่วมกองกำลังติดอาวุธเพราะความจำเป็น"

#### L15 — ฝูงโดรนกินกระสุนของวันพรุ่งนี้ (R วงจรร้าย)

```text
 cheap drone raids (up) ------> interceptor stock, Class V (down) ------> coverage gaps (up)
        ^                                                                     |
        |                                                                     v
 enemy raids more <--- depots & port hit: tomorrow's ammo (down) <--- more leakers get through
```

จากคลิป Steel Umbrella "ท่าเรือคือกระสุนสำรองของวันพรุ่งนี้" (0.5) และ Scenario D ข้อ 6–7

#### L16 — อ้างสิทธิ์กว้างเกินดูแล (B)

```text
 claimed area (up) ------> patrol, garrison, supply demand (up) ------> unattended cells (up)
        ^                                                                      |
        +---------- claimed area (down) <--- decay to Unclaimed / rivals take <+
```

ตามหัวข้อ 5.3 พื้นที่ที่อ้างสิทธิ์แล้วแต่ไม่ได้ดูแลจะหลุดกลับเป็น Unclaimed หรือถูกกลุ่มอื่นแย่ง

#### L17 — Governor ของเครื่อง (B)

```text
 sim density: tactical bubbles, live units (up) ------> CPU/GPU load & heat on M4 Pro (up)
        ^                                                        |
        |                                                        v
 sim density (down) <--- governor: fewer bubbles, smaller LOD radius, speed cap, local LLM paused
```

วงจรเชิงเทคนิคที่ต้องมีเพราะแล็ปท็อปมีข้อจำกัดด้านความร้อนเมื่อเล่นต่อเนื่อง 30–60 นาที (หัวข้อ 104) Governor อยู่ใน 34 PLAT แต่การตัดสินใจลดระดับเป็นของ 02 GSIM และ 25 ECH เพื่อให้ Deterministic และบันทึกได้

---

## 4. ผลกระทบข้ามระบบ (Cross-impact Matrix) — งานข้อ 113.3

### 4.1 กลุ่มระบบที่ใช้ในตาราง

ตารางใช้ 15 กลุ่มระบบโดเมน โมดูลชั้น Platform, Data, Core, AI และ UI (01, 02, 03, 12, 13, 24, 32, 33, 34) และ 31 POL (ซึ่งอยู่ใน L3 แต่ส่งผลผ่านค่านโยบายและคำสั่งที่กฎออก) ไม่อยู่ในตาราง เพราะส่งผลผ่านกลุ่มอื่นเสมอ ผลของโมดูลเหล่านี้อธิบายในหัวข้อ 5–8

| รหัส | กลุ่ม | โมดูล |
|---|---|---|
| POP | ประชากรและการตั้งถิ่นฐาน | 04 |
| PPL | บุคคล Lineage และ Social Graph | 14 |
| GOV | การปกครอง การทูต ความชอบธรรม | 05 |
| CITY | เมืองและบริการ | 09, 30 |
| WORK | แรงงาน การเกณฑ์ การฝึก | 29, 19 |
| ECON | เศรษฐกิจและการค้า | 06 |
| IND | อุตสาหกรรมและซ่อมบำรุง | 28 |
| LOG | ส่งกำลังและขนส่ง | 07 |
| TECH | เทคโนโลยีและยุทโธปกรณ์ | 10, 20 |
| TERR | ยึดอาคาร ฐาน และโซน | 17, 18, 25 (ส่วนโซน) |
| MIL | การจัดหน่วย การรบ การแพทย์ | 15, 08, 21 |
| A&N | อากาศและเรือ | 26, 27 |
| C2I | สื่อสาร EW ข่าวกรอง | 16, 22 |
| MERC | ทหารรับจ้าง | 23 |
| ORB | อวกาศ | 11 |

### 4.2 ตาราง (แถว = ระบบต้นเหตุ, คอลัมน์ = ระบบที่ได้รับผล)

**ตัวหนา** = การเชื่อมที่แรงที่สุด ใช้จัดลำดับการทดสอบการรวมระบบในข้อ 4.3 · "—" = ผลน้อยหรือไม่มีโดยตรง · ■ = ตัวเอง

| แถว → คอลัมน์ | POP | PPL | GOV | CITY | WORK | ECON | IND | LOG | TECH | TERR | MIL | A&N | C2I | MERC | ORB |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **POP** | ■ | ที่มาของบุคคล Tier C → B | แรงสนับสนุน ประท้วง แยกตัว | อุปสงค์บริการ ที่อยู่ | แรงงาน + Manpower | ผู้บริโภค ผู้เสียภาษี | — (ผ่าน WORK) | อุปสงค์ Class I น้ำ | ผู้เชี่ยวชาญ | ผู้อาศัยในอาคาร → ข้อจำกัดการยึด, การสนับสนุน → ZoC | พลเรือนในเขตรบ → ROE | — | HUMINT ข่าวลือ | แหล่งคนของ PMC | — |
| **PPL** | Story Promotion ครอบครัว | ■ | Personal Ties → Trust | ฝีมือผู้ว่าการ | ชวนกันสมัคร ทักษะเฉพาะ | คู่ค้า เจ้าหนี้ | วิศวกรอาวุโส | คุณภาพ S4 | ผู้เชี่ยวชาญ = ความรู้ | เจรจายึดผ่านคนรู้จัก | ขวัญ Cohesion หนีทัพ ฝีมือผู้บังคับบัญชา | ทักษะนักบินและลูกเรือ | แหล่งข่าว ผู้แปรพักตร์ | เคยร่วมรบหรือเคยรบกัน | ผู้รู้ช่องทางติดต่อ |
| **GOV** | กฎหมาย เคอร์ฟิว ปันส่วน | แต่งตั้ง ก๊ก เทียบยศ | ■ | ระดับอิสระของพื้นที่ งบ | **กฎหมายเกณฑ์ ความเต็มใจ** | ภาษี การค้า คว่ำบาตร | ลำดับผลิต สงคราม/พลเรือน | สิทธิผ่านด่าน ระเบียง | แบ่งปันเทคโนโลยีกับพันธมิตร | สถานะควบคุม การผนวก | War Goals ROE กำลังพันธมิตร | สิทธิน่านฟ้าและท่าเรือ | แลกเปลี่ยนข่าวกรอง | ชื่อเสียงผู้ว่าจ้าง → ราคา | ช่องทางการทูต |
| **CITY** | บริการ → สุขภาพ ความพอใจ ย้ายถิ่น | — | **ขีดความสามารถบริหาร → ความชอบธรรม** | ■ | ช่องงาน โรงเรียนอาชีวะ | งบเมือง ภาษี ค่าบริการ | **ไฟฟ้าและน้ำป้อนสายผลิต** | ถนน สะพาน ขนส่งสาธารณะ | มหาวิทยาลัย → Research Points | ไฟฟ้าและน้ำให้ฐาน เขตทหาร | โรงพยาบาล Role 3–4 เคอร์ฟิว | ท่าเรือและสนามบินพลเรือน | โครงข่ายพลเรือนที่กู้ได้ | — | — |
| **WORK** | ดึงคนออก, ว่างงาน → อาชญากรรม | เส้นทางอาชีพ → Tier B | เกณฑ์ไม่เป็นธรรม → ชอบธรรมลด | คนทำงานบริการ | ■ | ค่าจ้าง ↔ ผลผลิต | **แรงงานทักษะ กะงาน** | คนขับ คนงานคลัง | นักวิจัย ฝึกหลักนิยมใหม่ | แรงงานก่อสร้างและดัดแปลง | **ทหารใหม่ ระดับการฝึก การทดแทน** | นักบิน ช่าง ลูกเรือ | พลวิทยุ นักวิเคราะห์ | ทางเลือกแทนการเกณฑ์ | — |
| **ECON** | ราคาอาหาร → ความพอใจ | เงินเดือนตรงเวลา → ความภักดี | รายได้ หนี้ Trade Dependence | งบบริการ | ค่าจ้าง → อุปทานแรงงาน | ■ | วัตถุดิบ คำสั่งผลิต | สินค้าค้าขายที่ต้องขนส่ง | งบวิจัย ซื้อสิทธิ์ | ค่าชดเชย ซื้อหรือเช่าอาคาร | — (ผ่าน LOG และ IND) | ค่าเชื้อเพลิงอากาศยาน | ซื้อข่าวจากพ่อค้า | **ค่าจ้างตามสัญญา** | ซื้อขายสินค้าหายาก |
| **IND** | สินค้าอุปโภคกับสินค้าสงคราม มลพิษ | อุบัติเหตุ ล่วงเวลา | นัดหยุดงาน → เสถียรภาพ | ใช้ไฟและน้ำ มลพิษ | อุปสงค์แรงงานทักษะ | ผลผลิต → ราคา | ■ | ของใหม่เข้าคลัง ต้องการวัตถุดิบ | ประสบการณ์ผลิต → ความน่าเชื่อถือ | ซ่อมอาคารและสะพาน | **ยุทโธปกรณ์ + Readiness** | ซ่อมอากาศยานและเรือ → Sortie | ผลิตวิทยุและอุปกรณ์ EW | — | — |
| **LOG** | Food Security ราคา | — | เส้นทาง = การควบคุมพื้นที่ (หัวข้อ 3) | ของเข้าตลาดและศูนย์ปันส่วน | การเดินทางไปทำงาน | ต้นทุนขนส่ง → ราคา | คอขวดวัตถุดิบ | ■ | — | **การเชื่อมเส้นทาง → โซน, Class IV** | **Days of Supply → อำนาจรบ, Culmination** | เชื้อเพลิงและอาวุธ → Sortie | Signature ของขบวนรถ | งานคุ้มกันขบวน | — |
| **TECH** | การแพทย์และเกษตรดีขึ้น | ผู้เชี่ยวชาญเป็นเป้าแย่งตัว | Tech Gap → อำนาจต่อรอง | สาธารณูปโภคขั้นสูง | ระบบอัตโนมัติ → คนน้อยลง ช่างมากขึ้น | สินค้าใหม่ | Blueprint, Retool | **รุ่นและตระกูลกระสุนหลากหลาย → ภาระ** | ■ | โมดูลอาคารและกำแพงขั้นสูง | ค่าสถานะ Variant หลักนิยม | ปลดล็อกอากาศยานและเรือ | EW โดรน การเข้ารหัส | — | ติดต่ออวกาศ (Tier 5–6) |
| **TERR** | ยึดทรัพย์ กำแพงล้อมย่าน → ความพอใจลด | เจ้าหน้าที่เดิมทำงานต่อ | อาคารสำคัญ → การควบคุม, ใช้โรงเรียนหรือศาสนสถาน → ชอบธรรมลด | District ทหาร–พลเรือน | ช่องงานใหม่ | ตลาดและคลังใหม่ | **โรงงานดัดแปลง (20–60% ของเวลาสร้างใหม่)** | คลัง Railhead, กำแพงปิดถนน | ห้องแล็บและมหาวิทยาลัยที่ยึดได้ | ■ | ที่มั่น ป้อม, โซนจำกัดสิ่งที่ทำได้ | รันเวย์ Helipad ท่าเรือ | เสาบนตึกสูง HQ ในอาคาร | อาคารที่ถูกกักไว้ | สถานีภาคพื้นดาวเทียม |
| **MIL** | **ความสูญเสียพลเรือน ผู้ลี้ภัย UXO** | Battle Honors บาดแผล การเสียชีวิต | **ชัยชนะหรืออาชญากรรมสงคราม** | ไฟดับ ท่อแตก อาคารพัง | ดูดคน, ผู้พิการกลับมา | ยึดคลังหรือถูกยึด | งานซ่อม, ทำลายโรงงาน | อัตราใช้กระสุนและน้ำมัน, ตัดเส้นทาง | ซากยุทโธปกรณ์ → Salvage, Reverse Engineering | **ยึดหรือเสียอาคาร ความเสียหายราย Cell** | ■ | ขอ CAS และ MEDEVAC, AD ภาคพื้น | รายงาน Signature | ร่วมรบ ความสูญเสียของ PMC | — |
| **A&N** | โจมตีทางอากาศ → พลเรือน, ปราบโจรสลัด | นักบินตก → CSAR หรือเชลย | การปิดล้อม → การทูต | ท่าเรือเปิดการค้า | — | การค้าทางทะเลหรือการปิดล้อม | Strategic Strike, งานอู่ซ่อม | Airlift เรือลำน้ำ Interdiction | — | ฐานบินและท่าเรือ (ฐานระดับ 4–6) | **CAS สถานะน่านฟ้า** | ■ | IMINT AEW | นักบินรับจ้าง | — |
| **C2I** | PSYOP ข่าวสาร → ขวัญ | ค้นพบที่มาของข้าศึก | ข่าวกรองหนุนการเจรจา | — | — | ข่าวตลาด | — | เส้นทางเสี่ยง → Convoy AI, การควบคุมขบวน | เอกสารและแบบที่ยึดได้ | Coverage → ขยาย ZoC | **Command Delay, Fog of War, Call for Fire** | IADS, Data Link โดรน | ■ | ข่าวการถูกซื้อตัว | ต้องมีเครือข่ายจึงติดต่อสถานีได้ |
| **MERC** | วินัยต่ำ → พลเรือนเดือดร้อน | ผู้เชี่ยวชาญและครูฝึกรับจ้าง | ทำผิด ROE → ชื่อเสียงผู้ว่าจ้างเสีย | — | ลดแรงกดดันการเกณฑ์ | เงินสดไหลออก | — | คุ้มกันขบวน | — | ยึดแทนหรือกักอาคาร | กำลังเสริมทันที | เช่าอากาศยานพร้อมลูกเรือ | เสี่ยงรั่วข้อมูล | ■ | — |
| **ORB** | — | — | อำนาจภายนอก พันธมิตร | ข้อมูลภูมิอากาศ | — | สินค้าหายาก ราคาสูง | วัสดุขั้นสูง | — | เทคโนโลยี ข้อมูลวิศวกรรม | — | ขีดความสามารถจากวงโคจร (จำกัดมาก) | — | ดาวเทียมสื่อสาร IMINT | — | ■ |

**ข้อสังเกตจากตาราง**

- **MIL และ LOG เป็นต้นเหตุที่กระทบกว้างที่สุด** สงครามกระทบเศรษฐกิจและประชาชนผ่านความสูญเสียพลเรือน ความเสียหายของโครงสร้างพื้นฐาน การดูดแรงงาน และการเปลี่ยนเจ้าของอาคาร ซึ่งตอบคำถามตัวอย่างในงานข้อ 113.3 โดยตรง
- **GOV เป็นผู้รับที่กว้างที่สุด** (คอลัมน์ GOV มีผลจากเกือบทุกแถว) จึงต้องออกแบบความชอบธรรมเป็นสมุดบัญชีที่รับ Event จากหลายแหล่ง (G1) และแสดงที่มาให้ผู้เล่นเห็นใน Dashboard ว่าความชอบธรรมขึ้นลงเพราะอะไร
- **WORK เป็นจุดตัดของเศรษฐกิจกับกองทัพ** ทุกคนที่ไปเป็นทหารหายไปจากโรงงาน ตามหัวข้อ 62
- **ORB มีผลน้อยในระดับ National Fracture** ตามหัวข้อ 79 ซึ่งตรงกับการวางให้ระบบอวกาศเป็นส่วนขยายในระยะหลัง

### 4.3 การเชื่อมที่แรงที่สุด → ลำดับการทดสอบการรวมระบบ

| ลำดับ | คู่ที่เชื่อม | ทำไมต้องทดสอบก่อน | สถานการณ์ทดสอบขั้นต่ำ |
|---|---|---|---|
| 1 | MIL → TERR, TERR → IND | หัวใจของเสาหลัก Infrastructure Is the Prize และวงจร L5 | ยึดโกดังแล้วดัดแปลงเป็นคลัง (ขอบเขต Prototype ในหัวข้อ 103) |
| 2 | LOG → MIL | เสาหลัก Logistics Is Command และวงจร L3 | หมวดรบต่อเนื่องจนกระสุนหมด แล้วได้รับการส่งกำลังแบบ Pull |
| 3 | C2I → MIL | Command Delay ต้องรู้สึกได้ตั้งแต่ Prototype (Radio Order Panel) | สั่งการผ่านเสาอากาศที่ถูกทำลาย แล้วสลับช่องทางตาม PACE |
| 4 | WORK → IND และ WORK → MIL | สมุดบัญชีแรงงานเล่มเดียว วงจร L1 | เพิ่มโควตาเกณฑ์แล้วดูสายการผลิตขาดคน |
| 5 | CITY → IND, CITY → GOV | ไฟฟ้าหยุดโรงงาน บริการกำหนดความชอบธรรม วงจร L2 | ไฟดับเป็นพื้นที่ จัดลำดับให้โรงพยาบาลก่อน |
| 6 | IND → MIL | Readiness และการซ่อมบำรุง วงจร L11 | ยานเกราะหมวดหนึ่งใช้งานหนักโดยไม่มี Class IX |
| 7 | GOV → WORK, MIL → GOV | ความชอบธรรมเป็นตัวคูณของความเต็มใจ วงจร L8 | ยิงใส่อาคารที่มีพลเรือนแล้ววัดผลต่อผู้สมัคร |
| 8 | MIL → POP | ผลของสงครามต่อประชาชน | ผู้ลี้ภัยไหลเข้าเมืองข้างเคียงและกดดันบริการ |
| 9 | LOG → TERR | การเชื่อมเส้นทางเป็นปัจจัยของโซน | ตัดเส้นทางส่งกำลังของอาคารที่ยึดแล้วจนกลับเป็น Contested |
| 10 | ECON → MERC | วงจร L9 | จ่ายค่าจ้างช้าหนึ่งรอบ (Scenario B ข้อ 5) |
| 11 | A&N → MIL | CAS และสถานะน่านฟ้า | ขอ CAS ผ่าน Support Request Panel ภายใต้ Danger Close |
| 12 | TECH → LOG | ความหลากหลายของรุ่นเพิ่มภาระ | ใช้ปืนสองตระกูลกระสุนในกองพันเดียว |

### 4.4 ตัวอย่างไล่ผลกระทบข้ามระบบ (Causal Traces)

เส้นทางเหล่านี้ใช้เป็น **สถานการณ์ทดสอบการรวมระบบ** และเป็นตัวอย่างว่า "สถานการณ์ทั้งหมดต้องเกิดจากการโต้ตอบของระบบต่าง ๆ โดยไม่มีสคริปต์ตายตัว" (หัวข้อ 112 ท้าย)

**T1 — สะพานหลักขาด** (ตัวอย่างหัวข้อ 66 และ Scenario A)

```text
[08 CMB] shell hits bridge (TACTICAL) -> [18 BASE] bridge cells collapse, committed -> [07 LOG] route overlay: bridge closed
 -> Convoy AI re-routes, longer trip (REGIONAL) -> [06 ECON] transport cost up -> food price up (GLOBAL)
 -> [04 POP] satisfaction down -> [05 GOV] legitimacy down -> [19 MPT] willingness down -> fewer recruits (days later)
 levers: repair (18 + Class IV from 07 + engineers from 15) | alternate route (07) | deal with the convoy faction (05, 06)
```

**T2 — โรงงานริมถนนวงแหวน** (Scenario B)

```text
[08 CMB] ANVIL-1 occupies factory -> [17 CAP] Occupied -> Secured, but zone = Close (25) -> conversion blocked
 -> [18 BASE] antenna on a tall building -> [16 C2] coverage up -> [25 ECH] cells move Close -> Support (+ merc guard, 23)
 -> [17 CAP] conversion allowed (20-60% of new-build time) -> [28 IND] repair & assembly line needs skilled workers
 -> [29 WORK] same labor ledger as the draft -> player chooses: draft the workers (loop L1 risk) or keep the line staffed
```

**T3 — ข้าศึกหาทิศจนพบ HQ ส่วนหน้า** (Scenario B ข้อ 6 และหัวข้อ 78)

```text
[16 C2] our HQ emissions (signature) -> enemy [22 INTEL] DF bearing -> enemy [03 FAI] commander plans a fire mission
 -> enemy Gateway (12) -> mortar strike resolved in [08 CMB] -> [15 ORG] HQ damaged -> [16 C2] delay up, coverage gap
 -> subordinate units follow last orders / SOP / autonomy level (26) -> player moves the Mobile HQ, switches PACE (loop L7)
```

**T4 — ฝูงโดรนกับคลังเชื้อเพลิง** (Scenario D)

```text
[26 AIR] coastal radar / IADS detects the swarm -> layered defense in [08 CMB] spends Class V interceptors ([07 LOG])
 -> leakers hit a fuel depot -> [18 BASE] depot damaged, [07 LOG] Class III stock down -> Days of Supply below threshold
 -> [31 POL] rule fires: raise refinery priority (28) + dispatch a convoy (07) -> [03 FAI] staff planner re-scores plan B
 -> [32 AIDE] reports in its persona's voice and drafts a new rule "radar sees swarm -> disperse fuel trucks" (player activates)
```

**T5 — พยากรณ์ก่อนเปลี่ยนนโยบาย** (Scenario D ข้อ 5 และหัวข้อ 93.4)

```text
player edits the draft quota in [31 POL] -> [02 GSIM] Forecast fork on the knowledge snapshot
 -> result: [28 IND] ammo line loses its night shift, satisfaction -Y within 30 days (with an uncertainty band)
 -> player instead hires refugee labor ([29 WORK], [04 POP]) and opens a vocational school ([09 CITY] builds, [30 SVC] runs)
 -> labor gap closes over weeks; legitimacy not hit by the draft
```

---

## 5. State ร่วมและความเป็นเจ้าของข้อมูล (Shared State & Ownership)

### 5.1 หลักการ

| รหัส | หลักการ | ความหมายในทางปฏิบัติ |
|---|---|---|
| S1 | **Single Writer** | ข้อมูลแต่ละส่วน (Component) มีโมดูลเจ้าของเดียวที่เขียนได้ |
| S2 | **Event ถึงเจ้าของ** | โมดูลอื่นที่อยากเปลี่ยนค่า ส่ง Event หรือคำขอ เจ้าของนำไปใช้ในขั้น Commit ตามลำดับคงที่ (Tick → ขั้น → หมายเลขโมดูลผู้ส่ง → ลำดับ) |
| S3 | **อ่านจาก Snapshot ที่เผยแพร่แล้ว** | ทุกโมดูลอ่านสถานะ ณ ขอบ Tick ล่าสุด ไม่อ่านค่าที่กำลังถูกเขียน ผลจึงไม่ขึ้นกับลำดับการรันของ Thread |
| S4 | **ข้อมูลที่คำนวณได้ไม่ใช่ความจริงชุดที่สอง** | Zone Field, CityIndex, EligibleManpower, Readiness, Command Coverage เป็นค่าคำนวณ เจ้าของคือโมดูลที่คำนวณ และคำนวณใหม่จากแหล่งได้เสมอ (เก็บใน Save ได้ในฐานะ Cache ที่มีเวอร์ชัน) |
| S5 | **ID ถาวรเดียวทุกระดับซูม** | 13 SAVE ออก ID ให้ทุก Entity หน่วยหนึ่งใช้ ID เดียวตั้งแต่ Operational Counter ถึงทหารรายคน **Counter คือมุมมองของหน่วยเดิม ไม่ใช่ Entity แยก** ตาม Seamless Zoom ในหัวข้อ 16.1 |
| S6 | **ความจริงแยกจากความรู้** (D6) | ความจริงอยู่ในโมดูลโดเมน ความรู้ของแต่ละฝ่ายอยู่ใน 22 INTEL ผู้ตัดสินใจทุกตัวอ่านความรู้ |
| S7 | **Lease สำหรับข้อมูลที่เปลี่ยนเร็ว** (D5) | ข้อมูลการรบมีผู้ถือสิทธิ์เขียนได้ครั้งละหนึ่งตัวคำนวณ ส่งต่อที่ขอบ Tick |
| S8 | **ข้อมูลคงที่แยกจากข้อมูลที่เปลี่ยน** (D11) | Map Tile ไม่ถูกแก้ ความเสียหาย การควบคุม โซน และสิ่งก่อสร้างเป็น Overlay ที่บันทึกเป็นส่วนต่าง ป้องกัน "สิ่งปลูกสร้างหรือยานพาหนะซ้ำจากการโหลดพื้นที่ใหม่" (หัวข้อ 87) |

### 5.2 ตารางเจ้าของ Entity หลัก

| Entity | เจ้าของ (Source of Truth) | ข้อมูลส่วนที่โมดูลอื่นเป็นเจ้าของ | ผู้ส่ง Event หรือคำขอหลัก | ผู้อ่านหลัก |
|---|---|---|---|---|
| Map Tile (เรขาคณิตคงที่และแท็กเชิงเกม) | 01 OSM | — (ไม่แก้ระหว่างเล่น) | — | ทุกโมดูล, ฝั่งภาพ 12/33 |
| Area Cell (Region → Province → District → Sub-district → Locality) | 01 OSM (รูปทรง ลำดับชั้น) | ControlStatus: 05 · ZoneStatus: 25 · PopAggregate: 04 · CityIndex: 30 (ค่าคำนวณ) · Airspace Status: 26 | 08, 15, 16, 07, 22 (ผ่าน Z1) | 31, 12, 03, 32 |
| Faction | 05 GOV (ตัวตน รูปแบบการปกครอง ความชอบธรรม ชื่อเสียง ความสัมพันธ์) | Goals/Plans: 03 · Treasury: 06 · TechState: 10 · Policies/Rules: 31 · Knowledge: 22 | หลายโมดูลส่งส่วนต่างความชอบธรรม (G1) | ทุกโมดูล |
| Person (Tier A/B) | 14 PPL (Personnel Record, Traits, ความสัมพันธ์, Lineage) | Rank/Appointment: 15 · Job/Assignment: 29 · Health: 21 · Training: 19 | 08, 21, 15 (P13) | 12 (Dossier), 32, 03, 05 |
| Pop (Tier C) | 04 POP (ขนาด แท็กที่มา ความต้องการ ความพอใจ การย้ายถิ่น) | LaborAllocation: 29 | 30, 05, 25, 29, 08 | 19, 29, 06, 30, 05 |
| Unit / Formation (ชุดยิง → กลุ่มกองทัพ รวมเรือและฝูงบิน) | 15 ORG (ตัวตน TO&E สังกัด HQ ฝ่ายอำนวยการ สายการบังคับบัญชา ผู้ถือสิทธิ์บังคับบัญชา) | TacticalState: 08 หรือ 25 ตาม Lease · OnHandSupply: 07 (Lease ระหว่างรบ) · Experience: 19 · Readiness: คำนวณจาก 28 · Lineage Log: 14 | 19, 21, 23, Gateway | 08, 25, 16, 12, 03 |
| Equipment Item (Class VII รายชิ้นที่มีประวัติ) | 28 IND (ทะเบียนยุทโธปกรณ์: ID ที่มา สภาพ การสึกหรอ ความน่าเชื่อถือ) | Definition: 20 · Assigned-to: 15 · ตำแหน่งและผู้ครอบครองระหว่างขนส่ง: 07 · ความเสียหายระหว่างรบ: 08 (Lease) · History: 14 | 08, 26, 27 (M7) | 15, 08, 31 |
| Building | 01 OSM (รูปทรง แท็ก) | BuildingState (ผู้ครอบครอง วงจรการยึด หน้าที่ การดัดแปลง): 17 · Structure (ความเสียหายราย Cell โมดูล ป้อม): 18 (Lease ให้ 08 ระหว่างรบ) · Job Slots: 29 · Utility Hookup: 30 · ผู้อาศัยพลเรือน: 04 | 08, 23, 29 | 08, 12, 33, 22 |
| Base / Compound | 18 BASE (ระดับฐาน ผัง Blueprint แนวรั้ว) | Zone: 25 · Admin Load: 30 (ค่าคำนวณ) | 17, 31 | 31 (Base Overview), 03 |
| District ฝั่งพลเรือน | 09 CITY | Services: 30 | 31 | 30, 04 |
| Wall / Fortification / Antenna Structure | 18 BASE | สถานะ Node ในเครือข่าย: 16 | 08 (ความเสียหาย) | 08, 16, 07 |
| Supply Stock (คลังรายจุดราย Class) + Cargo | 07 LOG (สมุดบัญชีสิ่งของ) | — | 06, 28, 08, 30, 21 | 31, 03, 32, 08 |
| Convoy / Shipment | 07 LOG | หน่วยคุ้มกัน: 15 | Gateway | 12, 22 (ข้าศึกตรวจพบ) |
| Production Line | 28 IND | ตัวอาคาร: 17/18 · คนงาน: 29 | Gateway (ลำดับความสำคัญจาก 31), 10 | 31, 06 |
| เงิน: Treasury ราคา สกุลเงิน หนี้ | 06 ECON (สมุดบัญชีเงิน) | City Budget: 30 | 29, 23, 30, 05 | 31, 03 |
| Labor Allocation | 29 WORK (สมุดบัญชีแรงงาน) | — | 19, 28, 30, 18 | 06, 19, 31 |
| Service Contract (ทหารรับจ้าง) | 23 MERC | การจ่ายเงิน: 06 · การครอบครองอาคาร: 17 | Gateway, 06 | 05, 31 |
| Trade Agreement | 06 ECON | — | Gateway | 05, 07 |
| Treaty / Ceasefire / Alliance | 05 GOV | — | Gateway | 25 (เขตพิเศษ), 03 |
| Order | 12 UICMD (Order Ledger ใน Gateway) | สถานะการส่ง: 16 · สถานะการปฏิบัติ: ผู้ปฏิบัติส่งเป็น Event | 16, 08, 07, 26, 27 | 12 (Radio Log), 32 (Action Log) |
| Message / Report / Transmission | 16 C2 | เนื้อหามาจากผู้ส่ง | 08, 15, 07, 26, 27 | 22, 12 (Radio Log) |
| Comm Network (Node, Link, Coverage Field, สถานะสมุดรหัส) | 16 C2 | โครงสร้างเสา: 18 · ข้อความรหัสสมมติ: 24 | 18, 08 | 25, 12, 26 |
| Knowledge (Contacts, Intel Items, ขั้นการระบุตัวตน) ของแต่ละฝ่าย | 22 INTEL | — | 16, เซนเซอร์ใน 08, 26, 11, 14 | 12, 31, 32, 03 |
| Engagement / Frontline / Zone Field | 25 ECH | — | 08, 15, 16, 07, 04, 05, 22 | 17, 18, 28, 04, 07, 19, 05, 12 |
| Casualty / Patient | 21 MED | — | 08, 25 | 15, 14, 31 |
| Airbase / Runway Class / Sortie / Airspace | 26 AIR | โครงสร้างรันเวย์: 18 · อากาศยานรายลำ: 28 · นักบิน: 14 | Gateway, 18, 08 | 08, 22, 31 |
| Port / Shipyard / Naval Task | 27 NAV | โครงสร้างท่าและอู่: 18 · เรือรายลำ: 28 · ลูกเรือ: 14 | Gateway, 18 | 07, 06, 31 |
| Tech Project / Blueprint | 10 TECH | — | Gateway, 14 (ผู้เชี่ยวชาญ) | 28, 31 |
| Variant Registry | 20 EQDB | — | 10 (M9) | 08, 07, 28, 26, 27 |
| Policy / Automation Rule / Rule Fire Log | 31 POL | — | Gateway (ผู้เล่น · 32 ร่าง) | 02 (ประเมินกฎที่ REGIONAL), 32 |
| Aide Profile / Action Log / Campaign Memory | 32 AIDE | — | — | 12 |
| World Event / Game Clock / RNG Streams / Scenario Objectives | 02 GSIM | — | เงื่อนไขจากทุกโมดูล | ทุกโมดูล |
| Chronicle / Unit Lineage / Battle Honors | 14 PPL | — | 08, 15, 05, 02 | 32 (ร้อยแก้ว), 12 |
| Orbital Station / Contact Window | 11 ORB | ตัวตนของกลุ่มอวกาศ: 05 | Gateway | 16, 22, 06 |
| Codex Term / Localized String / Fictional Code Set | 24 CODEX | — | 02 (หมุนรหัสตามรอบ) | 12, 16, 32 |
| Color Token / Accessibility Profile | 33 STYLE | — | การตั้งค่าของผู้เล่น | ฝั่งภาพของ 12 |
| Entity ID Registry / Save Chunk / Command Log | 13 SAVE | — | 02, 12 | 02 (Load และ Replay) |

### 5.3 สมุดบัญชีและกฎ "ไม่มีอะไรเกิดจากความว่างเปล่า"

ตามข้อ D3 มี **สมุดบัญชีการไหล 3 เล่ม** (สิ่งของ เงิน แรงงาน) และ **ทะเบียน 2 ชุด** (คน ยุทโธปกรณ์รายชิ้น) ทั้ง 5 รายการตรวจด้วยสมการในขั้น AUDIT

| สมุดบัญชี / ทะเบียน | เจ้าของ | รายการเข้า | รายการออก | สมการตรวจ (รันทุก GLOBAL Tick ใน Debug Build และในชุดทดสอบ) |
|---|---|---|---|---|
| สมุดบัญชีสิ่งของแบบเหมา (ราย Class ราย Faction ไม่รวม Class VII รายชิ้น) | 07 LOG | ภาคปฐม (06), การผลิต (28), กู้ซากและยึด (08), ซื้อเข้า (06), ของจากวงโคจร (11), ความช่วยเหลือ | การใช้ (หน่วย ประชากร โรงงาน), เน่าเสีย, ถูกทำลาย, ขายออก, ถูกยึด | สต็อกรวมใหม่ = สต็อกรวมเดิม + เข้า − ออก (รวมของระหว่างขนส่งและของติดตัวหน่วย) |
| สมุดบัญชีเงิน | 06 ECON | ภาษี ค่าบริการ การค้า ค่าจ้างที่ได้จากการรับสัญญา | ค่าจ้าง ค่าสัญญา งบเมือง การซื้อ | บัญชีคู่ (Double-entry) ผลรวมการโอนระหว่างบัญชีเป็นศูนย์ การออกเงินใหม่ต้องเป็นรายการนโยบายที่บันทึกไว้ (ออกแบบรายละเอียดในรอบเศรษฐกิจ) |
| สมุดบัญชีแรงงาน | 29 WORK | การเติบโตของประชากร การย้ายเข้า การปลดประจำการ ผู้หายป่วย | การเสียชีวิต การย้ายออก ผู้พิการถาวรที่ทำงานไม่ได้ | ทุกส่วนของประชากรอยู่ในสถานะเดียว: มีงาน / ทหาร / ฝึก / ว่างงาน / นอกกำลังแรงงาน (เด็ก ผู้สูงอายุ ผู้ป่วย นักเรียน) **ผู้เยาว์ไม่มีทางออกจากสถานะนอกกำลังแรงงาน** ผลรวม = ประชากรใน 04 |
| ทะเบียนคน (การย้อนที่มา) | 04 POP + 14 PPL | การเกิด การย้ายเข้า | การตาย การย้ายออก | ทหาร ทหารรับจ้าง และคนงานทุกกลุ่มชี้กลับไปยัง Pop หรือ Person ต้นทางได้ การเกิด การตาย และการย้ายถิ่นเขียนโดย 04 เท่านั้น (การตายจากการรบมาเป็น Event จาก 08/21) |
| ทะเบียนยุทโธปกรณ์รายชิ้น (Class VII ที่มีหมายเลข) | 28 IND | การผลิต การกู้หรือยึด การซื้อ สภาพเริ่มต้นจาก History Generation | ถูกทำลาย ขาย ถูกยึด ถอดเป็นอะไหล่ | ทุกชิ้นมี ID และที่มา ยุทโธปกรณ์ในพื้นที่ทหารจาก OSM เป็นข้อมูลที่เกมสร้างขึ้น (หัวข้อ 84) |

### 5.4 กฎ Echelon Handoff บน State ร่วม + Deterministic Resolution

หัวข้อ 102 ให้แนวทางลดต้นทุนของ "การซูมข้าม Echelon ไร้รอยต่อ" ว่า "ใช้ State ร่วมกัน + Deterministic Resolution" ตารางนี้แปลกฎทั้ง 6 ข้อในหัวข้อ 16.1 เป็นกลไกของ State

| กฎในหัวข้อ 16.1 | กลไกในแผนผังนี้ |
|---|---|
| **Seamless Zoom** — ข้อมูลของหน่วยเป็นชุดเดียวกันทุกระดับ | หน่วยมี ID เดียว (S5) Operational Counter, ไอคอน และภาพยานพาหนะรายคัน เป็นมุมมองของ Entity เดียวกันตามช่วงซูมในหัวข้อ 105.3 การเปลี่ยนมุมมองไม่สร้าง Entity ใหม่ |
| **Delegation** — ระดับที่ผู้เล่นไม่คุมถูกบริหารโดย Commander AI | "ผู้ถือสิทธิ์บังคับบัญชา" เป็นข้อมูลของหน่วยที่ 15 ORG เป็นเจ้าของ ค่าเป็น ผู้เล่น หรือ Commander AI (นายทหารที่มีชื่อใน 14 ซึ่งรวมกรณีที่ผู้ช่วยมอบภารกิจระดับอำนาจ 3 ตามหัวข้อ 7.3) การยึดหรือคืนการควบคุมเป็นคำสั่งผ่าน Gateway และ Commander AI สั่งการผ่าน Gateway เหมือนผู้เล่น |
| **Resolution Consistency** — ผลนอกจอใช้ตัวแปรเดียวกับในจอ | OCR ของ 25 ECH และการรบของ 08 CMB อ่าน **ชุดตัวแปรเดียวกัน** (ภูมิประเทศ ที่กำบัง การฝึก ขวัญ กระสุน การกดดัน ความเหนื่อยล้า การสื่อสาร การส่งกำลัง สภาพอากาศ) จาก Owner เดียวกัน และปรับเทียบ (Calibrate) OCR จากการรันการรบระดับยุทธวิธีจำนวนมากแบบอัตโนมัติ |
| **Handoff** — ซูมเข้าสลับเป็น Tactical โดยคงสถานะ ซูมออกสรุปผลกลับ | Lease Protocol ในแผนภาพด้านล่าง |
| **Information Flow** — ข้อมูลขึ้นมีความหน่วงและคลาดเคลื่อน คำสั่งลงมีความหน่วง | รายงานขึ้นผ่าน 16 C2 ไปเป็นความรู้ใน 22 INTEL คำสั่งลงผ่าน Gateway และ 16 C2 (หัวข้อ 2.5) การซูมเข้าไม่ทำให้ HQ รู้ทุกอย่างทันที |
| **Command Capacity** — หน่วยใหญ่ต้องมี HQ และฝ่ายอำนวยการ | 15 ORG คำนวณบทลงโทษ Command Span และ 16 C2 ใช้เป็นปัจจัยของความหน่วง (K8, วงจร L6) |

**สถานะของการรบหนึ่งครั้ง (Engagement) และการส่งต่อสิทธิ์เขียน**

```text
+-----------------------------------+    PROMOTE at LOCAL tick edge T    +-----------------------------------+
| OPERATIONAL  (default mode)       |----------------------------------->| TACTICAL                          |
| resolver: 25 ECH  (OCR)           |  1 OCR partial step to T, freeze   | resolver: 08 CMB  (+ Unit AI)     |
| step: REGIONAL 60 s               |  2 expand aggregates (seeded)      | step: TACTICAL 50 ms (20 Hz)      |
| lease holder: 25                  |  3 hand write-lease to 08          | lease holder: 08                  |
|                                   |                                    |                                   |
|                                   |    DEMOTE at LOCAL tick edge T'    |                                   |
|                                   |<-----------------------------------|                                   |
|                                   |  1 aggregate leased components     |                                   |
|                                   |  2 conservation check              |                                   |
|                                   |  3 commit to owners, lease to 25   |                                   |
+-----------------------------------+                                    +-----------------------------------+
                  |                                                                       |
                  +---- SAME INPUT VARIABLES: terrain, cover, training, morale, ammo, ----+
                       suppression, fatigue, comms, supply, weather  (Resolution Consistency)

 remote low-importance fights may drop one level further: STRATEGIC resolution by 25 ECH at GLOBAL step
```

**ข้อมูลที่อยู่ภายใต้ Lease (เปลี่ยนเร็วระหว่างรบ)**

| อยู่ภายใต้ Lease | ไม่อยู่ภายใต้ Lease (เจ้าของเดิมดูแลตลอด) |
|---|---|
| ตำแหน่งและรูปขบวนของหน่วยใน AO, กำลังรายส่วนย่อย, ขวัญ, การกดดัน, ความเหนื่อยล้า | Personnel Record และ Social Graph (14) |
| กระสุนแยกชนิดและเชื้อเพลิงที่ติดตัวหน่วย (Basic Load) | สต็อกในคลังและขบวนรถ (07) — ส่งเข้า AO ผ่าน M11 ตามปกติ |
| ความเสียหายรายชิ้นส่วนของยานพาหนะ | สัญญา คำสั่ง นโยบาย (23, 12, 31) |
| ความเสียหายราย Combat Cell และผู้ครอบครองแต่ละชั้นของอาคารใน AO | ความชอบธรรมและชื่อเสียง (05) — การกระทำใน AO ส่งเป็น Event G1 |
| ผู้บาดเจ็บที่กำลังนับเวลา Golden Hour ใน AO | ความรู้ของแต่ละฝ่าย (22) — เซนเซอร์ใน AO ส่ง Contact เป็น Event |
| ควัน ฝุ่น ไฟ และ UXO ที่เกิดใหม่ใน AO | Zone Field (25) — คำนวณใหม่ที่ REGIONAL จากผลที่ Commit แล้ว |

**กติกาการสลับ (ค่าตั้งต้น ต้องวัดใน Technical Spike 3 และ 6)**

- **Promote เมื่อ:** ผู้เล่นซูมถึงช่วง Z13 ขึ้นไปเหนือ AO ใน Battle Command View หรือสั่งการระดับยุทธวิธีโดยตรง หรือการรบเกี่ยวกับสิ่งที่ผู้เล่นปักหมุดไว้ (Key Personnel, HQ, อาคารสำคัญ) **และ** Governor ของ 34 PLAT ยังมีงบสำหรับ Tactical Bubble เพิ่ม (ค่าตั้งต้นตาม R-07: สูงสุด 2 Bubble พร้อมกัน คือจุดที่ดูอยู่ + จุดที่เพิ่งออกมา ยืนยันใน Spike 3 และ Spike 6)
- **Demote เมื่อ:** กล้องออกจาก AO นานกว่าช่วงหน่วง (Hysteresis ตาม R-07: 30 วินาทีจริงหลังกล้องออก หรือจนไม่มีการยิงใน 60 วินาทีเกม แล้วแต่อย่างใดถึงก่อน) และไม่มีคำสั่งยุทธวิธีค้าง หรือการรบจบ หรือ Governor ต้องลดภาระ (ลด Bubble ที่สำคัญน้อยที่สุดก่อน)
- **สลับที่ขอบ LOCAL Tick เท่านั้น** OCR รองรับ "ก้าวบางส่วน" แบบ Deterministic ถึงขอบนั้น ผู้เล่นจึงไม่ต้องรอถึงขอบนาทีเกม
- **การกระจายสถานะ (Expand)** ใช้ RNG Stream ที่ Seed จาก ID ของการรบกับเวลา T สถานะเดิมจึงกระจายออกมาเหมือนเดิมทุกครั้ง
- **การสลับทุกครั้งถูกบันทึกเป็นเหตุการณ์ LOD ใน Command Log** (D10) Replay จึงได้ผลตรงแม้ผลขึ้นกับว่าผู้เล่นมองตรงไหน
- **Invariant:** ข้อมูลภายใต้ Lease มีผู้เขียนหนึ่งตัวเสมอ, ผลรวมคน (มีชีวิต บาดเจ็บ เสียชีวิต ถูกจับ) ก่อนและหลังสลับเท่ากัน, กระสุนที่ใช้ใน Tactical เท่ากับส่วนต่างในสมุดบัญชี, ความเสียหายของอาคารไม่ลดลงเองยกเว้นมีงานซ่อม
- **เกณฑ์ Resolution Consistency (ค่าตั้งต้น):** ใช้ตาราง Dual-run Calibration ของ [R-07](03-design-rulings-sec114.md) ชุดเดียว (200 seed: ผู้ชนะตรงกัน ≥80%, อัตราส่วนความสูญเสียค่ามัธยฐาน ±15%, กระสุน ±20%, ระยะเวลาการรบ ±25%) ตัวเลขนี้ต้องปรับหลังทดสอบจริง
- การรบหลายจุดพร้อมกันกับความเร็วของเวลาเป็นประเด็นในหัวข้อ 114 ดูคำตัดสินในเอกสาร 03 แผนผังนี้กำหนดเพียงว่า Bubble ทุกอันเดินด้วยก้าว TACTICAL เดียวกัน

---

## 6. จังหวะการอัปเดต (Tick Cadence)

### 6.1 ชั้นความถี่

| ชั้น | ก้าวเวลา (เวลาเกม) | ทำงานที่ไหน | ตัวอย่างงาน | อ้าง spec |
|---|---|---|---|---|
| GLOBAL | 3,600 วินาที (1 ชั่วโมงเกม) | ทั้งโลก | ตลาด การเมือง ประชากรศาสตร์ ความชอบธรรม Faction AI | 106.2, 86 |
| REGIONAL | 60 วินาที (1 นาทีเกม) | ทั้งโลก | OCR โซน แนวหน้า ขบวนรถแบบรวม การผลิต Commander AI กฎอัตโนมัติ | 106.2, 86 |
| LOCAL | 500 ms (2 ครั้งต่อวินาทีที่ความเร็ว 1×) | เฉพาะ LOCAL Bubble รอบพื้นที่ที่ผู้เล่นดูในช่วงซูมเมืองถึงย่าน (ประมาณ Z9–Z16) | พลเรือนรายคน ขบวนรถแบบกายภาพ การ Commit ผลจาก Tactical | 106.2, 86, 102 |
| TACTICAL | 50 ms (20 Hz) สำรอง 100 ms (10 Hz) ถ้า Spike 3 ไม่ผ่าน | เฉพาะ TACTICAL Bubble คือการรบที่ถูก Promote (อยู่ใน LOCAL Bubble เสมอ ถ้ายังไม่มี ระบบเปิด LOCAL Bubble รอบ AO ให้ก่อน) | การเคลื่อนที่ การยิง Unit AI ความเสียหายราย Cell | 106.2, 16.1 |
| FRAME | 60 หรือ 120 fps | หน้าจอเท่านั้น | วาดภาพนีออน Interpolate ระหว่าง State UI | 106.2 |
| ASYNC | ไม่มีก้าว | Worker นอกเส้นทางหลัก | LLM, โหลด Tile, เขียน Save, Forecast | 107.3 |

### 6.2 การซ้อนกันของชั้นและการแลกข้อมูลข้ามชั้น

```text
 GLOBAL   |G=================================================================================G|  1 step = 3600 s
 REGIONAL |R====R====R====R====R====R====R ...... (60 steps per GLOBAL step) ......R====R====R|  60 s each
 LOCAL    |  120 steps inside each REGIONAL step  (LOCAL bubbles only)                        |  500 ms each
 TACTICAL |  10 steps inside each LOCAL step at 20 Hz (TACTICAL bubbles only; 5 at 10 Hz)     |  50 ms each
 FRAME    |  60 / 120 fps on screen: interpolates the last two states, never writes           |
 ASYNC    |  LLM (32), tile IO (01), save IO (13), forecast fork (02): join at the next edge  |
          |<---------------------------------- 1 game-hour ---------------------------------->|

 slower tier --- targets, budgets, orders, policies --------------------------------> faster tier
 faster tier --- aggregated deltas + events, committed at the slower tier's edge ----> slower tier
```

- **ชั้นช้าส่งลง:** เป้าหมาย งบ คำสั่ง นโยบาย เช่น Faction AI กำหนดลำดับความสำคัญ → Commander AI แตกเป็นภารกิจ → Unit AI ปฏิบัติ
- **ชั้นเร็วส่งขึ้น:** ผลรวมและ Event ที่ Commit ที่ขอบของชั้นช้า เช่น กระสุนที่ใช้ใน Tactical ถูกรวมแล้วลงสมุดบัญชีทุก LOCAL Tick และผลผลิตรายนาทีถูกรวมเข้าตลาดทุกชั่วโมงเกม
- **FRAME ไม่เคยเขียน State** ภาพเคลื่อนที่ลื่นด้วยการ Interpolate ระหว่าง State สองชุดล่าสุด ตามหัวข้อ 106.2

### 6.3 ตารางความถี่รายโมดูล

"แบ่งเวลา" = งานถูกแบ่งเป็นชิ้นเล็กกระจายหลายเฟรมบน Worker ที่ QoS สูง (macOS จัดลง Performance Cores เป็นหลัก) เพื่อไม่ให้เฟรมใดสะดุด · macOS ไม่ให้ผูกเธรดกับคอร์โดยตรง คอลัมน์ขวาจึงหมายถึงระดับ QoS ที่ตั้ง: "Performance Cores" = QoS สูง, "Efficiency Cores" = QoS ระดับ Utility หรือ Background (ADR-0001 B8) · ตำแหน่งประมวลผลเป็นข้อเสนอ ต้องยืนยันด้วย Profiler บน M4 Pro

| # | Tag | ชั้นหลัก | ละเอียดขึ้นเมื่อ / หมายเหตุ | ที่ประมวลผลบน M4 Pro (ข้อเสนอ) |
|---|---|---|---|---|
| 01 | OSM | ASYNC (สตรีม Tile ตามกล้อง) | Pipeline รันนอกเกม ข้อมูลที่ระบบจำลองต้องใช้ (กราฟถนน ตารางอาคาร) โหลดตามพื้นที่จำลอง ไม่ตามกล้อง (D11) | Efficiency Cores / IO |
| 02 | GSIM | เป็นผู้จัดตารางของทุกชั้น | เหตุการณ์โลกและ Audit ที่ GLOBAL · Forecast เป็น ASYNC | Performance Cores (Scheduler) · Forecast บน Worker แยก |
| 03 | FAI | GLOBAL (Faction AI ทบทวนเป้าระยะยาวทุกวันเกม) · REGIONAL (Commander AI) | AI LOD ลดความถี่ตามระยะจากผู้เล่นและความสำคัญ (15.2) | แบ่งเวลา |
| 04 | POP | GLOBAL | LOCAL ใน LOCAL Bubble (พลเรือนรายคนเมื่อผู้เล่นดู) | Jobs บน Performance Cores |
| 05 | GOV | GLOBAL | Event ความชอบธรรมรับได้ทุก Tick แต่สรุปผลที่ GLOBAL | แบ่งเวลา |
| 06 | ECON | GLOBAL (ตลาด คลังเงิน) | ภาคปฐมผลิตที่ REGIONAL | แบ่งเวลา |
| 07 | LOG | REGIONAL | LOCAL/TACTICAL เมื่อขบวนรถเป็นแบบกายภาพตอนผู้เล่นดู (102) · Commit การใช้ของจาก Tactical ทุก LOCAL | Jobs (Pathfinding บนกราฟถนน) |
| 08 | CMB | TACTICAL 20 Hz (ก้าว 50 ms) | ทำงานเฉพาะใน TACTICAL Bubble ภายใต้ Lease นอกนั้นเป็น OCR ของ 25 | Jobs + Burst (งานหนักที่สุดของเกม) |
| 09 | CITY | REGIONAL | — | แบ่งเวลา |
| 10 | TECH | GLOBAL | — | แบ่งเวลา |
| 11 | ORB | GLOBAL | ช่วงเวลาติดต่อเป็นเหตุการณ์ตามเวลาเกม | แบ่งเวลา |
| 12 | UICMD | FRAME (UI) · Gateway ทำงานในขั้น INGEST ของทุก Tick | — | Main Thread (UI) · Sim Thread (Gateway) |
| 13 | SAVE | ASYNC | Snapshot ที่ขอบ GLOBAL หรือเมื่อสั่ง แล้วเขียน Chunk เบื้องหลัง | Efficiency Cores / IO |
| 14 | PPL | GLOBAL · Event | Story Promotion เป็น Event | แบ่งเวลา |
| 15 | ORG | REGIONAL · Event | การจัดหน่วยใหม่เป็น Event | แบ่งเวลา |
| 16 | C2 | REGIONAL (กราฟ Coverage) · ข้อความเดินตามชั้นของผู้ส่ง | Coverage คำนวณใหม่เมื่อ Node เปลี่ยนเท่านั้น (Precompute Visibility ราย Tile ตามหัวข้อ 102) · ใน TACTICAL Bubble ข้อความวิทยุเดินที่ TACTICAL | Jobs |
| 17 | CAP | REGIONAL · Event | การเปลี่ยนสถานะจากการรบเข้ามาเป็น Event | แบ่งเวลา |
| 18 | BASE | REGIONAL (คิวก่อสร้าง) | ความเสียหายราย Cell เขียนโดย 08 ระหว่าง Lease | แบ่งเวลา |
| 19 | MPT | GLOBAL | — | แบ่งเวลา |
| 20 | EQDB | โหลดครั้งเดียว · Event (รุ่นใหม่จาก 10) | — | — |
| 21 | MED | REGIONAL (สายการส่งกลับ Role 2–4) | TACTICAL ใน Bubble (ตัวนับ Golden Hour, CCP) | Jobs |
| 22 | INTEL | REGIONAL (หลอมข้อมูล อายุข้อมูล) | การตรวจจับในจอมาจากเซนเซอร์ของ 08 ที่ TACTICAL | แบ่งเวลา |
| 23 | MERC | GLOBAL · Event | การผิดสัญญาเป็น Event | แบ่งเวลา |
| 24 | CODEX | โหลดครั้งเดียว · GLOBAL (หมุนรหัสสมมติ) | — | — |
| 25 | ECH | REGIONAL (OCR, Zone Field, แนวหน้า) | Promote/Demote ที่ขอบ LOCAL · การรบห่างไกลที่สำคัญน้อยลดเป็นก้าว GLOBAL | Jobs |
| 26 | AIR | REGIONAL (Sortie Generation น่านฟ้า ภารกิจ) | TACTICAL เมื่ออากาศยานอยู่ใน Bubble | Jobs |
| 27 | NAV | REGIONAL | TACTICAL ใน Bubble | Jobs |
| 28 | IND | REGIONAL (ผลผลิต งานซ่อม) | การสึกหรอของยุทโธปกรณ์ที่จอดอยู่สรุปที่ GLOBAL | แบ่งเวลา |
| 29 | WORK | GLOBAL (ตลาดแรงงาน การเกณฑ์) | การเปลี่ยนกะที่ REGIONAL | แบ่งเวลา |
| 30 | SVC | REGIONAL (โครงข่ายไหลจริง คำนวณใหม่เมื่อมีการเปลี่ยน) · GLOBAL (งบ ขีดความสามารถการบริหาร) | — | Jobs (Graph Flow) |
| 31 | POL | REGIONAL (ประเมินกฎ) · FRAME (Dashboard) | นโยบายมีผลที่ขอบ GLOBAL · Forecast ผ่าน 02 แบบ ASYNC | แบ่งเวลา + Main Thread |
| 32 | AIDE | ASYNC เท่านั้น | ไม่บล็อก Tick ใด ๆ ผลเข้าระบบที่ขอบ Tick ถัดไปผ่าน Gateway · โมเดลบนเครื่องรันตามกติกาเดียวของ ADR-0001 หัวข้อ 6.3 (ต่อยอด 106.2) | Cloud: เครือข่าย · Local: GPU (แย่งกับการวาดภาพ จึงอยู่ใต้ Governor) |
| 33 | STYLE | FRAME | — | GPU (Metal, MSAA) |
| 34 | PLAT | FRAME + ตรวจสถานะเครื่องประมาณทุก 1 วินาทีจริง | Governor ส่งสัญญาณให้ 02 และ 25 ตัดสินใจลดระดับ (วงจร L17) | ทุกคอร์ |

### 6.4 ลำดับขั้นภายใน Tick (ทุกชั้นใช้โครงเดียวกัน)

1. **INGEST** — รับคำสั่งที่ถึงเวลาส่งมอบแล้วจาก 16 C2, ผลจากงาน Async (เช่น Tile พร้อมใช้), เหตุการณ์ LOD
2. **SENSE** — เซนเซอร์และแนวสายตาใน Bubble, สร้างรายงาน
3. **DECIDE** — AI ของชั้นนั้นตัดสินใจจาก Knowledge View (Unit AI ที่ TACTICAL, Commander AI ที่ REGIONAL, Faction AI ที่ GLOBAL)
4. **ACT** — โมดูลโดเมนทำงานตามลำดับคงที่ (ด้านล่าง)
5. **COMMIT** — เจ้าของข้อมูลนำ Event ไปใช้ตามลำดับคงที่ และสมุดบัญชีลงรายการ
6. **DERIVE** — คำนวณค่าที่ถึงรอบ เช่น Zone Field ที่ REGIONAL, CityIndex ที่ GLOBAL
7. **AUDIT** — (Debug Build และชุดทดสอบ) ตรวจสมการของสมุดบัญชี
8. **PUBLISH** — เผยแพร่ Snapshot ให้ภาพ UI Tool API และ Dashboard แล้วทำเครื่องหมาย Chunk ที่เปลี่ยนให้ 13 SAVE

**ลำดับ ACT ที่เสนอ** (ผู้ผลิตก่อนผู้ใช้ เพื่อลดความล่าช้าหนึ่ง Tick ลำดับใดก็ได้ถ้าคงที่ แต่ต้องคงที่)

- **REGIONAL:** 16 C2 (ส่งข้อความ Coverage) → 15 ORG (Span ผล HQ) → 25 ECH (OCR) → 26 AIR / 27 NAV → 21 MED → 07 LOG → 28 IND → 17 CAP / 18 BASE → 09 CITY → 30 SVC (โครงข่าย) → 22 INTEL → 31 POL (ประเมินกฎ ส่งคำสั่งเข้าคิว Tick ถัดไป) แล้ว DERIVE Zone Field (25)
- **GLOBAL:** DECIDE: 03 Faction AI → ACT: 29 WORK → 19 MPT → 04 POP → 06 ECON → 30 SVC (งบ ขีดความสามารถการบริหาร) → 05 GOV → 23 MERC → 10 TECH → 11 ORB → 14 PPL → 02 เหตุการณ์โลก → AUDIT → ทำเครื่องหมาย Autosave

### 6.5 ความเร็วของเวลาและ Determinism

- **ขนาดก้าวไม่เปลี่ยนตามความเร็วเกม** (D9) ความเร็วเกมคือจำนวนก้าวต่อวินาทีจริง ถ้าเครื่องไม่ทัน ความเร็วจริงจะลดลงและ UI แสดงให้เห็น ตามหัวข้อ 90 "ความเร็วสูงสุดขึ้นอยู่กับความหนาแน่นของการจำลอง"
- เมื่อความเร็วเกินเกณฑ์หนึ่ง LOCAL และ TACTICAL Bubble จะถูก Demote ตามระเบียบ Lease เดียวกัน ค่าเกณฑ์และกติกาเมื่อมีการรบหลายจุดอยู่ในเอกสาร 03
- ผลการจำลองไม่ขึ้นกับ Frame Rate ไม่ขึ้นกับว่า Tile ไหนโหลดอยู่ฝั่งภาพ และไม่ขึ้นกับว่ามี LLM หรือไม่

---

## 7. ขอบเขตของ LLM กับ Game AI

หลักจากหัวข้อ 15.1: **การตัดสินใจที่เปลี่ยนโลกจำลองต้องมาจาก Game AI แบบ Deterministic** ส่วน LLM ใช้เฉพาะงานด้านภาษาและการสื่อสารกับผู้เล่น และหัวข้อ 15.3: **ทุกการกระทำที่ LLM เสนอต้องผ่าน Command API** ที่ตรวจความถูกต้อง สิทธิ์ ข้อจำกัด และความหน่วงเหมือนคำสั่งของผู้เล่น

### 7.1 แผนภาพเส้นแบ่ง

```text
  OUTSIDE THE SIM: non-deterministic, ASYNC, optional   ||  INSIDE THE SIM: deterministic, replayable
                                                        ||
  player chat <---> [32 AIDE] persona, campaign memory  ||
                    backend: cloud LLM | local LLM      ||
                    (llama.cpp; MLX dev)| none=template ||
                          |   ^                         ||
            tool calls    |   |  structured results     ||
            (JSON schema) v   |  (JSON schema)          ||
  +---------------------- TOOL API (owner 32) ----------++--------------------------------------------+
  | query_state     --> Query API, staff-filtered ------++--> [22] Knowledge View (fog of war)        |
  | get_reports     --> report store -------------------++--> [16] / [22]                             |
  | forecast        --> Forecast Service, no writes ----++--> [02] fork on knowledge snapshot         |
  | propose_orders  --> Gateway dry-run, validate only -++--> [12] -> plan card for the player        |
  | issue_orders    ==> Gateway, aide level 2-3 only ===++==> [12] -> [16] delay -> world             |
  | delegate_task   ==> Gateway, level 3 only ==========++==> [03] Commander AI runs the task         |
  | set_policy      ==> Gateway, player confirms =======++==> [31] policies                           |
  | create_rule     --> draft only, player activates ---++--> [31] rule drafts                        |
  +-----------------------------------------------------++--------------------------------------------+
                          |
  LLM text out: chat replies, SITREP prose, plan wording, objections in the persona's voice,
  chronicle and memoir prose, radio "colour", diplomatic dialogue wording
  ==> presentation only (12), stored as cosmetic text, NEVER read by the simulation
```

- ทางซ้ายของเส้นคู่ `||` คือโลกที่ "ไม่ต้องซ้ำเดิม" ทางขวาคือระบบจำลองที่ต้องได้ผลเดิมทุกครั้ง สิ่งเดียวที่ข้ามเส้นได้คือ **ผลลัพธ์แบบมีโครงสร้าง** ผ่าน Tool API
- **Replay ไม่ต้องใช้ LLM** เพราะสิ่งที่ LLM ทำให้เกิดในโลก คือคำสั่งที่ผ่าน Gateway แล้ว ถูกบันทึกใน Command Log ครบ
- **Backend บนเครื่อง** ใน Build ที่แจกจ่ายคือ llama.cpp server ส่วน MLX ใช้ทดลองช่วงพัฒนาเท่านั้น และ Apple Foundation Models ใช้ได้เฉพาะโหมดภาษาอังกฤษ ([ADR-0001 B6](../../adr/ADR-0001-tech-stack.md))
- ข้อความของ LLM ถูกเก็บเป็นข้อความประกอบการแสดงผลเท่านั้น ระบบจำลองไม่อ่านกลับ

### 7.2 ใครตัดสิน ใครเรียบเรียง

| งาน | ผู้ตัดสินหรือคำนวณ (Game AI / ระบบจำลอง) | บทบาทของ LLM | โหมดไม่ใช้ LLM |
|---|---|---|---|
| กลยุทธ์ของกลุ่ม การทูต การผลิต นโยบายกำลังพล | 03 Faction AI (Utility + HTN/GOAP) | ไม่มี | — |
| แผนยุทธการของผู้บังคับบัญชา | 03 Commander AI (HTN + แม่แบบหลักนิยม) | เขียน Commander's Memoir จากเหตุการณ์จริงเท่านั้น | แม่แบบข้อความ |
| พฤติกรรมหน่วย พลเรือน ขบวนรถ ทหารรับจ้าง เศรษฐกิจ | Agent AI ในโมดูล 08, 04, 07, 23, 06 | ไม่มี | — |
| ผลการเจรจาทางการทูต | 05 GOV คำนวณ | เขียนบทพูดทางการทูต | แม่แบบข้อความ |
| ตอบคำถามสถานะ เช่น "ทำไมโรงงาน 3 หยุดผลิต" | 28 IND ส่งรายการสาเหตุแบบมีโครงสร้าง (คอขวด ไฟ คน วัตถุดิบ) + 22 Knowledge | เรียบเรียงคำตอบ | แม่แบบจากรหัสสาเหตุ |
| Daily Briefing (SITREP) และการแจ้งเตือน | 16/22 รวมรายงาน 31 จัดลำดับความรุนแรง | สรุปเป็นภาษาตามบุคลิก | SITREP แบบแม่แบบ |
| เสนอแผน A/B/C | **ตัววางแผนฝ่ายอำนวยการของ 03** สร้างทางเลือก + **02 Forecast** ให้ตัวเลขและช่วงความไม่แน่นอน | เปรียบเทียบและเรียบเรียง ประกอบชุดคำสั่งผ่าน propose_orders ที่ต้องผ่าน Dry-run | การ์ดแผนแบบแม่แบบ |
| อธิบายผลกระทบ เช่น "ถ้าเกณฑ์เพิ่ม ผลิตลดเท่าไร" | 02 Forecast | อธิบาย | ตัวเลข + แม่แบบ |
| คัดค้านคำสั่งที่ผิด ROE หรือกฎการสงคราม | **ตัวตรวจกฎใน Gateway (12)** ตัดสินว่าละเมิดหรือไม่ | พูดคัดค้านตามบุคลิก | ข้อความเตือนแบบแม่แบบ + ปุ่มยืนยัน |
| ร่างนโยบายและกฎอัตโนมัติ | Gateway ตรวจ Schema และ 02 พยากรณ์ผล ผู้เล่นเปิดใช้เอง | แปลงภาษาพูดเป็นกฎแบบมีโครงสร้าง | ตัวสร้างกฎแบบฟอร์ม |
| สอนและแปลศัพท์ทหาร | 24 CODEX | อธิบายเพิ่มตามบริบท | Tooltip ของ Codex |
| Chronicle และสีสันข้อความวิทยุ | 14 PPL (ข้อเท็จจริง) 16 C2 (ข้อความจริง) | เขียนร้อยแก้วและสีสัน | แม่แบบข้อความ |

### 7.3 ระดับอำนาจ 0–3 กับเส้นทางของคำสั่ง (หัวข้อ 29.2)

| ระดับ | ชื่อ | Tool ที่เปิดใช้ | เส้นทาง | ใครทำงานต่อเนื่อง |
|---|---|---|---|---|
| 0 | Advise | query_state, get_reports, forecast | ไม่มีคำสั่งออก | — |
| 1 | Propose & Approve | + propose_orders | ชุดคำสั่ง → Dry-run → การ์ดแผน → ผู้เล่นกดอนุมัติ → Gateway ในนามผู้เล่น | ผู้เล่น |
| 2 | Execute Within Limits | + issue_orders | คำสั่งแต่ละคำสั่ง → Gateway ตรวจกรอบอำนาจ (งบ ROE พื้นที่ ชุดหน่วย) → บันทึกใน Action Log พร้อมเหตุผล → ยกเลิกได้จนกว่าจะถูกปฏิบัติ | ผู้ช่วยออกคำสั่งเป็นครั้ง ๆ |
| 3 | Delegated Command | + delegate_task (ข้อเสนอเพิ่มจากรายการตัวอย่างในหัวข้อ 30.2) มอบภารกิจทั้งพื้นที่หรือทั้งภารกิจ | ผู้ช่วยแปลงเจตนาของผู้เล่นเป็น "ภารกิจมอบหมาย" แบบมีโครงสร้าง → **Commander AI แบบ Deterministic ของ 03** รับไปปฏิบัติทุก Tick ภายในกรอบอำนาจ → LLM รายงานผลตามรอบ | Commander AI (ทำงานได้แม้ออฟไลน์) |

**เหตุผลของระดับ 3 (D13):** การควบคุมต่อเนื่องทุก Tick ต้องเร็ว ทำงานออฟไลน์ได้ และ Replay ได้ ซึ่ง LLM ทำไม่ได้ จึงให้ Game AI เป็นผู้ปฏิบัติ ส่วน LLM เป็นผู้รับเจตนาและผู้รายงาน ผู้เล่นเพิกถอนได้ทุกเมื่อตามเสาหลักข้อ 10 · **กฎอัตโนมัติ** ที่ผู้ช่วยร่างต้องให้ผู้เล่นเปิดใช้เองทุกระดับอำนาจ ตามหัวข้อ 93.3 เพราะกฎคงอยู่และทวีผลได้นานกว่าคำสั่งครั้งเดียว

### 7.4 กติกาความยุติธรรม ความปลอดภัย และโหมดสำรอง

- **เห็นเท่าที่ฝ่ายอำนวยการรู้:** Tool API อ่าน Knowledge View ของฝ่ายผู้เล่นเท่านั้น และกรองความละเอียดตามค่าความสามารถของนายทหารฝ่ายอำนวยการที่ผู้ช่วยสวมบทบาท (หัวข้อ 28.2) เช่น ฝ่ายข่าว (S2) ที่ฝีมือต่ำได้เกรดข่าวกรองหยาบกว่า ฝ่ายส่งกำลัง (S4) ที่ฝีมือต่ำได้ช่วงพยากรณ์กว้างกว่า ผู้ช่วยจึง "ฉลาดกว่าฝ่ายอำนวยการของตัวเอง" ไม่ได้
- **ตัวเลขต้องมาจากเครื่องมือ:** ตัวเลขบนการ์ดแผนและแผง Dashboard แสดงจากข้อมูลแบบมีโครงสร้างที่ Tool ส่งกลับ ไม่ใช่ตัวเลขที่ LLM พิมพ์เอง LLM อ้างตัวเลขผ่านตัวแทน (Placeholder) ที่ UI เติมให้
- **กฎการสงคราม 3 ประเภท:** (1) **ไม่มีอยู่ในเกมเลย** เช่น การทรมาน ทหารเด็ก รหัสลับจริง จึงไม่มี Tool หรือคำสั่งใดทำได้ (2) **ทำได้แต่มีผลรุนแรง** เช่น ยิงใส่อาคารที่มีพลเรือน ใช้สถานที่คุ้มครองเป็นที่ตั้งทางทหาร บังคับใช้แรงงาน Gateway ทำเครื่องหมาย ผู้ช่วยคัดค้านตามบุคลิก ผู้เล่นต้องยืนยันเอง แล้วผลไหลเข้า G1 **ผู้ช่วยไม่ออกคำสั่งประเภทนี้เองในทุกระดับอำนาจ** (3) คำสั่งปกติ (หัวข้อ 101, 29.1)
- **ข้อความในเกมคือข้อมูล ไม่ใช่คำสั่ง:** ข้อความวิทยุของข้าศึก เอกสารที่ยึดได้ หรือชื่อที่ผู้เล่นตั้ง ซึ่งถูกส่งให้ LLM อ่าน ไม่มีผลต่อสิทธิ์ใด ๆ เพราะ Tool API ตรวจระดับอำนาจทุกครั้งโดยไม่สนใจสิ่งที่ LLM อ้าง
- **ตัวตนของผู้ช่วย:** ใบหน้ามาจากชุดภาพสมมติหรือตัวปรับแต่งของ 33 STYLE ห้ามใช้ใบหน้า เสียง หรือตัวตนของบุคคลจริง และอยู่ในโลกของเกมเสมอ (หัวข้อ 101, 28.1)
- **โหมดไม่ใช้ LLM มีเสมอ** (107.3) ทุกงานในตาราง 7.2 มีแม่แบบสำรอง และผลการจำลองเหมือนเดิมทุกโหมด (Invariant I8)
- **ประสิทธิภาพ:** Tool API อ่านจาก Snapshot ที่ PUBLISH แล้ว จึงไม่ล็อกระบบจำลอง โมเดลบนเครื่องใช้งบหน่วยความจำประมาณ 3–6.5 GB ตามขนาดโมเดล (106.1 ปรับใน ADR-0001 หัวข้อ 6.1) และรันได้เฉพาะตามกติกาเดียวใน [ADR-0001 หัวข้อ 6.3](../../adr/ADR-0001-tech-stack.md) (หยุดเกมหรือความเร็ว ≤1×, Thermal State Nominal/Fair, หน่วยความจำเหลือพอ) ส่วนโหมดคลาวด์ไม่กินหน่วยความจำเครื่อง
- **ความจำแคมเปญของผู้ช่วย** (30.3) เก็บใน Save เป็นข้อมูลนอกระบบจำลอง ไม่มีผลต่อ Determinism
- **การเลือกคลาวด์ บนเครื่อง หรือผสม** เป็นประเด็นในหัวข้อ 114 และขึ้นกับคำตอบข้อ 108.2 ข้อ 2 ดูเอกสาร 03 และ ADR-0001 แผนผังนี้รองรับทั้งสามแบบโดยไม่ต้องแก้ส่วนอื่น

---

## 8. รายการ Interface กลาง

| Interface | เจ้าของ | ทิศทาง | ผู้ใช้ | กติกาหลัก |
|---|---|---|---|---|
| **Command API / Gateway** | 12 UICMD | เข้าสู่ระบบจำลอง | ผู้เล่น, 31, 32 (ผ่าน Tool API), 03 | ลำดับเดียวกับ ADR-0001 B4: Schema → สิทธิ์ (ยศ HQ ระดับอำนาจ) → ROE กฎการสงคราม และการอนุมัติตามบันไดอำนาจการยิง → ต้นทุนและความเป็นไปได้ → บันทึก Command Log → ส่งต่อให้ 16 คิดเส้นทางและความหน่วง |
| **Query API / Knowledge View** | 22 INTEL | ออกจากระบบจำลอง | 12, 31, 32, 03 | แยกต่อฝ่าย มี Fog of War อายุข้อมูล และเกรด อ่านจาก Snapshot |
| **Tool API** | 32 AIDE | LLM ↔ เกม | LLM เท่านั้น | JSON Schema, Structured Output, กรอบอำนาจ, ตัวกรองตามฝ่ายอำนวยการ |
| **Forecast Service** | 02 GSIM | Sandbox | 31, 32, 03 | Fork ความละเอียดต่ำบน Knowledge Snapshot ไม่เขียนโลกจริง คืนค่าพร้อมช่วงความไม่แน่นอน |
| **Event Bus** | 02 GSIM | ระหว่างโดเมน | โมดูลใน L3 | Event มีชนิดชัดเจน ส่งถึงเจ้าของในขั้น COMMIT ลำดับคงที่ |
| **Ledger Transactions** | 07 / 06 / 29 (สมุดบัญชีการไหล 3 เล่ม) + ทะเบียนของ 04/14 และ 28 | โดเมน → สมุดบัญชีหรือทะเบียน | โมดูลใน L3 | บัญชีคู่ ตรวจสมการใน AUDIT |
| **Lease Protocol** | 02 GSIM | ภายใน Kernel | 25 ↔ 08 (การรบ), 07 (ขบวนรถกายภาพ), 04 (พลเรือนรายคน) | Promote/Demote ที่ขอบ LOCAL บันทึกเป็นเหตุการณ์ LOD |
| **Render Snapshot** | 02 GSIM (เผยแพร่) | ระบบจำลอง → ภาพ | 12, 33 | อ่านอย่างเดียว Interpolate ได้ |
| **Save API** | 13 SAVE | ระบบจำลอง ↔ ดิสก์ | 02 | Chunk ตามพื้นที่และชนิด Entity, Schema มีเวอร์ชัน, Command Log สำหรับ Replay, รองรับ Mod |
| **Tile Streaming** | 01 OSM | ดิสก์ → ภาพ | ฝั่งภาพของ 12/33 | Async ตามกล้อง แยกจากการโหลดข้อมูลที่ระบบจำลองต้องใช้ |
| **Platform Services** | 34 PLAT | ชั้นล่างสุด | ทุกชั้น | Jobs, Metal, IO, สัญญาณ Governor, โฮสต์เซิร์ฟเวอร์ LLM บนเครื่อง |

---

## 9. Invariant ที่ต้องทดสอบ

| ID | Invariant | วิธีตรวจ |
|---|---|---|
| I1 | Single Writer — ข้อมูลแต่ละส่วนถูกเขียนโดยเจ้าของเท่านั้น | ตรวจตอน Build และ Assert ตอนรันใน Debug |
| I2 | สมุดบัญชีการไหล 3 เล่ม (สิ่งของ เงิน แรงงาน) และทะเบียน 2 ชุด (คน ยุทโธปกรณ์รายชิ้น) สมดุลทั้งหมด | ขั้น AUDIT ทุก GLOBAL Tick ใน Debug และในชุดทดสอบ |
| I3 | Replay Determinism — Save เดียวกัน + Command Log เดียวกัน (รวมเหตุการณ์ LOD) → Hash ของสถานะตรงกันทุกขอบ GLOBAL | ชุดทดสอบ Replay อัตโนมัติ |
| I4 | Handoff Round-trip — Promote แล้ว Demote ทันทีโดยไม่มีการรบ ได้สถานะเดิม และเมื่อมีการรบ ผลรวมคนและกระสุนสอดคล้องกัน | ทดสอบหน่วย (Unit Test) ของ Lease Protocol |
| I5 | Resolution Consistency — ผลแบบ OCR กับแบบ Tactical อยู่ในเกณฑ์ข้อ 5.4 | รันการรบชุดมาตรฐานจำนวนมากแบบอัตโนมัติ |
| I6 | ความยุติธรรม — Query API และ Tool API ไม่คืน Entity ที่ไม่อยู่ใน Knowledge View และ Forecast ไม่ใช้ข้อมูลจริงที่ฝ่ายนั้นไม่รู้ | Fuzz Test ด้วยสถานะที่มีข้อมูลซ่อน |
| I7 | จริยธรรม — ไม่มีการจัดสรรผู้เยาว์ไปเป็นทหารหรือแรงงาน ไม่มีคำสั่งหรือ Tool สำหรับการทรมาน การใช้สถานที่คุ้มครองทางทหารสร้าง Event G1 เสมอ ผู้ช่วยไม่ออกคำสั่งประเภท (2) เอง | ทดสอบอัตโนมัติ + ตรวจรายการคำสั่งทั้งหมด |
| I8 | แยก Async — ผลการจำลองเหมือนกันเมื่อ LLM ปิด เปิดแบบคลาวด์ หรือเปิดแบบบนเครื่อง ถ้าคำสั่งชุดเดียวกัน | Replay เทียบ Hash |
| I9 | ไม่ขึ้นกับกล้อง — ผลเหมือนกันเมื่อ Tile ฝั่งภาพโหลดต่างกัน ถ้าเหตุการณ์ LOD เหมือนกัน | Replay ด้วยเส้นทางกล้องต่างกัน |
| I10 | งบประสิทธิภาพ — Tick แต่ละชั้นไม่เกินงบ และเล่นต่อเนื่อง 60 นาทีบน M4 Pro ได้ | Technical Spike 3 และ 6 (หัวข้อ 108.3) |

---

## 10. ประเด็นเปิดสำหรับรอบถัดไปและความเชื่อมกับคำถามข้อ 108.2

### 10.1 ประเด็นที่ทีมจะตัดสินในรอบถัดไป (ไม่ใช่คำถามถึงผู้ออกแบบ)

1. **สูตร OCR และชุดการรบมาตรฐานสำหรับ Calibrate** — ขยายในรอบที่ทำหัวข้อ GDD เรื่อง Echelons และ Tactical Combat
2. **ขนาดก้าวของแต่ละชั้น จำนวน Tactical Bubble พร้อมกัน และค่า Hysteresis** — ยืนยันด้วย Technical Spike 3 (ECS 5,000–10,000 หน่วย) และ Spike 6 (เล่นต่อเนื่อง 60 นาที)
3. **การผลิตควรสรุปทุกนาทีเกมหรือทุกชั่วโมงเกม** — เลือกตามผล Profiler เพราะกระทบทั้งความรู้สึกตอบสนองและภาระ CPU
4. **การออกแบบสกุลเงินและการออกเงินใหม่** ของ 06 ECON ให้ไม่ขัดกับสมุดบัญชีเงิน
5. **กติกาอายุข้อมูลฝ่ายเรา** ใน Knowledge View เมื่อ HQ ขาดการติดต่อ และการแสดงอายุข้อมูลใน Dashboard
6. **Schema ของ Event และรูปแบบ Entity ID** — จะออกเป็น ADR แยกหลังเลือกเอนจินแล้ว
7. **ชื่อของโมดูล 25** — เสนอปรับเป็น "Echelon Resolution, Zones & Handoff" ให้ตรงกับขอบเขตที่ขยายตาม D4 ในรอบปรับสารบัญถัดไป

### 10.2 คำถามข้อ 108.2 กับแผนผังนี้

ตามหัวข้อ 118 รอบนี้ถามผู้ออกแบบเฉพาะคำถามในข้อ 108.2 (รวบรวมไว้ใน [ADR-0001](../../adr/ADR-0001-tech-stack.md) และท้าย [docs/gdd/README.md](../README.md)) ผลของแต่ละคำตอบต่อแผนผังนี้คือ

| คำถามข้อ 108.2 | ผลต่อแผนผังนี้ |
|---|---|
| 1. ขนาดทีมและภาษาที่ถนัด | ไม่เปลี่ยนชั้นหรือการเป็นเจ้าของข้อมูล แผนผังนี้ไม่ผูกกับเอนจิน คำตอบมีผลต่อการเลือก ECS และวิธีทำ Job ใน 34 PLAT |
| 2. ผู้ช่วย AI ต้องเล่นแบบออฟไลน์ได้หรือไม่ | แผนผังรองรับทุกแบบอยู่แล้ว (หัวข้อ 7) คำตอบกำหนดค่าเริ่มต้นของ Backend ใน 32 AIDE และงบหน่วยความจำประมาณ 3–6.5 GB ใน 34 PLAT |
| 3. ประเทศหรือพื้นที่สำหรับ Prototype | กำหนดขอบเขตข้อมูลของ 01 OSM ขนาดข้อมูลแผนที่ที่ระบบจำลองต้องโหลด และภาษาของชื่อสถานที่ใน 24 CODEX |


