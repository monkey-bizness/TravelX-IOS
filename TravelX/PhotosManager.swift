//
//  PhotosManager.swift
//  TravelX
//
//  Created by Fawzi Bedidi on 12/21/19.
//  Copyright © 2019 Fawzi Bedidi. All rights reserved.
//

import Foundation
import Photos

var photos : Array<Photo> = [Photo]();
var sqliteHelper : SqliteHelper = SqliteHelper();

func getPhotosFromLibrary() {

    PHPhotoLibrary.requestAuthorization { (status) in
        var allPhotos : PHFetchResult<PHAsset>? = nil

        switch status {
        case .authorized:
            print("Good to proceed")
            let fetchOptions = PHFetchOptions()
            allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
          
            for i in 0..<allPhotos!.count {
                let photo =  allPhotos?.object(at: i);
                if (photo == nil) {
                    continue;
                }
                let localIdentifier = photo?.localIdentifier ?? nil;
                
                let coordinate = photo?.location?.coordinate;
                if (coordinate != nil && localIdentifier != nil) {
                    let photo = Photo(id: localIdentifier!, lat: coordinate!.latitude, lng: coordinate!.longitude);
                    photos.append(photo);
                    if !sqliteHelper.photoAlreadyExists(identifier: localIdentifier!) {
                        sqliteHelper.insertPhoto(photo: photo);
                    }
                }
            }
            
        case .denied, .restricted:
            print("Not allowed")
        case .notDetermined:
            print("Not determined yet")
        @unknown default:
            print("That's not supposed to happen");
        }
    }
}

func getPhotosFromSQLite() -> Array<Photo>{
    return sqliteHelper.getPhotos();
}
