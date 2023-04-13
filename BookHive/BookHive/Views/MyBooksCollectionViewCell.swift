//
//  MyBooksCollectionViewCell.swift
//  BookHive
//
//  Created by Mehdican Büyükplevne on 13.04.2023.
//

import UIKit

class MyBooksCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MyBooksCollectionViewCell"
    
    @IBOutlet weak var mybooksView: UIView!
    @IBOutlet weak var mybooksImageView: UIImageView!
    @IBOutlet weak var mybooksBookNameLabel: UILabel!
    @IBOutlet weak var mybooksAuthorNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyBooksCollectionViewCell", bundle: nil)
    }

}
