//
//  MFMailComposeViewControllerDelegate.swift
//  Spyfall
//
//  Created by bbb on 7/4/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import MessageUI

extension MFMailComposeViewControllerDelegate where Self: UIViewController {
    func showMailComposer(recipients: [String], body: String = "", isHTML: Bool = false) {
        guard MFMailComposeViewController.canSendMail() else {
            Spitter.showOkAlert("Mail composer is not available", viewController: self)
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(recipients)
        mail.setMessageBody(body, isHTML: isHTML)
        
        present(mail, animated: true)
    }
}
