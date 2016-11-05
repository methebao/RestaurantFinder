//
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by TheBao on 16/10/16.
//  Copyright © 2016 TheBao. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var venue: Venue? {
        didSet {
            self.configureView()
        }
    }


    func configureView() {
        // Update the user interface for the detail item.
        if let venue = self.venue {
            if let label = self.detailDescriptionLabel {
                label.text = venue.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

