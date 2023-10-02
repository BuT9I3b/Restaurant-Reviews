//
//  ViewController.swift
//  Restaurant Review
//
//  Created by Serhii Haponov on 27.09.2023.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate {
    var webView: WKWebView!

    var urlString: String = "https://quiz.chipaemc.pp.ua/quiz.php?num=1";
    
    let defaults = UserDefaults.standard
    
    override func loadView() {
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGestureRecognizer()
        
        if (defaults.string(forKey: "urlWebPage") != nil) {
            loadWebPage(urlString: getUrl())
        } else if urlString != "" {
            loadWebPage(urlString: urlString)
        } else {
            presentViewForNewDomen()
        }
    }
}

// MARK: - UserDefaults
extension ViewController {
    func setUrl(string: String?) {
        defaults.set(string, forKey: "urlWebPage")
    }

    func getUrl() -> String {
        if let urlWebPage = defaults.string(forKey: "urlWebPage") {
            urlString = urlWebPage
        } else {
            presentViewForNewDomen()
        }
        
        return urlString
    }
}

// MARK: - GestureRecognizer
extension ViewController {
    func loadGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.presentViewForNewDomen))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 5
        webView.isUserInteractionEnabled = true
        webView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,  shouldRecognizeSimultaneouslyWith:UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - AlertController
extension ViewController {
    @objc func presentViewForNewDomen() {
        let alert = UIAlertController(title: "Enter new url", message: "Please enter a new URL to display the page to the user", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Please enter a new url"
        }

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            if self.verifyUrl(urlString: textField?.text) {
                self.setUrl(string: textField!.text)
                self.loadWebPage(urlString: self.getUrl())
            } else {
                self.presentViewInvalidUrl()
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentViewInvalidUrl() {
        let alert = UIAlertController(title: "Invalid url", message: "Please check a new url and try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - WebView
extension ViewController {
    func verifyUrl(urlString: String?) -> Bool {
        guard let urlString = urlString
        else {
            return false
        }
        
        guard let url = NSURL(string: urlString)
        else {
            return false
        }
        
        if !UIApplication.shared.canOpenURL(url as URL) {
            return false
        }
        
        return true
    }
    
    func loadWebPage(urlString: String?) {
        if verifyUrl (urlString: urlString) {
            let requestObj = NSURLRequest(url: URL(string: urlString!)!,
                                          cachePolicy:NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
            
            webView.load(requestObj as URLRequest)
        } else {
            presentViewInvalidUrl()
        }
    }
}

