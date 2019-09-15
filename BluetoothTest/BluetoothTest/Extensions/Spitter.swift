import UIKit

typealias ErrorClosure = (String?, String?) -> Void
typealias Handler = () -> Void

class Spitter {
    static let blackList = [String]()
    static var activityIndicator: UIActivityIndicatorView?
    static func showErrorAlert(_ error: String?, viewController: UIViewController) {
        var permission = false
        blackList.forEach({ if error?.range(of: $0) != nil { permission = false }})
        if permission {
            showAlert(message: error, buttonTitles: ["Close"], actions: [nil], owner: viewController)
        }
    }
    static func showOkAlert(_ message: String?, title: String? = nil, action: Handler? = nil, viewController: UIViewController) {
        var permission = true
        blackList.forEach({ if message?.range(of: $0) != nil { permission = false }})
        if permission {
            showAlert(title, message: message, buttonTitles: ["Ok"], actions: [action ?? {}], owner: viewController)
        }
    }
    static func showActionAlert(_ title: String?, message: String?, controller: UIViewController, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
            action()
        }))
        var permission = true
        blackList.forEach({ if message?.range(of: $0) != nil { permission = false }})
        if permission {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    static func showActionAlertOnPVC(_ title: String? = nil, message: String?, action: @escaping () -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            var permission = true
            blackList.forEach({ if message?.range(of: $0) != nil { permission = false }})
            if permission {
                showActionAlert(title, message: message, controller: topController, action: action)
            }
        }
    }
    static func pvc() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    static func identifier(of object: AnyObject) -> String {
        return String(describing: ObjectIdentifier(object).hashValue)
    }
    static func showAlertOnPVC(_ title: String? = nil, message: String?, buttonTitles: [String], actions: [(() -> Void)?]) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            var permission = true
            blackList.forEach({ if message?.range(of: $0) != nil { permission = false }})
            if permission {
                showAlert(title, message: message, buttonTitles: buttonTitles, actions: actions, owner: topController)
            }
        }
    }
    static func showConfirmation(_ title: String = "Are you sure?", message: String? = nil, owner: UIViewController? = nil, confirmCompletion: @escaping () -> Void) {
        MultiActionAlert(style: .alert, title: title, message: message, buttonTitles: ["Ok", "Cancel"], actionStyles: [.default, .cancel], actions: [ {confirmCompletion()}, {} ], owner: owner ?? pvc())
            .showAlert()
    }
    static func showAlert(_ title: String? = nil, message: String?, buttonTitles: [String], actions: [(() -> Void)?], owner: UIViewController) {
        MultiActionAlert(style: UIAlertController.Style.alert, title: title, message: message, buttonTitles: buttonTitles, actions: actions, owner: owner).showAlert()
    }
    static func showSheet(_ title: String? = nil, message: String?, buttonTitles: [String], actions: [(() -> Void)?], styles: [UIAlertAction.Style]? = nil, owner: UIViewController) {
        MultiActionAlert(style: UIAlertController.Style.actionSheet, title: title, message: message, buttonTitles: buttonTitles, actionStyles: styles, actions: actions, owner: owner).showAlert()
    }
    static func shareUrl(_ urlString: String?, viewController: UIViewController) {
        if let urlString = urlString, let url = URL(string: urlString) {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = viewController.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 30, height: 30)
            viewController.present(activityVC, animated: true, completion: nil)
        }
    }
    static func showOk(vc: UIViewController? = nil, completion: @escaping () -> Void) {
        if let vc = vc {
            displayOk(vc: vc, completion: completion)
        } else {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                displayOk(vc: rootVC, completion: completion)
            }
        }
    }
    private static func displayOk (vc: UIViewController, completion: @escaping () -> Void) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_ok"))
        imageView.center = vc.view.center
        vc.view.addSubview(imageView)
        vc.view.bringSubviewToFront(imageView)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            imageView.alpha = 0
            imageView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        }) { _ in
            imageView.removeFromSuperview()
            completion()
        }
    }
    static func showWord(word: String, withColor color: UIColor = .black, vc: UIViewController? = nil, completion: @escaping () -> Void) {
        if let vc = vc {
            displayWord(word: word, withColor: color, vc: vc, completion: completion)
        } else {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                displayWord(word: word, withColor: color, vc: rootVC, completion: completion)
            }
        }
    }
    private static func displayWord (word: String, withColor color: UIColor, vc: UIViewController, completion: @escaping () -> Void) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        label.text = word
        label.textAlignment = .center
        label.textColor = color
        label.center = vc.view.center
        label.font = UIFont(name: label.font.fontName, size: 30)
        vc.view.addSubview(label)
        vc.view.bringSubviewToFront(label)
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            label.alpha = 0
            label.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        }) { _ in
            label.removeFromSuperview()
            completion()
        }
    }
    static func showSpinner(vc: UIViewController? = nil) {
        if let vc = vc {
            displaySpinner(vc: vc)
        } else {
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                displaySpinner(vc: rootController)
            }
        }
    }
    static func hideSpinner(vc: UIViewController? = nil) {
        if let vc = vc {
            removeSpinner(vc: vc)
        } else {
            if let rootController = UIApplication.shared.keyWindow?.rootViewController {
                removeSpinner(vc: rootController)
            }
        }
    }
    private static func displaySpinner (vc: UIViewController) {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
            activityIndicator.style = UIActivityIndicatorView.Style.gray
            activityIndicator.center = vc.view.center
            addSubview(subview: activityIndicator, toView: vc.view)
            activityIndicator.startAnimating()
            self.activityIndicator = activityIndicator
        }
    }
    private static func removeSpinner (vc: UIViewController) {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } else {
            for child in vc.view.subviews {
                if let activity = child as? UIActivityIndicatorView {
                    activity.stopAnimating()
                    activity.removeFromSuperview()
                }
            }
        }
    }
    static func handleErrorStringClosure() -> (String) -> Void {
        return {errStr in
            var permission = true
            blackList.forEach { if errStr.range(of: $0) != nil { permission = false } }
            if permission { showActionAlertOnPVC( message: errStr, action: { }) }
        }
    }
    static func handleError(error: NSError) {
        produceErrorClosure(error: error, errorClosure: handleErrorMessageClosure())
    }
    static func handleErrorMessageClosure(shouldHideActivityIndicator: Bool = false, completion: (() -> Void)? = nil) -> ErrorClosure {
        return { title, message in
            showActionAlertOnPVC(title, message: message, action: {})
            if shouldHideActivityIndicator { hideSpinner() }
            completion?()
        }
    }
    static func error(code: Int, description: String) -> NSError {
        return NSError(domain: "Rolique", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    static func produceErrorClosure(error: NSError, errorClosure: ErrorClosure) {
        errorClosure("Oooops.. ", error.localizedDescription)
        print(error)
    }
    static func displayErrorOnPVC(error: Error, action: (() -> Void)? = nil) {
        showActionAlertOnPVC("Oooops.. ", message: error.localizedDescription, action: action ?? {})
    }
    static func showOkAlertOnPVC(_ message: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            showOkAlert(message, viewController: topController)
        }
    }
    static func showInputAlert(title: String? = nil,
                               message: String? = nil,
                               buttons: [String],
                               actionStyles: [UIAlertAction.Style]? = nil,
                               actions: [(() -> Void)?],
                               owner: UIViewController,
                               textfieldConfigurationHandler: ((UITextField) -> Void)? = nil) {
        MultiActionAlert(style: .alert,
                         title: title,
                         message: message,
                         buttonTitles: buttons,
                         actionStyles: actionStyles,
                         actions: actions,
                         owner: owner,
                         textfieldConfigurationHandler: textfieldConfigurationHandler
            ).showAlert()
    }
    static func shareContent(_ text: String?, image: UIImage?, controller: UIViewController) {
        var itemsToShare = [AnyObject]()
        if let text = text { itemsToShare.append(text as AnyObject) }
        if let image = image { itemsToShare.append(image) }
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = activityCompletionHandler
        activityViewController.popoverPresentationController?.sourceView = controller.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        controller.present(activityViewController, animated: true) { () -> Void in
            print("Sharing view did appear")
        }
    }
    static func activityCompletionHandler(activityType: UIActivity.ActivityType?, completed: Bool, items: [Any]?, activityError: Error?) {
        if completed && activityError == nil {
            switch activityType! {
            case UIActivity.ActivityType.mail:print("activity finished for mail")
            case UIActivity.ActivityType.message:print("activity finished for message")
            case UIActivity.ActivityType.postToFacebook:print("activity finished for FB")
            case UIActivity.ActivityType.postToTwitter:print("activity finished for TWITTER")
            case UIActivity.ActivityType.postToFlickr:print("activity finished for Flickr")
            case UIActivity.ActivityType.postToVimeo:print("activity finished for Vimeo")
            case UIActivity.ActivityType.postToWeibo:print("activity finished for Weibo")
            default:print("activity finished with other type: \(String(describing: activityType))")
            }
        }
    }
    
    private static func addSubview(subview: UIView, toView parentView: UIView) {
        parentView.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subview
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", metrics: nil, views: viewBindingsDict))
    }
    static func spit(string: String, errorClosure: (_ title: String?, _ message: String?) -> Void) {
        produceErrorClosure(error: error(code: 777, description: string), errorClosure: errorClosure)
    }
    static func spit(error: NSError, errorClosure: (_ title: String?, _ message: String?) -> Void) {
        produceErrorClosure(error: error, errorClosure: errorClosure)
    }
}

class MultiActionAlert {
    var style: UIAlertController.Style
    var title: String?
    var message: String?
    var buttonTitles: [String]
    var actions: [(() -> Void)?]
    var owner: UIViewController?
    var actionStyles: [UIAlertAction.Style]?
    var textfieldConfigurationHandler: ((UITextField) -> Void)?
    
    init (style: UIAlertController.Style,
          title: String? = nil,
          message: String? = nil,
          buttonTitles: [String],
          actionStyles: [UIAlertAction.Style]? = nil,
          actions: [(() -> Void)?],
          owner: UIViewController? = nil,
          textfieldConfigurationHandler: ((UITextField) -> Void)? = nil) {
        self.style = style
        self.title = title
        self.message = message
        self.buttonTitles = buttonTitles
        self.actions = actions
        self.owner = owner
        self.actionStyles = actionStyles
        self.textfieldConfigurationHandler = textfieldConfigurationHandler
    }
    
    init (style: UIAlertController.Style,
          title: String? = nil,
          message: String? = nil,
          actions: [MultiActionAlert.Action],
          owner: UIViewController? = nil,
          textfieldConfigurationHandler: ((UITextField) -> Void)? = nil) {
        self.style = style
        self.title = title
        self.message = message
        self.buttonTitles = actions.map { $0.title }
        self.actions = actions.map { $0.handler }
        self.owner = owner
        self.actionStyles = actions.map { $0.style }
        self.textfieldConfigurationHandler = textfieldConfigurationHandler
    }
    
    func showAlert() {
        if owner == nil { owner = Spitter.pvc() }
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: self.style)
        alert.popoverPresentationController?.sourceView = owner!.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 30, height: 30)
        for x in 0..<buttonTitles.count {
            let buttonTitle = self.buttonTitles[x]
            let action =  self.actions[x]
            if let actionStyles = self.actionStyles {
                let style = actionStyles[x]
                alert.addAction(UIAlertAction(title: buttonTitle, style: style, handler: {_ in
                    action?()
                }))
            } else {
                alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {_ in
                    action?()
                }))
            }
        }
        if textfieldConfigurationHandler != nil {
            alert.addTextField(configurationHandler: self.textfieldConfigurationHandler)
        }
        owner!.present(alert, animated: true, completion: nil)
    }
    
    static let cancelAction: Action = Action(title: "Cancel", style: .destructive)
    
    class Action {
        var title: String
        var style: UIAlertAction.Style
        var handler: Handler?
        
        init(title: String, style: UIAlertAction.Style, handler: Handler? = {}) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }
}
