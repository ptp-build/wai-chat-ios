import UIKit
import WebKit
import MobileCoreServices
import UniformTypeIdentifiers

protocol SendMessageDelegate{
    func sendWord(message : String)
}

extension WaiIndexController:VideoRecordViewControllerDelegate,ScanViewControllerDelegate, WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler,UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    func setVideoRecordResult(message: String) {
        print(message)
    }
    
    func setScanResult(message: String) {
        print(message)
    }
    func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
        let params = message.body
        
        if(message.name == "startRecord"){
            RecordManager.shareManager.getInstance().beginRecord{(averagePower,peakPower,lowPass) in
                print("\(averagePower ?? 0) \(peakPower ?? 0) \(lowPass ?? 0)")
                self.webView.evaluateJavaScript(
                    "BDIosCallBack('onGetVolumn',{averagePower:\(averagePower ?? 0.0),peakPower:\(peakPower ?? 0.0),lowPass:\(lowPass ?? 0.0)},{})"
                )
            }
        }
        
        if(message.name == "stopRecord"){
            RecordManager.shareManager.getInstance()
                .stopRecord()
                .fetchResult{(duration,base64Data) in
                    self.webView.evaluateJavaScript(
                        "BDIosCallBack('onGetVolumn',{duration:\(duration ?? 0.0),base64Data:\(base64Data ?? "")},{})"
                    )
                }
        }
     
        if(message.name == "showProgressBar"){
            self.removeSpinner(onView: self.view)
        }
        if(message.name == "authorizeCameraWith"){
            LBXPermissions.authorizeCameraWith{(authorized) in
                self.webView.evaluateJavaScript(
                    "BDIosCallBack('onGetPermission',{Camera:\(authorized)},{})"
                )
            }
        }
        
        if(message.name == "authorizePhotoWith"){
            LBXPermissions.authorizePhotoWith{(authorized) in
                self.webView.evaluateJavaScript(
                    "BDIosCallBack('onGetPermission',{Photo:\(authorized)},{})"
                )
            }
        }
        
        if(message.name == "jumpToSystemPrivacySetting"){
            LBXPermissions.jumpToSystemPrivacySetting()
        }
    
        if(message.name == "openQrScanner"){
            let sc = ScanViewController();
            sc.delegateCb = self
            navigationController?.pushViewController(sc, animated: true)
        }
        
        if(message.name == "openVideoRecorder"){
            let vc = VideoRecordViewController();
            vc.delegateCb = self
            navigationController?.pushViewController(vc, animated: true)
        }
        
        if(message.name == "getMyLocation"){
            LocationManager.shareManager.creatLocationManager().startLocation{(location, adress, error) in
                if(error != nil){
                    self.webView.evaluateJavaScript("BDIosCallBack('getMyLocation',null,{message:'err'})")
                }else{
                    self.webView.evaluateJavaScript("BDIosCallBack('getMyLocation',{lat:\(location?.coordinate.latitude ?? 0.0),lng:\(location?.coordinate.longitude ?? 0.0)},{})")
                }
            }
        }
        
        if(message.name == "openImageGallery"){
            let p =  params as! [String: Any]
            getImageGo(type: p["type"] as! Int)
        }
        if message.name == "logging" {
            print("Log: \(message.body)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let b64Data = image?.toBase64(addMimePrefix:true) ?? ""
        let width = image?.getWidth()
        let height = image?.getHeight()
        self.webView.evaluateJavaScript(String(format: "BDIosCallBack('onUploadResponse',{widht:%d,height:%d,b64Data:\"%@\"},{})",
                                               width!,height!, b64Data))
        //截图
        //image.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        takingPicture.dismiss(animated: true, completion: nil)
    }
    func getImageGo(type:Int){
        takingPicture =  UIImagePickerController.init()
        if(type==1){
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                let alertController = UIAlertController(title: nil, message: "Device has no camera.", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "Alright", style: .default, handler: { (alert: UIAlertAction!) in
                })

                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                takingPicture.sourceType = .camera
            }
            //takingPicture.showsCameraControls = true
        }else if(type==2){
            takingPicture.sourceType = .photoLibrary
        }
        takingPicture.delegate = self
        //是否截取，设置为true在获取图片后可以将其截取成正方形
        takingPicture.allowsEditing = false
        present(takingPicture, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
             let host = url.host else {
           decisionHandler(.allow)
           return
       }
       
       let path = url.path
        
        if host.contains("bot-api.wai.chat"), path.starts(with: "/m/") {
           if !(path.starts(with: "/m/img-apple-") ) && !(path.starts(with: "/m/ios") ) {
                let filePath = Bundle.main.path(forResource: "wai" + path, ofType: nil)
                let mimeType = getMimeType(url: url)
                if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!)) {
                    _ = URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: "utf-8")
                    decisionHandler(.cancel)
                    webView.load(data, mimeType: mimeType, characterEncodingName: "utf-8", baseURL: url)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
        
    func getMimeType(url: URL) -> String {
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        return "application/octet-stream"
    }
}


class WaiIndexController: BaseController {
    
    var takingPicture:UIImagePickerController!

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        navigationItem.title = ""
    }
    var request: URLRequest!
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self

        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self;
        webView.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1.0)
        webView.isOpaque = false
        
        let overrideConsole = """
            function IAppIoslog(type, args) {
              window.webkit.messageHandlers.logging.postMessage(
                `JS ${type}: ${Object.values(args)
                  .map(v => typeof(v) === "undefined" ? "undefined" : typeof(v) === "object" ? JSON.stringify(v) : v.toString())
                  .map(v => v.substring(0, 3000)) // Limit msg to 3000 chars
                  .join(", ")}`
              )
            }
            let originalLog = console.log
            let originalWarn = console.warn
            let originalError = console.error
            let originalDebug = console.debug

            console.log   = function() { IAppIoslog( "log", arguments); originalLog.apply(null, arguments) }
            console.warn  = function() { IAppIoslog( "warning", arguments); originalWarn.apply(null, arguments) }
            console.error = function() { IAppIoslog( "error", arguments); originalError.apply(null, arguments) }
            console.debug = function() { IAppIoslog( "debug", arguments); originalDebug.apply(null, arguments) }
        """
        let script = WKUserScript(source: overrideConsole, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        
        webView.configuration.userContentController.add(self, name: "logging")
        webView.configuration.userContentController.add(self, name: "startRecord")
        webView.configuration.userContentController.add(self, name: "stopRecord")
        webView.configuration.userContentController.add(self, name: "showProgressBar")
        webView.configuration.userContentController.add(self, name: "openQrScanner")
        webView.configuration.userContentController.add(self, name: "openImageGallery")
        webView.configuration.userContentController.add(self, name: "getMyLocation")
        webView.configuration.userContentController.add(self, name: "jumpToSystemPrivacySetting")
        webView.configuration.userContentController.add(self, name: "authorizeCameraWith")
        webView.configuration.userContentController.add(self, name: "authorizePhotoWith")

        webView.configuration.userContentController.add(self, name: "openVideoRecorder")
        
        return webView
    }()
   
    
    // 构造器
    convenience init(url: String?) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        showSpinner(onView: self.view)
        
        guard let filePath = Bundle.main.path(forResource: "version", ofType: "txt", inDirectory: "Assets/wai/m"),
            let version = try? String(contentsOfFile: filePath, encoding: .utf8).trimmingCharacters(in: .newlines) else {
             // Handle the case where the file path is nil or version cannot be obtained
            return
        }
        let theme = "light" // Provide the desired theme value

        guard let indexURL = URL(string: "https://wai.chat/?v=\(version)&theme=\(theme)") else {
         // Handle the case where the URL is invalid
         return
        }

        request = URLRequest(url: indexURL)
        webView.load(request)
    }
    
    override func setupLayout() {
        view.addSubview(webView)
        webView.snp.makeConstraints{ $0.edges.equalTo(self.view.usnp.edges) }
      
    }
   
    @objc func reload() {
        webView.reload()
    }
    
    override func pressBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
