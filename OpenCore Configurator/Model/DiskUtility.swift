//  Copyright © 2019 notiflux. All rights reserved.

import Foundation

enum DiskUtility {
    private static let utilityURL = URL(fileURLWithPath: "/usr/sbin/diskutil")

    static func listAPFSContainers() throws -> DiskUtility.APFSContainerList {
        let outputData = try Process.launchAndWait(withExecutableUrl: utilityURL, arguments: ["apfs", "list", "-plist"])
        return try PropertyListDecoder().decode(DiskUtility.APFSContainerList.self, from: outputData)
    }

    static func listDisks() throws -> DiskUtility.DiskList {
        let outputData = try Process.launchAndWait(withExecutableUrl: utilityURL, arguments: ["list", "-plist"])
        return try PropertyListDecoder().decode(DiskUtility.DiskList.self, from: outputData)
    }

    class APFSContainerList: Codable {
        let containers: [APFSContainer]

        func containerUsingPhysicalStore(for identifier: UUID) -> APFSContainer? {
            return containers.first { $0.physicalStores.contains { $0.diskUUID == identifier } }
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            containers = try container.decodeIfPresent([APFSContainer].self, forKey: .containers) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case containers = "Containers"
        }
    }

    class APFSContainer: Codable, Hashable, CustomDebugStringConvertible {
        let containerIdentifier: UUID
        let capacityCeiling: UInt64
        let capacityFree: UInt64
        let containerReference: String
        let designatedPhysicalStore: String
        let isFusion: Bool
        let physicalStores: [PhysicalStore]
        let volumes: [Volume]

        var rolelessVolumes: [Volume] {
            return volumes.filter { $0.roles.isEmpty }
        }

        static func == (lhs: DiskUtility.APFSContainer, rhs: DiskUtility.APFSContainer) -> Bool {
            return lhs.containerIdentifier == rhs.containerIdentifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(containerIdentifier)
        }

        var debugDescription: String {
            return "<\(type(of: self)) \(containerReference) [\(containerIdentifier.uuidString)]: \(physicalStores.count) physical store(s), \(volumes.count) volume(s)>"
        }

        class PhysicalStore: Codable, Hashable, CustomDebugStringConvertible {
            let deviceIdentifier: String
            let diskUUID: UUID
            let size: UInt64

            static func == (lhs: DiskUtility.APFSContainer.PhysicalStore, rhs: DiskUtility.APFSContainer.PhysicalStore) -> Bool {
                return lhs.diskUUID == rhs.diskUUID
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(diskUUID)
            }

            var debugDescription: String {
                return "<\(type(of: self)) \(deviceIdentifier) [\(diskUUID.uuidString)]>"
            }

            private enum CodingKeys: String, CodingKey {
                case deviceIdentifier = "DeviceIdentifier"
                case diskUUID = "DiskUUID"
                case size = "Size"
            }
        }

        class Volume: Codable, Hashable, CustomDebugStringConvertible {
            let volumeUUID: UUID
            let capacityInUse: UInt64
            let capacityQuota: UInt64
            let capacityReserve: UInt64
            let cryptoMigrationOn: Bool
            let deviceIdentifier: String
            let usesEncryption: Bool
            let usesFileVault: Bool
            let isLocked: Bool
            let name: String
            let roles: [String]

            static func == (lhs: DiskUtility.APFSContainer.Volume, rhs: DiskUtility.APFSContainer.Volume) -> Bool {
                return lhs.volumeUUID == rhs.volumeUUID
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(volumeUUID)
            }

            var debugDescription: String {
                return "<\(type(of: self)) \(deviceIdentifier) \(name) [\(volumeUUID.uuidString)]: roles = \(roles.joined(separator: ", "))>"
            }

            private enum CodingKeys: String, CodingKey {
                case volumeUUID = "APFSVolumeUUID"
                case capacityInUse = "CapacityInUse"
                case capacityQuota = "CapacityQuota"
                case capacityReserve = "CapacityReserve"
                case cryptoMigrationOn = "CryptoMigrationOn"
                case deviceIdentifier = "DeviceIdentifier"
                case usesEncryption = "Encryption"
                case usesFileVault = "FileVault"
                case isLocked = "Locked"
                case name = "Name"
                case roles = "Roles"
            }
        }

        private enum CodingKeys: String, CodingKey {
            case containerIdentifier = "APFSContainerUUID"
            case capacityCeiling = "CapacityCeiling"
            case capacityFree = "CapacityFree"
            case containerReference = "ContainerReference"
            case designatedPhysicalStore = "DesignatedPhysicalStore"
            case isFusion = "Fusion"
            case physicalStores = "PhysicalStores"
            case volumes = "Volumes"
        }
    }

    class DiskList: Codable {
        let allDisks: [Disk]

        var disksWithEFIPartitions: [Disk] {
            return allDisks.filter { $0.partitions.contains { $0.isEFI } }
        }

        var disksWithAPFSContainers: [Disk] {
            return allDisks.filter { $0.partitions.contains { $0.isAPFSContainer } }
        }

        var efiPartitions: [Disk.Partition] {
            return allDisks.compactMap { $0.efiPartition }
        }

        func disk(for partition: Disk.Partition) -> Disk? {
            return allDisks.first { $0.partitions.contains(partition) }
        }

        func disk(for volume: Disk.APFSVolume) -> Disk? {
            return allDisks.first { $0.apfsVolumes.contains(volume) }
        }

        func disk(for volume: APFSContainer.Volume) -> Disk? {
            return allDisks.first { $0.apfsVolumes.contains { $0.volumeUUID == volume.volumeUUID } }
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            allDisks = try container.decodeIfPresent([Disk].self, forKey: .allDisks) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case allDisks = "AllDisksAndPartitions"
        }
    }

    class Disk: Codable, Hashable, CustomDebugStringConvertible {
        let content: String
        let deviceIdentifier: String
        let partitions: [Partition]
        let apfsVolumes: [APFSVolume]
        let size: UInt64

        var efiPartition: Partition? {
            return partitions.first { $0.isEFI }
        }

        var mountedItems: [MountableItem] {
            return mountedPartitions + mountedAPFSVolumes
        }

        var mountedPartitions: [Disk.Partition] {
            return partitions.filter { partition in
                guard let mountPoint = partition.mountPoint else {
                    return false
                }

                return mountPoint == "/" || mountPoint.starts(with: "/Volumes")
            }
        }

        var mountedAPFSVolumes: [Disk.APFSVolume] {
            return apfsVolumes.filter { volume in
                guard let mountPoint = volume.mountPoint else {
                    return false
                }

                return mountPoint == "/" || mountPoint.starts(with: "/Volumes")
            }
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            content = try container.decode(String.self, forKey: .content)
            deviceIdentifier = try container.decode(String.self, forKey: .deviceIdentifier)
            partitions = try container.decodeIfPresent([Partition].self, forKey: .partitions) ?? []
            apfsVolumes = try container.decodeIfPresent([APFSVolume].self, forKey: .apfsVolumes) ?? []
            size = try container.decode(UInt64.self, forKey: .size)
        }

        var debugDescription: String {
            return "<\(type(of: self)) \(deviceIdentifier): \(content), \(partitions.count) partition(s), \(apfsVolumes.count) APFS volume(s)>"
        }

        private enum CodingKeys: String, CodingKey {
            case content = "Content"
            case deviceIdentifier = "DeviceIdentifier"
            case partitions = "Partitions"
            case apfsVolumes = "APFSVolumes"
            case size = "Size"
        }

        static func == (lhs: DiskUtility.Disk, rhs: DiskUtility.Disk) -> Bool {
            return lhs.deviceIdentifier == rhs.deviceIdentifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(deviceIdentifier)
        }

        class Partition: Codable, MountableItem, Hashable, CustomDebugStringConvertible {
            let content: String
            let deviceIdentifier: String
            let diskUUID: UUID
            let mountPoint: String?
            let size: UInt64
            let volumeName: String?
            let volumeUUID: UUID?

            var isAPFSContainer: Bool {
                return content == "Apple_APFS"
            }

            var isHFS: Bool {
                return content == "Apple_HFS"
            }

            var isEFI: Bool {
                return content == "EFI"
            }

            var debugDescription: String {
                if let name = volumeName, let uuid = volumeUUID {
                    return "<\(type(of: self)) \(deviceIdentifier) [\(diskUUID.uuidString)]: \(content), Volume Name = \(name), Volume UUID = \(uuid.uuidString)>"
                } else {
                    return "<\(type(of: self)) \(deviceIdentifier) [\(diskUUID.uuidString)]: \(content)>"
                }
            }

            private enum CodingKeys: String, CodingKey {
                case content = "Content"
                case deviceIdentifier = "DeviceIdentifier"
                case diskUUID = "DiskUUID"
                case mountPoint = "MountPoint"
                case size = "Size"
                case volumeName = "VolumeName"
                case volumeUUID = "VolumeUUID"
            }

            static func == (lhs: Partition, rhs: Partition) -> Bool {
                return lhs.diskUUID == rhs.diskUUID
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(diskUUID)
            }
        }

        class APFSVolume: Codable, MountableItem, Hashable, CustomDebugStringConvertible {
            let deviceIdentifier: String
            let diskUUID: UUID
            let mountPoint: String?
            let size: UInt64
            let volumeName: String
            let volumeUUID: UUID

            var debugDescription: String {
                return "<\(type(of: self)) \(deviceIdentifier) [\(diskUUID.uuidString)]: \(volumeName)>"
            }

            private enum CodingKeys: String, CodingKey {
                case deviceIdentifier = "DeviceIdentifier"
                case diskUUID = "DiskUUID"
                case mountPoint = "MountPoint"
                case size = "Size"
                case volumeName = "VolumeName"
                case volumeUUID = "VolumeUUID"
            }

            static func == (lhs: APFSVolume, rhs: APFSVolume) -> Bool {
                return lhs.diskUUID == rhs.diskUUID
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(diskUUID)
            }
        }
    }
}

protocol MountableItem {
    var mountPoint: String? { get }
}

extension MountableItem {
    var isMounted: Bool {
        guard let mountPoint = mountPoint else {
            return false
        }

        return mountPoint.isEmpty == false
    }
}
