# خانه بهداشت پزشک خانواده

اپلیکیشن آفلاین و مینیمال برای ثبت اعضای خانواده، تاریخ تولد دقیق شمسی و یادآوری مراقبت‌ها و واکسیناسیون.

## Build

```bash
flutter pub get
flutter create . --platforms=android --org ir.khane.behdasht
python3 tool/prepare_android.py
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## نکته انتشار

برای انتشار پایدار در کافه‌بازار، کلید امضای Release را خارج از مخزن نگه دارید و برای نسخه‌های بعدی همیشه از همان کلید استفاده کنید.

برنامه به‌صورت آفلاین کار می‌کند و برای GPS، حساب کاربری یا سرور نیازی ندارد.
