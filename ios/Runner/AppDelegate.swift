import Flutter
import UIKit

class ExternalDisplay {
  var additionalWindows = [UIWindow]()

  func setup() {
    NotificationCenter.default.addObserver(forName: .UIScreenDidConnect,
                                           object: nil, queue: nil) { notification in
      // Get the new screen information.
      let newScreen = notification.object as! UIScreen
      let screenDimensions = newScreen.bounds

      // Configure a window for the screen.
      let newWindow = UIWindow(frame: screenDimensions)
      newWindow.screen = newScreen

      // You must show the window explicitly.
      newWindow.isHidden = false
      // Save a reference to the window in a local array.
      self.additionalWindows.append(newWindow)
      let extVC = FlutterViewController()
      newWindow.rootViewController = extVC
    }
    NotificationCenter.default.addObserver(forName:
      .UIScreenDidDisconnect,
                                           object: nil,
                                           queue: nil) { notification in
      let screen = notification.object as! UIScreen

      // Remove the window associated with the screen.
      for window in self.additionalWindows {
        if window.screen == screen {
          // Remove the window and its contents.
          let index = self.additionalWindows.index(of: window)
          self.additionalWindows.remove(at: index!)
        }
      }
    }
  }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Keep track of windows to make sure they are not released
  var extDisplay = ExternalDisplay()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    extDisplay.setup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}