import Foundation
import SharedKit
import Sentry

public class Crashlytics {
    public static let shared = Crashlytics()
    
    private init() {}
    
    public func configure() {
        print("[CRASHLYTICS] Initializing...")
        
        do {
            // Get DSN using the same approach as Analytics
            let dsn = try getPlistEntry("SENTRY_DSN", in: "Sentry-Info")
            
            // Initialize Sentry
            SentrySDK.start { options in
                options.dsn = dsn
                options.debug = false // Disable debug mode in production
                options.enableAutoSessionTracking = true
                options.enableSwizzling = true
                options.tracesSampleRate = 1.0
                options.profilesSampleRate = 1.0
                options.enableCrashHandler = true
                
                #if DEBUG
                options.environment = "development"
                #else
                options.environment = "production"
                #endif
            }
            print("[CRASHLYTICS] Successfully initialized")
        } catch {
            print("[CRASHLYTICS] ERROR: Failed to initialize - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Tracking
    
    public func captureError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        SentrySDK.capture(error: error) { scope in
            if let info = additionalInfo {
                scope.setExtras(info)
            }
        }
    }
    
    public func captureMessage(_ message: String, level: SentryLevel = .info) {
        SentrySDK.capture(message: message) { scope in
            scope.setLevel(level)
        }
    }
    
    // MARK: - User Management
    
    public func setUser(id: String, email: String? = nil, username: String? = nil) {
        let user = User()
        user.userId = id
        user.email = email
        user.username = username
        
        SentrySDK.setUser(user)
    }
    
    public func clearUser() {
        SentrySDK.setUser(nil)
    }
    
//    // MARK: - Breadcrumbs
//
//    public func leaveBreadcrumb(
//        _ message: String,
//        category: String? = nil,
//        level: SentryLevel = .info,
//        data: [String: Any]? = nil
//    ) {
//        let crumb = Breadcrumb()
//        crumb.message = message
//        crumb.category = category
//        crumb.level = level
//        crumb.data = data
//
//        SentrySDK.addBreadcrumb(crumb)
//    }
    
    // MARK: - Performance Monitoring
    
    public func startTransaction(
        name: String,
        operation: String
    ) -> Span? {
        return SentrySDK.startTransaction(
            name: name,
            operation: operation
        )
    }
}

