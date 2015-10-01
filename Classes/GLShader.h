

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "GLTexture.h"
#import "GLUniform.h"

enum ShaderAttrib {
	kAttrPosition = 0,
	kAttrUV,
	kAttrCount
};


@interface GLShader : NSObject
{

}

@property(readonly) GLint prog;
@property(readwrite,copy) NSArray *textureArray;
@property(readwrite,copy) NSArray *uniformArray;

-(bool) compileShader: (NSString*) shaderFile;
-(void) destroyShader;
-(GLint) validateProgram:(GLuint )prog;
-(void)loadTexture;
-(void)loadUniforms;
-(void)loadTextureFromFrameBuffer:(GLint) framebuffer Width:(int)width Height:(int)height;

@end

