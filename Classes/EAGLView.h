#import <UIKit/UIKit.h>
#import "ES2Renderer.h"
//#import "ESRenderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
	id <ESRenderer> renderer;

	id displayLink;
}


@property(readwrite) id <ESRenderer> renderer;

@property(readwrite) struct TextureInput texureInput;

- (void) drawView:(id)sender;

@end
