import Foundation
import SharedKit
import Sentry
import AnalyticsKit

/// Wrapper around the Sentry SDK for crash reporting and performance monitoring
public enum Crashlytics {
    /// Initialize Sentry with configuration from Sentry-Info.plist
    static public func initSentry() {
        guard let dsn = try? getPlistEntry("SENTRY_DSN", in: "Sentry-Info"), !dsn.isEmpty else {
            fatalError("ERROR: Couldn't find SENTRY_DSN in Sentry-Info.plist!")
        }
        
        #if DEBUG
        let environment = "development"
        #else
        let environment = "production"
        #endif
        
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = environment
            options.debug = environment == "development"
            options.tracesSampleRate = environment == "development" ? 1.0 : 0.1  // 100% in dev, 10% in prod
            options.profilesSampleRate = environment == "development" ? 1.0 : 0.1  // 100% in dev, 10% in prod
            options.enableAutoSessionTracking = true
            options.enableAppHangTracking = true
            options.enableAutoBreadcrumbTracking = true
        }
        
        Logger.info(
            id: "sentry_initialized",
            longDescription: "[CRASHLYTICS] Initialized Sentry in '\(environment)' environment.",
            properties: [
                "traces_sample_rate": environment == "development" ? 1.0 : 0.1,
                "profiles_sample_rate": environment == "development" ? 1.0 : 0.1
            ]
        )
    }
    
    /// Capture an error and send it to Sentry
    /// - Parameters:
    ///   - error: The error to capture
    ///   - level: The severity level of the error
    ///   - extras: Additional context to attach to the error
    static public func captureError(
        _ error: Error,
        level: SentryLevel = .error,
        extras: [String: Any] = [:]
    ) {
        var context = extras
        context["error_description"] = error.localizedDescription
        
        SentrySDK.capture(error: error) { scope in
            scope.level = level
            scope.setExtras(context)
        }
        
        // Also log to analytics for tracking
        Analytics.capture(
            .error,
            id: "error_captured",
            longDescription: error.localizedDescription,
            source: .general,
            relevancy: .high
        )
    }
    
    /// Start a new transaction for performance monitoring
    /// - Parameters:
    ///   - name: The name of the transaction
    ///   - operation: The type of operation being performed
    /// - Returns: A transaction object that should be finished when the operation completes
    static public func startTransaction(
        name: String,
        operation: String
    ) -> Span {
        let transaction = SentrySDK.startTransaction(
            name: name,
            operation: operation
        )
        
        Logger.info(
            id: "transaction_started",
            longDescription: "[CRASHLYTICS] Started transaction '\(name)' with operation '\(operation)'."
        )
        
        return transaction
    }
    
    /// Set user information in Sentry for better error tracking
    /// - Parameter id: The user's ID
    /// - Parameter email: The user's email (optional)
    /// - Parameter data: Additional user data (optional)
    static public func setUser(id: String, email: String? = nil, data: [String: Any] = [:]) {
        var userData = data
        if let email = email {
            userData["email"] = email
        }
        
        let user = User(userId: id)
        user.email = email
        user.data = userData
        
        SentrySDK.setUser(user)
        
        Logger.info(
            id: "user_context_set",
            longDescription: "[CRASHLYTICS] Set user context for ID: \(id)",
            properties: userData
        )
    }
    
    /// Clear the current user information from Sentry
    static public func clearUser() {
        SentrySDK.setUser(nil)
        
        Logger.info(
            id: "user_context_cleared",
            longDescription: "[CRASHLYTICS] Cleared user context"
        )
    }
    
    /// Add a breadcrumb to help track the sequence of events leading to an error
    /// - Parameters:
    ///   - message: A description of the event
    ///   - category: The category of the event (e.g., "auth", "ui", "network")
    ///   - level: The severity level of the breadcrumb
    ///   - data: Additional context for the breadcrumb
    static public func addBreadcrumb(
        message: String,
        category: String,
        level: SentryLevel = .info,
        data: [String: Any] = [:]
    ) {
        let crumb = Breadcrumb(level: level, category: category)
        crumb.message = message
        crumb.data = data
        
        SentrySDK.addBreadcrumb(crumb)
    }
} 