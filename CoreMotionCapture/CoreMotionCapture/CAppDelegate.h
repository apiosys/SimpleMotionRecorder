#import <UIKit/UIKit.h>

@class CMMotionManager;
@class CLLocationManager;

@interface CAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CMMotionManager *sharedMotionManager;
@property (strong, nonatomic, readonly) CLLocationManager *sharedLocationManger;

@end
