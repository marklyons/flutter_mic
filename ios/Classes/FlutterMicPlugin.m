#import "FlutterMicPlugin.h"
#import <flutter_mic/flutter_mic-Swift.h>

@implementation FlutterMicPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMicPlugin registerWithRegistrar:registrar];
}
@end
