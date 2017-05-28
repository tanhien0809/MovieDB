//
//  MovieDetailViewController.swift
//  MovieDB
//
//  Created by Hien on 5/19/17.
//  Copyright © 2017 Cntt08. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    
    var image: UIImage?
    var titleF: String?
    var overview: String?
    var releaseDate1: String?
    var voteaverage: String?
    
    @IBOutlet var titleFilm: UILabel!
    
    @IBOutlet var releaseDate: UILabel!

    @IBOutlet var overviewFilm: UILabel!
    
    @IBOutlet var poster: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        poster.image = image
        titleFilm.text = titleF
        overviewFilm.text = overview
        releaseDate.text = releaseDate1
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
