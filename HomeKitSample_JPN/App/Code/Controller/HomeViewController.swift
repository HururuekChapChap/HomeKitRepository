//
//  HomeViewController.swift
//
//  Created by ToKoRo on 2017-08-20.
//

import UIKit
import HomeKit

class HomeViewController: UITableViewController, ContextHandler {
    typealias ContextType = HMHome

    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var uniqueIdentifierLabel: UILabel?
    @IBOutlet weak var isPrimaryLabel: UILabel?
    @IBOutlet weak var homeHubStateLabel: UILabel?
    @IBOutlet weak var accessoriesCountLabel: UILabel?
    @IBOutlet weak var roomsCountLabel: UILabel?
    @IBOutlet weak var zonesCountLabel: UILabel?
    @IBOutlet weak var serviceGroupsCountLabel: UILabel?
    @IBOutlet weak var actionSetsCountLabel: UILabel?
    @IBOutlet weak var triggersCountLabel: UILabel?
    @IBOutlet weak var userNameLabel: UILabel?
    @IBOutlet weak var userIdentifierLabel: UILabel?
    @IBOutlet weak var isAdministratorLabel: UILabel?

    var home: HMHome { return context! }

    override func viewDidLoad() {
        super.viewDidLoad()

        home.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setToolbarHidden(false, animated: true)

        refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Accessory"?:
            sendContext(home, to: segue.destination)
        case "RoomForEntireHome"?:
            sendContext(home.roomForEntireHome(), to: segue.destination)
        case "Room"?:
            sendContext(home, to: segue.destination)
        case "Zone"?:
            sendContext(home, to: segue.destination)
        case "ServiceGroup"?:
            sendContext(home, to: segue.destination)
        case "ActionSet"?:
            sendContext(home, to: segue.destination)
        case "Trigger"?:
            sendContext(home, to: segue.destination)
        default:
            break
        }
    }

    private func refresh() {
        nameLabel?.text = home.name
        uniqueIdentifierLabel?.text = home.uniqueIdentifier.uuidString
        isPrimaryLabel?.text = String(home.isPrimary)
        homeHubStateLabel?.text = String(describing: home.homeHubState)

        accessoriesCountLabel?.text = String(home.accessories.count)
        roomsCountLabel?.text = String(home.rooms.count)
        zonesCountLabel?.text = String(home.zones.count)
        serviceGroupsCountLabel?.text = String(home.serviceGroups.count)
        actionSetsCountLabel?.text = String(home.actionSets.count)
        triggersCountLabel?.text = String(home.triggers.count)

        let user = home.currentUser
        userNameLabel?.text = user.name
        userIdentifierLabel?.text = user.uniqueIdentifier.uuidString
        isAdministratorLabel?.text = String(home.homeAccessControl(for: user).isAdministrator)
    }

    private func updateName() {
        let home = self.home

        let alert = UIAlertController(title: nil, message: "Homeの名前を入力してください", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = home.name
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard
                let name = alert.textFields?.first?.text,
                name.count > 0
            else {
                return
            }
            self?.handleNewHomeName(name)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    private func handleNewHomeName(_ name: String) {
        //HMHome의 이름을 변경 할 때, updateName
        home.updateName(name) { [weak self] error in
            if let error = error {
                print("# error: \(error)")
            }
            self?.refresh()
        }
    }

    private func manageUsers() {
        home.manageUsers { [weak self] error in
            if let error = error {
                print("# error: \(error)")
            }
            self?.refresh()
        }
    }
}

// MARK: - Actions

extension HomeViewController {
    @IBAction func removeButtonDidTap(sender: AnyObject) {
        ResponderChain(from: self).send(home, protocol: HomeActionHandler.self) { [weak self] home, handler in
            handler.handleRemove(home)

            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func primaryButtonDidTap(sender: AnyObject) {
        ResponderChain(from: self).send(home, protocol: HomeActionHandler.self) { [weak self] home, handler in
            handler.handleMakePrimary(home)

            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            // name
            updateName()
        case (2, 3):
            // manageUsers
            manageUsers()
        default:
            break
        }
    }
}

// MARK: - HMHomeDelegate

extension HomeViewController: HMHomeDelegate {
    
    /**
     * @brief Informs the delegate of a change in the name of a home.
     *
     * @param home Sender of this message.
     */
    func homeDidUpdateName(_ home: HMHome){} // 불리지 않았다.

    
    /**
     * @brief Informs the delegate when the access control for current user has been updated.
     *
     * @param home Sender of the message.
     */
    @available(iOS 11.0, *)
    func homeDidUpdateAccessControl(forCurrentUser home: HMHome){}

    
    /**
     * @brief Informs the delegate of addition of an accessory to the home.
     *
     * @param home Sender of the message.
     *
     * @param accessory Accessory that was added to the home.
     */
    func home(_ home: HMHome, didAdd accessory: HMAccessory){}//악세사리 추가 실행

    
    /**
     * @brief Informs the delegate of removal of an accessory from the home.
     *
     * @param home Sender of the message.
     *
     * @param accessory Accessory that was removed from the home.
     */
    func home(_ home: HMHome, didRemove accessory: HMAccessory){}

    
    /**
     * @brief Informs the delegate that a user was added to the home.
     *
     * @param home Sender of this message.
     *
     * @param user User who was granted access to the home.
     */
    func home(_ home: HMHome, didAdd user: HMUser){}

    
    /**
     * @brief Informs the delegate that a user was removed from the home.
     *
     * @param home Sender of this message.
     *
     * @param user User whose access was revoked from the home.
     */
    func home(_ home: HMHome, didRemove user: HMUser){}

    
    /**
     * @brief Informs the delegate when a new room is assigned to an accessory
     *
     * @param home Sender of the message.
     *
     * @param room New room for the accessory.
     *
     * @param accessory Accessory that was assigned a new room.
     */
    func home(_ home: HMHome, didUpdate room: HMRoom, for accessory: HMAccessory){} // - didAdd room 이후 didUpdate room 호출

    
    /**
     * @brief Informs the delegate of addition of a room to the home.
     *
     * @param home Sender of the message.
     *
     * @param room Room that was added to the home.
     */
    func home(_ home: HMHome, didAdd room: HMRoom){}//룸에 추가된 이후 호출 됨

    
    /**
     * @brief Informs the delegate of removal of a room from the home.
     *
     * @param home Sender of the message.
     *
     * @param room Room that was removed from the home.
     */
    func home(_ home: HMHome, didRemove room: HMRoom){}

    
    /**
     * @brief Informs the delegate that the name of a room was modified
     *
     * @param home Sender of this message.
     *
     * @param room Room that was modified.
     */
    func home(_ home: HMHome, didUpdateNameFor room: HMRoom){}

    
    /**
     * @brief Informs the delegate of addition of a zone to the home.
     *
     * @param home Sender of the message.
     *
     * @param zone Zone that was added to the home.
     */
    func home(_ home: HMHome, didAdd zone: HMZone){}

    
    /**
     * @brief Informs the delegate of removal of a zone from the home.
     *
     * @param home Sender of the message.
     *
     * @param zone Zone that was removed from the home.
     */
    func home(_ home: HMHome, didRemove zone: HMZone){}

    
    /**
     * @brief Informs the delegate that the name of a zone was modified.
     *
     * @param home Sender of this message.
     *
     * @param zone Zone that was modified.
     */
    func home(_ home: HMHome, didUpdateNameFor zone: HMZone){}

    
    /**
     * @brief Informs the delegate that the room was added to a zone.
     *
     * @param home Sender of this message.
     *
     * @param room Room that was added to the zone.
     *
     * @param zone Zone that was modified.
     */
    func home(_ home: HMHome, didAdd room: HMRoom, to zone: HMZone){}

    
    /**
     * @brief Informs the delegate that the room was removed from a zone.
     *
     * @param home Sender of this message.
     *
     * @param room Room that was removed from the zone.
     *
     * @param zone Zone that was modified.
     */
    func home(_ home: HMHome, didRemove room: HMRoom, from zone: HMZone){}

    
    /**
     * @brief Informs the delegate that a service group was added to the home.
     *
     * @param home Sender of the message.
     *
     * @param group Service group that was added to the home.
     */
    func home(_ home: HMHome, didAdd group: HMServiceGroup){}

    
    /**
     * @brief Informs the delegate that a service group was removed from the home.
     *
     * @param home Sender of the message.
     *
     * @param group Service group that was removed from the home.
     */
    func home(_ home: HMHome, didRemove group: HMServiceGroup){}

    
    /**
     * @brief Informs the delegate that the name of a service group was modified.
     *
     * @param home Sender of this message.
     *
     * @param group The service group that was modfied.
     */
    func home(_ home: HMHome, didUpdateNameFor group: HMServiceGroup){}

    
    /**
     * @brief Informs the delegate that a service was added to a service group.
     *
     * @param home Sender of this message.
     *
     * @param service Service that was added to the service group.
     *
     * @param group Service group that was modified.
     */
    func home(_ home: HMHome, didAdd service: HMService, to group: HMServiceGroup){}

    
    /**
     * @brief Informs the delegate that a service was removed from a service group.
     *
     * @param home Sender of this message.
     *
     * @param service Service that was removed from the service group.
     *
     * @param group Service group that was modified.
     */
    func home(_ home: HMHome, didRemove service: HMService, from group: HMServiceGroup){}

    
    /**
     * @brief Informs the delegate that an action set was added to the home.
     *
     * @param home Sender of this message.
     *
     * @param actionSet Action set that was added to the home.
     */
    func home(_ home: HMHome, didAdd actionSet: HMActionSet){}

    
    /**
     * @brief Informs the delegate that an action set was removed from the home.
     *
     * @param home Sender of this message.
     *
     * @param actionSet Action set that was removed from the home.
     */
    func home(_ home: HMHome, didRemove actionSet: HMActionSet){}

    
    /**
     * @brief Informs the delegate that the name of an action set was modified.
     *
     * @param home Sender of this message.
     *
     * @param actionSet Action set that was modified.
     */
    func home(_ home: HMHome, didUpdateNameFor actionSet: HMActionSet){}

    
    /**
     * @brief Informs the delegate that the actions of an action set was modified.
     * This indicates that an action was added/removed or modified (value replaced)
     *
     * @param home Sender of this message.
     *
     * @param actionSet Action set that was modified.
     */
    func home(_ home: HMHome, didUpdateActionsFor actionSet: HMActionSet){}

    
    /**
     * @brief Informs the delegate of the addition of a trigger to the home.
     *
     * @param home Sender of the message.
     *
     * @param trigger Trigger that was added to the home.
     */
    func home(_ home: HMHome, didAdd trigger: HMTrigger){}

    
    /**
     * @brief Informs the delegate of removal of a trigger from the home.
     *
     * @param home Sender of the message.
     *
     * @param trigger Trigger that was removed from the home.
     */
    func home(_ home: HMHome, didRemove trigger: HMTrigger){}

    
    /**
     * @brief Informs the delegate that the name of the trigger was modified.
     *
     * @param home Sender of this message.
     *
     * @param trigger Trigger that was modified.
     */
    func home(_ home: HMHome, didUpdateNameFor trigger: HMTrigger){}

    
    /**
     * @brief Informs the delegate whenever a trigger is updated. For example, this method may be
     *        invoked when a trigger is activated, when a trigger fires, or when the action sets
     *        associated with a trigger are modified.
     *
     * @param home Sender of this message.
     *
     * @param trigger The trigger that was updated.
     */
    func home(_ home: HMHome, didUpdate trigger: HMTrigger){}

    
    /**
     * @brief Informs the delegate that an accessory has been unblocked
     *
     * @param home Sender of this message.
     *
     * @param accessory Accessory that was unblocked
     */
    func home(_ home: HMHome, didUnblockAccessory accessory: HMAccessory){}

    
    
    /**
     * @brief Informs the delegate that a configured accessory encountered an error. The
     *        delegate should check the blocked state of the accessory
     *
     * @param home Sender of this message.
     *
     * @param error Error encountered by accessory.
     *
     * @param accessory Accessory that encountered the error
     */
    func home(_ home: HMHome, didEncounterError error: Error, for accessory: HMAccessory){}

    
    /**
     * @brief Informs the delegate when state of the home hub changes.
     *
     * @param home Sender of the message.
     *
     * @param homeHubState The new home hub state.
     */
    @available(iOS 11.0, *)
    func home(_ home: HMHome, didUpdate homeHubState: HMHomeHubState){}

    
    /**
     * @brief Informs the delegate when the supported features of this home changes.
     *
     * The supported features covered by this are currently:
     *   - supportsAddingNetworkRouter
     *
     * @param home Sender of the message.
     */
    @available(iOS 13.2, *)
    func homeDidUpdateSupportedFeatures(_ home: HMHome){}

    
    
}
