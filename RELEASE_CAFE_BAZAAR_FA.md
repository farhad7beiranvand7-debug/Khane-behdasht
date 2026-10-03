# آماده‌سازی انتشار در کافه‌بازار

کد پروژه و CI آماده شده‌اند تا پس از `flutter create`، تحلیل، تست و Build را در GitHub Actions انجام دهند. کافه‌بازار از AAB نیز پشتیبانی می‌کند. برای انتشار واقعی، مهم‌ترین موضوع باقی‌مانده **کلید امضای Release** است.

## GitHub Secrets

این چهار Secret را در مخزن GitHub بسازید:

- `BAZAAR_KEYSTORE_BASE64`
- `BAZAAR_KEYSTORE_PASSWORD`
- `BAZAAR_KEY_ALIAS`
- `BAZAAR_KEY_PASSWORD`

فایل keystore را هرگز داخل مخزن GitHub قرار ندهید.

پس از قرار دادن Secretها، اجرای Workflow نسخه Release را با همان کلید امضا می‌کند. برای همه نسخه‌های بعدی همین کلید باید حفظ شود.

اگر Secretها تنظیم نشده باشند، Workflow همچنان برای تست APK/AAB می‌سازد؛ اما قبل از انتشار نهایی در بازار باید امضای Release پایدار تنظیم شود.

بازار امکان انتشار با App Bundle را دارد و API پیشخان نیز برای CI/CD ارائه شده است.
