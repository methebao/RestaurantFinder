//
//  MasterViewController.swift
//  RestaurantFinder
//
//  Created by TheBao on 16/10/16.
//  Copyright © 2016 TheBao. All rights reserved.
//

import Foundation

enum FourSquare: Endpoint {
    case Venues(VenuesEndpoint)


    enum VenuesEndpoint: Endpoint {
        case Search(clientID: String, clientSecret: String, coordinate: Coordinate, category: Category, query: String?, searchRadius: Int?, limit: Int?)

        enum Category: CustomStringConvertible {
            case Food([FoodCategory]?)


            enum FoodCategory: String {
                case Afghan = "503288ae91d4c4b30a586d67"
            }
            var description: String {
                switch self {
                case .Food(let categories):
                    if let categories = categories {
                        let commaSeperatedString = categories.reduce("")
                        { categoryString, category in
                            "\(categoryString),\(category.rawValue)"
                        }
                        return commaSeperatedString.substring(from: commaSeperatedString.index(after: commaSeperatedString.startIndex))

                    } else {
                        return "4d4b7105d754a06374d81259"
                }
            }
            }
        }

        // MARK: ValueEndPoint - EndPoint

        var baseURL: String {
            return "https://api.foursquare.com"
        }
        var path: String {
            switch self {
            case .Search :
                return "/v2/venues/search"
            }
        }

        fileprivate struct ParameterKeys {
            static let clientID = "client_id"
            static let clientSecret = "client_secret"
            static let version = "v"
            static let category = "categoryId"
            static let location = "ll"
            static let query = "query"
            static let limit = "limit"
            static let searchRadius = "radius"
        }

        fileprivate struct DefaultValues {
            static let version = "20160301"
            static let limit = "50"
            static let searchRadius = "2000"
        }

        var parameters: [String : AnyObject] {
            switch self {
            case .Search(let clientID, let clientSecret,let coordinate, let category, let query ,let searchRadius,let limit):
                    var parameters: [String : Any] = [
                        ParameterKeys.clientID: clientID,
                        ParameterKeys.clientSecret: clientSecret,
                        ParameterKeys.version: DefaultValues.version,
                        ParameterKeys.location: coordinate.description,
                        ParameterKeys.category: category.description

                    ]

                    if let searchRadius = searchRadius {
                        parameters[ParameterKeys.searchRadius] = searchRadius
                    } else {
                        parameters[ParameterKeys.searchRadius] = DefaultValues.searchRadius
                    }
                    if let limit = limit {
                        parameters[ParameterKeys.limit] = limit
                    } else {
                        parameters[ParameterKeys.limit] = DefaultValues.limit
                    }
                    if let query = query {
                        parameters[ParameterKeys.query] = query
                    }

                    return parameters as [String : AnyObject]
            }
        }

    }
    //MARK: Foursquare - Endpoint
    var baseURL: String {
        switch self {
        case .Venues(let endpoint):
            return endpoint.baseURL
        }
    }
    var path: String {
        switch self {
        case .Venues(let endpoint):
            return endpoint.path
        }
    }
    var parameters: [String : AnyObject] {
        switch self {
        case .Venues(let endpoint):
            return endpoint.parameters
        }
    }
}
final class FoursquareClient: APIClient {
    

    var configuration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    let clientID: String
    let clientSecret: String
    init(configuration: URLSessionConfiguration, clientID: String, clientSecret: String) {
        self.configuration = configuration
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    convenience init (clientID: String, clientSecret: String) {
        self.init(configuration: URLSessionConfiguration.default, clientID: clientID, clientSecret: clientSecret)
    }
    func fetchRestaurantsFor(location: Coordinate,
                             category: FourSquare.VenuesEndpoint.Category,
                             query: String? = nil,
                             searchRadius: Int? = nil,
                             limit: Int? = nil,
                             completion: @escaping (APIResult<[Venue]>) -> Void) {
        let searchEndpoint = FourSquare.VenuesEndpoint.Search(clientID: self.clientID, clientSecret: self.clientSecret, coordinate: location, category: category, query: query, searchRadius: searchRadius, limit: limit)
        let endpoint = FourSquare.Venues(searchEndpoint)

        fetch(endpoint, parse: {
            (json) -> [Venue]? in
            guard let venue = json["response"]?["venues"] as? [[String : AnyObject]] else {
            return nil
            }
            return venue.flatMap {
                venueDict in
                return Venue(JSON: venueDict)
            }

        }, completion: completion)
    }
}
