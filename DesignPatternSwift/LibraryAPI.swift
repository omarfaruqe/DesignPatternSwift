//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by Omar Faruqe on 2016-03-27.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {

    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LibraryAPI.downloadImage(_:)), name: "BLDownloadImageNotification", object: nil)
    }
    
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbumAtIndex(index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    //1
    class var sharedInstance: LibraryAPI {
        //2
        struct Singleton {
            //3
            static let instance = LibraryAPI()
        }
        //4
        return Singleton.instance
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage((coverUrl as NSString).lastPathComponent)
            if imageViewUnWrapped.image == nil {
                //3
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    //4
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(downloadedImage, filename: (coverUrl as NSString).lastPathComponent)
                    })
                })
            }
        }
    }
    
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
    
}
