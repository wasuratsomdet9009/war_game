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

เอนจินและโครงสร้างโค้ดของเกมยังไม่ได้เลือก จะกำหนดตามแผนการทำเกม
