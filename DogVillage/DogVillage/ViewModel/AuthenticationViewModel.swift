//
//  AuthenticationViewModel.swift
//  MVPInstagram
//
//  Created by Mac on 2022/06/23.
//


import UIKit


protocol FormViewModel{
    func updateForm()
}

protocol AuthenticationViewModel{
    var formIsValid:Bool {get}
    var buttonBackgroundColor:UIColor {get}
    var buttonTitleColor:UIColor {get}
}

struct LoginViewModel: AuthenticationViewModel{
    var email:String?
    var password:String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor{
        return formIsValid ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}

struct RegistraionViewModel: AuthenticationViewModel{
    var email:String?
    var password:String?
    var fullname:String?
    var username:String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor{
        return formIsValid ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
   
}


struct ResetPasswordViewModel: AuthenticationViewModel{
    var email: String?
    
    var formIsValid: Bool{return email?.isEmpty == false}
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}

struct updateViewModel: AuthenticationViewModel{
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool{return fullname?.isEmpty == false && username?.isEmpty == false}
    
    var buttonBackgroundColor: UIColor{
        return formIsValid ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor{
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}
