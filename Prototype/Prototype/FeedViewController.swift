//
//  FeedViewController.swift
//  Prototype
//
//  Created by YashraJ Gujar on 02/05/22.
//

import UIKit

final class FeedViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 5
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath)
		
		return cell
	}
	
	
}
