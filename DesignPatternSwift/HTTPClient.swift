//
//  PersistencyManager.swift
//  BlueLibrarySwift
//
//  Created by Omar Faruqe on 2016-03-27.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class HTTPClient {
	
	func getRequest(url: String) -> (AnyObject) {
		return NSData()
	}
	
	func postRequest(url: String, body: String) -> (AnyObject){
		return NSData()
	}
	
	func downloadImage(url: String) -> (UIImage) {
		let aUrl = NSURL(string: url)
		let data = NSData(contentsOfURL: aUrl!)
		let image = UIImage(data: data!)
		return image!
	}
	
}