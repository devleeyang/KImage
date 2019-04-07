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
    private  var timer: Timer?
    
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
    
    func timerCallback(timer: Timer) {
        timer.invalidate()
        guard let searchText = searchController.searchBar.text else {
            return
        }
        page = 1
        NetworkManager().getImage(query: searchText, page: "\(page)") { [weak self] searchImage in
            self?.imageView.scrollsToTop = true
            self?.imageList = searchImage
            self?.imageView.reloadData()
        }
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dataCount = imageList.count - 1
        guard
            page < 50,
            indexPath.row == dataCount,
            let searchText = searchController.searchBar.text
            else {
                return
        }
        page = page + 1
        NetworkManager().getImage(query: searchText, page: "\(page)") { [weak self] searchImage in
            guard let beforeImageList = self?.imageList else {
                return
            }
            let updateImages = beforeImageList + searchImage
            self?.imageList = updateImages
            let indexs = (beforeImageList.count..<updateImages.count).map { (Int) -> IndexPath in
                IndexPath(row: Int, section: 0)
            }
            
            self?.imageView.beginUpdates()
            self?.imageView.insertRows(at: indexs, with: .bottom)
            self?.imageView.endUpdates()
            self?.imageView.scrollToRow(at: IndexPath(row: beforeImageList.count, section: 0), at: .bottom, animated: false)
        }
    }
}

extension SImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInfo = imageList[indexPath.row]
        return (UIScreen.main.bounds.size.width * CGFloat(imageInfo.height)) / CGFloat(imageInfo.width)
    }
}

extension SImageViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        imageList.removeAll()
        imageView.reloadData()
    }
}

extension SImageViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        guard
            let searchText = searchController.searchBar.text,
            searchText.count > 0
            else {
            imageList.removeAll()
            imageView.reloadData()
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: timerCallback)
        print("call updateSearchResults")
    }
}
