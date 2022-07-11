

import UIKit

protocol AutheticationDelegate: class{
    func authenticationComplete()
}

class LoginController: UIViewController{
    
    //MARK: - Properties
    private var viewModel = LoginViewModel()
    weak var delegate:AutheticationDelegate?
    
    
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "girl-g8e2dfe4b8_1920"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailTextField: UITextField = {

        let tf = CustomTextField(placeHolder: "이메일을 적어주세요")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
       
        let tf = CustomTextField(placeHolder: "패스워드를 적어주세요")
        tf.isSecureTextEntry = true
        return tf
        
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "비밀번호 찾기")
        
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
    }()
    
    private let dontHavaAccountButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "회원가입")
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG : loginController")
        configureUI()
        configureNotificationObservers()
    }
    
    
    //MARK: - Helpers
    
    func configureUI(){
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        
        configureGradientLayer()
        
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 80)
        iconImage.anchor(top:view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
//        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgetPasswordButton])//넣을 프로퍼티를 넣어주기
        let loginStack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        loginStack.axis = .vertical// 세로로 스택뷰로 넣어주기
        loginStack.spacing = 20// 각각 간격은 20으로
        
        view.addSubview(loginStack)//추가해주기
        loginStack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor , paddingTop: 32, paddingLeft: 32, paddingRight: 32)//위치 조정해 주기
        let infoSearchStack = UIStackView(arrangedSubviews: [forgetPasswordButton, dontHavaAccountButton])
        infoSearchStack.axis = .vertical
        infoSearchStack.spacing = 20
        
        view.addSubview(infoSearchStack)
        infoSearchStack.centerX(inView: view, topAnchor: loginStack.bottomAnchor, paddingTop: 10)
//        view.addSubview(dontHavaAccountButton)
//        dontHavaAccountButton.centerX(inView: view)
//        dontHavaAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
 
    func configureNotificationObservers(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    //MARK: - Actions
    @objc func textDidChange(sender: UITextField){
        
        if sender == emailTextField{
            viewModel.email = sender.text
        }else{
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleShowSignUp(){
        let controller = RegisterationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        showLoader(true)
        AuthService.logUserIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print("DEBUG : Failed to log user in \(error.localizedDescription)")
                self.showMessage(withTitle: "Error", message: "등록된 아이디가 아니거나 비밀번호가 틀렸습니다")
                self.showLoader(false)
                return
            }
            self.showLoader(false)
            self.delegate?.authenticationComplete()
            
        }
    }
    
    @objc func handleShowResetPassword(){
        let controller = ResetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
}


extension LoginController: FormViewModel{
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
    
    
}


//MARK: - ResetPasswordControllerDelegate
extension LoginController: ResetPasswordControllerDelegate{
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "이메일을 보냈으니 확인 후 바꿔주시기 바랍니다.")
    }
}


