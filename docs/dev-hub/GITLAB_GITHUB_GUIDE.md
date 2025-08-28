# دليل إدارة GitLab + GitHub لمشروع Digital PIN LLC

## 🎯 الوضع الحالي
- **المستودع الرئيسي**: مزدوج (GitLab + GitHub)
- **digital-pins.github.io**: مستودع منفصل على GitHub
- **dolibarr-custom**: مستودع منفصل على GitHub

## 📋 إستراتيجية الإدارة المقترحة

### 1. المستودع الرئيسي (مزدوج)
```bash
# دفع لـ GitHub
git push origin main

# دفع لـ GitLab
git push gitlab main
```

### 2. المستودعات الفرعية
```bash
# تحديث digital-pins.github.io
cd digital-pins.github.io
git pull origin main
git push origin main

# تحديث dolibarr-custom
cd ../dolibarr-custom
git pull origin main
git push origin main
```

## ⚠️ المخاطر المحتملة

### ❌ تضارب في الـ commits
**المشكلة**: نفس الملف تم تعديله على GitLab و GitHub
**الحل**: استخدم workflow موحد

### ❌ تضارب في الـ branches
**المشكلة**: branch موجود على GitHub وليس على GitLab
**الحل**: مزامنة الـ branches بانتظام

### ❌ تضارب في الـ tags
**المشكلة**: tag مختلف على كل platform
**الحل**: إنشاء tags من مكان واحد

## 🛠️ أدوات وأوامر مفيدة

### فحص حالة المزامنة
```bash
# مقارنة مع GitHub
git log --oneline origin/main..HEAD
git log --oneline HEAD..origin/main

# مقارنة مع GitLab
git log --oneline gitlab/main..HEAD
git log --oneline HEAD..gitlab/main
```

### مزامنة آمنة
```bash
# سحب من كلا المنصتين
git fetch --all

# دمج التغييرات
git merge origin/main
git merge gitlab/main

# حل التعارضات إذا حدثت
# ثم دفع لكلا المنصتين
```

## 📊 سيناريوهات الاستخدام

### السيناريو 1: تطوير محلي
```bash
# اعمل التغييرات
git add .
git commit -m "تطوير ميزة جديدة"

# ادفع لكلا المنصتين
git push origin HEAD
git push gitlab HEAD
```

### السيناريو 2: تحديث من GitHub
```bash
git fetch origin
git checkout main
git merge origin/main
git push gitlab main
```

### السيناريو 3: تحديث من GitLab
```bash
git fetch gitlab
git checkout main
git merge gitlab/main
git push origin main
```

## 🔧 إعدادات موصى بها

### 1. إعداد Git
```bash
git config --global user.name "اسمك"
git config --global user.email "email@example.com"
```

### 2. إعداد SSH keys
```bash
# SSH key لـ GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub

# SSH key لـ GitLab
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_gitlab
cat ~/.ssh/id_ed25519_gitlab.pub
```

### 3. إعداد .gitignore مشترك
```bash
# ملفات محلية
.env.local
*.log
.DS_Store

# نسخ احتياطية
backups/
*.bak

# node_modules
node_modules/
```

## 🚨 إشارات التحذير

### 🔴 علامات خطر
- رسائل خطأ في git push
- اختلاف في عدد الـ commits
- تعارض في الدمج

### 🟡 علامات تحذير
- تأخير في المزامنة
- اختلاف في الـ branches

## 📞 خطة الطوارئ

### عند حدوث تضارب كبير:
```bash
# 1. احفظ العمل الحالي
git stash

# 2. عد للحالة الآمنة
git reset --hard origin/main

# 3. استرج العمل المحفوظ
git stash pop

# 4. أعد المزامنة
git pull --rebase origin main
```

## 🎯 التوصيات النهائية

### ✅ افعل:
- حدد platform رئيسي للتطوير
- مزامنة يومية
- استخدام branches للميزات الجديدة
- مراجعة التغييرات قبل الدفع

### ❌ لا تفعل:
- دفع مباشر لكلا المنصتين بدون فحص
- تجاهل رسائل التعارض
- العمل على نفس الملف من شخصين مختلفين

## 📈 مراقبة الأداء
- استخدم GitHub Actions للـ CI/CD
- استخدم GitLab CI/CD للنشر
- راقب الـ repository size
- نظف الـ branches القديمة بانتظام

---

**تذكير**: النجاح في إدارة GitLab + GitHub معاً يعتمد على الانضباط والتواصل الجيد بين الفريق.
