import Foundation
import NaverThirdPartyLogin

@objc(RNNaverLogin)
class RNNaverLogin: NSObject {
	private var connection: NaverThirdPartyLoginConnection {
		get {
			return NaverThirdPartyLoginConnection.getSharedInstance()
		}
	}
	
	private var promiseResolver: RCTPromiseResolveBlock? = nil
	
	@objc
	static func requiresMainQueueSetup() -> Bool{
		return false;
	}
	
	@objc
	func login(_ serviceUrlScheme: String, consumerKey: String, consumerSecret: String,
			   appName: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
		DispatchQueue.main.async { [unowned self] in
			promiseResolver = resolve
			
			connection.serviceUrlScheme = serviceUrlScheme
			connection.consumerKey = consumerKey
			connection.consumerSecret = consumerSecret
			connection.appName = appName
			
			connection.delegate = self
			connection.requestThirdPartyLogin()
		}
	}
	
	@objc
	func logout(_ resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
		DispatchQueue.main.async { [unowned self] in
			
		}
	}
}

extension RNNaverLogin: NaverThirdPartyLoginConnectionDelegate {
	func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFinishAuthorizationWithResult receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
		
		promiseResolver = nil
	}
	
	func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailAuthorizationWithReceive receiveType: THIRDPARTYLOGIN_RECEIVE_TYPE) {
		guard let resolver = promiseResolver else { return }
		let isCancel = receiveType == THIRDPARTYLOGIN_RECEIVE_TYPE(rawValue: 2)
		
		let response: [String: Any] = [
			"isSuccess": false,
			"errorResponse": {
				isCancel
			}
		]
		resolver(response)
		promiseResolver = nil
	}
	
	
	// 로그인에 성공했을 경우 호출
	func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
	}
	
	// 접근 토큰 갱신
	func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
		
	}
	
	// 로그아웃 할 경우 호출(토큰 삭제)
	func oauth20ConnectionDidFinishDeleteToken() {
	}
	
	// 모든 Error
	func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
	}
}
