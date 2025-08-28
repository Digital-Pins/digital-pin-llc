# Digital PIN CMS Module

## Overview
نظام إدارة المحتوى (CMS) لشركة Digital PIN - مدعوم بالذكاء الاصطناعي

## Features
- إدارة المحتوى الرقمي
- تخطيط المحتوى الشهري
- تحسين المحتوى لمحركات البحث
- إدارة الوسائط المتعددة

## AI Agent
يستخدم هذا المشروع وكيل ذكاء اصطناعي متخصص في إدارة المحتوى:

```python
# من main.py
class CMSAgent(AIManager):
    def __init__(self):
        super().__init__("CMS Content Strategist")

    def plan_updates(self):
        return self.ask("Generate a structured plan for content updates this month.")
```

## Usage
لاستخدام وكيل CMS عبر API:

```bash
curl -X POST http://127.0.0.1:8000/digitalpin/ai \
  -H "Content-Type: application/json" \
  -d '{"user":"your_name","message":"Generate content plan for CMS"}'
```

## Structure
```
cms/
├── content/          # ملفات المحتوى
├── templates/        # قوالب الصفحات
├── assets/          # الوسائط (صور، فيديوهات)
├── config/          # إعدادات CMS
└── README.md        # هذا الملف
```

## Next Steps
1. إنشاء قاعدة بيانات للمحتوى
2. تطوير واجهة إدارة المحتوى
3. إضافة نظام النشر التلقائي
4. تكامل مع ERP و Learning modules
