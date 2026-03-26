import Flutter
import UIKit

#if !targetEnvironment(simulator)
import ICNFCCardReader
#endif

#if !targetEnvironment(simulator)
@main
@objc class AppDelegate: FlutterAppDelegate, ICMainNFCReaderDelegate {
    
    var flutterResult: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let nfcChannel = FlutterMethodChannel(name: "vnpt_nfc_channel", binaryMessenger: controller.binaryMessenger)
        
        nfcChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "startMRZNFC" {
                self.flutterResult = result
                
                var accessToken: String? = nil
                var tokenId: String? = nil
                var tokenKey: String? = nil
                
                if let args = call.arguments as? [String: Any] {
                    accessToken = args["accessToken"] as? String
                    tokenId = args["tokenId"] as? String
                    tokenKey = args["tokenKey"] as? String
                }
                
                self.startMRZ_NFC(accessToken: accessToken, tokenId: tokenId, tokenKey: tokenKey)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Khởi tạo luồng quét MRZ -> NFC (v2.2.6 API)
    private func startMRZ_NFC(accessToken: String?, tokenId: String?, tokenKey: String?) {
        if #available(iOS 13.0, *) {
            let objICMainNFCReader = ICMainNFCReaderRouter.createModule() as! ICMainNFCReaderViewController
            
            // Delegate
            objICMainNFCReader.icMainNFCDelegate = self
            
            // Ngôn ngữ — v2.2.6 mặc định "icnfc_vi"
            objICMainNFCReader.languageSdk = "icnfc_vi"
            
            // Hướng dẫn
            objICMainNFCReader.isShowTutorial = true
            objICMainNFCReader.isEnableGotIt = true
            
            // Luồng MRZ → NFC (v2.2.6: readerCardMode, enum ReaderCardMode)
            // QRCode=0, MRZCode=1, NFCReader=2, NFCOutside=3
            objICMainNFCReader.readerCardMode = MRZCode
            
            // Token xác thực (v2.2.6: trực tiếp trên ViewController)
            if let token = accessToken, !token.isEmpty {
                objICMainNFCReader.accessToken = token
            }
            if let tid = tokenId, !tid.isEmpty {
                objICMainNFCReader.tokenId = tid
            }
            if let tkey = tokenKey, !tkey.isEmpty {
                objICMainNFCReader.tokenKey = tkey
            }
            
            // Video hướng dẫn
            objICMainNFCReader.nameVideoHelpNFC = ""
            
            objICMainNFCReader.modalPresentationStyle = .fullScreen
            objICMainNFCReader.modalTransitionStyle = .coverVertical
            
            let controller = window?.rootViewController
            controller?.present(objICMainNFCReader, animated: true, completion: nil)
        } else {
            self.flutterResult?(FlutterError(code: "UNAVAILABLE", message: "iOS 13+ is required for NFC", details: nil))
        }
    }
    
    // MARK: - ICMainNFCReaderDelegate (v2.2.6)
    
    func icNFCMainDismissed(_ lastStep: ICNFCLastStep) {
        print("SDK đóng tại bước: \(lastStep.rawValue)")
        self.flutterResult?(nil)
    }
    
    func icNFCCardReaderGetResult() {
        let dataNFC = ICNFCSaveData.shared().dataNFCResult
        
        print("dataNFCResult = \(dataNFC)")
        
        if let data = dataNFC as? [String: Any] {
            self.flutterResult?(data)
        } else {
            self.flutterResult?(["rawData": "\(dataNFC)"])
        }
    }
}

#else
// MARK: - Simulator build (mock data)
@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var flutterResult: FlutterResult?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let nfcChannel = FlutterMethodChannel(name: "vnpt_nfc_channel", binaryMessenger: controller.binaryMessenger)
        
        nfcChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "startMRZNFC" {
                self.flutterResult = result
                self.startMockNFC()
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func startMockNFC() {
        let mockData: [String: Any] = [
            "fullName": "NGUYỄN VĂN A",
            "documentNumber": "001099012345",
            "dateOfBirth": "01/01/1990",
            "gender": "Nam",
            "nationality": "Việt Nam",
            "placeOfOrigin": "TP Hồ Chí Minh",
            "placeOfResidence": "123 Nguyễn Huệ, Quận 1, TP Hồ Chí Minh",
            "personalNumber": "001099012345",
            "issueDate": "01/01/2024",
            "expiryDate": "01/01/2034",
            "issuingAuthority": "Cục Cảnh sát QLHC về TTXH"
        ]
        self.flutterResult?(mockData)
    }
}
#endif
