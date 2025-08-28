````

---

## ملاحق تنفيذية (تم تنفيذه الآن)

أدرجت أدناه الكود والـ CSS واللوحة اللونية الخاصة بمكون المنصة (PlatformHero) الذي طُبّق كمسودة مرئية من لقطات التصميم.

- موقع المكون: `src/components/PlatformHero.tsx`
- ملف الأنماط: `src/components/PlatformHero.module.css`

SVG (الـ warp — نسخة مقتطفة من لقطة الشاشة):

```html
<svg viewBox="0 0 520 200" class="hero-svg" aria-hidden="true">
	<defs>
		<linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
			<stop offset="0%" stop-color="#E8C76B"></stop>
			<stop offset="100%" stop-color="#D4AF37"></stop>
		</linearGradient>
	</defs>
	<g stroke="#0B1F3A" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round" opacity=".9">
		<line x1="60" y1="140" x2="60" y2="170"></line>
		<line x1="460" y1="140" x2="460" y2="170"></line>
		<line x1="40" y1="140" x2="480" y2="140"></line>
		<path d="M40 140 Q 260 40 480 140"></path>
	</g>
	<g class="dots" fill="url(#g)">
		<circle class="dot" cx="200" cy="100" r="4"></circle>
		<circle class="dot--alt" cx="260" cy="80" r="4"></circle>
		<circle class="dot" cx="320" cy="100" r="4"></circle>
	</g>
	<rect x="88" y="70" width="90" height="60" rx="8" fill="#ECF0F1" stroke="#2C3E50"></rect>
	<rect x="210" y="50" width="100" height="80" rx="10" fill="#ECF0F1" stroke="#2C3E50"></rect>
	<rect x="334" y="62" width="76" height="68" rx="8" fill="#ECF0F1" stroke="#2C3E50"></rect>
	<g fill="none" stroke="#2C3E50" opacity=".7">
		<path d="M320 40c6-12 18-18 30-16 10-16 36-12 44 4 16-2 28 10 28 22 0 14-12 24-26 24h-72c-10 0-18-8-18-18 0-8 6-14 14-16Z"></path>
	</g>
</svg>
```

CSS (snippets من `PlatformHero.module.css` — استخدمنا أسماء الأصناف التالية في المكون):

```css
:root{
	--brand-900: #0a2540; /* dark */
	--brand-500: #1e90ff; /* primary */
	--brand-400: #22c55e; /* accent */
}
.hero-card{ max-width:920px; margin:0 auto; padding:36px; border-radius:18px; background:linear-gradient(#fff,#fbfdff); box-shadow:0 10px 30px rgba(10,37,64,0.06); }
.hero-visual{ position:relative; border-radius:14px; padding:18px; background:#fff; border:1px solid rgba(0,0,0,0.06); box-shadow:0 4px 12px rgba(0,0,0,0.04); }
.hero-svg{ width:100%; height:180px; display:block }
.svg .dot{ fill:var(--brand-500) }
.svg .dot--alt{ fill:var(--brand-400) }
.platform{ height:10px; border-radius:6px; background:linear-gradient(90deg,var(--brand-900),#243a4f) }
.platform::before{ content:""; position:absolute; left:44px; bottom:-40px; width:6px; height:36px; background:var(--brand-900); box-shadow:260px 0 0 var(--brand-900),520px 0 0 var(--brand-900) }
@media (max-width:640px){ .hero-svg{ height:140px } }
```

لوحة الألوان المطبقة:

- Dark / primary base: `#0a2540`
- Accent (button/indicator): `#1e90ff`
- Secondary accent: `#22c55e`

الملفات والتغييرات التي أنشأت/عدّلتها الآن:

- A  src/components/PlatformHero.tsx  — مكون جديد (مُدرج في الصفحة الرئيسية)
- A  src/components/PlatformHero.module.css — أنماط المكون مع متغيرات الألوان
- M  src/app/page.tsx — دمج `PlatformHero` أعلى `PlacementGroup`

التحقق: شغّلت `next build` و `next start` محلياً بعد التعديلات — البناء نجح والصفحة تُعرض على http://localhost:3000

تشغيل/تجربة محلية سريعة:

```bash
# تشغيل dev مع HMR
cd /home/pin2/digital-pin-llc/digital-pin-llc
npm run dev

# أو معاينة البناء (production)
npm run build && PORT=3000 npm run start
```

إذا تريد، أدمج الآن الـ SVG الأصلي بالكامل داخل `PlatformHero.tsx` (مع إضافة أصناف `.dot` و`.dot--alt`) وأكرره هنا مع commit ورسالة مفصّلة. أطبّق ذلك الآن إذا أعطيت الإذن.

## خطة عمل غداً — تنفيذ منقح من لقطات التصميم

مكان الملفات: `docs/design-snapshots/`

الهدف: تحويل لقطات التصميم إلى بداية عمل في الريبو (فرع مخصص، نسخ الأصول، commit مبدئي)، وتشغيل خطوات التأسيس مرة واحدة غداً.

مهام مذكورة هنا سيتم تنفيذها بواسطة السكربت `run-tomorrow.sh` الموجود في هذا المجلد. اقرأ التعليمات قبل التشغيل.

قائمة المهام (ترتيب التنفيذ):

1. إنشاء فرع عمل جديد: `feature/design-from-snapshots`
2. إنشاء مجلد موارد: `public/design-assets/`
3. نسخ كل لقطات التصميم من `docs/design-snapshots/` إلى `public/design-assets/`
4. عمل git add/commit للأصول المضافة: `chore: add design snapshots assets`
5. (اختياري) إنشاء ملفات skeleton لصفحات Next.js الأساسية إن رغبت: `home`, `about`, `projects`, `service`, `contact` — السكربت سيعرض خطوة تنفيذية لذلك ويمكن تفعيلها.

كيفية الاستخدام (آمن، dry-run افتراضي):

1. افحص السكربت `run-tomorrow.sh` في نفس المجلد.
2. لتشغيل تجريبي (لن يغيّر شيئًا، يعرض فقط ما سيفعله):

```bash
# من جذر المشروع
bash docs/design-snapshots/run-tomorrow.sh
```

3. للتنفيذ الفعلي (نفّذ بنفسك غداً أو عندما تكون جاهزًا):

```bash
# ملاحظة: سيجرى تغييرات git محلية. تأكد من عمل commit/ stash لأي تغييرات حالية.
bash docs/design-snapshots/run-tomorrow.sh --run
```

ملاحظات أمنية وتشغيلية:
- السكربت لن يدفع التغييرات إلى أي remote تلقائيًا.
- السكربت يفترض أنك تعمل من جذر المشروع وتملك صلاحيات git المناسبة.
- إن أردت جعل السكربت قابلاً للتنفيذ تلقائيًا عبر نظام جدولة، أخبرني وسأقترح طريقة آمنة (systemd timer أو cron) بعد موافقتك.

التأريخ: إنشاء الخطة: $(date +%Y-%m-%d)
