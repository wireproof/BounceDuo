#import <UIKit/UIKit.h>

// Godot 4.3 initializes its engine and view controller in AppDelegate. Adopt
// that existing window into the UIKit scene instead of creating another engine.
@interface BounceSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property(nonatomic, strong) UIWindow *window;
@end
@implementation BounceSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
    self.window = delegate.window;
    NSAssert(self.window != nil, @"Godot did not initialize its window");
    self.window.windowScene = (UIWindowScene *)scene;
    self.window.frame = ((UIWindowScene *)scene).coordinateSpace.bounds;
    [self.window makeKeyAndVisible];
    NSLog(@"Bounce: Godot window connected to UIKit scene");
}
- (void)windowScene:(UIWindowScene *)scene didUpdateCoordinateSpace:(id<UICoordinateSpace>)previousCoordinateSpace interfaceOrientation:(UIInterfaceOrientation)previousInterfaceOrientation traitCollection:(UITraitCollection *)previousTraitCollection {
    self.window.frame = scene.coordinateSpace.bounds;
    [self.window.rootViewController.view setNeedsLayout];
}
- (void)sceneDidBecomeActive:(UIScene *)scene {
    id<UIApplicationDelegate> d = UIApplication.sharedApplication.delegate;
    if ([d respondsToSelector:@selector(applicationDidBecomeActive:)]) [d applicationDidBecomeActive:UIApplication.sharedApplication];
}
- (void)sceneWillResignActive:(UIScene *)scene {
    id<UIApplicationDelegate> d = UIApplication.sharedApplication.delegate;
    if ([d respondsToSelector:@selector(applicationWillResignActive:)]) [d applicationWillResignActive:UIApplication.sharedApplication];
}
- (void)sceneDidEnterBackground:(UIScene *)scene {
    id<UIApplicationDelegate> d = UIApplication.sharedApplication.delegate;
    if ([d respondsToSelector:@selector(applicationDidEnterBackground:)]) [d applicationDidEnterBackground:UIApplication.sharedApplication];
}
- (void)sceneWillEnterForeground:(UIScene *)scene {
    id<UIApplicationDelegate> d = UIApplication.sharedApplication.delegate;
    if ([d respondsToSelector:@selector(applicationWillEnterForeground:)]) [d applicationWillEnterForeground:UIApplication.sharedApplication];
}
@end
