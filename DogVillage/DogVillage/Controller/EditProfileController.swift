//
//  EditProfileController.swift
//  DogVillage
//
//  Created by Mac on 2022/07/05.
//

import UIKit
import Firebase

private let reuseIdentifier = "EditCell"

var items = ["회원정보 수정하기","회원 탈퇴"]

class EditProfileContrller: UIViewController{
    
    
    //MARK: - Properties
    private let tableView = UITableView()
    var currentUser: User?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
    }
    
    
    
    //MARK: - Helpers
    func configureTableView(){
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
        
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    
    
    
    
}

//MARK: - UITableViewDataSource
extension EditProfileContrller: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = items[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    
    
}

//MARK: - UITableViewDelegate
extension EditProfileContrller: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let controller = ResetInfomation()
            print("DEBUG : tableview ResetInfo")
            navigationController?.pushViewController(controller, animated: true)
        }else{
            let alertAction = UIAlertController(title: "아이디 삭제", message: "아이디를 삭제하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
            
            let yesAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: { _ in
                self.showLoader(true)
                AuthService.deletaUser()
                self.showLoader(false)
                self.showMessage(withTitle: "성공", message: "아이디가 삭제되었습니다")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                      exit(0)
                     }
                }
            })
            
            let noAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.default, handler: nil)
            
            alertAction.addAction(yesAction)
            alertAction.addAction(noAction)
            
            present(alertAction,animated: true, completion: nil)
            
            
            
        }

        
        
    }
    
}




