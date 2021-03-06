//
//  AccessoryStore.swift
//
//  Created by ToKoRo on 2017-08-27.
//

import HomeKit

protocol AccessoryStore {
    var accessoryStoreKind: AccessoryStoreKind { get }
    var accessories: [HMAccessory] { get }
}

enum AccessoryStoreKind {
    case home(HMHome)
    case room(HMRoom)
    case identifiers(AccessoryIdentifiers)
}

// MARK: - HMHome

//HMHome에는 accessories가 정의되어 있기 땜에,
//AccessoryStore 프로토콜에서 accessories 추가되어도 괜찮
extension HMHome: AccessoryStore {
    var accessoryStoreKind: AccessoryStoreKind { return .home(self) }
}

// MARK: - HMRoom

extension HMRoom: AccessoryStore {
    var accessoryStoreKind: AccessoryStoreKind { return .room(self) }
}

// MARK: - AccessoryIdentifiers

struct AccessoryIdentifiers {
    let identifiers: [UUID]
}

extension AccessoryIdentifiers: AccessoryStore {
    var accessoryStoreKind: AccessoryStoreKind { return .identifiers(self) }

    var accessories: [HMAccessory] {
        var accessories: [HMAccessory] = []
        let homeManager = HMHomeManager.shared
        for home in homeManager.homes {
            for accessory in home.accessories where identifiers.contains(accessory.uniqueIdentifier) {
                accessories.append(accessory)
            }
        }
        return accessories
    }
}
