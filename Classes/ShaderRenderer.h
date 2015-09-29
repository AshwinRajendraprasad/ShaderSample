//#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include "GLShader.h"
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Utility.h"
#import "GLTexture.h"
struct TextureInput{

	CVImageBufferRef pixelBuffer;
	UIImage *image;
	CAEAGLLayer *renderedLayer;


};

@interface ShaderRenderer : NSObject
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
	
	GLShader *shaders;
	BOOL isOnScreenRender;
	CAEAGLLayer *renderedLayer;
	
}

@property(readwrite) int width;
@property(readwrite) int height;

- (void)renderWithTextures:(NSArray *) textures Uniforms:(NSArray *) uniforms;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (id) initWithShader:(NSArray *) shaderList  onScreen:(BOOL)isOnScreen2 textures:(NSArray *) texures Uniforms:(NSArray *) uniforms;
-(UIImage *)getRenderedImage;

@end

