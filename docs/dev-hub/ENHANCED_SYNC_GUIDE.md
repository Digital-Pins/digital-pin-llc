# دليل المزامنة المحسن بين GitLab + GitHub

## 🚀 البدء السريع

### المزامنة التلقائية (موصى بها)
```bash
cd /path/to/digital-pin-llc
./scripts/dev-hub/gitlab-github-sync-v2.sh
```

### المزامنة اليدوية
```bash
# دفع لـ GitHub
git push origin main

# دفع لـ GitLab (مع معالجة الأخطاء)
git push gitlab main || ./scripts/dev-hub/gitlab-github-sync-v2.sh
```

## 📋 الميزات الجديدة

### ✅ معالجة أخطاء محسنة
- **شلل حل**: يتعامل مع قيود "shallow update" على GitLab
- **حل بديل**: إنشاء فروع جديدة عند فشل الدفع
- **استمرارية**: لا يتوقف عند فشل منصة واحدة

### ✅ إدارة المستودعات الفرعية
- **تلقائي**: يحدث digital-pins.github.io و dolibarr-custom
- **ذكي**: يتجاهل الأخطاء ويستمر
- **مرن**: يمكن إضافة مستودعات جديدة

### ✅ تقارير مفصلة
- **تتبع**: يسجل جميع العمليات
- **تشخيص**: يظهر الاختلافات بين المنصتين
- **إحصائيات**: يعرض عدد الملفات المنقولة

## 🔧 التخصيص

### تعديل الإعدادات
```bash
# تحرير ملف الإعدادات
nano scripts/dev-hub/sync-config.sh

# تغيير المنصة الرئيسية
PRIMARY_PLATFORM="gitlab"  # بدلاً من "github"
```

### إضافة مستودعات جديدة
```bash
# في ملف sync-config.sh
SUBMODULES_TO_SYNC=(
    "digital-pins.github.io"
    "dolibarr-custom"
    "new-submodule"  # أضف هنا
)
```

## 📊 مراقبة المزامنة

### فحص الحالة
```bash
# الاختلافات مع GitHub
git log --oneline origin/main..HEAD
git log --oneline HEAD..origin/main

# الاختلافات مع GitLab
git log --oneline gitlab/main..HEAD
git log --oneline HEAD..gitlab/main
```

### سجلات المزامنة
```bash
# عرض سجل المزامنة الأخير
cat logs/sync-$(date +%Y%m%d).log

# عرض جميع السجلات
ls -la logs/sync-*.log
```

## ⚠️ حل المشاكل الشائعة

### مشكلة: "shallow update not allowed"
**الحل**: السكريبت يتعامل مع هذا تلقائياً بإنشاء فرع جديد

### مشكلة: "Protected branch"
**الحل**: السكريبت ينشئ فروع جديدة بدلاً من الدفع المباشر

### مشكلة: تضارب في الدمج
```bash
# حل يدوي
git checkout --ours conflicted-file.txt
git add conflicted-file.txt
git commit -m "حل تضارب الدمج"
```

## 🔄 الجدولة التلقائية

### إعداد Cron Job
```bash
# تحرير crontab
crontab -e

# إضافة مهمة يومية الساعة 2 صباحاً
0 2 * * * cd /path/to/digital-pin-llc && ./scripts/dev-hub/gitlab-github-sync-v2.sh >> logs/cron-$(date +\%Y\%m\%d).log 2>&1
```

### إعداد systemd Timer
```bash
# نسخ ملفات الخدمة
sudo cp scripts/dev-hub/systemd/gitlab-github-sync.* /etc/systemd/system/

# تفعيل الخدمة
sudo systemctl daemon-reload
sudo systemctl enable gitlab-github-sync.timer
sudo systemctl start gitlab-github-sync.timer
```

## 📈 أفضل الممارسات

### 1. تحديد منصة رئيسية
```bash
# اجعل GitHub المنصة الرئيسية
PRIMARY_PLATFORM="github"

# استخدم GitLab للنسخ الاحتياطي فقط
BACKUP_PLATFORM="gitlab"
```

### 2. المزامنة المنتظمة
- شغل المزامنة يومياً
- راجع السجلات أسبوعياً
- نظف الفروع القديمة شهرياً

### 3. النسخ الاحتياطية
```bash
# تفعيل النسخ الاحتياطية التلقائية
BACKUP_BEFORE_SYNC=true
BACKUP_RETENTION_DAYS=30
```

## 🎯 سيناريوهات متقدمة

### مزامنة انتقائية
```bash
# مزامنة GitHub فقط
git push origin main

# مزامنة GitLab فقط
./scripts/dev-hub/gitlab-github-sync-v2.sh --gitlab-only

# مزامنة المستودعات الفرعية فقط
./scripts/dev-hub/gitlab-github-sync-v2.sh --submodules-only
```

### استرداد من كارثة
```bash
# من GitHub
git reset --hard origin/main

# من GitLab
git reset --hard gitlab/main

# مزامنة من جديد
./scripts/dev-hub/gitlab-github-sync-v2.sh
```

## 📞 الدعم والصيانة

### فحص صحة المزامنة
```bash
# تشغيل فحص تشخيصي
./scripts/dev-hub/gitlab-github-sync-v2.sh --diagnose

# فحص إعدادات Git
git remote -v
git config --list | grep -E "remote\.|branch\."
```

### تحديث السكريبت
```bash
# تحديث من المستودع
git pull origin main
chmod +x scripts/dev-hub/gitlab-github-sync-v2.sh
```

---

## 🎉 النتيجة النهائية

مع هذا النظام المحسن، ستحصل على:
- ✅ مزامنة تلقائية وموثوقة
- ✅ معالجة ذكية للأخطاء
- ✅ تقارير مفصلة عن العمليات
- ✅ إمكانية التخصيص حسب الحاجة
- ✅ نسخ احتياطية تلقائية

**النظام جاهز للاستخدام! 🚀**
