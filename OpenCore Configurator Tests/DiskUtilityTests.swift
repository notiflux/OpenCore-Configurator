//  Copyright © 2019 notiflux. All rights reserved.

@testable import OpenCore_Configurator
import XCTest

class DiskUtilityTests: XCTestCase {
    func testEmptyAPFSResponse() throws {
        let plistURL = Bundle.current.url(forResource: "diskutil-apfs-list-empty-response", withExtension: "plist")!
        let data = try Data(contentsOf: plistURL)
        let containerList = try PropertyListDecoder().decode(DiskUtility.APFSContainerList.self, from: data)

        XCTAssertTrue(containerList.containers.isEmpty)
    }

    func testResponse() throws {
        let plistURL = Bundle.current.url(forResource: "diskutil-list-time-machine-response", withExtension: "plist")!
        let data = try Data(contentsOf: plistURL)
        let diskList = try PropertyListDecoder().decode(DiskUtility.DiskList.self, from: data)

        XCTAssertFalse(diskList.allDisks.isEmpty)
    }
}
