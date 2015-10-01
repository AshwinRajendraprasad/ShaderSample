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
#import "ShaderProperties.h"


@interface ShaderRenderer : NSObject
{
	
	
@private
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
//	GLShader *shaders;
	BOOL isOnScreenRender;
	
	NSArray * shaderList;
	
}

@property(readwrite) int width;
@property(readwrite) int height;
@property(readwrite,retain,nonatomic) CAEAGLLayer *renderedLayer;

- (void)renderWithTextures:(NSArray *) shaderArray;

- (id) initWithShader:(NSArray *) shaderList  onScreen:(BOOL)isOnScreen2;
-(UIImage *)getRenderedImage;

@end

