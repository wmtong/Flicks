//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by William Tong on 1/23/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var errorButton: UIButton!
    
    //var navigationItem: UINavigationItem!
    
    //var searchBar : UISearchBar!
    var movies: [NSDictionary]?
    
    var endpoint: String!
    lazy var searchBar = UISearchBar(frame: CGRectMake(0, 0, 290, 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView:searchBar)
        
        errorButton.hidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        networkRequest()
    }
    
    var moviedata: NSData!
    
    func networkRequest(){
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.moviedata = data
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                            self.errorButton.hidden = true
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            var MovieTitles: [String] = []
                            var MoviePosters: [String] = []
                            for var index = 0; index < self.movies!.count; ++index {
                                let MovieInfo = self.movies![index] as NSDictionary
                                MovieTitles.append(MovieInfo["title"] as! String)
                                MoviePosters.append(MovieInfo["poster_path"] as! String)
                            }
                            self.data = MovieTitles
                            self.filteredData = self.data
                            
                            self.posterData=MoviePosters
                            self.filteredPosters = self.posterData
                    }
                }
                else{
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.errorButton.hidden = false
                }
                self.filteredMovies = self.movies

        })
        task.resume()

    }
    

    func refreshControlAction(refreshControl: UIRefreshControl) {

        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // Reload the collectionView now that there is new data
                self.collectionView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            //NetworkErrorLabel.hidden = true
            return filteredData.count
        } else {
            //NetworkErrorLabel.hidden = false
            return 0
        }
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieIdentifier", forIndexPath: indexPath) as! MovieCell
        let posterPath = filteredPosters[indexPath.item]
        let smallBaseUrl = "https://image.tmdb.org/t/p/w45"
        let largeBaseUrl = "https://image.tmdb.org/t/p/w342"
        let smallImageUrl = NSURL(string: smallBaseUrl+posterPath)
        let largeImageUrl = NSURL(string: largeBaseUrl+posterPath)
        let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
        let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
        
        cell.backgroundColor = UIColor.blackColor()

        cell.movieImage.setImageWithURLRequest(
            smallImageRequest,
            placeholderImage: nil,
            success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                
                // imageResponse will be nil if the image is cached
                if smallImageResponse != nil {
                    cell.movieImage.alpha = 0.0
                    cell.movieImage.image = smallImage
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        cell.movieImage.alpha = 1.0
                        },completion: {
                            (sucess) -> Void in
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            cell.movieImage.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    cell.movieImage.image = largeImage;
                                },
                                failure: { (request, response, error) -> Void in
                                    cell.movieImage.image = UIImage(named: "error")
                                    
                            })
                        }
                    )
                } else {
                    cell.movieImage.alpha = 0.0
                    cell.movieImage.image = smallImage
                    UIView.animateWithDuration(
                        0.2, animations: {
                            () -> Void in
                            cell.movieImage.alpha = 1.0
                        }, completion: {
                            (sucess) -> Void in
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            cell.movieImage.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    cell.movieImage.image = largeImage;
                                },
                                failure: { (request, response, error) -> Void in
                                    cell.movieImage.image = UIImage(named: "error")
                                    
                                }
                            )
                        }
                    )
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                cell.movieImage.image = UIImage(named: "error")
        })
        
        
        return cell
    }
    
    @IBAction func networkError(sender: AnyObject) {
        networkRequest()
    }

    var data: [String]?
    var posterData: [String]?
    var filteredData: [String]!
    var filteredPosters: [String]!
    var totalIndexes: [Int]?
    var filteredMovies: [NSDictionary]?

    
    func searchBar(searchBar: UISearchBar, var textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = data
            filteredPosters = posterData
            filteredMovies = movies
            
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            
            
            var tempTitleList: [String] = []
            var tempPosterList: [String] = []
            var tempIndexList: [Int] = []
            var tempMovieList: [NSDictionary] = []
            
            searchText = searchText.lowercaseString

            // Go through each element in data
            for var filterIndex = 0; filterIndex < data!.count; ++filterIndex {
                
                // For each that matches the filter
                
                if data![filterIndex].lowercaseString.containsString(searchText) {
                    // Add index to temporary list
                    tempPosterList.append(posterData![filterIndex])
                    tempTitleList.append(data![filterIndex])
                    tempIndexList.append(filterIndex)
                    tempMovieList.append(movies![filterIndex])
                    
                                    }
            }

            // Change filtered list to temporary list
            filteredData = tempTitleList
            filteredPosters = tempPosterList
            filteredMovies = tempMovieList

        }
        collectionView.reloadData()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredMovies![indexPath!.item]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }

}
