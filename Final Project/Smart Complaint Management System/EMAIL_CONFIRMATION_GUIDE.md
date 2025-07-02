# Email Confirmation Guide

## Issue Description
When students try to login, they may encounter an "email not confirmed" error. This happens because Supabase Auth requires email confirmation by default when new users are created.

## Root Cause
1. **Default Supabase Behavior**: When users are created through the admin interface, Supabase Auth automatically sends an email confirmation link
2. **Email Delivery Issues**: The confirmation email might not be delivered due to:
   - Incorrect email addresses
   - Email provider blocking automated emails
   - Supabase SMTP configuration issues
3. **User Inaction**: Users might not check their email or click the confirmation link

## Solutions

### For Development/Testing Environment

#### Option 1: Disable Email Confirmation (Recommended for Development)
1. Go to your Supabase Dashboard
2. Navigate to **Authentication** > **Settings**
3. Find **Email Confirmations** section
4. **Disable** "Enable email confirmations"
5. Save the changes

This allows users to login immediately without email confirmation.

#### Option 2: Use Test Email Addresses
- Use real email addresses that you have access to
- Check spam/junk folders for confirmation emails
- Click the confirmation link when received

### For Production Environment

#### Option 1: Configure SMTP Settings
1. Go to Supabase Dashboard > **Authentication** > **Settings**
2. Configure SMTP settings with a reliable email provider:
   - Gmail SMTP
   - SendGrid
   - Amazon SES
   - Other SMTP providers
3. Test email delivery
4. Keep email confirmation enabled for security

#### Option 2: Use Custom Email Templates
1. Customize email templates in Supabase Dashboard
2. Make confirmation emails more professional and clear
3. Include proper branding and instructions

## Current App Behavior

### Development Mode
- Users can login even with unconfirmed emails
- A warning dialog appears but allows continuation
- Admin can monitor authentication status

### Production Mode
- Email confirmation is enforced
- Users must confirm email before login
- Clear error messages guide users

## User Experience Improvements

### Login Screen Features
1. **Resend Email Button**: Users can request a new confirmation email
2. **Clear Error Messages**: Specific guidance for email confirmation issues
3. **Development Mode Warning**: Informs users about development settings

### Admin Features
1. **User Authentication Status**: Monitor email confirmation status
2. **Help Documentation**: Guide for resolving issues
3. **User Management**: Create users with proper email addresses

## Troubleshooting Steps

### For Students
1. Check email inbox and spam folder
2. Click "Resend Email" on login screen
3. Contact administrator if issues persist
4. Verify email address is correct

### For Administrators
1. Check Supabase Auth settings
2. Verify SMTP configuration
3. Monitor email delivery logs
4. Use "User Authentication Status" feature
5. Consider disabling email confirmation for development

### For Developers
1. Review Supabase Auth configuration
2. Test email delivery in development
3. Implement proper error handling
4. Consider environment-specific settings

## Best Practices

### Development
- Disable email confirmation for faster testing
- Use test email addresses
- Monitor authentication logs
- Provide clear development instructions

### Production
- Enable email confirmation for security
- Configure reliable SMTP provider
- Customize email templates
- Monitor email delivery success rates
- Provide user support documentation

## Configuration Files

### Supabase Settings
- Authentication > Settings > Email Confirmations
- SMTP Configuration
- Email Templates
- Redirect URLs

### App Configuration
- Environment variables for email settings
- Development vs production flags
- Error message customization

## Support Resources

1. **Supabase Documentation**: https://supabase.com/docs/guides/auth
2. **Email Configuration**: https://supabase.com/docs/guides/auth/auth-email
3. **SMTP Setup**: https://supabase.com/docs/guides/auth/auth-smtp
4. **App Support**: Contact system administrator

## Quick Fix Commands

### Disable Email Confirmation (Development)
```sql
-- This is handled through Supabase Dashboard UI
-- Go to Authentication > Settings > Email Confirmations
-- Toggle off "Enable email confirmations"
```

### Check User Status
```sql
-- View users in your database
SELECT id, email, role, created_at FROM users;
```

### Monitor Auth Logs
- Check Supabase Dashboard > Logs > Auth
- Look for email delivery failures
- Monitor user signup attempts

---

**Note**: This guide is specific to the Smart Complaint Management System. For general Supabase Auth issues, refer to the official Supabase documentation. 