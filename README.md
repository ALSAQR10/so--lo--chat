# 💬 سواب (Sowab) — تطبيق مراسلة آمن

تطبيق مراسلة فوري مشابه لواتساب، يدعم **التشفير التام (E2EE)** باستخدام بروتوكول ECDH + AES-256-GCM.

---

## 🏗️ هيكل المشروع

```
sowab/
├── backend/                  # الخادم (Node.js)
│   ├── src/
│   │   ├── server.js         # نقطة الدخول الرئيسية
│   │   ├── config/
│   │   │   └── database.js   # اتصال PostgreSQL
│   │   ├── controllers/
│   │   │   ├── authController.js        # التسجيل والدخول
│   │   │   ├── messageController.js     # إرسال وجلب الرسائل
│   │   │   ├── conversationController.js # المحادثات والمجموعات
│   │   │   └── uploadController.js      # رفع الملفات
│   │   ├── middleware/
│   │   │   └── auth.js       # التحقق من JWT
│   │   ├── routes/
│   │   │   └── index.js      # جميع المسارات
│   │   ├── services/
│   │   │   └── socketService.js  # WebSocket (Socket.io)
│   │   └── utils/
│   │       └── migrate.js    # إنشاء قاعدة البيانات
│   ├── Dockerfile
│   ├── package.json
│   └── .env.example
│
├── frontend/                 # الواجهة الأمامية
│   ├── index.html            # التطبيق الكامل (HTML + JS + CSS)
│   └── src/
│       └── utils/
│           ├── crypto.js     # تشفير E2EE (Web Crypto API)
│           ├── api.js        # طلبات HTTP
│           └── socket.js     # WebSocket client
│
├── docker-compose.yml        # نشر بأمر واحد
├── nginx.conf                # إعداد Nginx
└── README.md
```

---

## ⚙️ المتطلبات

| الأداة | الإصدار |
|--------|---------|
| Node.js | 18+ |
| PostgreSQL | 14+ |
| npm | 8+ |
| Docker (اختياري) | 24+ |

---

## 🚀 التشغيل المحلي (خطوة بخطوة)

### 1. إعداد قاعدة البيانات

```bash
# تثبيت PostgreSQL (Ubuntu/Debian)
sudo apt install postgresql postgresql-contrib

# أو macOS
brew install postgresql@15

# إنشاء المستخدم والقاعدة
sudo -u postgres psql
```

```sql
CREATE USER sowab_user WITH PASSWORD 'your_password';
CREATE DATABASE sowab_db OWNER sowab_user;
GRANT ALL PRIVILEGES ON DATABASE sowab_db TO sowab_user;
\q
```

---

### 2. إعداد الـ Backend

```bash
cd backend

# نسخ ملف البيئة
cp .env.example .env

# عدّل القيم في .env
nano .env
```

**القيم المهمة في `.env`:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sowab_db
DB_USER=sowab_user
DB_PASSWORD=your_password
JWT_SECRET=your_random_64_char_secret_here
FRONTEND_URL=http://localhost:3000
```

```bash
# تثبيت الاعتماديات
npm install

# إنشاء جداول قاعدة البيانات
npm run db:migrate

# تشغيل الخادم
npm run dev
```

✅ الخادم يعمل على: `http://localhost:3001`

---

### 3. تشغيل الـ Frontend

```bash
cd frontend

# فتح مباشرة في المتصفح
open index.html

# أو استخدم أي خادم ثابت
npx serve . -p 3000
```

✅ التطبيق على: `http://localhost:3000`

---

## 🐳 التشغيل بـ Docker (الأسهل)

```bash
# في جذر المشروع
docker compose up -d

# مشاهدة اللوج
docker compose logs -f backend

# إيقاف التشغيل
docker compose down
```

✅ التطبيق على: `http://localhost:3000`
✅ الـ API على: `http://localhost:3001`

---

## 🔌 API Endpoints

### المصادقة
| Method | Path | الوصف |
|--------|------|-------|
| POST | `/api/auth/register` | إنشاء حساب جديد |
| POST | `/api/auth/login` | تسجيل الدخول |
| POST | `/api/auth/logout` | تسجيل الخروج |
| GET | `/api/auth/me` | بيانات المستخدم الحالي |
| GET | `/api/auth/key/:userId` | المفتاح العام لمستخدم |

### المحادثات
| Method | Path | الوصف |
|--------|------|-------|
| GET | `/api/conversations` | جلب كل المحادثات |
| POST | `/api/conversations/direct` | بدء محادثة فردية |
| POST | `/api/conversations/group` | إنشاء مجموعة |
| GET | `/api/users/search?q=` | البحث عن مستخدمين |

### الرسائل
| Method | Path | الوصف |
|--------|------|-------|
| GET | `/api/messages/:convId` | جلب رسائل محادثة |
| POST | `/api/messages` | إرسال رسالة |
| DELETE | `/api/messages/:id` | حذف رسالة |

### الرفع
| Method | Path | الوصف |
|--------|------|-------|
| POST | `/api/upload/media` | رفع صورة/ملف |
| POST | `/api/upload/avatar` | رفع صورة شخصية |
| PUT | `/api/profile` | تحديث الملف الشخصي |

---

## 🔐 كيف يعمل التشفير E2EE

```
التسجيل:
1. العميل يولّد زوج مفاتيح ECDH (P-256)
2. يشفّر المفتاح الخاص بكلمة المرور (PBKDF2 + AES-256-GCM)
3. يرسل: المفتاح العام + المفتاح الخاص المشفّر → الخادم
4. الخادم يخزّنهما لكنه لا يستطيع فك تشفير المفتاح الخاص!

إرسال رسالة:
1. العميل A يجلب المفتاح العام للعميل B من الخادم
2. يشتق سراً مشتركاً: ECDH(خاص_A, عام_B) = سر مشترك
3. يشفّر الرسالة: AES-256-GCM(سر_مشترك, نص_الرسالة) = نص مشفر
4. يرسل النص المشفر للخادم
5. الخادم يخزّن ويوجّه النص المشفر → لا يرى المحتوى أبداً

استقبال رسالة:
1. العميل B يجلب الرسالة المشفرة
2. يشتق نفس السر: ECDH(خاص_B, عام_A) = سر مشترك
3. يفك التشفير: AES-256-GCM-Decrypt(سر_مشترك, مشفر) = النص الأصلي
```

---

## 🔄 WebSocket Events

| الحدث | الاتجاه | الوصف |
|-------|---------|-------|
| `new_message` | خادم → عميل | رسالة جديدة |
| `typing_start` | عميل → خادم → عملاء | بدء الكتابة |
| `typing_stop` | عميل → خادم → عملاء | توقف الكتابة |
| `mark_read` | عميل → خادم | تم القراءة |
| `message_read` | خادم → عميل | تأكيد القراءة |
| `user_status` | خادم → عملاء | تغير حالة مستخدم |
| `message_deleted` | خادم → عملاء | حذف رسالة |
| `call_offer` | عميل → خادم → عميل | WebRTC بدء مكالمة |
| `call_answer` | عميل → خادم → عميل | WebRTC قبول المكالمة |

---

## 🛡️ الأمان

- **bcrypt** cost=12 لتشفير كلمات المرور
- **JWT** مع انتهاء صلاحية 7 أيام
- **Rate Limiting**: 100 طلب/15 دقيقة، 10 محاولات دخول/15 دقيقة
- **Helmet.js** لحماية headers
- **CORS** مقيّد للـ Frontend URL فقط
- الخادم **لا يقرأ** محتوى الرسائل أبداً (E2EE حقيقي)
- المفاتيح الخاصة **لا تغادر** الجهاز بنصها الواضح

---

## 📱 للنشر على السحابة (Render / Railway / VPS)

### Render.com (مجاناً)
1. ارفع المشروع على GitHub
2. أنشئ **Web Service** للـ backend
3. أنشئ **PostgreSQL** database
4. أضف متغيرات البيئة
5. ارفع frontend على **Static Site**

### VPS (DigitalOcean / Hetzner)
```bash
# على السيرفر
git clone <repo>
cd sowab
cp backend/.env.example backend/.env
# عدّل .env
docker compose up -d
```

---

## 🗺️ خارطة الطريق (Road Map)

- [x] تسجيل / دخول مع E2EE
- [x] محادثات فردية مشفرة
- [x] WebSocket فوري
- [x] رفع الصور والملفات
- [x] مؤشر الكتابة
- [x] حالة القراءة ✓✓
- [ ] مكالمات صوتية (WebRTC)
- [ ] المجموعات مع Sender Key
- [ ] الرسائل المؤقتة (تدمير ذاتي)
- [ ] النسخ الاحتياطي المشفر
- [ ] تطبيق موبايل (React Native)

---

**بُني بـ ❤️ — جميع الرسائل مشفرة**
