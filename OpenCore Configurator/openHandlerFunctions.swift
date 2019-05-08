//
//  openHandlerFunctions.swift
//  OpenCore Configurator
//
//  Created by Max Banmann on 25.04.19.
//  Copyright © 2019 notiflux. All rights reserved.
//

import Cocoa

class openHandlerFunctions {
    func arrayOfDictionarys(entry: NSDictionary) -> [String:String] {
        var tempDict: [String:String] = [String:String]()       // temporary dictionary to append to the tableview datasource
        for (key, value) in entry {
            if value is NSData{
                tempDict[key as! String] = (value as! Data).hexEncodedString(options: .upperCase)       // "data" should be displayed as a hexadecimal string
            }
            else if value is Bool{
                if value as! Bool {
                    tempDict[key as! String] = "1"      // the tableview extension checks for these values and changes the button state accordingly
                } else {
                    tempDict[key as! String] = "0"
                }
            }
            else {
                tempDict[key as! String] = value as? String     // default case: hande data as Strings (TODO: sanetize the input so non-strings never get here)
            }
        }
        return tempDict
    }

    func arrayOfStrings(predefinedKey: String, entry: String) -> [String:String] {
        var tempDict: [String:String] = [String:String]()
        tempDict[predefinedKey] = entry
        return tempDict
    }

    func dictionaryOfDictionarys(key: String, value: NSDictionary) -> [[String:String]] {     // TODO: find a way to implement this dynamically (no hardcoding) without requiring tons of function parameters
        var tempArray: [[String: String]] = [[String: String]]()
        for (innerKey, innerValue) in value {
            var tempDict: [String:String] = [String:String]()
            tempDict["device"] = key
            tempDict["property"] = innerKey as? String
            switch innerValue {
            case is String:
                tempDict["value"] = (innerValue as? String ?? String()).data(using: .ascii)!.hexEncodedString(options: .upperCase)
            case is Int:
                tempDict["value"] = String(innerValue as? Int ?? Int()).data(using: .ascii)!.hexEncodedString(options: .upperCase)
            case is Bool:
                tempDict["value"] = String(innerValue as? Bool ?? false).data(using: .ascii)!.hexEncodedString(options: .upperCase)
            case is Data:
                tempDict["value"] = (innerValue as? Data ?? Data()).hexEncodedString(options: .upperCase)
            default:
                break
            }
            tempDict["edit"] = ""
            tempArray.append(tempDict)
        }
        return tempArray
    }

    func dictionaryOfArrays(key: String, value: NSArray) -> [String:String] {
        var tempDict: [String:String] = [String:String]()
        tempDict["device"] = key
        for item in value {
            tempDict["property"] = item as? String
        }
        return tempDict
    }

    func dictionaryOfDataTypes(table: NSTableView, key: String, value: Any) {
        if tableLookup[table]!.firstIndex(of: ["property": key, "value": "" ]) != nil {
            switch value {
            case is String:
                tableLookup[table]![tableLookup[table]!.firstIndex(of: ["property": key, "value": "" ])!] = ["property": key, "value": value as? String ?? String()]
            case is Int:
                tableLookup[table]![tableLookup[table]!.firstIndex(of: ["property": key, "value": "" ])!] = ["property": key, "value": String(value as? Int ?? Int())]
            case is Data:
                tableLookup[table]![tableLookup[table]!.firstIndex(of: ["property": key, "value": "" ])!] = ["property": key, "value": (value as? Data ?? Data()).hexEncodedString(options: .upperCase)]
            default:
                break
            }
        }
    }

    func createData(input: Any, table: inout NSTableView, predefinedKey: String? = nil) {
        var tempDict: [String:String] = [String:String]()
        switch input {
        case is NSArray:
            for entry in input as! NSArray {
                if entry is NSDictionary {
                    tempDict = arrayOfDictionarys(entry: entry as! NSDictionary)
                }
                    
                else if entry is NSString, predefinedKey != nil {
                    tempDict = arrayOfStrings(predefinedKey: predefinedKey!, entry: entry as! String)
                }
                tableLookup[table]!.append(tempDict)
                tableLookup[table]! = tableLookup[table]!.sorted { $0.values.first! < $1.values.first! }
            }
            
        case is NSDictionary:
            for (key, value) in input as! NSDictionary {
                if value is NSDictionary {
                    let tempArray: [[String: String]] = (dictionaryOfDictionarys(key: key as! String, value: value as! NSDictionary))
                    for item in tempArray {
                        tableLookup[table]!.append(item)
                    }
                }
                else if value is NSArray {
                    tempDict = dictionaryOfArrays(key: key as! String, value: value as! NSArray)
                }
                else if value is String || value is Int || value is Data {
                    dictionaryOfDataTypes(table: table, key: key as! String, value: value)
                }
                if tempDict != [:] {
                    tableLookup[table]!.append(tempDict)
                }
            }
            
        default:
            break
        }
        table.reloadData()
    }

    func createQuirksData(input: NSDictionary, quirksDict: [String: NSButton]) {
        for (key, value) in input {
            if value is Bool {
                if value as! Bool {
                    quirksDict[key as! String]?.state = .on
                }
                else {
                    quirksDict[key as! String]?.state = .off
                }
            }
            }
    }

    func createNvramData(value: Any, table: inout NSTableView, guidString: String? = nil) {
        var tempDict: [String:String] = [String:String]()
        switch value {
        case is NSDictionary:
            for (innerKey, innerValue) in value as! NSDictionary {
                if guidString != nil {
                    tempDict["guid"] = guidString!
                }
                tempDict["property"] = innerKey as? String
                
                switch innerValue {
                case is String:
                    tempDict["value"] = innerValue as? String
                case is Int:
                    tempDict["value"] = String(innerValue as? Int ?? Int()).data(using: .ascii)!.hexEncodedString(options: .upperCase)
                case is Bool:
                    tempDict["value"] = String(innerValue as? Bool ?? false).data(using: .ascii)!.hexEncodedString(options: .upperCase)
                case is Data:
                    tempDict["value"] = (innerValue as? Data ?? Data()).hexEncodedString(options: .upperCase)
                default:
                    break
                }
                tableLookup[table]!.append(tempDict)
            }
        case is NSArray:
            for innerKey in value as! NSArray {
                if guidString != nil {
                    tempDict["guid"] = guidString!
                    tempDict["property"] = innerKey as? String
                    tableLookup[table]!.append(tempDict)
                }
            }
        default:
            break
        }
        table.reloadData()
    }
    
    func createTopLevelBools(buttonDict: inout [NSButton: Bool]) {
        for bool in Array(buttonDict.values) {
            if bool {
                ((buttonDict as NSDictionary).allKeys(for: bool).first as! NSButton).state = .on        // need to use the button as the key since booleans will eventually return the same value on more than one
            }                                                                                           // entry which is forbidden. This is just a hacky way to get the key for a certain bool, and since we don't
            else {                                                                                      // have duplicates in there, it works reliably
                ((buttonDict as NSDictionary).allKeys(for: bool).first as! NSButton).state = .off
            }
        }
    }
}
