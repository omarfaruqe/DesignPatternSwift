//
//  PersistencyManager.swift
//  BlueLibrarySwift
//
//  Created by Omar Faruqe on 2016-03-27.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var allAlbums = [Album]()
    private var currentAlbumData : (titles:[String], values:[String])?
    private var currentAlbumIndex = 0
    
    // We will use this array as a stack to push and pop operation for the undo option
    var undoStack: [(Album, Int)] = []

    @IBOutlet weak var scroller: HorizontalScroller!
	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        //1
        self.navigationController?.navigationBar.translucent = false
        currentAlbumIndex = 0
        
        //2
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        // 3
        // the uitableview that presents the album data
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        view.addSubview(dataTable!)
        
        self.showDataForAlbum(currentAlbumIndex)
        
        loadPreviousState()
        
        scroller.delegate = self
        reloadScroller()
        
        let undoButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action:#selector(ViewController.undoAction))
        undoButton.enabled = false;
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target:nil, action:nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .Trash, target:self, action:#selector(ViewController.deleteAlbum))
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ViewController.saveCurrentState), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    
    func addAlbumAtIndex(album: Album,index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    
    func deleteAlbum() {
        //1
        let deletedAlbum : Album = allAlbums[currentAlbumIndex]
        //2
        let undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, atIndex: 0)
        //3
        LibraryAPI.sharedInstance.deleteAlbum(currentAlbumIndex)
        reloadScroller()
        //4
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        let undoButton : UIBarButtonItem = barButtonItems[0]
        undoButton.enabled = true
        //5
        if (allAlbums.count == 0) {
            let trashButton : UIBarButtonItem = barButtonItems[2]
            trashButton.enabled = false
        }
    }
    
    
    func undoAction() {
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        //1
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.removeAtIndex(0)
            addAlbumAtIndex(deletedAlbum, index: index)
        }
        //2
        if undoStack.count == 0 {
            let undoButton : UIBarButtonItem = barButtonItems[0]
            undoButton.enabled = false
        }
        //3
        let trashButton : UIBarButtonItem = barButtonItems[2]
        trashButton.enabled = true
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
    
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
    
    func showDataForAlbum(albumIndex: Int) {
        // defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            // save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        // we have the data we need, let's refresh our tableview
        dataTable!.reloadData()
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataForAlbum(currentAlbumIndex)
    }
    
    //MARK: Memento Pattern
    func saveCurrentState() {
        // When the user leaves the app and then comes back again, he wants it to be in the exact same state
        // he left it. In order to do this we need to save the currently displayed album.
        // Since it's only one piece of information we can use NSUserDefaults.
        NSUserDefaults.standardUserDefaults().setInteger(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = NSUserDefaults.standardUserDefaults().integerForKey("currentAlbumIndex")
        showDataForAlbum(currentAlbumIndex)
    }
    
}


extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) //as! UITableViewCell
        if let albumData = currentAlbumData {
            cell.textLabel!.text = albumData.titles[indexPath.row]
            cell.detailTextLabel!.text = albumData.values[indexPath.row]
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        //1
        let previousAlbumView = scroller.viewAtIndex(currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(false)
        //2
        currentAlbumIndex = index
        //3
        let albumView = scroller.viewAtIndex(index) as! AlbumView
        albumView.highlightAlbum(true)
        //4
        showDataForAlbum(index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> (Int) {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> (UIView) {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(true)
        } else {
            albumView.highlightAlbum(false)
        }
        return albumView
    }
    
}

