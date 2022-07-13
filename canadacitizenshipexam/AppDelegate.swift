  //
  //  AppDelegate.swift
  //  canadacitizenshipexam
  //
  //  Created by hainguyen on 2022-04-30.
  //

import UIKit
import CoreData
import FirebaseCore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  let isDebugging = true

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    if (isDebugging) {
      let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
      if let last = searchPath.last {
        print("AppDelegate: \(last as String)")
      }
    }

    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    print("applicationWillTerminate")
    do {
      if let userID = Auth.auth().currentUser?.uid {
        try Auth.auth().signOut()
        NetworkManager.shared.removedCachedUsersData(userID: userID)
      }
    }
    catch {
      print("Error signing user out.")
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    print("applicationWillResignActive")
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    print("applicationDidEnterBackground")
  }

  // MARK: - UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "canadacitizenshipexam")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

}
