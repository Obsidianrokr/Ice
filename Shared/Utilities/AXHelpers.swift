//
//  AXHelpers.swift
//  Shared
//

import AXSwift
import Cocoa

enum AXHelpers {
    private static let queue = DispatchQueue.targetingGlobal(
        label: "AXHelpers.queue",
        qos: .userInteractive,
        attributes: .concurrent
    )

    private static let accessibilityProbeCallback: CGEventTapCallBack = { _, _, event, _ in
        Unmanaged.passUnretained(event)
    }

    /// Returns a Boolean value that indicates whether the process can
    /// receive accessibility events according to the live TCC database.
    ///
    /// Unlike ``checkIsProcessTrusted(prompt:)``, this method does not
    /// rely on a cached value and reflects the current code signature.
    static func hasLiveAccessibilityAccess() -> Bool {
        let eventMask = CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: accessibilityProbeCallback,
            userInfo: nil
        ) else {
            return false
        }
        CFMachPortInvalidate(tap)
        return true
    }

    @discardableResult
    static func isProcessTrusted(prompt: Bool = false) -> Bool {
        queue.sync {
            if hasLiveAccessibilityAccess() {
                return true
            }
            return checkIsProcessTrusted(prompt: prompt)
        }
    }

    static func element(at point: CGPoint) -> UIElement? {
        queue.sync { try? systemWideElement.elementAtPosition(Float(point.x), Float(point.y)) }
    }

    static func application(for runningApp: NSRunningApplication) -> Application? {
        queue.sync { Application(runningApp) }
    }

    static func extrasMenuBar(for app: Application) -> UIElement? {
        queue.sync { try? app.attribute(.extrasMenuBar) }
    }

    static func children(for element: UIElement) -> [UIElement] {
        queue.sync { try? element.arrayAttribute(.children) } ?? []
    }

    static func isEnabled(_ element: UIElement) -> Bool {
        queue.sync { try? element.attribute(.enabled) } ?? false
    }

    static func frame(for element: UIElement) -> CGRect? {
        queue.sync { try? element.attribute(.frame) }
    }

    static func role(for element: UIElement) -> Role? {
        queue.sync { try? element.role() }
    }
}
