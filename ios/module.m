#import "RNNaverLogin-Bridging-Header.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(IosNaverLogin, NSObject)

@end

// todo remove

@interface RCT_EXTERN_MODULE(NotificationModule, RCTEventEmitter)
RCT_EXTERN_METHOD(
				  showLocalNotification: (NSString)title
				  text: (NSString)text
				  )
RCT_EXTERN_METHOD(
				  reserveAlarm: (int)hour
				  minute: (int)minute
				  week: (int)week
				  )
RCT_EXTERN_METHOD(
				  getPendingTappedNotificationUrl: (RCTPromiseResolveBlock)resolve
				  reject: (RCTPromiseRejectBlock)reject
				  )
RCT_EXTERN_METHOD(
				  removeAllPendingAlarm
				  )
RCT_EXTERN_METHOD(
				  removeAllTodayPendingRepeatedAlarm
				  )
@end

@interface RCT_EXTERN_MODULE(ReviewPromptModule, NSObject)
RCT_EXTERN_METHOD(prompt)
@end

@interface RCT_EXTERN_MODULE(OrientationModule, NSObject)
RCT_EXTERN_METHOD(unlock)
RCT_EXTERN_METHOD(lock: (NSString) orientation)
RCT_EXTERN_METHOD(rotate: (NSString) orientation)
@end

@interface RCT_EXTERN_MODULE(SafeAreaModule, RCTEventEmitter)
RCT_EXTERN_METHOD(
				  getSafeAreaInsets: (RCTPromiseResolveBlock)resolve
				  reject: (RCTPromiseRejectBlock)reject
				  )
@end

@interface RCT_EXTERN_MODULE(KakaoModule, NSObject)
RCT_EXTERN_METHOD(
				  shareFriendInvite: (int)templateId
				  params: (NSDictionary *)params
				  resolve: (RCTPromiseResolveBlock)resolve
				  reject: (RCTPromiseRejectBlock)reject
				  )
@end

@interface RCT_EXTERN_MODULE(SketchViewManager, RCTViewManager)
//RCT_EXPORT_VIEW_PROPERTY(textProp, NSString)

RCT_EXTERN_METHOD(clear: (nonnull NSNumber *)node)
RCT_EXTERN_METHOD(undo: (nonnull NSNumber *)node)
RCT_EXTERN_METHOD(redo: (nonnull NSNumber *)node)
RCT_EXTERN_METHOD(open: (nonnull NSNumber *)node)
RCT_EXTERN_METHOD(close: (nonnull NSNumber *)node)
@end

@interface RCT_EXTERN_MODULE(AirbridgeModule, NSObject)
RCT_EXTERN_METHOD(
				  sendCustomEvent: (NSString)name
				  properties: (NSDictionary *)properties
				  )
RCT_EXTERN_METHOD(
				  addStringUserProperty: (NSString)key
				  value: (NSString)value
				  )
RCT_EXTERN_METHOD(
				  addNumberUserProperty: (NSString)key
				  value: (double)value
				  )
RCT_EXTERN_METHOD(
				  removeUserProperty: (NSString)key
				  )
RCT_EXTERN_METHOD(
				  onSignIn: (NSString)loginType
				  userId: (int)userId
				  )
RCT_EXTERN_METHOD(
				  onSignUp: (NSString)loginType
				  userId: (int)userId
				  )
RCT_EXTERN_METHOD(
				  getDeviceUUID: (RCTPromiseResolveBlock)resolve
				  reject: (RCTPromiseRejectBlock)reject
				  )
@end

