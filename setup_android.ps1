# Run this script AFTER you run 'flutter create .' to configure Android settings for VaultNote

$manifestPath = "android\app\src\main\AndroidManifest.xml"
$buildGradlePath = "android\app\build.gradle"

if (-Not (Test-Path $manifestPath)) {
    Write-Host "Error: AndroidManifest.xml not found. Please run 'flutter create .' first." -ForegroundColor Red
    exit
}

# 1. Update AndroidManifest.xml for permissions
$manifestContent = Get-Content $manifestPath -Raw

$permissions = @"
    <!-- VaultNote Permissions -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
"@

if ($manifestContent -notmatch "USE_BIOMETRIC") {
    $manifestContent = $manifestContent -replace '<application', "$permissions`n    <application"
    Set-Content -Path $manifestPath -Value $manifestContent
    Write-Host "Added permissions to AndroidManifest.xml" -ForegroundColor Green
} else {
    Write-Host "Permissions already exist in AndroidManifest.xml" -ForegroundColor Yellow
}

# 2. Update build.gradle for minSdkVersion 23 (required for flutter_secure_storage and local_auth)
if (-Not (Test-Path $buildGradlePath)) {
    Write-Host "Error: app/build.gradle not found." -ForegroundColor Red
    exit
}

$gradleContent = Get-Content $buildGradlePath -Raw
$gradleContent = $gradleContent -replace 'minSdkVersion flutter.minSdkVersion', 'minSdkVersion 23'
$gradleContent = $gradleContent -replace 'minSdkVersion flutter.ndkVersion', 'minSdkVersion 23'

Set-Content -Path $buildGradlePath -Value $gradleContent
Write-Host "Updated minSdkVersion to 23 in build.gradle" -ForegroundColor Green

Write-Host "`nAndroid setup complete! You are ready to run the app on your Samsung S22." -ForegroundColor Cyan
