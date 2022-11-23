//
//  ViewController.swift
//  Sample CloudKit and SignInWithApple iOS
//
//  Created by Rizal Hilman on 21/11/22.
//

import UIKit
import AuthenticationServices
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    private let publicDatabase = CKContainer(identifier: "iCloud.khilmand.Sample-CloudKit-and-SignInWithApple-iOS").publicCloudDatabase
    private var userIdentifier: String = KeychainItem.currentUserIdentifier
    private var userProfile: UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appleIDAuthenticationCheck()
        setupProviderLoginView()
    }
    
    private func appleIDAuthenticationCheck() {
        
        let isUserLogin = UserDefaults.standard.bool(forKey: "isLogin")
        
        if isUserLogin {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
                switch credentialState {
                case .authorized:

                    self.fetchUserProfile { userProfile in
                        self.userProfile = userProfile
                        DispatchQueue.main.async {
                            self.showUserProfileController()
                        }
                    }
                    
                    break // The Apple ID credential is valid.
                case .revoked, .notFound:
                    // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                    print("login not found")
                default:
                    break
                }
            }
        }
    }
    
    private func setupProviderLoginView(){
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc private func handleAuthorizationAppleIDButtonPress(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    private func showUserProfileController() {
        performSegue(withIdentifier: "segueToProfile", sender: self)
    }
    
    private func fetchUserProfile(completion: @escaping (UserProfile) -> Void){
        publicDatabase.fetch(withRecordID: CKRecord.ID(recordName: userIdentifier), completionHandler: { [self] (record, error) in
            if error != nil {
                print(error.debugDescription)
            }
            if let fetchedInfo = record {
                let appleIDEmail = fetchedInfo[UserProfileRecordKeys.appleIDEmail.rawValue] as? String
                let givenName = (fetchedInfo[UserProfileRecordKeys.givenName.rawValue] as? String) ?? ""
                let familyName = (fetchedInfo[UserProfileRecordKeys.familyName.rawValue] as? String) ?? ""
                
                self.userProfile = UserProfile(userIdentifier: userIdentifier, appleIDEmail: appleIDEmail!, givenName: givenName, familyName: familyName)
                
                completion(userProfile)
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserProfileViewController {
            vc.userIdentifier = self.userIdentifier
            vc.userProfile = userProfile
        }
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // MARK: User successfully sign in with apple id
            self.userIdentifier = appleIDCredential.user
            
            // Save to key chain if needed
            self.saveUserInKeychain(userIdentifier)
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            if let givenName = appleIDCredential.fullName?.givenName, let familyName = appleIDCredential.fullName?.familyName, let email = appleIDCredential.email {
                // MARK: 1st time sign in, make sure to save necessary data
                print("1st time Sign In")
                
                // Cloudkit operation here
                // MARK: Save to cloudkit
                userProfile = UserProfile(userIdentifier: userIdentifier,
                                              appleIDEmail: email,
                                              givenName: givenName,
                                              familyName: familyName)
                
                publicDatabase.save(userProfile.record) { (record, error) in
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.showUserProfileController()
                    }
                }
            } else {
                // MARK: returned user
                print("returned sign in")
                // Cloudkit operation here
                // MARK: Fetch data from cloudkit
                
                self.fetchUserProfile { userProfile in
                    self.userProfile = userProfile
                    DispatchQueue.main.async {
                        self.showUserProfileController()
                    }
                }
            }
            
            break
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle Error
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "khilmand.Sample-CloudKit-and-SignInWithApple-iOS", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIDentifier to keychain.")
        }
    }
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
