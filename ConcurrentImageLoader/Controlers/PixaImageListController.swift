//
//  PixaImageListController.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 22/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import UIKit

class PixaImageListController: UITableViewController, UITableViewDataSourcePrefetching {
  
    lazy var activityInicator = UIActivityIndicatorView(style: .large)
    var pendingOperation = [IndexPath : [URLSessionTask]]()
    let totalCount = 500
    var viewModel: ViewModel!
    
    @IBAction func updatearow(_ sender: Any) {
        if let indices = tableView.indexPathsForVisibleRows {
            print("visible indices \(indices)")
            tableView.reloadRows(at: indices, with: .none)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOutlet()
        viewModel = ViewModel(delegate: self)
        viewModel.fetchImageList()
        tableView.prefetchDataSource = self
    }
    
    func setupOutlet() {
        self.view.addSubview(activityInicator)
        activityInicator.center = view.center
        activityInicator.startAnimating()
        navigationItem.title = "PixaImage"
    }
    
    private func startDownloadOperation(for imagerecord: PixaImage, at indexPath: IndexPath) {
//        print("start download", indexPath)
        if let _ = pendingOperation[indexPath] {
          //  print("return index", indexPath)
            return
        }
//        print(imagerecord.imageUrl, imagerecord.authorImageUrl)
        guard let imageUrl = URL(string: imagerecord.imageUrl), let authorImageUrl = URL(string: imagerecord.authorImageUrl) else {
            return
        }
        
        let imageTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode < 300, let data = data {
                let image = UIImage(data: data)
                imagerecord.image = image
                self?.updateCell(at: indexPath)
                
            }
            self?.pendingOperation.removeValue(forKey: indexPath)
        }
        
        let authorImageTask = URLSession.shared.dataTask(with: authorImageUrl) { [weak self] (data, response, error) in
            if let response = response as? HTTPURLResponse, response.statusCode < 300, let data = data {
                let image = UIImage(data: data)
                imagerecord.authorImage = image
                self?.updateCell(at: indexPath)
            }
            print(indexPath)
            self?.pendingOperation.removeValue(forKey: indexPath)
        }
        pendingOperation[indexPath] = [imageTask, authorImageTask]
        imageTask.resume(); authorImageTask.resume()
        
    }
    
    private func updateCell(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let indexPaths = self.tableView.indexPathsForVisibleRows, indexPaths.contains(indexPath) {
                self.tableView.reloadRows(at: indexPaths, with: .none)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.imageList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for item", indexPath)
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "pixaimagecell", for: indexPath) as! PixaImageCell
        let imageData = viewModel.imageList[indexPath.row]
        if imageData.image != nil, imageData.authorImage != nil{
            imageCell.configureCell(with: imageData)
        }else {
            imageCell.configureCell(with: .none)
            startDownloadOperation(for: imageData, at: indexPath)
        }
        
        return imageCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = viewModel.currentCount
        if indexPath.row == count - 1, count <= totalCount{
            print("call for new list request", "count \(count)")
            viewModel.fetchImageList()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetch",indexPaths)
        indexPaths.forEach { (indexpath) in
            let pixaImage = viewModel.imageList[indexpath.row]
            if pixaImage.image == nil || pixaImage.authorImage == nil {
                startDownloadOperation(for: pixaImage, at: indexpath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancel prefetch", indexPaths)
        indexPaths.forEach { (indexPath) in
            if let pendingOperation = pendingOperation[indexPath] {
                pendingOperation.forEach { $0.cancel() }
                self.pendingOperation.removeValue(forKey: indexPath)
            }
        }
    }

}

extension PixaImageListController: ViewModelDelegate {
    func onFetchComplete() {
        activityInicator.stopAnimating()
        tableView.reloadData()
    }
    
    func onFetchFailed(with reason: String) {
        print(reason)
    }
    
    
}
