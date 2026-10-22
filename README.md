# war_game

เกมสำหรับเล่นบน **macOS** เท่านั้น และจัดส่งผ่าน **git** เท่านั้น (ไม่มีไฟล์ดาวน์โหลดแยก)

## วิธีโหลดและเล่น

ต้องมี `git` บนเครื่อง Mac (ถ้ายังไม่มี ระบบจะให้ติดตั้ง Command Line Tools ตอนรันคำสั่งครั้งแรก)

```bash
git clone -b setup/mac-game-skeleton https://github.com/wasuratsomdet9009/war_game.git
cd war_game
./play.command
```

หรือเปิดโฟลเดอร์ `war_game` ใน Finder แล้วดับเบิลคลิก `play.command`

อัปเดตเกมเป็นเวอร์ชันล่าสุด:

```bash
git pull
```

## โครงสร้าง

| ไฟล์ / โฟลเดอร์ | หน้าที่ |
| --- | --- |
| `play.command` | จุดเริ่มเล่น ตรวจว่าเป็น macOS ก่อนเสมอ |
| `.gitattributes` | บังคับ line ending แบบ LF ให้สคริปต์ทำงานได้บน Mac |
| `.gitignore` | ไม่บันทึกไฟล์ที่เครื่องสร้างขึ้นเอง เช่น `.DS_Store`, build output |

| `docs/design/` | สเปกต้นฉบับของผู้ออกแบบ (Master Prompt v3.1) |
| `docs/gdd/` | Game Design Document ที่ส่งเป็นรอบ — เริ่มอ่านที่ [docs/gdd/README.md](docs/gdd/README.md) |
| `docs/adr/` | Architecture Decision Records เช่น [ADR-0001 Tech Stack](docs/adr/ADR-0001-tech-stack.md) |

ตอนนี้อยู่ในขั้นออกแบบ (ยังไม่เขียนโค้ดเกม) เอนจินจะเลือกตาม ADR-0001 และผล Technical Spike
