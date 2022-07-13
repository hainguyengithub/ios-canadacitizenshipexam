  //
  //  HomeVC.swift
  //  canadacitizenshipexam
  //
  //  Created by hainguyen on 2022-04-30.
  //

import UIKit
import FirebaseAuth

class HomeVC: UIViewController {

  // ===========================================================================
  // UI variables
  // ===========================================================================

  var headingView: CCEHeadingView!

  var tableView: UITableView = UITableView()

  var dateTimeTextField: UITextField = UITextField()

  var appointment: Date! = Date()

  // ===========================================================================
  // Logic variables
  // ===========================================================================

  var sections: [CCESection_Complex] = [
    CCESection_Complex(
      primaryTitleTexts: ["Create a Study Schedule"],
      bodyTexts: ["Make a schedule to meet your goals. Turn on notifications for reminders."],
      iconNames: [SFSymbols.notifications]),
    CCESection_Complex(
      primaryTitleTexts: ["Start Practicing"],
      bodyTexts: ["Practice makes perfect. Test your knowledge now."],
      iconNames: [SFSymbols.tests]),
    CCESection_Complex(
      primaryTitleTexts: ["Test Exemptions"],
      bodyTexts: ["You do not need to take the test if you are under the age of 18 or 55 and over."],
      iconNames: [SFSymbols.info]),
    CCESection_Complex(
      primaryTitleTexts: ["Read the Study Book"],
      bodyTexts: ["Detailed excerpts from the official Discover Canada study guide."],
      iconNames: [SFSymbols.book])
    ]

  // ===========================================================================
  // Lifecycle methods
  // ===========================================================================

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .secondarySystemBackground
    // If there is no active user session, redirects user to the Register VC.
    guard let currentUser = Auth.auth().currentUser else {
      self.navigationController?.pushViewController(RegisterVC(), animated: true)
      return
    }
    // This is a good chance to cache the logged in user data.
    NetworkManager.shared.cacheUsersData(userID: currentUser.uid)
  }

  override func viewWillAppear(_ animated: Bool) {
    // When user is back to Home tab, this deselects the currently selected row.
    if let indexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: indexPath, animated: false)
    }
    self.tabBarController?.tabBar.isHidden = false
    self.navigationItem.setHidesBackButton(true, animated: false)
    // Allows one second for the network request completes.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.loadProgress()
    }
  }

  // ===========================================================================
  // Helper functions
  // ===========================================================================

  func loadProgress() -> Void {
    guard let currentUser = Auth.auth().currentUser else {
      return
    }
    guard let usersData = NetworkManager.shared.getUsersData(userID: currentUser.uid) else {
      return
    }
    let totalChaptersRead = usersData.readChapters.count
    let totalChapters = Chapters.storage.count
    let progress = Float(totalChaptersRead * 100 / totalChapters)
    DispatchQueue.main.async {
      self.headingView = CCEHeadingView(
        progress: progress,
        title: "Practice Progress",
        bodyOne: "\(totalChaptersRead) out of \(totalChapters) chapters read",
        bodyTwo: "Progress: \(progress)%"
      )
      self.configureTableView()
      self.configureHeadingView()
    }
  }

  /* Users picked a date time to start practicing. */
  func registerAppointment() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [
      .alert,
      .badge,
      .sound
    ]) { granted, error in
      // code
    }
    let content = UNMutableNotificationContent()
    content.title = "Practice Reminder"
    content.body = "You booked a pratice session."
    let dateComponents = Calendar.current.dateComponents([
      .year,
      .month,
      .day,
      .hour,
      .minute,
      .second
    ], from: self.appointment) // let date = Date().addingTimeInterval(15)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    center.add(request) { error in
      // code
    }
  }

  // ===========================================================================
  // UI configurations, constraints, etc.
  // ===========================================================================

  func configureHeadingView() -> Void {
    self.headingView.progress = 100
    self.view.addSubview(self.headingView)
    self.headingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.headingView.topAnchor.constraint(
        equalTo: self.view.topAnchor, constant: 10),
      self.headingView.leadingAnchor.constraint(
        equalTo: self.view.leadingAnchor, constant: 10),
      self.headingView.trailingAnchor.constraint(
        equalTo: self.view.trailingAnchor, constant: -10)
    ])
  }

  func configureTableView() -> Void {
    self.tableView.separatorStyle = .none
    self.view.addSubview(self.tableView)
    self.tableView.delegate   = self
    self.tableView.dataSource = self
    self.tableView.register(
      CCESectionCell_Complex.self,
      forCellReuseIdentifier: K.sectionCellIdentifier)
    self.tableView.pin(to: self.view)
    self.tableView.backgroundColor = .secondarySystemBackground
    self.tableView.translatesAutoresizingMaskIntoConstraints = false
    // Moves table content down 80 units down -> the Heading Label is visible.
    self.tableView.contentInset = UIEdgeInsets(
      top: 80, left: 0, bottom: 0, right: 0)
  }

}