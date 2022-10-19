import Foundation

@objc(IosNaverLogin)
class IosNaverLogin: NSObject {
	
	@objc
	static func requiresMainQueueSetup() -> Bool{
		return false;
	}
	
	@objc(multiply:withB:withResolver:withRejecter:)
	func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
		resolve(a*b)
	}
}
