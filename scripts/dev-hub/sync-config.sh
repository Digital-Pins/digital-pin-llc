# GitLab + GitHub Sync Configuration
# إعدادات المزامنة بين GitLab و GitHub

# إعدادات عامة
SYNC_CONFIG_VERSION="2.0"
PRIMARY_PLATFORM="github"  # github أو gitlab
BACKUP_PLATFORM="gitlab"   # المنصة الاحتياطية

# إعدادات المزامنة
AUTO_RESOLVE_CONFLICTS=true
PREFER_LOCAL_CHANGES=true
CREATE_BACKUP_ON_CONFLICT=true

# قائمة المستودعات الفرعية للمزامنة
SUBMODULES_TO_SYNC=(
    "digital-pins.github.io"
    "dolibarr-custom"
)

# إعدادات GitLab (قد تحتاج تعديل حسب الصلاحيات)
GITLAB_PROTECTED_BRANCHES=("main" "master" "develop")
GITLAB_ALLOW_FORCE_PUSH=false

# إعدادات النسخ الاحتياطية
BACKUP_BEFORE_SYNC=true
BACKUP_RETENTION_DAYS=7

# إعدادات الإشعارات
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_FAILURE=true

# مسارات مهمة
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SYNC_LOG="$PROJECT_ROOT/logs/sync-$(date +%Y%m%d).log"

# إعدادات الاستثناءات
EXCLUDE_PATTERNS=(
    "*.log"
    "*.tmp"
    ".env"
    "node_modules/"
    ".next/"
)

# إعدادات الجدولة الزمنية
SYNC_INTERVAL_HOURS=24
AUTO_SYNC_ENABLED=false

# معلومات الاتصال
GITHUB_REMOTE="origin"
GITLAB_REMOTE="gitlab"

# إعدادات الأمان
REQUIRE_AUTH=true
VALIDATE_CERTIFICATES=true

# إعدادات التشخيص
DEBUG_MODE=false
VERBOSE_LOGGING=true
