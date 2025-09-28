import 'package:jwt_decode/jwt_decode.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

/// Utility class for JWT token operations
class JwtUtil {
  
  /// Decode JWT token and return payload as Map
  static Map<String, dynamic> decodeToken(String token) {
    try {
      if (token.isEmpty) {
        AppLogger.warning('[JWT UTIL] Token is empty');
        return {};
      }
      
      // Remove 'Bearer ' prefix if present
      String cleanToken = token;
      if (token.startsWith('Bearer ')) {
        cleanToken = token.substring(7);
      }
      
      final payload = Jwt.parseJwt(cleanToken);
      AppLogger.info('[JWT UTIL] Token decoded successfully');
      AppLogger.info('[JWT UTIL] Payload keys: ${payload.keys.toList()}');
      return payload;
    } catch (e) {
      AppLogger.error('[JWT UTIL] Failed to decode token: $e');
      return {};
    }
  }
  
  /// Extract user ID from JWT token
  static String? getUserIdFromToken(String token) {
    try {
      final payload = decodeToken(token);
      
      // Try common user ID field names
      final userId = payload['userId'] ?? 
                     payload['user_id'] ?? 
                     payload['sub'] ?? 
                     payload['id'] ?? 
                     payload['_id'] ?? 
                     payload['user']?['id'] ?? 
                     payload['user']?['_id'] ?? 
                     payload['user']?['userId'];
      
      if (userId != null) {
        AppLogger.info('[JWT UTIL] User ID found in token: $userId');
        return userId.toString();
      } else {
        AppLogger.warning('[JWT UTIL] No user ID found in token payload');
        AppLogger.info('[JWT UTIL] Available payload fields: ${payload.keys.toList()}');
        return null;
      }
    } catch (e) {
      AppLogger.error('[JWT UTIL] Error extracting user ID: $e');
      return null;
    }
  }
  
  /// Extract user email from JWT token
  static String? getEmailFromToken(String token) {
    try {
      final payload = decodeToken(token);
      
      final email = payload['email'] ?? 
                    payload['user']?['email'];
      
      if (email != null) {
        AppLogger.info('[JWT UTIL] Email found in token: $email');
        return email.toString();
      }
      return null;
    } catch (e) {
      AppLogger.error('[JWT UTIL] Error extracting email: $e');
      return null;
    }
  }
  
  /// Extract user name from JWT token
  static String? getNameFromToken(String token) {
    try {
      final payload = decodeToken(token);
      
      final name = payload['name'] ?? 
                   payload['username'] ?? 
                   payload['fullName'] ?? 
                   payload['full_name'] ?? 
                   payload['user']?['name'] ?? 
                   payload['user']?['username'] ?? 
                   payload['user']?['fullName'];
      
      if (name != null) {
        AppLogger.info('[JWT UTIL] Name found in token: $name');
        return name.toString();
      }
      return null;
    } catch (e) {
      AppLogger.error('[JWT UTIL] Error extracting name: $e');
      return null;
    }
  }
  
  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      final exp = payload['exp'];
      
      if (exp is int) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final isExpired = DateTime.now().isAfter(expiryTime);
        AppLogger.info('[JWT UTIL] Token expiry check: $expiryTime, expired: $isExpired');
        return isExpired;
      }
      return false;
    } catch (e) {
      AppLogger.error('[JWT UTIL] Error checking token expiry: $e');
      return true; // Assume expired if we can't check
    }
  }
  
  /// Get token expiry time
  static DateTime? getExpiryTime(String token) {
    try {
      final payload = decodeToken(token);
      final exp = payload['exp'];
      
      if (exp is int) {
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        AppLogger.info('[JWT UTIL] Token expires at: $expiryTime');
        return expiryTime;
      }
      return null;
    } catch (e) {
      AppLogger.error('[JWT UTIL] Error getting expiry time: $e');
      return null;
    }
  }
}
