Deployment & Restore Report — 2025-08-21

1. Conversation Overview:
- Primary Objectives:
  - Create safe backups from the remote server, verify and copy them off-server before reinstalling the OS.
  - Restore the projects to the remote server, build and run them, configure nginx reverse proxy and obtain TLS for domains.
- Session Context: Backups were created on the Rescue environment and copied to local `/ssd2/backups`. Archives were extracted and rsynced to the remote host at `/home/pin2/digital-pin-llc` and `/home/pin2/cms`. Node/pnpm were installed on the server, both projects were built, systemd units and nginx config were created, and certbot was used to provision TLS for the domains.

2. Key Actions & Findings:
- Verified SHA256 checksums for the archives (all .tgz OK).
- Restored code to the remote and built:
  - Next.js site (`digital-pin-llc`) built and running on port 3000 behind nginx.
  - Strapi CMS (`cms`) built; initially failed as a systemd service due to module path and native binding issues.
- Diagnostics and fixes performed:
  - Inspected `cms-strapi.service` and project layout (`/home/pin2/cms/cms`).
  - Found the project configured for PostgreSQL in `.env`, but PostgreSQL was not present on the server.
  - Temporarily switched Strapi to use the packaged SQLite database (`.tmp/data.db`) to recover service quickly (original `.env` backed up).
  - Rebuilt native modules (better-sqlite3) by installing build dependencies and rebuilding from source, which allowed Strapi to start successfully.
  - Verified nginx configuration and that Let's Encrypt certificates for `4egtrust.com`, `cms.4egtrust.com`, and `staging.4egtrust.com` were created and valid.

3. Current State (summary):
- `digital-pin` (Next.js) — active, listening on :3000, proxied by nginx and served with a valid cert.
- `cms` (Strapi) — active, currently using the bundled SQLite `.tmp/data.db`; admin panel available at `/admin` and proxied by nginx with a valid cert.
- Certificates — Let's Encrypt cert installed for `4egtrust.com` with SANs for `cms.4egtrust.com` and `staging.4egtrust.com`.

4. Notes & Next Steps:
- If you want production-ready DB:
  - Install PostgreSQL, restore the Postgres dump (if available), revert `.env` to Postgres settings, and restart `cms-strapi.service`.
- If you prefer to keep SQLite for now:
  - Ensure `.tmp/data.db` and uploads are backed up regularly and consider moving uploads to persistent storage.
- Security/hardening suggestions:
  - Move secrets to a secure EnvironmentFile and update the systemd unit to use `EnvironmentFile=`.
  - Limit restart loops and add a monitoring/health check.

5. Provenance & backups:
- Original `.env` was backed up to `.env.bak.<timestamp>` in `/home/pin2/cms/cms`.
- Local verified archives remain in `/ssd2/backups/` on the local workstation.

Digital PIN LLC
شكر مقدم ل copilot

نسخة عربية

تقرير الاستعادة والنشر — 2025-08-21

1. ملخص المحادثة:
- الأهداف الرئيسية:
  - إنشاء نسخ احتياطية آمنة من السيرفر البعيد، التحقق منها ونقلها إلى جهاز محلي قبل إعادة تثبيت نظام التشغيل.
  - استعادة المشاريع على السيرفر البعيد، بناؤها وتشغيلها، إعداد nginx والحصول على شهادات TLS للنطاقات.
- سياق الجلسة: تمت إنشاء النسخ الاحتياطية على بيئة الإنقاذ (Rescue)، ونُقلت إلى المسار المحلي `/ssd2/backups`. فُكّت الأرشيفات ونُقلت إلى المضيف البعيد إلى `/home/pin2/digital-pin-llc` و`/home/pin2/cms`. تم تثبيت Node/pnpm على الخادم، وبُنيت المشاريع، وأنشئت وحدات systemd وتكوين nginx، واستخدمت certbot للحصول على الشهادات.

2. الإجراءات الرئيسية والنتائج:
- تم التحقق من SHA256 للملفات الأرشيفية (جميع ملفات .tgz بحالة OK).
- استعادة وبناء المشاريع على الخادم:
  - موقع Next.js (`digital-pin-llc`) بُني ويعمل على المنفذ 3000 خلف nginx.
  - CMS Strapi (`cms`) بُني؛ فشل مبدئياً عند التشغيل كنظام خدمة بسبب مسار الحزمة ومشاكل في وحدات native.
- التشخيص والإصلاحات:
  - فحصت `cms-strapi.service` وبنية المشروع في `/home/pin2/cms/cms`.
  - وُجد أن المشروع مُعد لاستخدام PostgreSQL في `.env` لكن PostgreSQL غير مثبت.
  - تم مؤقتاً تحويل Strapi لاستخدام SQLite المحلي `.tmp/data.db` لاستعادة الخدمة بسرعة (تم الاحتفاظ بنسخة احتياطية من `.env`).
  - أُعيد بناء الوحدات المحلية (better-sqlite3) بتثبيت أدوات البناء وبنائها من المصدر، مما سمح بتشغيل Strapi بنجاح.
  - التحقق من تكوين nginx وأن شهادات Let's Encrypt للنطاقات `4egtrust.com`, `cms.4egtrust.com`, `staging.4egtrust.com` صالحة.

3. الحالة الحالية:
- `digital-pin` (Next.js) — نشط، يستمع على :3000، مُمرّر عبر nginx ومؤمّن بشهادة صالحة.
- `cms` (Strapi) — نشط، يعمل حالياً باستخدام SQLite `.tmp/data.db`؛ لوحة الإدارة متاحة عبر `/admin` وممرّرة عبر nginx مع شهادة صالحة.
- الشهادات — شهادة Let's Encrypt مُنصبة للنطاق `4egtrust.com` مع SANs للنطاقات الفرعية.

4. ملاحظات وخطوات مقترحة:
- لإعداد إنتاجي مع PostgreSQL:
  - تثبيت PostgreSQL، استعادة نسخة القاعدة (إن وُجدت)، إعادة `.env` إلى إعدادات Postgres، وإعادة تشغيل `cms-strapi.service`.
- للحفاظ على SQLite مؤقتاً:
  - اجعل `.tmp/data.db` والمرفقات جزءاً من النسخ الاحتياطية الدورية ونقل المرفقات لمخزن دائم إذا لزم.
- اقتراحات أمنية:
  - نقل الأسرار إلى `EnvironmentFile` محمي وتحديث وحدة systemd لاستخدامه.
  - إضافة مراقبة وفحص صحي لتجنب حلقات إعادة التشغيل.

Digital PIN LLC
شكر مقدم ل copilot

## Local build run — 2025-08-21T02:04:27Z UTC

- digital-pin-llc build: exit code 1
- cms build: exit code 1

Logs:
- /tmp/dpl-build-logs-If6j/digital-pin-llc.build.log
- /tmp/dpl-build-logs-If6j/cms.build.log
