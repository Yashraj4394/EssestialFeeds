//
//  FeedImageCell.swift
//  Prototype
//
//  Created by YashraJ Gujar on 02/05/22.
//

import UIKit

class FeedImageCell: UITableViewCell {
	
	@IBOutlet private(set) weak var locationContainer: UIView!
	@IBOutlet private(set) weak var locationLabel: UILabel!
	@IBOutlet private(set) weak var feedImageView: UIImageView!
	@IBOutlet private(set) weak var descriptionLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		feedImageView.alpha = 0
	}
	
	override func prepareForReuse() {
		feedImageView.alpha = 0
	}
	
	func fadeIn(_ image: UIImage?) {
		feedImageView.image = image
		UIView.animate(withDuration: 0.30, delay: 0.50, options: []) {
			self.feedImageView.alpha = 1
		} completion: { _ in }
		
	}
}
