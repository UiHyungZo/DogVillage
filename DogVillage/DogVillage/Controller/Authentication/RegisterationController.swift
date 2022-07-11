

import UIKit
import PhotosUI

class RegisterationController: UIViewController{
 
    // MARK : - Properties
    private var viewModel = RegistraionViewModel()
    private var profileImage: UIImage?
    weak var delegate: AutheticationDelegate?

    var restoreFrameValue: CGFloat = 0.0
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        
        return button
    }()
    
    private let emailTextField: CustomTextField = {
        
        let tf = CustomTextField(placeHolder: "사용하시는 email을 적어주세요")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let duplicateEmail: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "테스트"
        
        return label
    }()
    
    
    private let passwordTextField: CustomTextField = {
        
        let tf = CustomTextField(placeHolder: "6글자 이상 비밀번호 입력하세요")
        tf.isSecureTextEntry = true
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let fullnameTextField = CustomTextField(placeHolder: "사용할 닉네임을 적어주세요")
    private let usernameTextField = CustomTextField(placeHolder: "애완동물 이름을 적어주세요")
    
    private let signUpButton: UIButton = {
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
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
//        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Sign Up")
        button.attributedTitle(firstPart: "이미 회원입니다")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
           let button = UIButton(type: .system)
           button.tintColor = .white
           button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
           button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
           return button
    }()
    

    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showMessage(withTitle: "사용하시는 이메일을 적어주세요", message: "사용하시는 이메일을 적어주셔야 나중에 비밀번호를 잃어버렸을 경우에 비밀번호를 찾을 수 있습니다.")
        configureUI()
        configureNotificationObservers()
        
    }
    
    
    
   
   

    // MARK : - Helpers
    func configureUI(){
        configureGradientLayer()//그라디언트로 빠진 배경화면
        
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField, fullnameTextField,usernameTextField,signUpButton])
        
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor ,left: view.leftAnchor, right:view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32 )
        /*
        view.addSubview(duplicateEmail)
        duplicateEmail.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor, paddingLeft: 32)
        */
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }

    
    func configureNotificationObservers(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - Actions
    @objc func handleShowLogin(){
        let controller = RegisterationController()
        controller.delegate = delegate
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField){
        
        if sender == emailTextField {
            viewModel.email = sender.text
        }else if sender == passwordTextField{
            viewModel.password = sender.text
        }else if sender == fullnameTextField{
            viewModel.fullname = sender.text
        }else{
            viewModel.username = sender.text
        }
        
        updateForm()
    }
    
    
    
    
    @objc func handleProfilePhotoSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let username = usernameTextField.text?.lowercased() else {return}
        guard let profileImage = self.profileImage else {return}
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        showLoader(true)
        AuthService.registerUser(withCredential: credentials) { error in
            if let error = error{
                print("DEBUG : Failed to handleShowSignUp user\(error.localizedDescription)")
                self.showMessage(withTitle: "아이디 중복", message: "아이디가 중복 되었습니다")
                self.showLoader(false)
                return
            }
            self.showLoader(true)
            self.delegate?.authenticationComplete()
        }
        
    }
    
    @objc func handleDismissal(){
        navigationController?.popViewController(animated: true)
    }
    
    
   
    
    
    
}

//MARK: - FormViewModel

extension RegisterationController: FormViewModel{
    func updateForm() {
        
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
        
    }
    
    
}

extension RegisterationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
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

