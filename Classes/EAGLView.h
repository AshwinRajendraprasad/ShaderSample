#import <UIKit/UIKit.h>
#import "ShaderRenderer.h"


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
//	ShaderRenderer  *renderer;

//	id displayLink;
}


@property(readwrite,retain) ShaderRenderer *renderer;

@property(readwrite) struct TextureInput texureInput;

- (void) drawView:(id)sender;

@end
