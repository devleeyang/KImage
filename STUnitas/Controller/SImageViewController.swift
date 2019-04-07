//
//  SImageViewController.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import UIKit
import SnapKit

class SImageViewController: UIViewController {

    private var imageView = UITableView()
    private let listCellId = "SImageCell"
    private var imageList = Array<ImageInfo>()
    private var page = Int()
    private let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Images"
        searchController.searchBar.delegate = self
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    
        imageView = UITableView()
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.backgroundColor = .white
        imageView.register(SImageCell.self, forCellReuseIdentifier: listCellId)
        imageView.keyboardDismissMode = .onDrag
        imageView.delegate = self
        imageView.dataSource = self
        imageView.separatorStyle = .none

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
extension SImageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SImageCell = imageView.dequeueReusableCell(withIdentifier: listCellId, for: indexPath) as! SImageCell
        cell.resultImage = imageList[indexPath.row]
        return cell
    }
extension SImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SImageViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}
    }
}
