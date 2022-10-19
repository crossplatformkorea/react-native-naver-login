import Foundation
import NaverThirdPartyLogin

@objc(IosNaverLogin)
class IosNaverLogin: NSObject {
	private let connection: NaverThirdPartyLoginConnection {
		get {
			return NaverThirdPartyLoginConnection.getSharedInstance()
		}
	}
	
	@objc
	static func requiresMainQueueSetup() -> Bool{
		return false;
	}
	
	@objc(multiply:withB:withResolver:withRejecter:)
	func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
		resolve(a*b)
	}
	
	
	@objc
	func login(_ serviceUrlScheme: String, consumerKey: String, consumerSecret: String,
			   appName: String, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock){
		DispatchQueue.main.async {
			NaverThirdPatyLoginConnection.
		}
	}
	
	@objc
	func logout(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
		DispatchQueue.main.async {
			
		}
	}
}
