//
//  ContactUsViewController.swift
//  Ens
//
//  Created by liu-george-p on 4/2/18.
//  Copyright © 2018 tehillim. All rights reserved.
//

import UIKit
import MapKit


class ContactUsViewController: UIViewController {

    let CONTACT_US_PHONE_NUMBER = "855-522-6748"
    let CONTACT_US_EMAIL_POC = "enterpriseservicedesk@dol.gov"
    let CONTACT_US_ISSUES_URL = "https://github.com/USDepartmentofLabor/EnterpriseNotification-IOS/issues"
    
    @IBAction func contactNumberTouched(_ sender: Any) {
        makeAPhoneCall(phone: CONTACT_US_PHONE_NUMBER)
    }
    
    @IBAction func contactUsEmailTouched(_ sender: Any) {
        sendEmailTo(email: CONTACT_US_EMAIL_POC)
    }
    
    @IBAction func submitBugsButtonTouched(_ sender: Any) {
        openEnsIssuesPage(url: CONTACT_US_ISSUES_URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Support ops
    func openMapForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, placeName: String) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    func makeAPhoneCall(phone: String) {
        let phoneUrl = "TEL://\(phone)"
        let url: NSURL = URL(string: phoneUrl)! as NSURL
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            if UIApplication.shared.canOpenURL(url as URL) {
                let phoneUrl = "tel:\(phone)"
                let url: NSURL = URL(string: phoneUrl)! as NSURL
                UIApplication.shared.openURL(url as URL)
            }
        }
    }

    func openEnsIssuesPage(url: String) {
        UIApplication.shared.openURL(URL(string: url)!)
    }
    func sendEmailTo(email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}
