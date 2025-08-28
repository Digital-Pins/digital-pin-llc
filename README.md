# Digital PIN LLC (الجسر الرقمي)

Unified digital & engineering solutions: custom ERP (Dolibarr), learning platforms, and engineering products (solar structures, signage kiosks).

## 🌐 Frontend (This Repo)
Next.js 14 + App Router + TypeScript + Tailwind.

## 🧱 Related Backends
- Strapi (CMS / Headless content / KB)
- Dolibarr (ERP custom fork) ـ إدارة الموارد

## 🚀 Getting Started
```bash
git clone https://github.com/Digital-Pins/digital-pin-llc.git
cd digital-pin-llc/digital-pin-llc
npm install
npm run dev
```
Visit: http://localhost:3000

Edit `app/page.tsx` and save; hot reload will refresh.

## 🛠️ Tech Stack
- Next.js 14
- React / TypeScript
- Tailwind CSS
- (Planned) Playwright for E2E tests

## ✅ Smoke Test (اختبار سريع)
سلسلة أوامر سريعة للتحقق قبل فتح PR أو بعد نشر محلي:
```bash
# 1. إظهار الإصدارات
node -v && npx next --version

# 2. تثبيت نظيف (في CI استعمل npm ci)
npm install

# 3. فحص بناء سريع (قد يتجاهل خيار --dry-run)
npm run build --dry-run 2>/dev/null || echo "(قد لا يدعم --dry-run)"

# 4. تشغيل dev مؤقتاً ثم طلب الصفحة الرئيسية
npm run dev & DEV_PID=$!; sleep 6; curl -I http://localhost:3000 | head -n 1; kill $DEV_PID

# 5. Lint إن وُجد سكربت
npm run lint || echo "Lint skipped"

# 6. تحقق من ملفات أساسية
[ -f next.config.ts ] && echo "next.config.ts OK" || echo "Missing next.config.ts"
[ -d app ] && echo "app dir OK" || echo "Missing app dir"
```
نتائج متوقعة:
- سطر يحتوي HTTP/1.1 200 أو 304.
- عدم وجود أخطاء قاتلة في البناء.
- ظهور نسخ Node و Next.

## 🧪 CI (مثال مبسط)
```bash
npm ci
npm run build
npx next export || echo "(اختياري)"
```

## 📂 هيكل (مختصر)
```
digital-pin-llc/
  app/
  components/
  public/
  styles/
  tests/
```
أضف لاحقاً:
- tests/unit لاختبارات منطقية.
- tests/e2e لاختبارات الواجهة (Playwright).

## 🤝 المساهمة
افتح Issue أو PR. حافظ على بساطة الـ commits. استخدم فروع feature/*.

## 🧭 الخطوات القادمة (Roadmap)
- دمج Playwright.
- إضافة ESLint + Prettier config محسّن (إن لم يكن موجوداً).
- ربط مع Strapi endpoints.
- مكون 3D (Three.js) للمعرض الهندسي.

## 📄 الترخيص
انظر LICENSE.

---
© Digital PIN LLC