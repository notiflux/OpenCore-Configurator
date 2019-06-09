//
//  AcpiAddViewContoller.swift
//  test
//
//  Created by Henry Brock on 6/8/19.
//  Copyright © 2019 Henry Brock. All rights reserved.
//

import Cocoa

class AcpiAddViewContoller: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func addAcpiBtn(_ sender: Any) {
        addEntryToTable(table: &acpiAddTable, appendix: ["Path": "", "Comment": "", "Enabled": ""])
    }
    
    @IBAction func remAcpiBtn(_ sender: Any) {
        removeEntryFromTable(table: &acpiAddTable)
    }
    
    @IBAction func autoAddAcpi(_ sender: Any) {
        if mountedESP != "" {
            let fileManager = FileManager.default
            let acpiUrl = URL(fileURLWithPath: "\(mountedESP)/EFI/OC/ACPI/Custom")
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: acpiUrl, includingPropertiesForKeys: nil)
                var filenames: [String] = [String]()
                for i in fileURLs {
                    if !i.lastPathComponent.hasSuffix(".aml") {
                        messageBox(message: "\(i.lastPathComponent) does not have the .aml extension.")
                        continue
                    }
                    
                    let checksum = calcAcpiChecksum(table: i)
                    if checksum != 0 {
                        if checksum != nil {
                            messageBox(message: "Invalid Checksum", info: "The checksum for \(i.lastPathComponent) is invalid.")
                        } else {
                            messageBox(message: "The length of \(i.lastPathComponent) could not be verified.")
                        }
                        continue
                    }
                    filenames.append(i.lastPathComponent)
                }
                
                for file in filenames {
                    tableLookup[acpiAddTable]!.append(["Comment": "", "Path": file, "Enabled": "1"])
                }
                acpiAddTable.reloadData()
            } catch {
                print("Error while enumerating files \(acpiUrl.path): \(error.localizedDescription)")
            }
        } else {
            espWarning()
        }
    }
}
