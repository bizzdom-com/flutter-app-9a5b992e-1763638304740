class ErrorHandler {
  static String getHumanReadableError(String error) {
    // Remove "Exception: " prefix if it exists
    String cleanError = error.replaceFirst('Exception: ', '');
    
    // Handle registration errors
    if (cleanError.contains('Registration failed:')) {
      cleanError = cleanError.replaceFirst('Registration failed: ', '');
      
      if (cleanError.contains('duplicate key value violates unique constraint') && 
          cleanError.contains('users_email_key')) {
        return 'This email address is already registered. Please use a different email or try logging in.';
      }
      
      if (cleanError.contains('invalid_credentials') || 
          cleanError.contains('weak_password')) {
        return 'Password must be at least 6 characters long.';
      }
      
      if (cleanError.contains('invalid_email')) {
        return 'Please enter a valid email address.';
      }
      
      if (cleanError.contains('signup_disabled')) {
        return 'Registration is temporarily disabled. Please try again later.';
      }
    }
    
    // Handle login errors
    if (cleanError.contains('Login failed:')) {
      cleanError = cleanError.replaceFirst('Login failed: ', '');
      
      if (cleanError.contains('Invalid login credentials') || 
          cleanError.contains('invalid_credentials')) {
        return 'Invalid email or password. Please check your credentials and try again.';
      }
      
      if (cleanError.contains('Cannot coerce the result to a single JSON object') ||
          cleanError.contains('The result contains 0 rows')) {
        return 'Account not found. Please check your email or register a new account.';
      }
      
      if (cleanError.contains('email_not_confirmed')) {
        return 'Please check your email and confirm your account before logging in.';
      }
      
      if (cleanError.contains('too_many_requests')) {
        return 'Too many login attempts. Please wait a few minutes and try again.';
      }
    }
    
    // Handle password reset errors
    if (cleanError.contains('Failed to send password reset email:')) {
      cleanError = cleanError.replaceFirst('Failed to send password reset email: ', '');
      
      if (cleanError.contains('user_not_found') || 
          cleanError.contains('Invalid email')) {
        return 'No account found with this email address.';
      }
      
      return 'Unable to send password reset email. Please try again later.';
    }
    
    // Handle password update errors
    if (cleanError.contains('Failed to update password:')) {
      cleanError = cleanError.replaceFirst('Failed to update password: ', '');
      
      if (cleanError.contains('weak_password')) {
        return 'Password must be at least 6 characters long.';
      }
      
      if (cleanError.contains('same_password')) {
        return 'New password must be different from your current password.';
      }
      
      return 'Unable to update password. Please try again.';
    }
    
    // Handle staff/customer errors
    if (cleanError.contains('Failed to find customer:')) {
      return 'Customer not found. Please check the QR code and try again.';
    }
    
    if (cleanError.contains('Failed to get customer balance:')) {
      return 'Unable to load customer points balance. Please try again.';
    }
    
    if (cleanError.contains('Failed to award points:')) {
      return 'Unable to award points. Please try again.';
    }
    
    if (cleanError.contains('Failed to find coupon:')) {
      return 'Coupon not found. Please check the code and try again.';
    }
    
    if (cleanError.contains('Failed to redeem coupon:')) {
      return 'Unable to redeem coupon. Please check if it\'s still valid.';
    }
    
    if (cleanError.contains('Failed to get staff record:')) {
      return 'Staff access denied. Please contact your administrator.';
    }
    
    // Handle reward errors
    if (cleanError.contains('Failed to load rewards:')) {
      return 'Unable to load rewards. Please check your connection and try again.';
    }
    
    if (cleanError.contains('Failed to redeem reward:')) {
      return 'Unable to redeem reward. Please check your points balance.';
    }
    
    // Handle admin errors
    if (cleanError.contains('Failed to delete staff member:')) {
      return 'Unable to remove staff member. Please try again.';
    }
    
    if (cleanError.contains('Failed to add staff member:')) {
      return 'Unable to add staff member. Please check the email and try again.';
    }
    
    // Handle network/connection errors
    if (cleanError.contains('SocketException') || 
        cleanError.contains('Connection failed') ||
        cleanError.contains('timeout')) {
      return 'Connection error. Please check your internet and try again.';
    }
    
    // Handle generic database errors
    if (cleanError.contains('PostgrestException')) {
      if (cleanError.contains('permission denied') || 
          cleanError.contains('insufficient_privilege')) {
        return 'Access denied. You don\'t have permission for this action.';
      }
      
      if (cleanError.contains('relation') && cleanError.contains('does not exist')) {
        return 'Service temporarily unavailable. Please try again later.';
      }
      
      return 'Database error. Please try again later.';
    }
    
    // If no specific match, return a generic user-friendly message
    if (cleanError.length > 100) {
      return 'Something went wrong. Please try again or contact support if the problem persists.';
    }
    
    return cleanError;
  }
}