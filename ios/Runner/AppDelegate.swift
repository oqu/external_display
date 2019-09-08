import Flutter
import UIKit

class ExternalDisplay {
  var additionalWindows = [UIWindow]()

  func setup(route: String, mainFvc: FlutterViewController) {
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
      extVC.setInitialRoute(route)
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
    let counterChannel = FlutterMethodChannel(name: "io.github.oqu/externalA", binaryMessenger: mainFvc.binaryMessenger)

    counterChannel.setMethodCallHandler {
      (call: FlutterMethodCall, _: @escaping FlutterResult) -> Void in
      // Dispatch event to all external displays
      for window in self.additionalWindows {
        let fvc = window.rootViewController as! FlutterViewController
        // fvc.invokeMethod()
        let c = FlutterMethodChannel(name: "io.github.oqu/externalB", binaryMessenger: fvc.binaryMessenger)
        c.invokeMethod(call.method, arguments: call.arguments)
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
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    extDisplay.setup(route: "/external", mainFvc: controller)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}