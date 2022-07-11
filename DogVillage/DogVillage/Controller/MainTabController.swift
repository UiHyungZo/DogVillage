

import UIKit
import Firebase
import YPImagePicker

class MainTabController: UITabBarController {

    //MARK: - Properties
    var user:User?{
        didSet{
            guard let user = user else {return}
            configureViewController(withUser: user)
        }
    }
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkIfUserIsLoggedIn()
        fetchUser()
        print("DEBUG : mainTab")
    }
    
    
    //MARK: - Helpers
    
    func configureViewController(withUser user: User){
        
        self.tabBar.backgroundColor = .white
        self.delegate = self
        
        
        let layout = UICollectionViewFlowLayout()//초기화 중요
        
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected")
                                                , selectedImage: #imageLiteral(resourceName: "home_selected"), rootController: FeedController(collectionViewLayout: layout))
        
        
        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "search_unselected")
                                                  , selectedImage: #imageLiteral(resourceName: "search_selected"), rootController: SearchController())

        let calendar = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus_unselected")
                                                         , selectedImage: #imageLiteral(resourceName: "save_shadow"), rootController: CalendarController())
        
        let notification = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "ribbon")
                                                        , selectedImage: #imageLiteral(resourceName: "ribbon"), rootController: NotificationController())
        let profileController = ProfileController(user: user)
        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "profile_unselected")
                                                   , selectedImage: #imageLiteral(resourceName: "profile_selected"), rootController: profileController)
        
        
        
        
        viewControllers = [feed, search, calendar, notification, profile]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootController: UIViewController) -> UINavigationController{
        
        let nav = UINavigationController(rootViewController: rootController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        
        
        
        return nav
        
    }
    
    func didFinishPickingMedia(_ picker: YPImagePicker){
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectedImage = items.singlePhoto?.image else {return}
                
                let controller = UploadPostController()
                controller.selectedImage = selectedImage
                controller.delegate = self
                controller.currentUser = self.user
                let nav = UINavigationController(rootViewController: controller)
                
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - API
    func checkIfUserIsLoggedIn(){
        print("DEBUG: check : \(Auth.auth().currentUser?.uid)")
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                print("DEBUG : login 정보 없음")
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func logout(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("DEBUG : Failed to sign out")
        }
    }
    
    func fetchUser(){
        UserService.fetchUser { user in
            self.user = user
        }
    }
    
    

}

//MARK: - AutheticationDelegate
extension MainTabController: AutheticationDelegate{
    func authenticationComplete() {
        fetchUser()
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITabBarControllerDelegate
extension MainTabController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        var index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2{
            var config = YPImagePickerConfiguration()
            
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library, .photo]
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.library.maxNumberOfItems = 1
            config.library.minNumberOfItems = 1
            config.library.numberOfItemsInRow = 1
            
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
            
            didFinishPickingMedia(picker)
        }
        
        return true
    }
}

//MARK: - UploadPostControllerDelegate
extension MainTabController: UploadPostControllerDelegate{
    func controllerDidFinishUploadingPost(_ controller: UploadPostController) {
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else{return}
        guard let feed = feedNav.viewControllers.first as? FeedController else{return}
        feed.handleRefresh()
        
    }
    
    
}
