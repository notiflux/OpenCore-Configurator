//
//  saveHandlerFunctions.swift
//  OpenCore Configurator
//
//  Created by notiflux on 01.05.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Cocoa

var clearDict = true

class saveHandlerFunctions {
    let dataTypeLookup: [String: String] = [
        "Enabled": "Bool",
        "All": "Bool",
        "OemTableId": "Data",
        "TableLength": "Int",
        "TableSignature": "Stringdata",
        "Count": "Int",
        "Find": "Data",
        "Limit": "Int",
        "Mask": "Data",
        "Replace": "Data",
        "ReplaceMask": "Data",
        "Skip": "Int",
        "ARTFrequency": "Int",
        "BoardRevision": "Data",
        "DevicePathsSupported": "Data",
        "FSBFrequency": "Int",
        "InitialTSC": "Int",
        "SmcBranch": "Data",
        "SmcPlatform": "Data",
        "SmcRevision": "Data",
        "StartupPowerEvents": "Int",
        "ROM": "Data",
        "FirmwareFeatures": "Data",
        "FirmwareFeaturesMask": "Data",
        "BoardType": "Int",
        "ChassisType": "Int",
        "PlatformFeature": "Int",
        "ProcessorType": "Int",
        "MemoryFormFactor": "Int",
        "boot-args": "String"
    ]
    func saveArrayOfDictData(table: NSTableView, array: inout NSMutableArray) {
        array.removeAllObjects()
        for entry in tableLookup[table]! {
            let tempDict: NSMutableDictionary = NSMutableDictionary()
            for (key, value) in entry {
                if key != "advanced", key != "kernelAdvanced" {
                    tempDict.addEntries(from: [key: value.toType(type: dataTypeLookup[key] ?? "String")])
                }
            }
            array.add(tempDict)
        }
    }
    
    func saveDictOfDictData(table: NSTableView, dict: inout NSMutableDictionary) {
        dict.removeAllObjects()
        for entry in tableLookup[table]! {
            dict.addEntries(from: [entry["property"]!: entry["value"]!.toType(type: dataTypeLookup[entry["property"]!] ?? "String")])
        }
    }
    
    func saveNvramBootData(table: NSTableView, dict: inout NSMutableDictionary) {
        if clearDict { dict.removeAllObjects() }
        clearDict = false
        let tempDict: NSMutableDictionary = NSMutableDictionary()
        if tableLookup[table]!.count > 0 {
            for entry in tableLookup[table]! {
                tempDict.addEntries(from: [entry["property"]!: entry["value"]!.toType(type: dataTypeLookup[entry["property"]!] ?? "Data")])
            }
            dict.addEntries(from: ["7C436110-AB2A-4BBB-A880-FE41995C9F82": tempDict])
        }
    }
    
    func saveNvramVendorData(table: NSTableView, dict: inout NSMutableDictionary) {
        if clearDict { dict.removeAllObjects() }
        clearDict = false
        let tempDict: NSMutableDictionary = NSMutableDictionary()
        if tableLookup[table]!.count > 0 {
            for entry in tableLookup[table]! {
                tempDict.addEntries(from: [entry["property"]!: entry["value"]!.toType(type: dataTypeLookup[entry["property"]!] ?? "Data")])
            }
            dict.addEntries(from: ["4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14": tempDict])
        }
    }
    
    func saveNvramCustomData(table: NSTableView, dict: inout NSMutableDictionary) {
        if clearDict { dict.removeAllObjects() }
        clearDict = false
        for entry in tableLookup[table]! {
            if entry["value"] != nil {
                if dict.object(forKey: entry["guid"]!) as? NSDictionary != nil {
                    var deviceDict = dict.object(forKey: entry["guid"]!) as! [AnyHashable : Any]
                    deviceDict[entry["property"]!] = Data(hexString: entry["value"]!)!
                    dict.removeObject(forKey: entry["guid"]!)
                    dict.addEntries(from: [entry["guid"]!: deviceDict])
                }
                else {
                    dict.addEntries(from: [entry["guid"]!: [entry["property"]!: Data(hexString: entry["value"]!)!]])
                }
            }
            else {
                dict.addEntries(from: [entry["guid"]!: [entry["property"]!]])
            }
        }
    }
    
    func saveNvramBlockData(table: NSTableView, dict: inout NSMutableDictionary) {
        dict.removeAllObjects()
        for entry in tableLookup[table]! {
            if dict.object(forKey: entry["guid"]!) as? NSArray != nil {
                var guidArray = dict.object(forKey: entry["guid"]!) as! [Any]
                guidArray.append(entry["property"]!)
                dict.removeObject(forKey: entry["guid"]!)
                dict.addEntries(from: [entry["guid"]!: guidArray])
            }
            else {
                dict.addEntries(from: [entry["guid"]!: [entry["property"]!]])
            }
        }
    }
    
    func saveStringData(table: NSTableView, array: inout NSMutableArray) {
        array.removeAllObjects()
        for entry in tableLookup[table]! {
            for (_, value) in entry {
                array.add(value)
            }
        }
    }
    
    /*func saveNvramBootData(table: NSTableView, dict: inout NSMutableDictionary) {
        dict.removeAllObjects()
        for entry in tableLookup[table]! {
            let tempDict: NSMutableDictionary = NSMutableDictionary()
            for (key, value) in entry {
                
            }
        }
    }*/
    
    func saveDeviceData(table: NSTableView, dict: inout NSMutableDictionary) {
        dict.removeAllObjects()
        for entry in tableLookup[table]! {
            if entry["value"] != nil {
                if dict.object(forKey: entry["device"]!) as? NSDictionary != nil {
                    var deviceDict = dict.object(forKey: entry["device"]!) as! [AnyHashable : Any]
                    deviceDict[entry["property"]!] = Data(hexString: entry["value"]!)!
                    dict.removeObject(forKey: entry["device"]!)
                    dict.addEntries(from: [entry["device"]!: deviceDict])
                }
                else {
                    dict.addEntries(from: [entry["device"]!: [entry["property"]!: Data(hexString: entry["value"]!)!]])
                }
            }
            else {
                dict.addEntries(from: [entry["device"]!: [entry["property"]!]])
            }
        }
    }
    
    func saveQuirksData( dict: [String: NSButton],quirksDict: inout NSMutableDictionary){
        quirksDict.removeAllObjects()
        for (quirkname, button) in dict {
            if button.state == .on {
                quirksDict.addEntries(from: [quirkname: true])
            }
            else {
                quirksDict.addEntries(from: [quirkname: false])
            }
        }
    }
}

extension String {
    func toType(type: String) -> Any {
        //if self != "" {
            switch type {
            case "Data":
                return Data(hexString: self) ?? Data()
            case "Stringdata":
                return self.data(using: .ascii) ?? Data()
            case "Bool":
                if self == "1" {
                    return true
                }
                else {
                    return false
                }
                
            case "Int":
                return Int(self) ?? Int()
                
            default:
                return self
            }
        //} else { return "" }
    }
}
