//
//  HomesViewController.swift
//
//  Created by ToKoRo on 2017-08-18.
//

import UIKit
import HomeKit

class HomesViewController: UITableViewController {
    lazy var homeManager: HMHomeManager = HMHomeManager.shared

    var homes: [HMHome] { return homeManager.homes }

    var selectedHome: HMHome?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Delegate를 먼저 설정 해준다.
        
        if #available(iOS 13.0, *) {
            print("홈 메니저 권환상태 -1",homeManager.authorizationStatus)
        } else {
            // Fallback on earlier versions
        }
        
        homeManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Home"?:
            sendContext(selectedHome, to: segue.destination)
        default:
            break
        }
    }

    func refresh() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("홈스 결과 : ",self.homes)
        }
    }

    func home(at indexPath: IndexPath) -> HMHome? {
        return homes.safe[indexPath.row]
    }

    @IBAction func addButtonDidTap(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "追加するHomeの名前を入力してください", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard
                let name = alert.textFields?.first?.text,
                name.count > 0
            else {
                return
            }
            self?.handleNewHome(withName: name)
        })
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true)
    }

    func handleNewHome(withName name: String) {
        homeManager.addHome(withName: name) { home, error in
            if let home = home {
                print("# added: \(home)")
                self.refresh()
            }
            if let error = error {
                print("# error: \(error)")
            }
        }
    }
}

// MARK: - HomeActionHandler

extension HomesViewController: HomeActionHandler {
    func handleRemove(_ home: HMHome) {
        homeManager.removeHome(home) { [weak self] error in
            if let error = error {
                print("# error: \(error)")
            }
            self?.refresh()
        }
    }

    func handleMakePrimary(_ home: HMHome) {
        homeManager.updatePrimaryHome(home) { [weak self] error in
            if let error = error {
                print("# error: \(error)")
            }
            self?.refresh()
        }
    }
}

// MARK: - UITableViewDataSource

extension HomesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Home", for: indexPath)
        if let home = home(at: indexPath) {
            
            cell.textLabel?.text = home.name
            cell.detailTextLabel?.text = home.isPrimary ? "primary" : nil
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        self.selectedHome = home(at: indexPath)

        performSegue(withIdentifier: "Home", sender: nil)
    }
}

// MARK: - HMHomeManagerDelegate

extension HomesViewController: HMHomeManagerDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("# homeManagerDidUpdateHomes")

        // 起動直後？に一度呼ばれた - 시작 직후?에 한 번 불렸다.
        // これが呼ばれるまでhomeManager.primaryHomeはnil - 이것이 불리기 전까지 homeManager.primaryHome은 nil

        // 1つめのHomeをaddした時には呼ばれなかった - 히토츠노 홈을 추가했을 때는 불려지지 않았다.
        // 2つめのHomeをaddした時には呼ばれなかった - 후타츠노 홈을 추가했을 때는 불리지 않았다.
        refresh()
    }

    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        print("# homeManagerDidUpdatePrimaryHome")

        // 1つめのHomeをaddした時に呼ばれた
        // primaryなHomeを削除した時に呼ばれた
        // 안 불렸다...
    }

    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        print("# homeManager didAdd home")

        // Homeを追加しても呼ばれない? - 홈을 추가해도 부르지않아?
        //나도 안 불렸다.
    }

    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        print("# homeManager didRemove home")
        //안 불렀다...
    }
}
