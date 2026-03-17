#!/bin/bash

# กำหนดตัวแปร
IP="3.90.114.58"
PORT="3027"
ENDPOINT="/encode?text=test"
URL="http://$IP:$PORT$ENDPOINT"

echo "==============================================="
echo " 🔍 ตรวจสอบสถานะ API: $IP พอร์ต $PORT"
echo "==============================================="

# 1. ตรวจสอบว่าพอร์ต 3027 เปิดอยู่หรือไม่ (Network Connection)
# ใช้ nc (Netcat) ซึ่งมีมาให้ใน macOS (ใช้ -G 5 เพื่อ Timeout ใน 5 วินาที)
echo "⌛ [1/2] กำลังตรวจสอบการเชื่อมต่อมาที่พอร์ต $PORT..."
if nc -z -G 5 "$IP" "$PORT" > /dev/null 2>&1; then
    echo "✅ [ผ่าน] พอร์ต $PORT เปิดอยู่ สามารถเชื่อมต่อได้"
else
    echo "❌ [ไม่ผ่าน] ไม่สามารถเชื่อมต่อพอร์ต $PORT ได้ (พอร์ตอาจจะปิดอยู่ หรือติด Security Group / Firewall)"
    echo ""
    echo "🛠️ คำสั่ง SSH สำหรับเข้าไปดู Log เครื่อง EC2:"
    echo "ssh -i /path/to/your-key.pem ubuntu@$IP \"tail -f /path/to/app.log\""
    echo "*** หมายเหตุ: เปลี่ยน /path/to/your-key.pem, ubuntu (user) และ /path/to/app.log ให้ตรงกับความเป็นจริง"
    echo "==============================================="
    exit 1
fi

echo "-----------------------------------------------"

# 2. ทดลองส่ง Request ไปที่ Endpoint แล้วเช็คว่ามี JSON ตอบกลับมาหรือไม่
echo "⌛ [2/2] กำลังส่ง HTTP Request ไปที่ $URL..."

# ใช้ curl เพื่อดึงข้อมูล (ซ่อน progress, รอ response 5 วิ, และดึง HTTP Status Code มาพ่วงท้าย)
RESPONSE=$(curl -s -m 5 -w "\n%{http_code}" "$URL")

if [ $? -ne 0 ]; then
    echo "❌ [ไม่ผ่าน] ไม่สามารถส่ง Request ไปยัง API ได้ (Connection Timeout) หรือเซิร์ฟเวอร์ไม่ตอบสนอง"
    echo ""
    echo "🛠️ คำสั่ง SSH สำหรับเข้าไปดู Log เครื่อง EC2:"
    echo "ssh -i /path/to/your-key.pem ubuntu@$IP \"tail -f /path/to/app.log\""
    exit 1
fi

# แยกบรรทัดสุดท้าย (Status Code) ออกจาก Body
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

# ตรวจสอบว่า Status Code เป็น 200 หรือไม่
if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
    echo "✅ [ผ่าน] ได้รับ HTTP Status: $HTTP_STATUS"
    
    # ตรวจสอบรูปแบบว่าชิ้นส่วนเริ่มต้นและลงท้ายด้วย {} หรือ [] ของ JSON (การเช็คแบบเบื้องต้น)
    if echo "$HTTP_BODY" | grep -qE '^(\{.*\}|\[.*\])$'; then
        echo "✅ [ผ่าน] ได้รับข้อมูลตอบกลับเป็น JSON:"
        echo "$HTTP_BODY"
    else
        echo "⚠️ [คำเตือน] ได้รับการตอบกลับ แต่ข้อมูลไม่ได้อยู่ในรูปแบบ JSON ปกติ:"
        echo "$HTTP_BODY"
    fi
else
    echo "❌ [ไม่ผ่าน] API ตอบกลับมาเป็น HTTP Status Error: $HTTP_STATUS"
    echo "📦 รายละเอียดตอบกลับ: $HTTP_BODY"
    echo ""
    echo "🛠️ คำสั่ง SSH สำหรับเข้าไปดู Log ว่าทำไม API ถึง Error:"
    echo "ssh -i /path/to/your-key.pem ubuntu@$IP \"tail -f /path/to/app.log\""
fi

echo "==============================================="
