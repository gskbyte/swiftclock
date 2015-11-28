//
//  ViewController.swift
//  swiftclock
//
//  Created by Jose Alcalá-Correa on 28/11/15.
//  Copyright © 2015 Jose Alcalá-Correa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var systemTimeLabel: UILabel!
    @IBOutlet weak var serverTimeLabel: UILabel!
    @IBOutlet weak var requestThresholdLabel: UILabel!
    @IBOutlet weak var requestThresholdStepper: UIStepper!

    @IBOutlet weak var alarmDatePicker: UIDatePicker!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var scheduleAlarmButton: UIButton!

    private var dateDisplayFormatter : NSDateFormatter!
    private var remoteTimeFormatter : NSDateFormatter!
    private var localTimer : NSTimer!
    private var remoteTimer : NSTimer!
    private var nextTimerRequest = NSDate()
    private var requestThreshold: NSTimeInterval = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        self.alarmDatePicker.datePickerMode = .Time
        self.alarmDatePicker.locale = NSLocale(localeIdentifier: "en_GB") // 24 hour
        self.alarmLabel.text = ""

        self.dateDisplayFormatter = NSDateFormatter()
        self.dateDisplayFormatter.dateStyle = .NoStyle
        self.dateDisplayFormatter.timeStyle = .MediumStyle
        self.dateDisplayFormatter.locale = NSLocale(localeIdentifier: "en_GB") // 24 hour

        self.remoteTimeFormatter = NSDateFormatter()
        self.remoteTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        self.requestThresholdStepper.value = requestThreshold
        self.requestThresholdStepper.stepValue = 1
        updateThresholdLabel()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.localTimer = NSTimer(fireDate: NSDate(), interval: 1, target: self, selector: "updateSystemTimeLabel", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.localTimer, forMode: NSRunLoopCommonModes)
        self.localTimer.fire()


        scheduleServerTimeRequest();
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.localTimer.invalidate()
        self.remoteTimer.invalidate()
    }

    @IBAction func scheduleAlarm(sender: AnyObject) {
        let notification = UILocalNotification()
        self.alarmLabel.text = "Alarm at " + self.alarmDatePicker.date.description
        notification.fireDate = self.alarmDatePicker.date
        notification.alertTitle = "Alarm!"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func scheduleServerTimeRequest() {
        let now = NSDate()
        if self.nextTimerRequest.compare(now) != .OrderedDescending {
            requestServerTime()
        } else {
            let timeInterval = self.nextTimerRequest.timeIntervalSinceDate(now)
            self.remoteTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "requestServerTime", userInfo: nil, repeats: false)
        }

        self.nextTimerRequest = NSDate(timeInterval: self.requestThreshold, sinceDate: self.nextTimerRequest)
    }

    func requestServerTime() {
        let timeRequest = NSURLRequest(URL: NSURL(string: "http://www.timeapi.org/utc/now.json")!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(timeRequest) { (data, response, error) -> Void in
            if let error = error {
                self.serverTimeLabel.text = "req error"
                print(error)
                return
            }

            guard let data = data else {
                self.serverTimeLabel.text = "No data received"
                return
            }

            guard let JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary else {
                self.serverTimeLabel.text = "Invalid data received"
                return
            }

            guard let dateString = JSON["dateString"] as! String?,
                date = self.remoteTimeFormatter.dateFromString(dateString) else {
                self.serverTimeLabel.text = "JSON does not contain time info"
                return
            }

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.serverTimeLabel.text = self.timeString(date)
                self.scheduleServerTimeRequest()
            })
        }
        task.resume()
    }

    func updateSystemTimeLabel() {
        self.systemTimeLabel.text = timeString(NSDate())
    }

    @IBAction func didChangeThresholdStepper(sender: AnyObject) {
        self.requestThreshold = self.requestThresholdStepper.value
        self.nextTimerRequest = NSDate(timeIntervalSinceNow: self.requestThreshold)
        updateThresholdLabel()
    }


    func updateThresholdLabel() {
        self.requestThresholdLabel.text = "every \(self.requestThreshold) s"
    }

    func timeString(date: NSDate) -> String {
        return self.dateDisplayFormatter.stringFromDate(date);
    }
}

