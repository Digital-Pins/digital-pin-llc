#!/bin/bash

# GitLab + GitHub Sync Script for Digital PIN LLC
# سكريبت مزامنة بين GitLab و GitHub

set -e  # توقف عند أول خطأ

echo "🔄 بدء مزامنة GitLab + GitHub..."
echo "================================="

# التحقق من الحالة الحالية
echo "📊 فحص الحالة الحالية..."
git status --short

# جلب آخر التحديثات من كلا المنصتين
echo "📥 جلب التحديثات..."
git fetch --all --prune

# فحص الاختلافات
echo "🔍 فحص الاختلافات..."
echo "مع GitHub:"
git log --oneline HEAD..origin/main | head -5 || echo "لا توجد اختلافات"

echo "مع GitLab:"
git log --oneline HEAD..gitlab/main | head -5 || echo "لا توجد اختلافات"

# دمج التحديثات من GitHub
echo "🔀 دمج تحديثات GitHub..."
if git log --oneline HEAD..origin/main | grep -q .; then
    echo "⚠️  توجد تحديثات على GitHub - جاري الدمج..."
    git merge origin/main --no-edit
else
    echo "✅ GitHub محدث"
fi

# دمج التحديثات من GitLab
echo "🔀 دمج تحديثات GitLab..."
if git log --oneline HEAD..gitlab/main | grep -q .; then
    echo "⚠️  توجد تحديثات على GitLab - جاري الدمج..."
    git merge gitlab/main --no-edit
else
    echo "✅ GitLab محدث"
fi

# دفع لكلا المنصتين
echo "📤 دفع لكلا المنصتين..."
echo "دفع لـ GitHub..."
git push origin HEAD

echo "دفع لـ GitLab..."
git push gitlab HEAD

# تحديث المستودعات الفرعية
echo "🔄 تحديث المستودعات الفرعية..."

if [ -d "digital-pins.github.io" ]; then
    echo "تحديث digital-pins.github.io..."
    cd digital-pins.github.io
    git pull origin main
    git push origin main
    cd ..
fi

if [ -d "dolibarr-custom" ]; then
    echo "تحديث dolibarr-custom..."
    cd dolibarr-custom
    git pull origin main
    git push origin main
    cd ..
fi

echo "✅ انتهت المزامنة بنجاح!"
echo "📊 الحالة النهائية:"
git log --oneline --graph --all --decorate -n 5
