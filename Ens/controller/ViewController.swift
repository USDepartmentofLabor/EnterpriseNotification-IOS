//
//  ViewController.swift
//  Ens
//
//  Created by liu-george-p on 3/5/18.
//  Copyright © 2018 tehillim. All rights reserved.
//

import UIKit

let didReceiveNotificationNSKey = "dol.gov.oasam.didReceiveNotification"

class ViewController: UIViewController {

    
    // MARK: UI STUFF
    @IBOutlet weak var detailMsgTextView: UITextView!
    @IBOutlet weak var updatedAt: UILabel!
    
    // MARK: Class attributes, etc.
    var ensStore: EnsStore!
    
    
    
    @objc func updateDisplayDetailMsg() {
        let detailMsg = LibraryAPI.sharedInstance.getDetailMessage() as String
        detailMsgTextView.text = detailMsg
        
        let updatedAt = LibraryAPI.sharedInstance.getUpdatedAt() as String
        self.updatedAt.text = updatedAt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEWCONTROLLER: viewDidLoad")
        // Do any additional setup after loading the view, typically from a nib.
        ensStore = EnsStore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDisplayDetailMsg), name: NSNotification.Name(rawValue: didReceiveNotificationNSKey), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("VIEWCONTROLLER: viewDidLoad")
        updateDisplayDetailMsg()
//        loadEnsArchiveArray()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func convertToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        
        let newDate: String = dateFormatter.string(from: date) // pass Date here
        print(newDate) // New formatted Date string
        
        return newDate
    }
    
    
    func displayEnsNoMas() {
        self.detailMsgTextView.text = "Cannot retrieve messages at this time"
        
        
        self.updatedAt.text = convertToString(date: Date())
    }
    
    func resetUserHistoryTableView() {
        print("noop")
    }
    
    // MARK: Supporting methods
    func loadEnsArchiveArray() {
        ensStore.fetchEnsArchives() {
            (ensArchives) -> Void in
    
            switch ensArchives {
            case let .Success(ensArchives):

                print("ENSVC: loadEnsArchiveArray: Successfully found \(ensArchives.count) enses")
                let ensItem = ensArchives[0] as Ens
                
                self.detailMsgTextView.text = ensItem.description
                self.updatedAt.text = ensItem.updatedAt
                
            case let .Failure(_):
                    let alert = UIAlertController(title: "Alert!", message: "Cannot retrieve messages at this time.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                        self.resetUserHistoryTableView()
                    })
                    self.present(alert, animated: true, completion: nil)

            }   // end switch
    }   // end loadEnsArchiveArray

    }
}

