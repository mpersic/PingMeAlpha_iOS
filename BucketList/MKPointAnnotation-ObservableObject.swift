//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by COBE on 12/05/2021.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown Value"
        }
        set {
            title = newValue
        }
    }
    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown Value"
        }
        set {
            subtitle = newValue
        }
    }
}

