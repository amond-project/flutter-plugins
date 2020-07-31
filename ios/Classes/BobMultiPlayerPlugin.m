#import "BobMultiPlayerPlugin.h"
#if __has_include(<bob_multi_player/bob_multi_player-Swift.h>)
#import <bob_multi_player/bob_multi_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bob_multi_player-Swift.h"
#endif

@implementation BobMultiPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBobMultiPlayerPlugin registerWithRegistrar:registrar];
}
@end
