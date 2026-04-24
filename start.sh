#!/bin/bash
# ══════════════════════════════════════════
#  SOWAB — Quick Start Script
#  تشغيل: chmod +x start.sh && ./start.sh
# ══════════════════════════════════════════

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${GREEN}"
echo "  ███████╗ ██████╗ ██╗    ██╗ █████╗ ██████╗ "
echo "  ██╔════╝██╔═══██╗██║    ██║██╔══██╗██╔══██╗"
echo "  ███████╗██║   ██║██║ █╗ ██║███████║██████╔╝"
echo "  ╚════██║██║   ██║██║███╗██║██╔══██║██╔══██╗"
echo "  ███████║╚██████╔╝╚███╔███╔╝██║  ██║██████╔╝"
echo "  ╚══════╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═════╝ "
echo -e "${NC}"
echo -e "${BLUE}  سواب — Secure Messaging App${NC}"
echo ""

# ─── التحقق من المتطلبات ───────────────────
echo -e "${YELLOW}🔍 التحقق من المتطلبات...${NC}"

if ! command -v node &>/dev/null; then
  echo -e "${RED}❌ Node.js غير مثبت. حمّله من https://nodejs.org${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Node.js $(node -v)${NC}"

if ! command -v psql &>/dev/null; then
  echo -e "${YELLOW}⚠️  PostgreSQL غير موجود محلياً — سيُستخدم Docker إذا توفر${NC}"
  USE_DOCKER=1
fi

# ─── إعداد Backend ────────────────────────
echo ""
echo -e "${YELLOW}📦 تثبيت اعتماديات Backend...${NC}"
cd backend
npm install --silent

if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${GREEN}✅ تم إنشاء ملف .env${NC}"
  echo -e "${YELLOW}⚠️  يرجى تعديل backend/.env بمعلومات قاعدة البيانات ثم أعد التشغيل${NC}"
  echo ""
  echo "  DB_HOST=localhost"
  echo "  DB_NAME=sowab_db"
  echo "  DB_USER=sowab_user"
  echo "  DB_PASSWORD=your_password"
  echo "  JWT_SECRET=$(openssl rand -hex 32 2>/dev/null || echo 'change_this_secret')"
  echo ""
  exit 0
fi

echo -e "${YELLOW}🗄️  إنشاء جداول قاعدة البيانات...${NC}"
node src/utils/migrate.js && echo -e "${GREEN}✅ قاعدة البيانات جاهزة${NC}"

cd ..

# ─── تشغيل الخادم ─────────────────────────
echo ""
echo -e "${GREEN}🚀 تشغيل سواب...${NC}"
echo ""
echo -e "  ${BLUE}Backend API:${NC}  http://localhost:3001"
echo -e "  ${BLUE}Frontend:${NC}     افتح frontend/index.html في المتصفح"
echo -e "  ${BLUE}Health:${NC}       http://localhost:3001/health"
echo ""
echo -e "${YELLOW}اضغط Ctrl+C للإيقاف${NC}"
echo ""

cd backend && npm run dev
