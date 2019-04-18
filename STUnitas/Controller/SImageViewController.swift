//
//  SImageViewController.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class SImageViewController: UIViewController {

    private lazy var imageView = UITableView()
    private let listCellId = "SImageCell"
    private lazy var imageList = Array<ImageInfo>()
    private lazy var page = Int()
    private let searchController = UISearchController(searchResultsController: nil)
    private var timer: Timer?
    private let backGroundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .gray
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        
        return view
    }()
    private let indicator: UIActivityIndicatorView = {
        let active = UIActivityIndicatorView(style: .whiteLarge)
        active.backgroundColor = .clear
        
        return active
    }()
    
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
        imageView.prefetchDataSource = self
        imageView.separatorStyle = .none

        view.addSubview(backGroundView)
        backGroundView.addSubview(indicator)
        backGroundView.alpha = 0.0
        
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        backGroundView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        indicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    func timerCallback(timer: Timer) {
        backGroundView.alpha = 1.0
        indicator.startAnimating()
        timer.invalidate()
        page = 1
        getSearchImage { [weak self] searchImage in
            self?.imageView.scrollsToTop = true
            self?.imageList = searchImage
            self?.imageView.reloadData()
            self?.backGroundView.alpha = 0.0
            self?.indicator.stopAnimating()
        }
    }
    
    func showErrorMesseage(msg: String) {
        let alertVC = UIAlertController.init(title: "알림", message: "\(msg)\n잠시 후 다시 시도해주세요", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default)
        alertVC.addAction(confirm)
        present(alertVC, animated: true, completion: nil)
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
            imageList.count % 80 == 0
            else {
                return
        }
        page = page + 1
        getSearchImage { [weak self] searchImage in
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
            self?.imageView.scrollToRow(at: IndexPath(row: dataCount, section: 0), at: .bottom, animated: false)
        }
    }
    
    private func getSearchImage(onData: @escaping ([ImageInfo]) -> Void) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        NetworkManager().getImage(query: searchText, page: "\(page)", onSuccess: {
            onData($0)
        }, onFailure: { [weak self] error in
            switch error {
            case .cancel: break
            default :
                self?.backGroundView.alpha = 0.0
                self?.indicator.stopAnimating()
                self?.showErrorMesseage(msg: error.localizedDescription)
            }
        })
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
        timer?.invalidate()
        imageList.removeAll()
        imageView.reloadData()
    }
}

extension SImageViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        timer?.invalidate()
        guard
            let searchText = searchController.searchBar.text,
            searchText.count > 0
            else {
            imageList.removeAll()
            imageView.reloadData()
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: timerCallback)
    }
}

extension SImageViewController : UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let resources = imageList.map {
            return ImageResource(downloadURL: URL(string: $0.imageURL)!, cacheKey: $0.imageURL)
        }
        let prefetcher = ImagePrefetcher(resources: resources)
        prefetcher.start()
    }
}
