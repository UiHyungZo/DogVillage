//
//  ResetInfomation.swift
//  DogVillage
//
//  Created by Mac on 2022/07/06.
//

import UIKit
import CoreMedia
import Firebase

class ResetInfomation: UIViewController{
    
    //MARK: - Properties
    private var profileImage: UIImage?
    private var viewModel = updateViewModel()
    weak var delegate: AutheticationDelegate?
    var currentUser: User?

    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        
        return button
    }()
    
    private let fullnameTextField = CustomTextField(placeHolder: "사용할 닉네임을 적어주세요")
    private let usernameTextField = CustomTextField(placeHolder: "애완동물 이름을 적어주세요")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    func configureNotificationObservers(){
     

        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

    }
    
    
    //MARK: - Helpers
    func configureUI(){
        view.backgroundColor = .white
        
        configureGradientLayer()//그라디언트로 빠진 배경화면
        

        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [ fullnameTextField,usernameTextField,signUpButton])
        
        stack.axis = .vertical
        stack.spacing = 40
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor ,left: view.leftAnchor, right:view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32 )
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: - Actions
    @objc func handleProfilePhotoSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
   
    @objc func textDidChange(sender: UITextField){
        if sender == fullnameTextField{
            viewModel.fullname = sender.text
        }else{
            viewModel.username = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleSignUp(){
        guard let username = usernameTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let profileImage = self.profileImage else {return}
        print("DEBUG : update")
        showLoader(true)
        AuthService.upDateUser(username: username, fullname: fullname, image: profileImage){
            error in
            
            if let error = error{
                self.showMessage(withTitle: "에러", message: "실패하였습니다")
                self.showLoader(false)
                return
            }
            
        }
        self.showMessage(withTitle: "성공", message: "수정되었습니다")
        self.showLoader(false)
        
    }
    
    
    
}

extension ResetInfomation:FormViewModel{
    
    func updateForm() {
        
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
        
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ResetInfomation: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
