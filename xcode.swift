import UIKit
import WebKit
import Foundation
import SystemConfiguration

class ViewController: UIViewController{
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.uiDelegate = self
        webViewInit()
    }
    
    
    
    //인터넷 연결 안되어있으면 오류 표시
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard Reachability.networkConnected() else {
            let alert = UIAlertController(title: "네트워크 오류", message: "인터넷에 연결되어있지 않습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "종료", style: .default) { (action) in
                exit(0)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
    }
    
    //웹뷰 로드
    func webViewInit(){
        
        WKWebsiteDataStore.default().removeData(ofTypes:
                                                    [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0)) {
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        if let url = URL(string: "https://example.com) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
    }
    
    
    //인터넷 연결 체크
    class Reachability {
        
        class func networkConnected() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            let isRachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let neddsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            
            
            return (isRachable && !neddsConnection)
        }
        
    }
    
}

//JS alert + confirm
extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
