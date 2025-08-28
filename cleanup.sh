#!/bin/bash

# Digital PIN LLC - Cleanup Script
# تنظيف الملفات العالقة وتنظيم المشروع

echo "🧹 بدء عملية التنظيف لمشروع Digital PIN LLC..."
echo "=================================================="

# النسخ الاحتياطي من الملفات المهمة قبل الحذف
echo "📦 إنشاء نسخة احتياطية من الملفات المهمة..."
mkdir -p backups/cleanup-$(date +%Y%m%d-%H%M%S)

# نسخ الملفات المهمة
cp main.py backups/cleanup-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true
cp requirements.txt backups/cleanup-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true
cp .env backups/cleanup-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true

echo "✅ تم إنشاء النسخة الاحتياطية"

# حذف الملفات العالقة غير المهمة
echo "🗑️  حذف الملفات العالقة غير المهمة..."

# حذف ملفات Python المؤقتة
rm -rf __pycache__/ 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
find . -name "*.pyo" -delete 2>/dev/null || true

# حذف ملفات التقارير المؤقتة
rm -f BOOTSTRAP_CODE_ANALYSIS_REPORT.md 2>/dev/null || true

# حذف ملفات PHP المؤقتة
rm -f run_init_pin.php tmp_list_modules.php 2>/dev/null || true

# حذف مجلدات الصيانة القديمة (إذا كانت غير مطلوبة)
read -p "هل تريد حذف مجلدات الصيانة القديمة؟ (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf maintenance-4egtrust/ maintenance-4egtrust-repo/ 2>/dev/null || true
    echo "✅ تم حذف مجلدات الصيانة القديمة"
fi

# تنظيف مجلد backups
echo "🧽 تنظيف مجلد backups..."
find backups/ -name "*.tar.gz" -mtime +30 -delete 2>/dev/null || true
find backups/ -name "*.sql" -mtime +30 -delete 2>/dev/null || true
find backups/ -name "*.bak*" -mtime +30 -delete 2>/dev/null || true

# تنظيف الملفات المؤقتة
echo "🗂️  تنظيف الملفات المؤقتة..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true
find . -name "*.swp" -delete 2>/dev/null || true
find . -name ".DS_Store" -delete 2>/dev/null || true

# إعادة تعيين git status
echo "🔄 إعادة تعيين حالة git..."
git add . 2>/dev/null || true
git reset HEAD . 2>/dev/null || true

# عرض الحالة الجديدة
echo ""
echo "📊 الحالة بعد التنظيف:"
echo "========================"
git status --porcelain

echo ""
echo "✅ انتهى التنظيف بنجاح!"
echo "📁 النسخة الاحتياطية محفوظة في: backups/cleanup-$(date +%Y%m%d-%H%M%S)"
echo ""
echo "📋 الخطوات التالية المقترحة:"
echo "1. راجع الملفات المتبقية"
echo "2. أعد تشغيل الخادم للتأكد من عمله"
echo "3. قم بتجربة API endpoints"
echo "4. إذا كنت راضياً، يمكنك حذف مجلد backups القديم"
