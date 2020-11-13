//
//  PixaImageCell.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 23/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import UIKit

class PixaImageCell: UITableViewCell {
    static let cellIdenitifier = "pixaimagecell"
    
    @IBOutlet weak var superBigcontainerView: UIView!
    @IBOutlet weak var bigContainerView: UIView!
    @IBOutlet weak var smallContainerView: UIView!
    @IBOutlet weak var image_View: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpOutlet()
    }
    
    func configureCell(with imageData: PixaImage?) {
        if let imageData = imageData {
            image_View.image = imageData.image
            authorImageView.image = imageData.authorImage
            nameLabel.text = imageData.authorName
        }else {
            nameLabel.text = nil
            image_View.image = nil
            authorImageView.image = nil
            authorImageView.backgroundColor = .lightGray
            image_View.backgroundColor = .lightGray
           // nameLabel.backgroundColor = .lightGray
            
        }
    }
    
    private func setUpOutlet() {
        superBigcontainerView.layer.cornerRadius = 20
        bigContainerView.layer.cornerRadius = 12
        bigContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        bigContainerView.layer.shadowOffset = .zero
        bigContainerView.layer.shadowRadius = 3
        bigContainerView.layer.shadowOpacity = 0.3
        
        smallContainerView.layer.cornerRadius = 6
        smallContainerView.layer.shadowColor = UIColor.darkGray.cgColor
        smallContainerView.layer.shadowOffset = .zero
        smallContainerView.layer.shadowRadius = 3
        smallContainerView.layer.shadowOpacity = 0.3
        
        authorImageView.layer.cornerRadius = 6
        
        image_View.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
