# Environment Configuration Guide

## Overview
This document explains how to set up and manage environment variables for the Globin Care application.

## Files

### `.env` (Private - Not Tracked)
- Contains your actual sensitive configuration values
- **MUST be added to `.gitignore`** ✅ (Already configured)
- **NEVER commit this file to version control**
- Each developer maintains their own `.env` file locally

### `.env.example` (Public - Tracked)
- Template file showing required environment variables
- Contains no sensitive information
- Safe to commit to version control
- Use this as a reference for setting up your `.env` file

## Setup Instructions

### 1. Initial Setup
```bash
# Copy the example file to create your local .env file
cp .env.example .env

# Edit .env with your actual values
nano .env  # or use your preferred editor
```

### 2. Fill in Configuration Values

Replace all placeholder values in `.env` with your actual credentials:

```env
# API Configuration
API_BASE_URL=http://your-api-domain.com/api
API_TIMEOUT=30

# Database
DB_HOST=your_db_host
DB_PORT=5432
DB_NAME=your_db_name
DB_USER=your_db_user
DB_PASSWORD=your_secure_password

# JWT
JWT_SECRET_KEY=your_generated_jwt_secret_key

# Email (SMTP)
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Third-party Services
GOOGLE_CLIENT_ID=your_google_id
FIREBASE_API_KEY=your_firebase_key
STRIPE_SECRET_KEY=sk_test_xxx
```

## Environment Variables Reference

### App Configuration
- `APP_NAME` - Application name (default: Globin Care)
- `APP_ENV` - Environment type (development/staging/production)
- `DEBUG_MODE` - Enable debug logging (true/false)

### API Configuration
- `API_BASE_URL` - Backend API base URL
- `API_TIMEOUT` - Request timeout in seconds
- `AUTH_LOGIN_ENDPOINT` - Login endpoint
- `AUTH_LOGOUT_ENDPOINT` - Logout endpoint
- `AUTH_REFRESH_TOKEN_ENDPOINT` - Token refresh endpoint

### Database
- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password

### Authentication
- `JWT_SECRET_KEY` - JWT signing secret key
- `JWT_EXPIRY_HOURS` - Token expiry time in hours
- `JWT_REFRESH_EXPIRY_DAYS` - Refresh token expiry in days

### OAuth
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth secret
- `FACEBOOK_APP_ID` - Facebook app ID
- `FACEBOOK_APP_SECRET` - Facebook app secret

### Email (SMTP)
- `SMTP_HOST` - SMTP server host (e.g., smtp.gmail.com)
- `SMTP_PORT` - SMTP port (e.g., 587)
- `SMTP_USER` - SMTP username
- `SMTP_PASSWORD` - SMTP password (use app-specific password for Gmail)
- `SMTP_FROM_EMAIL` - Sender email address
- `SMTP_FROM_NAME` - Sender name

### SMS & Notifications
- `TWILIO_ACCOUNT_SID` - Twilio account SID
- `TWILIO_AUTH_TOKEN` - Twilio auth token
- `TWILIO_PHONE_NUMBER` - Twilio phone number

### Firebase
- `FIREBASE_API_KEY` - Firebase API key
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_MESSAGING_SENDER_ID` - Firebase sender ID
- `FIREBASE_APP_ID` - Firebase app ID

### Payment Gateway (Stripe)
- `STRIPE_PUBLIC_KEY` - Stripe publishable key
- `STRIPE_SECRET_KEY` - Stripe secret key
- `STRIPE_WEBHOOK_SECRET` - Webhook signing secret

### AWS
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region
- `AWS_S3_BUCKET` - S3 bucket name

### Feature Flags
- `ENABLE_TWO_FACTOR_AUTH` - Enable 2FA (true/false)
- `ENABLE_BIOMETRIC_LOGIN` - Enable biometric auth (true/false)
- `ENABLE_DARK_MODE` - Enable dark mode (true/false)
- `ENABLE_OFFLINE_MODE` - Enable offline mode (true/false)
- `MAINTENANCE_MODE` - Enable maintenance mode (true/false)

## Usage in Code

### Import the Configuration
```dart
import 'package:master_app/config/environment_config.dart';
```

### Initialize at App Startup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvironmentConfig.init();  // Initialize before running app
  runApp(const Globapp());
}
```

### Access Configuration Values
```dart
// Using AppConfig helper class (easiest way)
String apiUrl = AppConfig.apiBaseUrl;
String jwtSecret = AppConfig.jwtSecretKey;
bool debugMode = AppConfig.debugMode;

// Using EnvironmentConfig directly
String? apiUrl = EnvironmentConfig.get('API_BASE_URL');
int timeout = EnvironmentConfig.getInt('API_TIMEOUT', defaultValue: 30);
bool debug = EnvironmentConfig.getBool('DEBUG_MODE', defaultValue: false);
```

### Getting Configuration Values
```dart
// String value with optional default
String value = EnvironmentConfig.get('KEY', defaultValue: 'default') ?? '';

// Boolean value
bool flag = EnvironmentConfig.getBool('FLAG', defaultValue: false);

// Integer value
int number = EnvironmentConfig.getInt('NUMBER', defaultValue: 0);

// Double value
double decimal = EnvironmentConfig.getDouble('DECIMAL', defaultValue: 0.0);

// Check if key exists
bool exists = EnvironmentConfig.has('KEY');

// Get all variables (for debugging)
Map<String, String> all = EnvironmentConfig.getAll();
```

## Best Practices

### Security Best Practices
1. ✅ **Always use `.env` for sensitive data**
   - API keys
   - Database credentials
   - Secret keys
   - Access tokens

2. ✅ **Never commit `.env` to version control**
   - Ensure `.env` is in `.gitignore`
   - Only commit `.env.example`

3. ✅ **Use strong, unique values**
   - Generate secure JWT secrets: `openssl rand -hex 32`
   - Use different keys for different environments
   - Rotate keys regularly

4. ✅ **Protect .env file permissions**
   ```bash
   chmod 600 .env  # Linux/Mac
   ```

5. ✅ **Use environment-specific files**
   - `.env` - Local development
   - `.env.production` - Production values (git-ignored)
   - `.env.staging` - Staging values (git-ignored)

### Development Workflow
1. Copy `.env.example` to `.env`
2. Add your local development values
3. **Never commit** your `.env` file
4. When pulling changes, ensure `.env.example` is updated if new variables are added
5. Other developers will update their `.env` accordingly

### CI/CD Integration
For GitHub Actions, GitLab CI, or other CI/CD systems:

1. Store sensitive values as **Secrets** in the platform
2. Create the `.env` file during build:
   ```bash
   echo "API_BASE_URL=$API_BASE_URL" >> .env
   echo "JWT_SECRET_KEY=$JWT_SECRET_KEY" >> .env
   ```
3. Reference secrets in your CI/CD pipeline

### Production Deployment
1. Use your hosting platform's secret management (e.g., AWS Secrets Manager, Azure Key Vault)
2. Set environment variables through your platform's dashboard or API
3. Never manually create `.env` files in production
4. Rotate secrets regularly
5. Monitor and log access to sensitive configurations

## Troubleshooting

### .env file not being loaded
- Ensure file is named exactly `.env` (not `.env.txt`)
- Check file is in the project root directory
- Verify file format: `KEY=VALUE` (no spaces around `=`)
- Ensure comments start with `#` on a new line

### Values not being read
- Check variable names match exactly (case-sensitive)
- Ensure no extra whitespace in values
- For quoted values, ensure proper quote format:
  ```env
  VALUE="quoted value"  # ✅ Correct
  VALUE=quoted value    # ✅ Also correct
  VALUE="mismatched'    # ❌ Wrong
  ```

### Accessing null values
- Add default values when accessing: `AppConfig.apiBaseUrl ?? 'default'`
- Check if `.env` is properly initialized before accessing values
- Verify environment variable exists in `.env`

## Support
For issues with environment configuration, check:
1. `.env` file format and syntax
2. File permissions (600 for `.env`)
3. Flutter build cache: `flutter clean && flutter pub get`
4. Log output for configuration loading errors
