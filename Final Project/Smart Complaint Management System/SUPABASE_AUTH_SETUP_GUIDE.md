# Supabase Authentication Setup Guide

## Issue: "Email login are disabled"

This error occurs when email/password authentication is not properly configured in your Supabase project.

## 🔧 **Quick Fix Steps**

### **Step 1: Enable Email Authentication**

1. **Go to Supabase Dashboard**
   - Visit [https://supabase.com/dashboard](https://supabase.com/dashboard)
   - Select your project

2. **Navigate to Authentication Settings**
   - Click on **Authentication** in the left sidebar
   - Click on **Providers**

3. **Enable Email Provider**
   - Find the **Email** provider section
   - **Enable** the following options:
     - ✅ **Enable email signups**
     - ✅ **Enable email confirmations** (optional for development)
   - Click **Save**

### **Step 2: Configure Email Settings (Optional)**

1. **SMTP Configuration** (for production)
   - Go to **Authentication** → **Settings**
   - Configure SMTP settings if you want custom email delivery
   - For development, you can use Supabase's default email service

2. **Email Templates** (optional)
   - Customize email templates in **Authentication** → **Templates**
   - Make emails more professional and branded

## 🛠️ **Detailed Configuration**

### **Authentication Providers Setup**

```yaml
# In Supabase Dashboard > Authentication > Providers

Email Provider:
  ✅ Enable email signups: ON
  ✅ Enable email confirmations: ON (or OFF for development)
  ✅ Double confirm changes: OFF (for development)
  ✅ Enable secure email change: OFF (for development)

Additional Providers (Optional):
  - Google (if needed)
  - GitHub (if needed)
  - Other OAuth providers
```

### **Site URL Configuration**

1. Go to **Authentication** → **Settings**
2. Set **Site URL** to your app's URL:
   - Development: `http://localhost:3000` or your local URL
   - Production: Your actual domain

### **Redirect URLs**

1. In **Authentication** → **Settings**
2. Add redirect URLs:
   - Development: `http://localhost:3000/auth/callback`
   - Production: `https://yourdomain.com/auth/callback`

## 🚀 **Development vs Production Setup**

### **Development Environment**
```yaml
Email Confirmations: OFF (for faster testing)
Secure Email Change: OFF
Double Confirm Changes: OFF
Site URL: http://localhost:3000
```

### **Production Environment**
```yaml
Email Confirmations: ON (for security)
Secure Email Change: ON
Double Confirm Changes: ON
Site URL: https://yourdomain.com
SMTP: Configured with reliable provider
```

## 🔍 **Troubleshooting**

### **Common Issues and Solutions**

#### **1. "Email login are disabled" Error**
- **Cause**: Email provider not enabled
- **Solution**: Enable email signups in Authentication → Providers

#### **2. "Invalid login credentials"**
- **Cause**: User doesn't exist or wrong password
- **Solution**: Check user creation and password

#### **3. "Email not confirmed"**
- **Cause**: Email confirmation required but not completed
- **Solution**: Check email or disable confirmation for development

#### **4. "Site URL not allowed"**
- **Cause**: Incorrect site URL configuration
- **Solution**: Update site URL in Authentication → Settings

### **Verification Steps**

1. **Check Provider Status**
   ```sql
   -- In Supabase Dashboard > SQL Editor
   SELECT * FROM auth.providers;
   ```

2. **Test User Creation**
   - Try creating a test user through admin interface
   - Check if authentication works

3. **Test Login**
   - Try logging in with test credentials
   - Check for any error messages

## 📱 **App Configuration**

### **Environment Variables**

Make sure your app has the correct Supabase configuration:

```dart
// In your app initialization
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### **Authentication Service**

The app now includes better error handling for authentication issues:

```dart
// Enhanced error messages
- "Email authentication is disabled" → Check Supabase settings
- "Email not confirmed" → Check email or disable confirmation
- "Invalid credentials" → Check user/password
```

## 🎯 **Quick Checklist**

### **Before Testing Login**

- [ ] Email provider enabled in Supabase
- [ ] Site URL configured correctly
- [ ] Redirect URLs set up
- [ ] Test user created in database
- [ ] App configured with correct Supabase credentials

### **For Production**

- [ ] SMTP configured for reliable email delivery
- [ ] Email templates customized
- [ ] Security settings enabled
- [ ] Domain configured properly
- [ ] SSL certificates in place

## 📞 **Support Resources**

1. **Supabase Documentation**: [https://supabase.com/docs/guides/auth](https://supabase.com/docs/guides/auth)
2. **Authentication Guide**: [https://supabase.com/docs/guides/auth/auth-email](https://supabase.com/docs/guides/auth/auth-email)
3. **Troubleshooting**: [https://supabase.com/docs/guides/auth/troubleshooting](https://supabase.com/docs/guides/auth/troubleshooting)

## 🔄 **Testing After Setup**

1. **Create a test user** through admin interface
2. **Try logging in** with test credentials
3. **Check error messages** if login fails
4. **Verify user data** in database
5. **Test email confirmation** (if enabled)

---

**Note**: After making changes in Supabase Dashboard, it may take a few minutes for the changes to take effect. If you're still having issues, try refreshing your app or waiting a few minutes before testing again. 