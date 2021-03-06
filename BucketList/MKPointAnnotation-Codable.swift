//
//  MKPointAnnotation-Codable.swift
//  BucketList
//
//  Created by COBE on 13/05/2021.
//

import Foundation
import MapKit

class CodableMKPointAnnotation: MKPointAnnotation, Codable {
    enum CodingKeys: CodingKey {
        case title, subtitle, latitude, longitude
    }
    override init() {
        super.init()
    }
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    func encode(to encoder: Encoder) throws {
        var containter = encoder.container(keyedBy: CodingKeys.self)
        try containter.encode(title ?? "", forKey: .title)
        try containter.encode(subtitle ?? "", forKey: .subtitle)
        try containter.encode(coordinate.latitude, forKey: .latitude)
        try containter.encode(coordinate.longitude, forKey: .longitude)
    }
}
