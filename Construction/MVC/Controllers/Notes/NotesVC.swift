////
//  NotesVC.swift
//  Construction
//
//  Created by CodeX on 04/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit
import Alamofire

class NotesVC: UIViewController {

    @IBOutlet var notesTblView: UITableView!

    fileprivate var notesData: [NoteData] = []
    
    var noteType: Int = -1
    var referenceId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Notes"
        
        self.setupRightNavItem()
        
        self.notesTblView.backgroundColor = UIColor.groupTableViewBackground
        
        self.notesTblView.delegate = self
        self.notesTblView.dataSource = self
        
        self.notesTblView.register(UINib(nibName: "NotesTVCell", bundle: nil), forCellReuseIdentifier: "NotesTVCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getNotesDataFromServer()
    }
    
    fileprivate func setupRightNavItem() {
        let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightItemAction(_:)))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc fileprivate func rightItemAction(_ sender: UIBarButtonItem) {
        let newNoteVC = storyboard?.instantiateViewController(withIdentifier: "AddNotesVC") as! AddNotesVC
        newNoteVC.referenceId = self.referenceId
        newNoteVC.noteType = self.noteType
        self.navigationController?.pushViewController(newNoteVC, animated: true)
    }
    
    fileprivate func getNotesDataFromServer() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GETNotesURL)?noteType=\(self.noteType)&reference=\(self.referenceId)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (response: BasicResponse<[NoteData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                self!.showBanner(title: err, style: .danger)
                return
            }
            if response?.success == true {
                self!.notesData = response!.data!.sorted(by: { $0.createdDate!.dateFromISO8601! > $1.createdDate!.dateFromISO8601! })
                self!.notesTblView.reloadData()
            } else {
                self!.showBanner(title: response?.error ?? "An error occurred. Please try again.", style: .danger)
            }
        }
    }
    
    deinit {
        print("NotesVC deinit")
    }
}

extension NotesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTVCell", for: indexPath) as! NotesTVCell
        let note = self.notesData[indexPath.row]
        cell.dateLbl.text = note.createdDate?.dateFromISO8601?.humanReadableDate ?? "N/A"
        cell.headerLbl.text = note.noteHeading ?? "N/A"
        cell.imageView?.tintColor = UIColor.primaryColor
        cell.contentLbl.text = note.noteContent ?? "N/A"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
