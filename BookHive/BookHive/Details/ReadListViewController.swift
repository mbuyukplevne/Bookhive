//
//  ReadListViewController.swift
//  BookHive
//
//  Created by Mehdican Büyükplevne on 29.04.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReadListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var favoriteBooks = [Book]()
    var viewModel = DetailViewModel()
    var readingBooks: [ReadBook] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       setTableView()
        fetchReadingBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFavoriteBooks()
    }
    
    // MARK: - Table View Setup
    private func setTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(WantToReadTableViewCell.nib(),
                           forCellReuseIdentifier: WantToReadTableViewCell.identifier)
    }
    
    // MARK: - Fetch Favorite Books Collection (Firebase)
    private func fetchFavoriteBooks() {
        if let uuid = Auth.auth().currentUser?.uid {
            let favoriteBooksCollection = Firestore.firestore().collection("users/\(uuid)/favoriteBooks")
            favoriteBooksCollection.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    self.showAlert(title  : "error",
                                   message: "No Favorite Books Found")
                    return
                }
                var books = [Book]()
                for document in documents {
                    let coverID = document.data()["coverID"] as! String
                    let title   = document.data()["title"] as! String
                    let author  = document.data()["author"] as? String
                    let book    = Book(coverID: coverID, title: title, author: author)
                    books.append(book)
                }
                self.favoriteBooks = books
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchReadingBooks() {
        if let uuid = Auth.auth().currentUser?.uid {
            let favoriteBooksCollection = Firestore.firestore().collection("users/\(uuid)/ReadsBooks")
            favoriteBooksCollection.getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching favorite books: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    self.showAlert(title: "hata", message: "No read books found.")
                    return
                }
                for document in documents {
                    let documentID      = document.documentID
                    let coverID         = document.data()["coverID"] as! String
                    let title           = document.data()["title"] as! String
                    let finish          = document.data()["finish"] as! Bool
                    let readPage        = document.data()["readPage"] as! Int
                    let readingDate     = document.data()["readingdate"] as? Date
                    let author          = document.data()["author"] as? String
                    let totalpageNumber = document.data()["totalpageNumber"] as! Int
                    
                    let readbookArray   = ReadBook(coverID: coverID, title: title, finish: finish, readPage: readPage, readingDate: readingDate, totalpageNumber: totalpageNumber, author: author,documentID:documentID)
                    self.readingBooks.append(readbookArray)
                    
                }
            }
        }
    }
    
    //MARK: - Remove Favorite
    func favoriteBookDelete(index: Int) {
        if let uuid = Auth.auth().currentUser?.uid {
            let favoriteBooksCollection = Firestore.firestore().collection("users/\(uuid)/favoriteBooks")
            let coverIDToDelete = self.favoriteBooks[index].coverID
            favoriteBooksCollection.whereField("coverID", isEqualTo: coverIDToDelete!).getDocuments { (snapshot, error) in
                if let error = error {
                    self.showAlert(title: "ERROR", message: "Favorilere ekleme sırasında bir hata ile karşılaşıldı.")
                } else {
                    if let documents = snapshot?.documents {
                        for document in documents {
                            let bookID = document.documentID
                            favoriteBooksCollection.document(bookID).delete()
                        }
                        DispatchQueue.main.async {
                            self.fetchFavoriteBooks()
                        }
                    }
                }
            }
        }
    }
    
    func addReadBook(index: Int) {
        if let uuid = Auth.auth().currentUser?.uid {
            let favoriteBooksCollection = Firestore.firestore().collection("users/\(uuid)/ReadsBooks")
            let coverIDToDelete = self.favoriteBooks[index].coverID
            let bookTitle = self.readingBooks[index].title
            let authorName = self.readingBooks[index].author
            let totalPage = self.readingBooks[index].totalpageNumber
            favoriteBooksCollection.whereField("coverID", isEqualTo: coverIDToDelete!).getDocuments { (snapshot, error) in
                if let error = error {
                    self.showAlert(title: "ERROR", message: "Okumaya başlama sırasında bir hata ile karşılaşıldı.")
                } else {
                    favoriteBooksCollection.addDocument(data: ["coverID" : coverIDToDelete!,
                                                               "title"   : bookTitle!,
                                                               "readPage": 0,
                                                               "author"  : authorName!,
                                                               "readingdate" : FieldValue.serverTimestamp(),
                                                               "totalpageNumber": totalPage ?? 0,
                                                               "finish": false])
                }
                DispatchQueue.main.async {
                    self.fetchReadingBooks()
                }
            }
        }
    }
    
    private func delete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { action, view, completion in
            if let uuid = Auth.auth().currentUser?.uid {
                let favoriteBooksCollection = Firestore.firestore().collection("users/\(uuid)/favoriteBooks")
                let coverIDToDelete = self.favoriteBooks[indexPath.row].coverID
                favoriteBooksCollection.whereField("coverID", isEqualTo: coverIDToDelete ?? "").getDocuments { (snapshot, error) in
                    if error != nil {
                        self.showAlert(title: "ERROR", message: "Favorilere ekleme sırasında bir hata ile karşılaşıldı.")
                    } else {
                        if let documents = snapshot?.documents {
                            for document in documents {
                                let bookID = document.documentID
                                favoriteBooksCollection.document(bookID).delete() { error in
                                    if let error = error {
                                        print("Error deleting document: \(error)")
                                    } else {
                                        self.favoriteBooks.remove(at: indexPath.row)
                                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        return deleteAction
    }
    
    private func read(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let readAction = UIContextualAction(style: .normal, title: "Read") { action, view, completion in
            self.favoriteBookDelete(index: indexPath.row)
            self.addReadBook(index: indexPath.row)
            completion(true)
        }
        readAction.backgroundColor = UIColor(named: "addedFavoriteButton")
        readAction.image = UIImage(systemName: "book")
        return readAction
        
    }
    
    // MARK: - Back Button Action
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: - Extensions
extension ReadListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WantToReadTableViewCell.identifier, for: indexPath) as! WantToReadTableViewCell
        cell.configure(book: favoriteBooks[indexPath.row])
        return cell
    }
}

extension ReadListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = self.delete(rowIndexPathAt: indexPath)
        let read = self.read(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete,read])
        return swipe
    }
 
}





