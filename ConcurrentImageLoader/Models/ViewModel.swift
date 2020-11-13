//
//  ViewModel.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 23/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import Foundation

protocol ViewModelDelegate: class {
    func onFetchComplete()
    func onFetchFailed(with reason: String)
}


final class ViewModel {
    private weak var delegate: ViewModelDelegate?
    private var currentPage = 0
    private var totalPage = 0
    var imageList: [PixaImage] = []
    
    var currentCount: Int{
        return imageList.count
    }
    
    
    private let networkmanager = PixaNetworking()
    
    init(delegate: ViewModelDelegate) {
        self.delegate = delegate
    }
    
    func fetchImageList() {
        let nextpage = currentPage + 1
        networkmanager.fetchPxaImageList(page: nextpage) { (result) in
            switch result{
            case .success(let dataReponse):
                DispatchQueue.main.async {
                    self.currentPage = nextpage
                    self.totalPage = dataReponse.total
                    self.imageList.append(contentsOf: dataReponse.imageList)
                    self.delegate?.onFetchComplete()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.onFetchFailed(with: error.reason)
                }
            }
        }
    }
}
