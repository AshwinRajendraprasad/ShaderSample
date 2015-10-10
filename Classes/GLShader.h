

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
@property(readwrite,copy) NSString *fragmentShaderFileName;
@property(readwrite,copy) NSString *vertexShaderFileName;

-(bool) compileShader;
-(void) destroyShader;
-(GLint) validateProgram:(GLuint )prog;
-(void)loadTexture;
-(void)loadUniformsWithTransform:(GLKMatrix4) mat;
//-(void)loadTextureFromFrameBuffer:(GLint) framebuffer Width:(int)width Height:(int)height;
-(void)loadTextureFromFrameBuffer:(GLint) framebuffer Tex:(GLuint) texId Width:(int)width Height:(int)height;

@end

