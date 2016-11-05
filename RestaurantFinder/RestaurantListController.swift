//
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by TheBao on 16/10/16.
//  Copyright © 2016 TheBao. All rights reserved.
//

import UIKit
import MapKit

class RestaurantListController: UITableViewController, MKMapViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var stackView: UIStackView!
    var coordinate: Coordinate?

    var venues : [Venue] = [] {
        didSet{
            tableView.reloadData()
            addMapAnotation()
        }
    }
    let foursqareClient = FoursquareClient(clientID: "X3U5SEL3EMXXKFHRWHD0GE02YJOMYAIXUISKCH3H4LUS0FUW", clientSecret: "O4CC2FF4APTKANKWDW4H13A4TNOPTTS4AR0F2Z25FFMDMPXZ")

    let manager = LocationManager()

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        //Search bar congfiguration
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        stackView.addSubview(searchController.searchBar)
        manager.getPermission()
        
        fetchRestaurantForLocation()

    }


    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

                let venue = venues[indexPath.row]

                controller.venue = venue

                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell

        let venue = venues[indexPath.row]
        cell.restaurantTitleLabel.text = venue.name
        cell.restaurantCheckinLabel.text = venue.checkins.description
        cell.restaurantCategoryLabel.text = venue.categoryName

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func fetchRestaurantForLocation() {
        manager.onLocationFix = { [weak self] coordinate in

            self?.coordinate = coordinate

            self?.foursqareClient.fetchRestaurantsFor(location: coordinate, category: .Food(nil)) { result in
                switch result {
                case .success(let venues):
                    self?.venues = venues
                case .failure(let error):
                    print(error)
                }
            }
        }

    }

    @IBAction func refreshRestaurantData(_ sender: Any) {

        fetchRestaurantForLocation()
        refreshControl?.endRefreshing()
    }

    // UPDATE Delegete to Request Location Again
    //https://stackoverflow.com/questions/35589996/uitableview-embedded-in-container-not-refreshing


    // MKMAPVIEW Delegate
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        var region = MKCoordinateRegion()

        region.center = mapView.userLocation.coordinate
        // Zoom
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01

        mapView.setRegion(region, animated: true)
        // Class MKMAPITEM to custom traveltime,...


    }
    func addMapAnotation() {
        removeMapAnotation()
        if venues.count > 0 {
            let anotations: [MKPointAnnotation] = venues.map {
                venue in
                let point = MKPointAnnotation()

                if let coordinate = venue.location?.coordinate {
                    point.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    point.title = venue.name
                }

                return point
            }
            mapView.addAnnotations(anotations)
        }
    }

    func removeMapAnotation() {
        if mapView.annotations.count != 0 {
            for anotation in mapView.annotations {
                mapView.removeAnnotation(anotation)
            }
        }
    }

    // MARK: UI Search Result Updating 
    func updateSearchResults(for searchController: UISearchController) {

        if let coordinate = coordinate {
            foursqareClient.fetchRestaurantsFor(location: coordinate, category: .Food(nil), query: searchController.searchBar.text) { result in
                switch result {
                case .success(let venues):
                    self.venues = venues
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

