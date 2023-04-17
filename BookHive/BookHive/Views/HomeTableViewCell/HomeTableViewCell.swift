//
//  HomeTableViewCell.swift
//  BookHive
//
//  Created by Anıl AVCI on 12.04.2023.
//

import UIKit
import Kingfisher

class HomeTableViewCell: UITableViewCell {
    private var viewModel = HomeViewModel()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionSetup()
        initViewModel()
        observeEvent()
    }
    func initViewModel() {
        //        ProductEndPoint.products.path =
        viewModel.fetchTrendBooks()
    }
    func observeEvent() {
        print("DENEME")
        viewModel.eventHandler = { [weak self] event in
            guard let self else {return}
            
            switch event {
            case .loading:
                //indicator show
                print("Product loading...")
            case .stopLoading:
                // indicator hide
                print("Stop loading...")
            case .dataLoaded:
                if self.viewModel.trendBook.count == 0 {
                    print("DATA COUNT ----->>>> 0")
                } else {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                print("Data loaded count...\( self.viewModel.trendBook.count)")
            case .error(let error):
                print("HATA VAR!!!! \(error?.localizedDescription)")
            }
        }
    }
    private func collectionSetup() {
        collectionView.register(TableCollectionViewCell.nib(), forCellWithReuseIdentifier: TableCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}
extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.trendBook.count
        //return bookList[collectionView.tag].bookImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCollectionViewCell.identifier, for: indexPath) as! TableCollectionViewCell
        //cell.imageView.image = UIImage(named: bookList[collectionView.tag].bookImage[indexPath.row])
       
        if let isbn = viewModel.trendBook[indexPath.row].availability?.isbn {
            print("-----> ISBN \(indexPath.row) ---- \(isbn)")
//            cell.imageView.setImageIsbn(with: isbn)
            cell.imageView.kf.setImage(with: URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-S.jpg"))
        }
        else {
            if let olid = viewModel.trendBook[indexPath.row].availability?.openlibrary_edition {
                print("-----> OLID \(indexPath.row) ---- \(olid)")
                cell.imageView.setImageOlid(with: olid)
            }
            cell.bookName.text = viewModel.trendBook[indexPath.row].title
        }
        
        return cell
    }
    
    
}

// Kingfisher image cache Extensions
extension UIImageView {
    func setImageIsbn(with isbn: String) {
        let urlString = "https://covers.openlibrary.org/b/isbn/\(isbn)-S.jpg"
        guard let url = URL(string: urlString) else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        print("------> \(resource)")
        kf.indicatorType = .activity
        kf.setImage(with: resource)
    }
    func setImageOlid(with olid: String) {
        // https://covers.openlibrary.org/b/olid/OL25418275M-M.jpg
        let urlString = "https://covers.openlibrary.org/b/olid/\(olid)-S.jpg"
        guard let url = URL(string: urlString) else {
            return
        }
        let resource = ImageResource(downloadURL: url, cacheKey: urlString)
        kf.indicatorType = .activity
        kf.setImage(with: resource)
    }
}
