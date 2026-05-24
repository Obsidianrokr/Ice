//
//  ScreenCapture.swift
//  Ice
//

import CoreGraphics
import ScreenCaptureKit

/// A namespace for screen capture operations.
enum ScreenCapture {

    // MARK: Permissions

    /// Returns a Boolean value that indicates whether the app can capture
    /// screen content according to the live TCC database.
    ///
    /// Unlike ``CGPreflightScreenCaptureAccess()``, this performs an actual
    /// capture attempt and reflects the current code signature.
    static func hasLiveScreenCaptureAccess() -> Bool {
        if CGPreflightScreenCaptureAccess() {
            return true
        }

        let windowIDs = Bridging.getMenuBarWindowList(option: [.itemsOnly, .activeSpace])
        let currentPID = ProcessInfo.processInfo.processIdentifier

        for windowID in windowIDs {
            guard
                let window = WindowInfo(windowID: windowID),
                window.ownerPID != currentPID
            else {
                continue
            }
            if captureWindow(with: windowID) != nil {
                return true
            }
        }

        for windowID in windowIDs where captureWindow(with: windowID) != nil {
            return true
        }

        return false
    }

    /// Returns a Boolean value that indicates whether the app has screen
    /// capture permissions.
    static func checkPermissions() -> Bool {
        hasLiveScreenCaptureAccess()
    }

    /// Returns a Boolean value that indicates whether the app has screen
    /// capture permissions.
    ///
    /// This function caches its initial result and returns it on subsequent
    /// calls. Pass `true` to the `reset` parameter to replace the cached
    /// result with a newly computed value.
    static func cachedCheckPermissions(reset: Bool = false) -> Bool {
        enum Context {
            static var cachedGranted = false
        }
        if reset {
            Context.cachedGranted = false
        }
        if Context.cachedGranted {
            return true
        }
        let result = checkPermissions()
        if result {
            Context.cachedGranted = true
        }
        return result
    }

    /// Requests screen capture permissions.
    static func requestPermissions() {
        _ = CGRequestScreenCaptureAccess()
        SCShareableContent.getWithCompletionHandler { _, _ in }
    }

    // MARK: Capture Window(s)

    /// Captures a composite image of an array of windows.
    ///
    /// The windows are composited from front to back, according to the order
    /// of the `windowIDs` parameter.
    ///
    /// - Parameters:
    ///   - windowIDs: The identifiers of the windows to capture.
    ///   - screenBounds: The bounds to capture, specified in screen coordinates.
    ///     Pass `nil` to capture the minimum rectangle that encloses the windows.
    ///   - option: Options that specify which parts of the windows are captured.
    static func captureWindows(with windowIDs: [CGWindowID], screenBounds: CGRect? = nil, option: CGWindowImageOption = []) -> CGImage? {
        guard let array = Bridging.createCGWindowArray(with: windowIDs) else {
            return nil
        }
        let bounds = screenBounds ?? .null
        // ScreenCaptureKit doesn't support capturing images of offscreen menu bar
        // items, so we call CGWindowListCreateImageFromArray through a shim.
        return CGWindowListCreateImageFromArray(bounds, array, option)?.takeRetainedValue()
    }

    /// Captures an image of a window.
    ///
    /// - Parameters:
    ///   - windowID: The identifier of the window to capture.
    ///   - screenBounds: The bounds to capture, specified in screen coordinates.
    ///     Pass `nil` to capture the minimum rectangle that encloses the window.
    ///   - option: Options that specify which parts of the window are captured.
    static func captureWindow(with windowID: CGWindowID, screenBounds: CGRect? = nil, option: CGWindowImageOption = []) -> CGImage? {
        captureWindows(with: [windowID], screenBounds: screenBounds, option: option)
    }
}
