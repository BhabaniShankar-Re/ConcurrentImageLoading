//
//  ViewController.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 17/07/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import UIKit

let dataSourceUrl = URL(string: "http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageRecords = [ImageRecord]()
    let pendingOperation = PendingOperation()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageRecordDetails()
    }
    
    //MARK: Get all information about the ImageList as .plist file
    fileprivate func imageRecordDetails(){
        activityIndicator.startAnimating()
        let alertController = UIAlertController(title: "Error", message: "Unknown Error Occurs", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        if let url = dataSourceUrl{
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let error = error{
                    DispatchQueue.main.async {
                        alertController.message = error.localizedDescription
                        self?.present(alertController, animated: true, completion: nil)
                    }
                }
                
                if let data = data{
                    do{
                        let dataSourceDictionary = try PropertyListDecoder().decode([String: String].self, from: data)
                        
                        for (name, url) in dataSourceDictionary{
                            
                            if let url = URL(string: url){
                                let imageRecord = ImageRecord(name: name, url: url)
                                self?.imageRecords.append(imageRecord)
                            }
                                
                        }
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    }catch let error as NSError{
                        DispatchQueue.main.async {
                            alertController.message = error.domain
                            self?.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
            }.resume()
        }
    }
    
    fileprivate func startOperationForImageRecord(imageRecord: ImageRecord, indexPath: IndexPath){
        switch imageRecord.state {
        case .new:
            startDownloadOperation(for: imageRecord, at: indexPath)
        case .downloaded:
            startFilerOperation(for: imageRecord, at: indexPath)
        default:
            NSLog("Process Completed or Some Other State")
        }
    }
    
    //MARK: Start Download Operation for a image record.
    fileprivate func startDownloadOperation(for imageRecord: ImageRecord, at index: IndexPath){
        if let _ = pendingOperation.pendingDownloadOperation[index]{
            return
        }
        
        let downloader = ImageDownloader(imageRecord: imageRecord)
        pendingOperation.pendingDownloadOperation[index] = downloader
        pendingOperation.downloadQueue.addOperation(downloader)
        
        downloader.completionBlock = {
            self.pendingOperation.pendingDownloadOperation.removeValue(forKey: index)
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [index], with: .left)
            }
        }
        
    }
    
    //MARK: Start Filter Operation for a image recod.
    fileprivate func startFilerOperation(for imageRecord: ImageRecord, at index: IndexPath){
        if let _ = pendingOperation.pendingFilterationOperation[index]{
            return
        }
        
        let filterization = ImageFilter(imageRecord: imageRecord)
        
        pendingOperation.pendingFilterationOperation[index] = filterization
        pendingOperation.filterQueue.addOperation(filterization)
        
        filterization.completionBlock = {
            self.pendingOperation.pendingFilterationOperation.removeValue(forKey: index)
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [index], with: .right)
            }
        }
        
    }


}

//MARK: Table view Datasource and Delegate method.
extension ListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageRecCell", for: indexPath)
        
        if cell.accessoryView == nil{
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .blue
            cell.accessoryView = indicator
        }
        
        let imageDetails = imageRecords[indexPath.row]
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        cell.textLabel?.text = imageDetails.name
        cell.imageView?.image = imageDetails.image
        
        switch imageDetails.state {
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to Load Image"
        case .filtered:
            indicator.stopAnimating()
        case .downloaded, .new:
            indicator.startAnimating()
            if (!tableView.isDragging && !tableView.isDecelerating){
                startOperationForImageRecord(imageRecord: imageDetails, indexPath: indexPath)
            }
            
        }
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperation()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate{
            loadForOnlyVisibleRows()
            resumeAllOperation()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadForOnlyVisibleRows()
        resumeAllOperation()
    }
    
    
    
    //MARK: Reload only those rows which are visible now.
    func loadForOnlyVisibleRows(){
        if let visibleRows = tableView.indexPathsForVisibleRows{
        
            var pendingOperation = Set(self.pendingOperation.pendingDownloadOperation.keys)
            pendingOperation =  pendingOperation.union(self.pendingOperation.pendingFilterationOperation.keys)
            
            let toBeCancel = pendingOperation.subtracting(visibleRows)
            
            let toBeStart = Set(visibleRows).subtracting(pendingOperation)
            
            for index in toBeCancel{
                if let downloadOperation = self.pendingOperation.pendingDownloadOperation[index]{
                    downloadOperation.cancel()
                }
                self.pendingOperation.pendingDownloadOperation.removeValue(forKey: index)
                if let filterOperation = self.pendingOperation.pendingFilterationOperation[index]{
                    filterOperation.cancel()
                }
                self.pendingOperation.pendingFilterationOperation.removeValue(forKey: index)
            }
            
            for index in toBeStart{
                let imageRecord = imageRecords[index.row]
                startOperationForImageRecord(imageRecord: imageRecord, indexPath: index)
            }
        }
        
    }
    
    //MARK: Suspend all operation in PendingOperationQueue
    fileprivate func suspendAllOperation(){
        pendingOperation.downloadQueue.isSuspended = true
        pendingOperation.filterQueue.isSuspended = true
    }
    
    //MARK: Resume all operation in PendingOperationQueue
    fileprivate func resumeAllOperation(){
        pendingOperation.downloadQueue.isSuspended = false
        pendingOperation.filterQueue.isSuspended = false
    }
    
}
