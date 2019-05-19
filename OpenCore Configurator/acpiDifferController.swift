//
//  acpiDifferController.swift
//  OpenCore Configurator
//
//  Created by Max Banmann on 16.05.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Cocoa

class acpiDifferController: NSViewController {
    
    @IBOutlet var beforeTextfield: NSTextView!
    @IBOutlet weak var beforeScrollview: NSScrollView!
    @IBOutlet var afterTextfield: NSTextView!
    @IBOutlet weak var afterScrollview: NSScrollView!
    @IBOutlet weak var currentOccurence: NSTextField!
    @IBOutlet weak var totalOccurences: NSTextField!
    @IBOutlet weak var applySelected: NSButton!
    @IBOutlet weak var applyAll: NSButton!
    
    let popover = NSPopover()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popover.behavior = .transient
        
        let beforeScrollingView = beforeScrollview.contentView
        beforeScrollingView.postsBoundsChangedNotifications = true
        
        let afterScrollingView = afterScrollview.contentView
        afterScrollingView.postsBoundsChangedNotifications = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewContentBoundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: beforeScrollingView)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewContentBoundsDidChange(_:)), name: NSView.boundsDidChangeNotification, object: afterScrollingView)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        allPatchesApplied = ""
        onePatchApplied = ""
    }
    
    @objc func scrollViewContentBoundsDidChange(_ notification: Notification) {
        
        
        
        let senderScrollView = (notification.object as! NSClipView).superview as! NSScrollView
        
        var scrollView: NSScrollView = NSScrollView()
        
        if senderScrollView == beforeScrollview {
            scrollView = afterScrollview
        }
        else if senderScrollView == afterScrollview {
            scrollView = beforeScrollview
        }
        
        guard let scrolledView = notification.object as? NSClipView else { return }
        
        let viewToScroll = scrollView.contentView
        let currentOffset = viewToScroll.bounds.origin
        var newOffset = currentOffset
        newOffset.y = scrolledView.documentVisibleRect.origin.y
        
        guard newOffset != currentOffset else { return }
        
        viewToScroll.scroll(to: newOffset)
        scrollView.reflectScrolledClipView(viewToScroll)
    }
    
    class func loadFromNib() -> acpiDifferController {
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "acpiDiffer") as! acpiDifferController       // we need this because we're calling this function from another view controller
        vc.popover.contentViewController = vc
        return vc           // allow for access of objects from this view controller from another one
    }
    
    func showPopover(bounds: NSRect, window: NSView) {
        popover.show(relativeTo: bounds, of: window, preferredEdge: .minY)
    }
    
    var afterOccurrencesArray: [Int] = [Int]()
    var beforeOccurrencesArray: [Int] = [Int]()
    var onePatchApplied: String = String()
    
    func populatePopover(before: String, after: String) {
        beforeTextfield.string = before
        afterTextfield.string = after
        onePatchApplied = after
        
        totalOccurences.stringValue = "\(String(after.components(separatedBy: currentReplace).count - 1)) occurences of \"\(currentReplace)\" in \(currentTable)"
        
        afterOccurrencesArray = findOccurences(after, of: currentReplace)
        beforeOccurrencesArray = findOccurences(before, of: currentFind)
        
        if Int(totalOccurences.stringValue.components(separatedBy: " ").first!)! > 0 {
            currentOccurence.stringValue = "1"
            afterTextfield.selectedRange = NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count)
            afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
            afterTextfield.showFindIndicator(for: NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count))
            beforeTextfield.showFindIndicator(for: NSRange(location: beforeOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentFind.count))
        }
        afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
    }
    
    func findOccurences(_ string: String, of: String) -> [Int] {
        var occArray: [Int] = [Int]()
        var tempArray: [Range<String.Index>?] = [Range<String.Index>?]()
        
        let currentOccurenceIndex = string.range(of: of)
        
        if currentOccurenceIndex != nil {
            occArray.append(string.distance(from: string.startIndex, to: string.range(of: of)!.lowerBound))
            tempArray.append(string.range(of: of))
            
            while true {
                let currentOccurenceIndex = string.range(of: of, range: ((tempArray.last?!.upperBound)!..<string.endIndex))
                
                if currentOccurenceIndex != nil {
                    let currentOccurence = string.distance(from: string.startIndex, to: string.range(of: of, range: ((tempArray.last?!.upperBound)!..<string.endIndex))!.lowerBound)
                    occArray.append(currentOccurence)
                    tempArray.append(currentOccurenceIndex)
                } else {
                    break
                }
            }
        }
        return occArray
    }
    
    @IBAction func previousOccurence(_ sender: Any) {
        if Int(currentOccurence.stringValue)! > 1 {
            currentOccurence.stringValue = String(Int(currentOccurence.stringValue)! - 1)
            afterTextfield.selectedRange = NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count)
            afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
            afterTextfield.displayIfNeeded()
            afterTextfield.showFindIndicator(for: NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count))
            beforeTextfield.showFindIndicator(for: NSRange(location: beforeOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentFind.count))
        }
        else if currentOccurence.stringValue == "1" {
            currentOccurence.stringValue = totalOccurences.stringValue.components(separatedBy: " ").first!
            afterTextfield.selectedRange = NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count)
            afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
            afterTextfield.displayIfNeeded()
            afterTextfield.showFindIndicator(for: NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count))
            beforeTextfield.showFindIndicator(for: NSRange(location: beforeOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentFind.count))
        }
    }
    @IBAction func nextOccurence(_ sender: Any) {
        if Int(currentOccurence.stringValue)! < Int(totalOccurences.stringValue.components(separatedBy: " ").first!)! {
            currentOccurence.stringValue = String(Int(currentOccurence.stringValue.components(separatedBy: " ").first!)! + 1)
            afterTextfield.selectedRange = NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count)
            afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
            afterTextfield.displayIfNeeded()
            afterTextfield.showFindIndicator(for: NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count))
            beforeTextfield.showFindIndicator(for: NSRange(location: beforeOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentFind.count))
        }
        else if Int(currentOccurence.stringValue)! == Int(totalOccurences.stringValue.components(separatedBy: " ").first!)! {
            currentOccurence.stringValue = "1"
            afterTextfield.selectedRange = NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count)
            afterTextfield.scrollRangeToVisible(afterTextfield.selectedRange())
            afterTextfield.displayIfNeeded()
            afterTextfield.showFindIndicator(for: NSRange(location: afterOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentReplace.count))
            beforeTextfield.showFindIndicator(for: NSRange(location: beforeOccurrencesArray[Int(currentOccurence.stringValue)! - 1], length: currentFind.count))
        }
    }
    
    @IBAction func onlyApplySelected(_ sender: Any) {
        applyAll.state = .off
        afterTextfield.string = onePatchApplied
        afterTextfield.showFindIndicator(for: NSRange(location: 0, length: allPatchesApplied.count - 1))
    }
    
    @IBAction func applyAll(_ sender: Any) {
        applySelected.state = .off
        if allPatchesApplied == "" {
            NotificationCenter.default.post(name: .applyAllPatches, object: nil)
        }
        afterTextfield.string = allPatchesApplied
        afterTextfield.showFindIndicator(for: NSRange(location: 0, length: allPatchesApplied.count - 1))
    }
    
    @IBAction func openExt(_ sender: Any) {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let beforeURL = temporaryDirectory.appendingPathComponent("\(currentTable)_before.aml", isDirectory: false)

        if applySelected.state == .on {
            let afterURL = temporaryDirectory.appendingPathComponent("\(currentTable)_after.aml", isDirectory: false)
            NSWorkspace.shared.open(beforeURL)
            NSWorkspace.shared.open(afterURL)
        }
        else if applyAll.state == .on {
            let allPatchesURL = temporaryDirectory.appendingPathComponent("\(currentTable)_allPatches.aml", isDirectory: false)
            NSWorkspace.shared.open(beforeURL)
            NSWorkspace.shared.open(allPatchesURL)
        }
    }
}
