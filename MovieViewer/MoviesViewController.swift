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

class MoviesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var errorButton: UIButton!

    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorButton.hidden = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)

        collectionView.dataSource = self
        collectionView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
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
                        
                    }
                }
                else{
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.errorButton.hidden = false
                }
        })
        task.resume()
    }
    
    var moviedata: NSData!
    

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
        if let movies = movies{
            return movies.count
        }else{
            return 0
        }
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieIdentifier", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        let posterPath = movie["poster_path"] as! String
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let imageURL = NSURL(string: posterBaseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: imageURL!)

        cell.movieImage.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.movieImage.alpha = 0.0
                    cell.movieImage.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.movieImage.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.movieImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        return cell
    }
    
    @IBAction func networkError(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
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
                            
                    }
                }
                else{
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.errorButton.hidden = false
                }
        })
        task.resume()
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
