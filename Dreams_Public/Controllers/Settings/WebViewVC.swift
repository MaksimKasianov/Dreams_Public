//
//  WebViewVC.swift
//  Gia
//
//  Created by Kasianov on 13.12.2023.
//

import UIKit
import WebKit

class WebViewVC: UIViewController , WKNavigationDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()

    private let url: URL
    
    init(url: URL){
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
        configureButtons()

        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    private func configureButtons(){
        navigationItem.largeTitleDisplayMode = .never
//        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = .gray
//        navigationController?.navigationBar.standardAppearance = appearance
//
//        navigationController?.navigationBar.backgroundColor = UIColor(named: "green 0")
//        navigationController?.navigationBar.tintColor = UIColor(named: "white")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapDone))
    }

    @objc private func didTapDone(){
        dismiss(animated: true)
    }
}
