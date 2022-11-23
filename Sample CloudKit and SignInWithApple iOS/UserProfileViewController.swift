//
//  UserProfileViewController.swift
//  Sample CloudKit and SignInWithApple iOS
//
//  Created by Rizal Hilman on 21/11/22.
//

import UIKit

class UserProfileViewController: UIViewController {

    public var userIdentifier: String!
    public var userProfile: UserProfile!
    
    @IBOutlet weak var labelUserIdentifier: UILabel!
    @IBOutlet weak var labelAppleIDEmail: UILabel!
    @IBOutlet weak var labelGivenName: UILabel!
    @IBOutlet weak var labelFamilyName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelUserIdentifier.text = userIdentifier
        labelAppleIDEmail.text = userProfile.appleIDEmail
        labelGivenName.text = userProfile.givenName
        labelFamilyName.text = userProfile.familyName
        
        print("Loginned \(userIdentifier)")
    }
    @IBAction func actionAppleIDSignOut(_ sender: Any) {
        KeychainItem.deleteUserIdentifierFromKeychain()
        UserDefaults.standard.set(false, forKey: "isLogin")
        dismiss(animated: true)
    }
    
}
