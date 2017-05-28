//
//  ViewController.swift
//  MovieDB
//
//  Created by Hien on 5/20/17.
//  Copyright © 2017 Cntt10. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    var dataTask: URLSessionDataTask?
    var Results = [Movie]()
    var filteredMovies = [Movie]()
    var p=1
    var prefixImg: String = "https://image.tmdb.org/t/p/w320"
    fileprivate let itemsPerRow: CGFloat = 2 // set 2 items on row
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0) // set margin for row
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var collectionView: UICollectionView!
    
    var posters = [String]()
    var downloadsSession = URLSession()
    var queue = OperationQueue()

    class Downloader {
        class func downloadImageWithURL(_ url:String) -> UIImage! {
            let data = try? Data(contentsOf: URL(string: url)!)
            return UIImage(data: data!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //defaultSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self as? URLSessionDelegate,     delegateQueue: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        downloadsSession = {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: nil)
            return session
        }()
        //requestData()
        
        reloadMovie(page: 1)
        

    }

    
    private func reloadMovie(page : Int) {
        //  if the data task is already initialized. you cancel this task
        if dataTask != nil {
            dataTask?.cancel()
        }
        // You enable the network activity indicator on the status bar to indicate to the user that a network process is running.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=24b1973f805d7f765ee59e3481812a29&language=en-US&page=\(page)")
        // 5
        dataTask = downloadsSession.dataTask(with: url! as URL) {
            data, response, error in
            // 6
            DispatchQueue.main.async() {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            // 7
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateSearchResults(data)
                }
            }
        }
        // 8
        dataTask?.resume()
    }
    
    // This helper method helps parse response JSON NSData into an array of Track objects.
    func updateSearchResults(_ data: Data?) {
        Results.removeAll()
        do {
            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                
                // Get the results array
                if let array: AnyObject = response["results"] {
                    for movieDictonary in array as! [AnyObject] {
                        if let movieDictonary = movieDictonary as? [String: AnyObject]{
                            // Parse the search result
                            let posterPath = movieDictonary["poster_path"] as? String
                            let overview = movieDictonary["overview"] as? String
                            let title = movieDictonary["title"] as? String
                            let release_date = movieDictonary["release_date"] as? String
                            let id = movieDictonary["id"] as? Int
                            let genres = movieDictonary["genre_ids"] as? [Int]

                            Results.append(Movie(id: id!, title: title!, poster: posterPath!, overview: overview!, releaseDate: release_date!, genres: genres!))
                        } else {
                            print("Not a dictionary")
                        }
                    }
                } else {
                    print("Results key not found in dictionary")
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(CGPoint.zero, animated: false)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(searchController.isActive && searchController.searchBar.text != ""){
            return filteredMovies.count
        }
        else{
            return Results.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        var movies : Movie
        if(searchController.isActive && searchController.searchBar.text != ""){
            movies = filteredMovies[indexPath.row]
        }
        else{
            movies = Results[indexPath.row]
        }
        
        queue.addOperation { () -> Void in
            if movies.getPoster() != "" {
                if let img = Downloader.downloadImageWithURL("\(self.prefixImg)\(movies.getPoster())") {
                    OperationQueue.main.addOperation({
                        cell.poster?.image = img
                        cell.title.text = movies.getTitle()
                    })
                }
            }
        }
        return cell

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "MovieDetail"){
             let movieDetail = segue.destination as! MovieDetailViewController
            if let cell = sender as? UICollectionViewCell,let indexPath = collectionView!.indexPath(for: cell){
                if(searchController.isActive && searchController.searchBar.text != ""){
                    movieDetail.titleF = filteredMovies[indexPath.row].getTitle()
                    movieDetail.image = Downloader.downloadImageWithURL("\(self.prefixImg)\(filteredMovies[indexPath.row].getPoster())")
                    movieDetail.overview = filteredMovies[indexPath.row].getOverview()
                    movieDetail.releaseDate1 = filteredMovies[indexPath.row].getReleaseDate()
                }
                else{
                    movieDetail.titleF = Results[indexPath.row].getTitle()
                    movieDetail.image = Downloader.downloadImageWithURL("\(self.prefixImg)\(Results[indexPath.row].getPoster())")
                    movieDetail.releaseDate1 = Results[indexPath.row].getReleaseDate()
                    movieDetail.overview = Results[indexPath.row].getOverview()

                }
            }
            

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as! SearchCollectionReusableView
            return header
        }
        
        return UICollectionReusableView()
    }
    func filterContentForSearchText(searchText: String) {
        filteredMovies = Results.filter { movie in
            return  movie.getTitle().lowercased().contains(searchText.lowercased())
        }
        
        collectionView.reloadData()
    }


}
extension ViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
}
extension ViewController : UICollectionViewDelegateFlowLayout {
    //1 set size for item on row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // your code here
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 2 * widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
extension ViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            self.collectionView?.reloadData()
        }
        print("bth")
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            //reload your data source if necessary
            self.collectionView?.reloadData()
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            self.collectionView?.reloadData()
        }
    }
}
extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}





