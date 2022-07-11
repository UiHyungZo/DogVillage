


import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {

    
    //MARK: - Properties
    private var posts = [Post](){
        didSet{collectionView.reloadData()}
    }
    
    var post: Post?{
        didSet{collectionView.reloadData()}
        
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchPosts()
        
        if post != nil{
            checkIfUserLikedPosts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    
    //MARK: - Helpers
    
    func configureUI(){
        
        collectionView.backgroundColor = .white
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if post == nil{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        navigationItem.title = "게시글"
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    

    
    
    //MARK: - Actions
    
    @objc func handleLogout(){
        do{
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }catch{
            print("DEBUG: Failed to sign out")
        }
    }
    
    @objc func handleRefresh(){
        posts.removeAll()
        fetchPosts()
    }
    
    //MARK: - API
    func fetchPosts(){
        guard post == nil else {return}
        
        PostService.fetchPosts { posts in
            self.posts = posts
            self.checkIfUserLikedPosts()
            self.collectionView.refreshControl?.endRefreshing()
            
            
        }
        
//        PostService.fetchFeedPosts { posts in
//            self.posts = posts
//            self.checkIfUserLikedPosts()
//            self.collectionView.refreshControl?.endRefreshing()
//        }
    }
    
    func checkIfUserLikedPosts(){
        //개인 feed로 들어 갔을 때
        if let post = post{
            PostService.checkIfUserLikedPost(post: post) { didLike in
                DispatchQueue.main.async {
                    self.post?.didLike = didLike
                    self.collectionView.reloadData()
                }
                
            }
            
        }else{
            //전체 feed에서 나오는
            self.posts.forEach { post in
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    DispatchQueue.main.async {
                        if let index = self.posts.firstIndex(where: {$0.postId == post.postId}){
                            self.posts[index].didLike = didLike
                        }
                    }
                }
            }
        }
    }
    
}


//MARK: - CollectionViewDataSource

extension FeedController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        return posts.count
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if let post = post{
            cell.viewModel = PostViewModel(post: post)
            
        }else{
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
            
        }
                
        return cell
    }
    
   
}

//MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout{

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width+8+40+8
        height += 50
        height += 60
        
        return CGSize(width: width, height: height)
    }
}

//MARK: - FeedCellDelegate
extension FeedController: FeedCellDelegate{
    
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        guard let tab = tabBarController as? MainTabController else {return}
        guard let user = tab.user else {return}
        
        cell.viewModel?.post.didLike.toggle()
        print("DEBUG: FeedController tab")
        if post.didLike{
            PostService.unlikePost(post: post) { error in
                if let error = error{
                    return
                }
//                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
//                cell.likeButton.tintColor = .black
                
                cell.viewModel?.post.likes = post.likes - 1
            }
            
        }else{
            PostService.likePost(post: post){ error in
                
                if let error = error{
                    print("DEBUG: controller likePost error: \(error.localizedDescription)")
                    return
                }
                
//                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
//                cell.likeButton.tintColor = .red
                
                cell.viewModel?.post.likes = post.likes + 1
                
                NotificationService.uploadNotification(toUid: post.ownerUid
                                                       ,fromUser: user
                                                       ,type: .like
                                                       ,post: post)
            }
        }
        
    }
    
    func cell(_ cell: FeedCell, wantsToshowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: FeedCell, removePost post: Post){
        guard let tab = tabBarController as? MainTabController else {return}
        guard let user = tab.user else {return}
        
        let alertAction = UIAlertController(title: "게시글 삭제", message: "게시글을 삭제하시겠습니까? 본인의 아이디가 아니면 불가능 합니다.", preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default, handler: { _ in
            self.showLoader(true)
            PostService.removePost(postId: post.postId, currentUser: user.uid) { error in
            self.showMessage(withTitle: "실패", message: "본인의 아이디가 아닙니다.")
        }
            self.showLoader(false)
            self.showMessage(withTitle: "성공", message: "삭제가 성공하였습니다.")
        })

        let noAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.default, handler: nil)
        
        alertAction.addAction(yesAction)
        alertAction.addAction(noAction)
        
        present(alertAction,animated: true, completion: nil)
        self.collectionView.reloadData()

    }
    
    
    
}

