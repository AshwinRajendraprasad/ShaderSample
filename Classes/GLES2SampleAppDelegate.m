#import "GLES2SampleAppDelegate.h"
#import "EAGLView.h"

@implementation GLES2SampleAppDelegate

@synthesize window;
@synthesize glView;

- (void) applicationDidFinishLaunching:(UIApplication *)application
{
	
}

- (void) applicationWillResignActive:(UIApplication *)application
{

}

- (void) applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{
	
}

- (void) dealloc
{
	[window release];
	[glView release];
	
	[super dealloc];
}

@end
