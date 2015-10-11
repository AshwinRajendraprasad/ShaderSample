#import <UIKit/UIKit.h>

@class EAGLView;

@interface GLES2SampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet EAGLView *glView;

@end

