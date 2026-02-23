import Foundation
import BackgroundTasks
import OSLog

@MainActor
final class PrayerBackgroundTaskManager: Sendable {
    static let shared = PrayerBackgroundTaskManager()
    
    static let taskIdentifier = "com.karriapps.smartsiddur.prayerrefresh"
    
    nonisolated let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "BackgroundTask")
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.taskIdentifier,
            using: nil
        ) { task in
            Task { @MainActor in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
        
        logger.info("Registered background task: \(Self.taskIdentifier)")
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        
        // Schedule for 12 hours from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Scheduled background refresh for 12 hours from now")
        } catch {
            logger.error("Failed to schedule background refresh: \(error.localizedDescription)")
        }
    }
    
    func cancelScheduledRefresh() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Self.taskIdentifier)
        logger.info("Cancelled scheduled background refresh")
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule the next refresh
        scheduleAppRefresh()
        
        let refreshTask = Task { @MainActor in
            do {
                guard let cacheService = DependencyContainer.shared.prayerCacheService else {
                    logger.warning("No cache service available for background refresh")
                    task.setTaskCompleted(success: true)
                    return
                }
                
                try await cacheService.performBackgroundRefreshIfNeeded()
                logger.info("Background refresh completed successfully")
                task.setTaskCompleted(success: true)
            } catch {
                logger.error("Background refresh failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
        
        task.expirationHandler = {
            refreshTask.cancel()
        }
    }
}
