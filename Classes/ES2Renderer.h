//#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include "Shaders.h"
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Utility.h"

struct TextureInput{

	CVImageBufferRef pixelBuffer;
	UIImage *image;
	


};

@protocol ESRenderer <NSObject>

- (void)renderWithTextures:(struct TextureInput) textureInput;
- (BOOL)resizeFromLayer:(CAEAGLLayer*)layer;

@end

@interface ES2Renderer : NSObject<ESRenderer>
{
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	/* the shader program object */
//	struct ShaderProperties program;
	
	GLfloat rotz;
	
	Shaders *shaders;
	
}

- (void)renderWithTextures:(struct TextureInput) textureInput;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (id <ESRenderer>) initWithShader:(NSString *) shader textures:(NSArray *) texures Attributes:(NSArray *) attrib;

@end

