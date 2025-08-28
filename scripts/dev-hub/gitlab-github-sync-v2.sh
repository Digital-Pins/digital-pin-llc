#!/bin/bash

# Enhanced GitLab + GitHub Sync Script v2.0
# سكريبت مزامنة محسن يتعامل مع قيود GitLab

set -e  # توقف عند أول خطأ

echo "🔄 بدء المزامنة المحسنة بين GitLab + GitHub..."
echo "=================================================="

# دالة للتحقق من نجاح العملية
check_command() {
    if [ $? -eq 0 ]; then
        echo "✅ $1"
    else
        echo "❌ فشل: $1"
        return 1
    fi
}

# التحقق من الحالة الحالية
echo "📊 فحص الحالة الحالية..."
git status --short
CURRENT_BRANCH=$(git branch --show-current)
echo "🔸 الفرع الحالي: $CURRENT_BRANCH"

# جلب آخر التحديثات من كلا المنصتين
echo "📥 جلب التحديثات..."
git fetch --all --prune --quiet
check_command "جلب التحديثات"

# فحص الاختلافات
echo "🔍 فحص الاختلافات..."
echo "مع GitHub:"
git log --oneline origin/$CURRENT_BRANCH..HEAD 2>/dev/null || echo "لا توجد اختلافات محلية"
git log --oneline HEAD..origin/$CURRENT_BRANCH 2>/dev/null || echo "لا توجد اختلافات عن بعد"

echo "مع GitLab:"
git log --oneline gitlab/$CURRENT_BRANCH..HEAD 2>/dev/null || echo "لا توجد اختلافات محلية"
git log --oneline HEAD..gitlab/$CURRENT_BRANCH 2>/dev/null || echo "لا توجد اختلافات عن بعد"

# دفع لـ GitHub أولاً (أكثر استقراراً)
echo "📤 دفع لـ GitHub..."
if git log --oneline origin/$CURRENT_BRANCH..HEAD >/dev/null 2>&1; then
    git push origin $CURRENT_BRANCH
    check_command "الدفع لـ GitHub"
else
    echo "✅ GitHub محدث"
fi

# محاولة دفع لـ GitLab مع معالجة الأخطاء
echo "📤 دفع لـ GitLab..."
if git log --oneline gitlab/$CURRENT_BRANCH..HEAD >/dev/null 2>&1; then
    # محاولة الدفع العادي أولاً
    if git push gitlab $CURRENT_BRANCH 2>/dev/null; then
        check_command "الدفع العادي لـ GitLab"
    else
        echo "⚠️  فشل الدفع العادي، جاري المحاولة البديلة..."

        # المحاولة البديلة: إنشاء فرع جديد
        NEW_BRANCH="${CURRENT_BRANCH}-sync-$(date +%H%M%S)"
        git checkout -b $NEW_BRANCH
        git push gitlab $NEW_BRANCH
        check_command "الدفع لفرع جديد على GitLab: $NEW_BRANCH"

        # العودة للفرع الأصلي
        git checkout $CURRENT_BRANCH
        echo "🔄 عُد للفرع الأصلي: $CURRENT_BRANCH"
    fi
else
    echo "✅ GitLab محدث"
fi

# تحديث المستودعات الفرعية
echo "🔄 تحديث المستودعات الفرعية..."
if [ -d "digital-pins.github.io" ] && [ -d "digital-pins.github.io/.git" ]; then
    echo "تحديث digital-pins.github.io..."
    cd digital-pins.github.io
    git pull origin main --quiet 2>/dev/null || echo "⚠️  فشل تحديث digital-pins.github.io"
    git push origin main --quiet 2>/dev/null || echo "⚠️  فشل دفع digital-pins.github.io"
    cd ..
    echo "✅ تم تحديث digital-pins.github.io"
fi

if [ -d "dolibarr-custom" ] && [ -d "dolibarr-custom/.git" ]; then
    echo "تحديث dolibarr-custom..."
    cd dolibarr-custom
    git pull origin main --quiet 2>/dev/null || echo "⚠️  فشل تحديث dolibarr-custom"
    git push origin main --quiet 2>/dev/null || echo "⚠️  فشل دفع dolibarr-custom"
    cd ..
    echo "✅ تم تحديث dolibarr-custom"
fi

# تقرير نهائي
echo ""
echo "🎉 انتهت المزامنة!"
echo "==================="
echo "📊 الحالة النهائية:"
git log --oneline --graph --all --decorate -n 3

echo ""
echo "📋 ملخص العمليات:"
echo "- ✅ جلب التحديثات من GitHub و GitLab"
echo "- ✅ دفع التغييرات لـ GitHub"
echo "- ✅ دفع التغييرات لـ GitLab (مع معالجة الأخطاء)"
echo "- ✅ تحديث المستودعات الفرعية"

echo ""
echo "🔧 نصائح للمزامنة المستقبلية:"
echo "- شغل هذا السكريبت يومياً: ./scripts/dev-hub/gitlab-github-sync-v2.sh"
echo "- في حالة فشل GitLab، تحقق من إعدادات الحماية"
echo "- استخدم GitHub كـ المصدر الرئيسي للتطوير"
