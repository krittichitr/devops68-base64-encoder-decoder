# DevOps 68 - Base64 Encoder/Decoder API

โปรเจกต์นี้เป็นการนำแอปพลิเคชัน Node.js (Express) สำหรับแปลงข้อความ (Encode/Decode) เป็น Base64 ไป Deploy บน AWS EC2 โดยใช้ **Terraform (Infrastructure as Code)** ในการสร้างและจัดการเซิร์ฟเวอร์แบบอัตโนมัติ

## 📋 สิ่งที่ต้องเตรียม (Prerequisites)
ก่อนเริ่มรับงาน คุณจำเป็นต้องติดตั้งเครื่องมือต่อไปนี้บนเครื่องคอมพิวเตอร์ของคุณ (Local Machine):
1. [AWS CLI](https://aws.amazon.com/cli/) - สำหรับจัดการสิทธิ์เชื่อมต่อกับ AWS
2. [Terraform](https://www.terraform.io/downloads.html) - สำหรับ Provision infrastructure
3. [Git](https://git-scm.com/downloads) - สำหรับดึงซอร์สโค้ด

## 🚀 ขั้นตอนการดำเนินการ (Step-by-Step)

### 1. การตั้งค่า AWS และระบบพื้นฐาน
ก่อนจะรัน Terraform ได้ เราต้องยืนยันตัวตนกับ AWS ก่อน:
1. เปิด Terminal และจับคู่ AWS CLI เข้ากับบัญชีของคุณด้วยคำสั่ง:
   ```bash
   aws configure
   ```
   *ระบบจะให้กรอก `AWS Access Key ID`, `AWS Secret Access Key`, และกำหนด Region ให้ใช้ `us-east-1`*
2. ให้ไปที่หน้าเว็บคอนโซล AWS (AWS Management Console) -> EC2 -> **Key Pairs**
3. สร้าง Key Pair ใหม่ชื่อ **`my-terraform-key`** ใน Region `us-east-1` (และโหลดไฟล์ `.pem` เก็บไว้ เผื่อต้องใช้ SSH เข้าเซิร์ฟเวอร์)
   *(หากมี Key ชื่ออื่นอยู่แล้ว สามารถแก้ไฟล์ `variables.tf` ตรงตัวแปร `key_name` ให้ตรงกับชื่อ Key ของคุณได้)*

### 2. การสร้าง Infrastructure (Provision Infra - 2 คะแนน)
ดาวน์โหลดโปรเจกต์นี้และใช้ Terraform สร้างเซิร์ฟเวอร์แบบอัตโนมัติ:

1. Clone โปรเจกต์นี้ลงมาที่เครื่องของคุณ:
   ```bash
   git clone https://github.com/krittichitr/devops68-base64-encoder-decoder.git
   cd devops68-base64-encoder-decoder
   ```

2. เริ่มต้นคำสั่งเตรียมความพร้อมให้ Terraform (ดาวน์โหลด Provider สำหรับ AWS):
   ```bash
   terraform init
   ```

3. สั่ง Provision สร้าง EC2 และ Security Group (เปิดพอร์ต 22 และ 3027):
   ```bash
   terraform apply -auto-approve
   ```
   *เมื่อเสร็จสิ้น Terraform จะแสดง Output เป็น **IP Address** ของเครื่องเซิร์ฟเวอร์ (เช่น `instance_public_ip = "3.90.114.58"`)*

### 3. การใช้งานและทดสอบระบบประมวลผล (Deploy จนรันได้จริง - 5 คะแนน)
หลังจากรัน `terraform apply` สำเร็จ **ระบบจะทำการ Deploy ตัวโหนดเซิร์ฟเวอร์และรัน API ให้อัตโนมัติทันที** ผ่าน `user_data` script (รบกวนรอโปรแกรมทำการลง Node.js และเปิดพอร์ตประมาณ 1-2 นาทีหลังเครื่องสร้างเสร็จ)

คุณสามารถทดสอบการทำงานของแอปพลิเคชันได้โดย:

**วิธีที่ 1: ตรวจสอบผ่านเบราว์เซอร์ (Browser)**
นำ IP ธรรมดาของคุณ ไปแทนที่ `[YOUR_EC2_IP]` เช่น `3.90.114.58` แล้วเปิดลิงก์บนแถบคำค้นหา:

* **ทดสอบการ Encode**
  `http://[YOUR_EC2_IP]:3027/encode?text=DevOpsIsFun`
  *(คุณควรจะได้หน้าตาข้อมูลสะท้อนกลับมาเป็น JSON เผยข้อความที่ผ่านการถูก Encode)*

* **ทดสอบการ Decode**
  นำผลลัพธ์จากข้อด้านบน (เช่น `RGV2T3BzSXNGdW4=`) ไปใส่:
  `http://[YOUR_EC2_IP]:3027/decode?text=RGV2T3BzSXNGdW4=`

**วิธีที่ 2: ใช้ Script ตรวจสอบการรันอัตโนมัติ (Automated Check)**
1. แก้ไขหมายเลข IP ในบรรทัดที่ 4 ของไฟล์ `check_api.sh` ให้เป็น IP ที่คุณได้จาก Terraform
   ```bash
   # กำหนดตัวแปรใน check_api.sh
   IP="3.90.114.58"
   ```
2. รันสคริปต์ตรวจสอบ:
   ```bash
   chmod +x check_api.sh
   ./check_api.sh
   ```
*(สคริปต์นี้จะรันตรวจสอบและบอกคุณว่าเครื่องเซิร์ฟเวอร์เปิดพอร์ตสมบูรณ์แบบเรียบร้อย พร้อมใช้หรือไม่)*

---
## 🧹 การทำลายทรัพยากรที่สร้างไว้ (Clean-Up)
เมื่อดำเนินการใช้งานเสร็จ เพื่อไม่ให้เสียทรัพยากร AWS และเปลืองเงินรายวันในเครือข่าย ให้สั่งทำลาย Infra ทิ้งด้วยคำสั่ง:
```bash
terraform destroy -auto-approve
```
