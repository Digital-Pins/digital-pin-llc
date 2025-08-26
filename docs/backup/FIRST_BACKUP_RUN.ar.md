# أول نسخة احتياطية (ERP Dev → OCI Object Storage)

الغرض: توثيق إجراء موحّد لتنفيذ أول نسخة ناجحة إلى OCI باستخدام السكربت الموحد `scripts/backup/oci-backup.sh`.

## النطاق
- البيئة: erp-dev (دوليبار المعدّل)
- الأصول: قاعدة بيانات MariaDB (dolibarr_dev) + مجلد المستندات + مسارات إضافية اختيارية
- الهدف: حاوية (Bucket) OCI باسم `bucket-pin`
- الأدوات: OCI CLI + السكربت oci-backup.sh + systemd timer

## المتطلبات المسبقة
1. تثبيت وإعداد OCI CLI (ملف `~/.oci/config`).
2. الحاوية `bucket-pin` موجودة ولدى المستخدم صلاحيات put/list/delete.
3. ملف كلمة مرور قاعدة البيانات موجود (مثال: `/root/dolibarr_dev-db.creds` — صلاحيات 600 يحتوي السطر فقط كلمة المرور).
4. مسار المستندات موجود: `/opt/dolibarr-dev/htdocs/documents`.
5. السكربت متوفر في: `/opt/dev-hub/scripts/backup/oci-backup.sh`.

## المتغيرات
| الاسم | مثال | ملاحظات |
|------|-------|---------|
| SERVICE | erp-dev | تُستخدم كوسم (Tag) و Prefix |
| DB_NAME | dolibarr_dev | فارغ = تخطي الـ DB |
| DB_USER | dolibarr_dev | مفضل مستخدم غير root |
| DB_PASS_FILE | /root/dolibarr_dev-db.creds | كلمة واحدة فقط |
| DOCS_PATH | /opt/dolibarr-dev/htdocs/documents | اختياري |
| BUCKET | bucket-pin | يجب أن يكون موجود مسبقاً |
| RETAIN | 7 | عدد النسخ الحديثة المراد الاحتفاظ بها |

## فحص الاتصال بالقاعدة
```
mysql -u dolibarr_dev -p"$(cat /root/dolibarr_dev-db.creds)" dolibarr_dev -e "SHOW TABLES LIMIT 3;"
```
عودة نتائج = اعتماد الكريدنشال ✅

## تشغيل Dry Run
```
sudo bash /opt/dev-hub/scripts/backup/oci-backup.sh \
  --service erp-dev \
  --bucket bucket-pin \
  --db-name dolibarr_dev \
  --db-user dolibarr_dev \
  --db-pass-file /root/dolibarr_dev-db.creds \
  --documents-path /opt/dolibarr-dev/htdocs/documents \
  --retain 7 \
  --dry-run
```
تأكد لا أخطاء (لن يتم رفع شيء).

## النسخة الفعلية الأولى
```
sudo bash /opt/dev-hub/scripts/backup/oci-backup.sh \
  --service erp-dev \
  --bucket bucket-pin \
  --db-name dolibarr_dev \
  --db-user dolibarr_dev \
  --db-pass-file /root/dolibarr_dev-db.creds \
  --documents-path /opt/dolibarr-dev/htdocs/documents \
  --retain 7
```

## التحقق بعد التنفيذ
```
oci os object list --bucket-name bucket-pin --prefix erp-dev/ | grep erp-dev_backup_
```
(اختياري) فحص سلامة:
```
OBJ=$(oci os object list --bucket-name bucket-pin --prefix erp-dev/ --fields name | grep 'erp-dev_backup_' | head -1 | sed 's/.*"name": "\(.*\)".*/\1/')
oci os object get --bucket-name bucket-pin --name "$OBJ" --file /tmp/test.tar.gz
sha256sum /tmp/test.tar.gz
```
قارن مع ملف `.sha256` المقابل.

## جدولة عبر systemd
```
sudo install -m 644 /opt/dev-hub/scripts/backup/systemd/devhub-oci-backup.service /etc/systemd/system/
sudo install -m 644 /opt/dev-hub/scripts/backup/systemd/devhub-oci-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now devhub-oci-backup.timer
systemctl list-timers | grep devhub-oci-backup
```
تشغيل يدوي للاختبار:
```
sudo systemctl start devhub-oci-backup.service
journalctl -u devhub-oci-backup.service -n 50 --no-pager
```

## أفضل الممارسات
- مستخدم قاعدة بيانات مخصص الأقل صلاحية.
- صلاحيات ملفات حساسة: (600) لكلمة مرور القاعدة والمفتاح الخاص.
- الإبقاء على تفعيل Versioning في الـ Bucket.
- مراقبة النجاح مستقبلاً عبر Prometheus أو تنبيه بسيط.
- تجنب ظهور كلمة المرور في سطر الأوامر.

## لماذا لا نستخدم سكربت بديل؟
| جانب | السكربت الموحد | سكربت بديل بسيط |
|------|----------------|-----------------|
| أرشيف موحد + checksum | نعم | لا |
| حذف قديم (Retention) عن بُعد | نعم | لا |
| تنظيم حسب prefix | نعم | يدوي |
| تقليل ظهور كلمة السر | نعم | لا |
| مخاطر التكرار | منخفضة | عالية |

## قائمة نجاح
| عنصر | حالة |
|------|-------|
| تحقق اتصال DB | ✅ |
| Dry Run نظيف | ✅ |
| أول أرشيف مرفوع | ✅ |
| تحقق checksum | ✅ |
| Retention بعد 7+ نسخ | ⏳ |
| Timer فعّال | ✅ |

## الخطوات التالية
- تعميم على الإنتاج (erp-prod).
- إضافة مراقبة آلية.
- إجراء اختبارات استرجاع دورية.

## مراجع
- `docs/backup/OCI_BACKUP_SETUP.md`
- `docs/backup/RESTORE_RUNBOOK.md`
