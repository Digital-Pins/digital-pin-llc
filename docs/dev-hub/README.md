# GitLab + GitHub Management Guide
## دليل إدارة GitLab و GitHub معاً

### 📋 الوضع الحالي للمشروع
- **المستودع الرئيسي**: موجود على GitLab و GitHub
- **digital-pins.github.io**: مستودع منفصل على GitHub
- **dolibarr-custom**: مستودع منفصل على GitHub

### 🚀 الاستخدام السريع

#### مزامنة تلقائية
```bash
# تشغيل المزامنة التلقائية
./scripts/dev-hub/gitlab-github-sync.sh
```

#### مزامنة يدوية
```bash
# دفع لـ GitHub فقط
git push origin main

# دفع لـ GitLab فقط
git push gitlab main

# سحب من GitHub
git pull origin main

# سحب من GitLab
git pull gitlab main
```

### 📊 مراقبة الحالة

#### فحص الاختلافات
```bash
# مقارنة مع GitHub
git log --oneline origin/main..HEAD  # commits لديك وليس على GitHub
git log --oneline HEAD..origin/main  # commits على GitHub وليس لديك

# مقارنة مع GitLab
git log --oneline gitlab/main..HEAD  # commits لديك وليس على GitLab
git log --oneline HEAD..gitlab/main  # commits على GitLab وليس لديك
```

#### فحص المستودعات الفرعية
```bash
# فحص digital-pins.github.io
cd digital-pins.github.io && git status && cd ..

# فحص dolibarr-custom
cd dolibarr-custom && git status && cd ..
```

### ⚠️ سيناريوهات شائعة وحلولها

#### 1. تضارب في الدمج
```bash
# عند حدوث تضارب
git status  # لرؤية الملفات المتضاربة
# عدل الملفات يدوياً
git add <file>
git commit -m "حل تضارب الدمج"
```

#### 2. فرق في عدد الـ commits
```bash
# إذا كان GitHub أمام
git pull origin main --rebase

# إذا كان GitLab أمام
git pull gitlab main --rebase
```

#### 3. مشاكل في المستودعات الفرعية
```bash
# إعادة ربط digital-pins.github.io
cd digital-pins.github.io
git remote set-url origin https://github.com/Digital-Pins/digital-pins.github.io.git
git pull origin main --allow-unrelated-histories
cd ..
```

### 🔧 الصيانة الدورية

#### تنظيف الـ branches
```bash
# حذف branches المدمجة
git branch -d branch-name

# حذف من remote
git push origin --delete branch-name
```

#### تحديث المستودعات الفرعية
```bash
# تحديث جميع المستودعات الفرعية
find . -name ".git" -type d -execdir git pull origin main \;
```

### 📞 الاتصال بالدعم

#### إذا واجهت مشاكل:
1. تحقق من الـ network connection
2. تأكد من صحة SSH keys
3. راجع الصلاحيات على كلا المنصتين
4. استخدم الـ sync script للمزامنة التلقائية

#### للمساعدة الفورية:
```bash
# تشغيل التشخيص
./scripts/dev-hub/gitlab-github-sync.sh --diagnose
```

### 📚 المراجع
- [دليل التفصيلي](GITLAB_GITHUB_GUIDE.md)
- [سكريبت المزامنة](../scripts/dev-hub/gitlab-github-sync.sh)
- [إعدادات Git](../.gitignore)

---

**نصيحة**: شغل المزامنة التلقائية يومياً لتجنب المشاكل الكبيرة! 🔄
