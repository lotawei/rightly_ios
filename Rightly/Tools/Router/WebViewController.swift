
import UIKit
import WebKit

/*
 Pass the changes in the WebController to the delegate.
 */
@objc public protocol WebControllerDelegate: class {
    
    /**
     Called when title changes.
     - Parameters:
        - webController: WebControllerDelegate The UIViewController invoking the delegate method.
        - didChangeTitle: The title to change.
     */
    @objc optional func webController(_ webController: WebController, didChangeTitle: String?)
    
    /**
     Called when url changes.
     - Parameters:
        - webController: WebControllerDelegate The UIViewController invoking the delegate method.
        - didChangeURL: The url to change.
     */
    @objc optional func webController(_ webController: WebController, didChangeURL: URL?)
    
    /**
     It is called when the load starts or ends.
     - Parameters:
        - webController: WebControllerDelegate The UIViewController invoking the delegate method.
        - didLoading: load starts or ends.
     */
    @objc optional func webController(_ webController: WebController, didLoading: Bool)
    
    /**
     Called when title changes.
     - Parameters:
        - webController: WebControllerDelegate The UIViewController invoking the delegate method.
        - title: will change based on the return value.
     - Returns: UINavigationTitle is changed. default is changed to title which is received as argument.
     */
    @objc optional func webController(_ webController: WebController, title: String?) -> String?
    
    /**
     Called Error.
     - Parameters:
        - webController: WebControllerDelegate The UIViewController invoking the delegate method.
        - error: Error
     */
    @objc optional func webController(_ webController: WebController, error: Error)
    
    /**
     It will be called when the site becomes an Alert.
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - alertController: This is an alert window that will appear on the screen.
     - didUrl: The website URL with the alert window.
     */
    @objc optional func webController(_ webController: WebController, alertController: UIAlertController, didUrl: URL?)
    
    /**
     If the website fails to load, the Alert is called.
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - alertController: This is an alert window that will appear on the screen.
     - didUrl: The website URL with the alert window.
     */
    @objc optional func webController(_ webController: WebController, failAlertController: UIAlertController, didUrl: URL?)
    
    /**
     If the scheme is not http or https, think of it as a deep link or universal link
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - openUrl: Url to use 'UIApplication.shared.openURL'.
     - Returns: Return true to use 'UIApplication.shared.openURL'. default is true.
     */
    @objc optional func webController(_ webController: WebController, openUrl: URL?) -> Bool
    
    /**
     Decides whether to allow or cancel a navigation.
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - navigationAction: Descriptive information about the action triggering the navigation request.
     - decisionHandler: The decision handler to call to allow or cancel the navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
     */
    @objc optional func webController(_ webController: WebController, navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void)
    
    /**
     Decides whether to allow or cancel a navigation after its response is known.
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - navigationResponse: Descriptive information about the navigation response.
     - decisionHandler: decisionHandler The decision handler to call to allow or cancel the navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
     */
    @objc optional func webController(_ webController: WebController, navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void)
    
    /**
     Invoked when the web view needs to respond to an authentication challenge.
     - Parameters:
     - webController: WebControllerDelegate The UIViewController invoking the delegate method.
     - challenge: The authentication challenge.
     - completionHandler: The completion handler you must invoke to respond to the challenge. The disposition argument is one of the constants of the enumerated type NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential, the credential argument is the credential to use, or nil to indicate continuing without a credential.
     */
    @objc optional func webController(_ webController: WebController, challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    
}

/*
 WebController Options
 */
public struct WebOptions {
    var strings = Strings()
    
    public struct Strings {
        var confirm = "Confirm"
        var cancel = "Cancel"
        var error = "Error"
    }
    
}

open class WebController: BaseViewController {
    
    // MARK: deinit
    
    deinit {
        self.webView.stopLoading()
        self.webView.uiDelegate = nil
        self.webView.navigationDelegate = nil
    }
    
    // MARK: delegate
    
    public weak var delegate: WebControllerDelegate?
    
    
    // MARK: Public Properties
    
    /**
     WebOptions
     */
    public var options = WebOptions()
    
    /**
     WKWebView
     */
    public let webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }()
    
    /**
     The UIProgressView that appears above the WebView when the site loads
     */
    public let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        return progressView
    }()
    
    /**
     The UIActivityIndicatorView that appears in the center of the webview when the site loads
     */
    public let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicatorView.color = UIColor.darkGray
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    /**
     A UIView that wraps around the bottom UIToolbar.
     */
    public let toolView: ToolView = {
        let view = ToolView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /**
     Paints the title color of the UINavigationBar.
     */
    public var titleTintColor: UIColor? {
        didSet {
            self.titleButton.setTitleColor(self.titleTintColor, for: .normal)
            self.navigationController?.navigationBar.tintColor = self.titleTintColor
        }
    }
    
    /**
     Paints the background color of the UINavigationBar.
     */
    public var barTintColor: UIColor? {
        didSet {
            self.navigationController?.navigationBar.barTintColor = self.barTintColor
            self.navigationController?.navigationBar.backgroundColor = self.barTintColor
        }
    }
    
    
    // MARK: Private Properties
    
    private var openLoadURL: URL?
    
    public let titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.sizeToFit()
        return button
    }()
    
    
    // MARK: Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTintColor = UIColor.black
        self.navigationItem.titleView = self.titleButton
        self.navigationController?.navigationBar.barTintColor = self.barTintColor
        self.navigationController?.navigationBar.backgroundColor = self.barTintColor
        self.navigationController?.navigationBar.tintColor = self.titleTintColor
        self.titleButton.setTitleColor(self.titleTintColor, for: .normal)
        
        if let host = self.webView.url?.host {
            if let title = self.delegate?.webController?(self, title: host) {
                self.titleButton.setTitle(title, for: .normal)
            }
            self.titleButton.sizeToFit()
        }
        if let t = self.title {
            self.titleButton.setTitle(t, for: .normal)
            self.titleButton.sizeToFit()
        }
        
        // Set up webView
        self.view.addSubview(self.webView)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: [], metrics: nil, views: ["webView": self.webView]))
        self.webView.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
//        // Set up toolView
//        self.view.addSubview(self.toolView)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolView]-0-|", options: [], metrics: nil, views: ["toolView": self.toolView]))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toolView]-0-|", options: [], metrics: nil, views: ["toolView": self.toolView]))
//
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[webView]-0-[toolView]|", options: [], metrics: nil, views: ["webView": self.webView, "toolView": self.toolView, "topGuide": self.topLayoutGuide]))
//
        // Set up indicatorView
        self.view.addSubview(self.indicatorView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[webView]-(<=1)-[indicatorView]", options:.alignAllCenterY, metrics: nil, views: ["webView": self.webView, "indicatorView": self.indicatorView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[webView]-(<=1)-[indicatorView]", options:.alignAllCenterX, metrics: nil, views: ["webView": self.webView, "indicatorView": self.indicatorView]))
        
        // Set up progressView
        self.view.addSubview(self.progressView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[progressView]-0-|", options: [], metrics: nil, views: ["progressView": self.progressView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide]-0-[progressView(2)]", options: [], metrics: nil, views: ["progressView": self.progressView, "topGuide": self.topLayoutGuide]))
        
        self.titleButton.addTarget(self, action: #selector(self.titleAction(_:)), for: .touchUpInside)
        self.toolView.delegate = self
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        
        self.toolView.initVars()
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.webView.stopLoading()
    }
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    private var urlObserver: NSKeyValueObservation?
    private var titleObserver: NSKeyValueObservation?
    private var loadingObserver: NSKeyValueObservation?

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !self.webView.canGoBack
        
        self.removeObserver()
        
        self.estimatedProgressObserver = self.webView.observe(\.estimatedProgress, options: [.new]) { [weak self] (object, change) in
            guard let self = self else { return }
            guard let newValue = change.newValue else { return }
            self.progressView.setProgress(Float(newValue), animated: false)
            if newValue == 1 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.progressView.alpha = 0
                }) { (_) in
                    self.progressView.setProgress(0, animated: false)
                }
            } else {
                self.progressView.alpha = 1
            }
        }
        
        self.urlObserver = self.webView.observe(\.url, options: [.new]) { [weak self] (object, change) in
            guard let self = self else { return }
            guard let host = self.webView.url?.host else { return }
            if let title = self.delegate?.webController?(self, title: host) {
                self.titleButton.setTitle(title, for: .normal)
            } else {
                self.titleButton.setTitle("\(host) ▾", for: .normal)
            }
            self.titleButton.sizeToFit()
            self.delegate?.webController?(self, didChangeURL: self.webView.url)
        }
        
        self.titleObserver = self.webView.observe(\.title, options: [.new]) { [weak self] (object, change) in
            guard let self = self else { return }
            self.delegate?.webController?(self, didChangeTitle: self.webView.title)
        }
        
        self.loadingObserver = self.webView.observe(\.isLoading, options: [.new]) { [weak self] (object, change) in
            guard let self = self else { return }
            guard let newValue = change.newValue else { return }
            self.delegate?.webController?(self, didLoading: !newValue)
            if newValue {
                self.indicatorView.isHidden = false
                self.indicatorView.startAnimating()
                self.toolView.loadDidStart()
            } else {
                self.indicatorView.isHidden = true
                self.indicatorView.stopAnimating()
                self.toolView.loadDidFinish()
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.removeObserver()
    }
    
    private func removeObserver() {
        if #available(iOS 11.0, *) {
            if let observer = self.estimatedProgressObserver {
                observer.invalidate()
                self.estimatedProgressObserver = nil
            }
            
            if let observer = self.urlObserver {
                observer.invalidate()
                self.urlObserver = nil
            }
            
            if let observer = self.titleObserver {
                observer.invalidate()
                self.titleObserver = nil
            }
            
            if let observer = self.loadingObserver {
                observer.invalidate()
                self.loadingObserver = nil
            }
        } else {
            if let observer = self.estimatedProgressObserver {
                observer.invalidate()
                self.webView.removeObserver(observer, forKeyPath: "estimatedProgress")
                self.estimatedProgressObserver = nil
            }
            
            if let observer = self.urlObserver {
                observer.invalidate()
                self.webView.removeObserver(observer, forKeyPath: "URL")
                self.urlObserver = nil
            }
            
            if let observer = self.titleObserver {
                observer.invalidate()
                self.webView.removeObserver(observer, forKeyPath: "title")
                self.titleObserver = nil
            }
            
            if let observer = self.loadingObserver {
                observer.invalidate()
                self.webView.removeObserver(observer, forKeyPath: "loading")
                self.loadingObserver = nil
            }
        }
    }
    
    
    // MARK: Public Method
    
    /**
     Navigates to a requested URL.
     - Parameters:
     - urlPath: Url to Load WebView
     - cachePolicy: cachePolicy The cache policy for the request. Defaults to `.useProtocolCachePolicy`
     - timeoutInterval: timeoutInterval The timeout interval for the request. Defaults to 0.0
     */
    public func load(_ urlPath: String?, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 0) {
        guard let urlPath = urlPath, let url = URL(string: urlPath) else { return }
        self.load(url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }
    
    /**
     Navigates to a requested URL.
     - Parameters:
     - url: Url to Load WebView
     - cachePolicy: cachePolicy The cache policy for the request. Defaults to `.useProtocolCachePolicy`
     - timeoutInterval: timeoutInterval The timeout interval for the request. Defaults to 0.0
     */
    public func load(_ url: URL?, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 0) {
        guard let url = url else { return }
        self.webView.load(URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval))
    }
    
    /**
     Evaluates the given JavaScript string.
     - Parameters:
     - javaScriptString: The JavaScript string to evaluate.
     - completionHandler: A block to invoke when script evaluation completes or fails.
     */
    public func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((Any?, Error?) -> Void)?) {
        self.webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    }
    
    
    // MARK: Private Method
    
    /**
     When you touch TitleView, a shared event that runs
     - Parameters:
     - sender: UIButton
     */
    @objc private func titleAction(_ sender: UIButton) {
        self.titleTap(sender)
    }

    open func titleTap(_ sender: UIButton) {
        guard let urlPath = self.webView.url?.absoluteString else { return }
        let activityViewController = UIActivityViewController(activityItems: [urlPath], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: ToolViewDelegate
extension WebController: ToolViewDelegate {
    
    var toolViewWebCanGoBack: Bool {
        return self.webView.canGoBack
    }
    
    var toolViewWebCanGoForward: Bool {
        return self.webView.canGoForward
    }
    
    func toolViewWebStopLoading() {
        self.webView.stopLoading()
    }
    
    func toolViewWebReload() {
        self.webView.reload()
    }
    
    func toolViewWebGoForward() {
        self.webView.goForward()
    }
    
    func toolViewWebGoBack() {
        self.webView.goBack()
    }
    
    func toolViewInteractivePopGestureRecognizerEnabled(_ isEnabled: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}

// MARK: WKNavigationDelegate
extension WebController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.toolView.loadDidStart()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.toolView.loadDidFinish()
        self.delegate?.webController?(self, error: error)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.toolView.loadDidFinish()
        if error._code == NSURLErrorCancelled { return }
        let alertController = UIAlertController(title: self.options.strings.error, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.options.strings.confirm, style: .default, handler: nil))
        guard self.delegate?.webController?(self, alertController: alertController, didUrl: webView.url) != nil else {
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard self.delegate?.webController?(self, navigationAction: navigationAction, decisionHandler: decisionHandler) != nil else {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
            if let scheme = url.scheme, !( scheme == "http" || scheme == "https") {
                self.openLoadURL = nil
                guard self.delegate?.webController?(self, openUrl: url) != nil else {
                    UIApplication.shared.openURL(url)
                    return
                }
            } else if url.absoluteString.contains("app.link") && self.openLoadURL == nil{
                self.openLoadURL = url
                self.load(url)
            } else {
                self.openLoadURL = nil
                if let currentURL = self.webView.url, url == currentURL {
                    return
                }
            }
            return
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard self.delegate?.webController?(self, navigationResponse: navigationResponse, decisionHandler: decisionHandler) != nil else {
            decisionHandler(.allow)
            return
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard self.delegate?.webController?(self, challenge: challenge, completionHandler: completionHandler) != nil else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
    }
}

// MARK: WKUIDelegate
extension WebController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.options.strings.confirm, style: .default, handler: {(action: UIAlertAction) -> Void in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: self.options.strings.cancel, style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler(false)
        }))
        guard self.delegate?.webController?(self, alertController: alertController, didUrl: webView.url) != nil else {
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController: UIAlertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: self.options.strings.confirm, style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler(alertController.textFields?.first?.text)
        }))
        guard self.delegate?.webController?(self, alertController: alertController, didUrl: webView.url) != nil else {
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: self.options.strings.confirm, style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler()
        }))
        guard self.delegate?.webController?(self, alertController: alertController, didUrl: webView.url) != nil else {
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }
}

import UIKit

/*
 A delegate that passes the state changes of the ToolView to the WebController.
 */
protocol ToolViewDelegate: class {
    
    /**
     Check if WebView can 'GoBack'.
     */
    var toolViewWebCanGoBack: Bool { get }
    
    /**
     Check if WebView can 'GoForward'.
     */
    var toolViewWebCanGoForward: Bool { get }
    
    /**
     Passes an event when 'Back UIBarButtonItem' is touched.
     */
    func toolViewWebGoBack()
    
    /**
     Passes an event when 'Forward UIBarButtonItem' is touched.
     */
    func toolViewWebGoForward()
    
    /**
     Passes an event when 'Reload UIBarButtonItem' is touched.
     */
    func toolViewWebReload()
    
    /**
     Passes an event when 'Stop UIBarButtonItem' is touched.
     */
    func toolViewWebStopLoading()
    
    /**
     Pass in the value of the state of InteractivePopGestureRecognizerd in UINavigation.
     - Parameters:
     - isEnabled: If true, BackSwipe of UINavigation is enabled.
     */
    func toolViewInteractivePopGestureRecognizerEnabled(_ isEnabled: Bool)
}

public class ToolView: UIView {
    
    // MARK: delegate
    
    weak var delegate: ToolViewDelegate?
    
    
    // MARK: Public Properties
    
    /**
     UIToolbar
     */
    public let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        return toolbar
    }()
    
    /**
     Paints the colors of the UIToolbar's items.
     */
    public var itemTintColor: UIColor? {
        didSet {
            self.changeItemTintColor()
        }
    }
    
    /**
     Paints the background color of the UIToolbar.
     */
    public var barTintColor: UIColor? {
        didSet {
            self.changeBarTintColor()
        }
    }
    
    /**
     Hide the ToolBar's Refresh UIBarButtonItem, Stop UIBarButtonItem.
     Default is false.
     */
    public var isHiddenRefresh: Bool = false {
        didSet {
            self.setHiddenRefresh()
        }
    }
    
    /**
     Hides the ToolBar at the bottom of the WebController.
     Default is false.
     */
    public var isHiddenToolBar: Bool = false {
        didSet {
            self.makeToolBar()
        }
    }
    
    
    // MARK: Private Properties
    
    private var toolViewHeightConstraint: NSLayoutConstraint?
    
    /**
     backBarButtonItem Private Properties
     Included in items in UIToolBar.
     */
    private var backBarButtonItem: UIBarButtonItem?
    
    /**
     forwardBarButtonItem Private Properties
     Included in items in UIToolBar.
     */
    private var forwardBarButtonItem: UIBarButtonItem?
    
    /**
     reloadBarButtonItem Private Properties
     Included in items in UIToolBar.
     */
    private lazy var reloadBarButtonItem: UIBarButtonItem? = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reload(_:)))
    
    /**
     stopBarButtonItem Private Properties
     Included in items in UIToolBar.
     */
    private lazy var stopBarButtonItem: UIBarButtonItem? = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.stop(_:)))
    
    
    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // MARK: Public Method
    
    /**
     Back to UIToolbar Change UIBarButtonitem to title.
     - Parameters:
     - title: Title of UIBarButtonitem
     */
    public func setBackBarButtonItem(_ title: String?) {
        self.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.goBack(_:)))
        self.backBarButtonItem?.tintColor = self.itemTintColor
    }
    
    /**
     Back to UIToolbar Change UIBarButtonitem to image.
     - Parameters:
     - image: Image of UIBarButtonitem
     */
    public func setBackBarButtonItem(_ image: UIImage?) {
        self.backBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.goBack(_:)))
        self.backBarButtonItem?.tintColor = self.itemTintColor
    }
    
    /**
     Forward to UIToolbar Change UIBarButtonitem to title.
     - Parameters:
     - title: Title of UIBarButtonitem
     */
    public func setForwardBarButtonItem(_ title: String?) {
        self.forwardBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.goForward(_:)))
        self.forwardBarButtonItem?.tintColor = self.itemTintColor
    }
    
    /**
     Forward to UIToolbar Change UIBarButtonitem to image.
     - Parameters:
     - image: Image of UIBarButtonitem
     */
    public func setForwardBarButtonItem(_ image: UIImage?) {
        self.forwardBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.goForward(_:)))
        self.forwardBarButtonItem?.tintColor = self.itemTintColor
    }
    
    
    // MARK: Internal Method
    
    /**
     Runs when the site is loaded.
     stopBarButtonItem appears.
     */
    func loadDidStart() {
        var items = self.historyBarButtonItem()
        if let stopBarButtonItem = self.stopBarButtonItem {
            items.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                stopBarButtonItem
                ])
        }
        self.toolbar.setItems(items, animated: false)
    }
    
    /**
     Run when the site is finished.
     refreshBarButtonItem appears.
     */
    func loadDidFinish() {
        var items = self.historyBarButtonItem()
        if let reloadBarButtonItem = self.reloadBarButtonItem {
            items.append(contentsOf: [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                reloadBarButtonItem
                ])
        }
        self.toolbar.setItems(items, animated: false)
    }
    
    func initVars() {
        let toolViewHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        toolViewHeightConstraint.priority = UILayoutPriority(500)
        self.addConstraint(toolViewHeightConstraint)
        self.makeToolBar()
        
        self.clipsToBounds = true
        self.toolbar.setItems(self.historyBarButtonItem(), animated: false)
        self.changeItemTintColor()
        self.changeBarTintColor()
        self.setHiddenRefresh()
    }
    
    
    // MARK: Private Method
    
    private func makeToolBar() {
        if self.isHiddenToolBar {
            self.removeConstraints(self.constraints.filter({ $0.firstAttribute != .height }))
            self.toolbar.removeFromSuperview()
        } else {
            if self.subviews.filter({ $0 == self.toolbar }).isEmpty {
                self.addSubview(self.toolbar)
                self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: [], metrics: nil, views: ["toolbar": toolbar]))
                var bottomConstant: CGFloat = 0
                if #available(iOS 11.0, *) {
                    bottomConstant = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                }
                let topConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: toolbar,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0)
                let bottomConstraint = NSLayoutConstraint(
                    item: self,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: toolbar,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: bottomConstant)
                self.addConstraints([topConstraint, bottomConstraint])
            }
        }
    }
    
    private func historyBarButtonItem() -> [UIBarButtonItem] {
        guard let canGoBack = self.delegate?.toolViewWebCanGoBack,
            let canGoForward = self.delegate?.toolViewWebCanGoForward
            else { return [UIBarButtonItem]() }
        
        self.backBarButtonItem?.isEnabled = canGoBack
        self.forwardBarButtonItem?.isEnabled = canGoForward
        self.delegate?.toolViewInteractivePopGestureRecognizerEnabled(!canGoBack)
        var items = [UIBarButtonItem]()
        if let barButtonItem = self.backBarButtonItem {
            items.append(barButtonItem)
        } else {
            let barButtonItem = UIBarButtonItem(title: "◀︎", style: .plain, target: self, action: #selector(self.goBack(_:)))
            barButtonItem.isEnabled = canGoBack
            items.append(barButtonItem)
            self.backBarButtonItem = barButtonItem
        }
        if let barButtonItem = self.forwardBarButtonItem {
            items.append(barButtonItem)
        } else {
            let barButtonItem = UIBarButtonItem(title: "▶︎", style: .plain, target: self, action: #selector(self.goForward(_:)))
            barButtonItem.isEnabled = canGoForward
            items.append(barButtonItem)
            self.forwardBarButtonItem = barButtonItem
        }
        return items
    }
    
    private func changeItemTintColor() {
        self.backBarButtonItem?.tintColor = self.itemTintColor
        self.forwardBarButtonItem?.tintColor = self.itemTintColor
        self.reloadBarButtonItem?.tintColor = self.itemTintColor
        self.stopBarButtonItem?.tintColor = self.itemTintColor
    }
    
    private func changeBarTintColor() {
        self.backgroundColor = self.barTintColor
        self.toolbar.barTintColor = self.barTintColor
    }
    
    private func setHiddenRefresh() {
        if self.isHiddenRefresh {
            self.reloadBarButtonItem = nil
            self.stopBarButtonItem = nil
        } else {
            self.reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reload(_:)))
            self.stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.stop(_:)))
            self.reloadBarButtonItem?.tintColor = self.itemTintColor
            self.stopBarButtonItem?.tintColor = self.itemTintColor
        }
    }
    
    @objc private func goBack(_ sender: UIBarButtonItem) {
        self.delegate?.toolViewWebGoBack()
    }
    
    @objc private func goForward(_ sender: UIBarButtonItem) {
        self.delegate?.toolViewWebGoForward()
    }
    
    @objc private func reload(_ sender: UIBarButtonItem) {
        self.delegate?.toolViewWebReload()
    }
    
    @objc private func stop(_ sender: UIBarButtonItem) {
        self.delegate?.toolViewWebStopLoading()
    }
}

