

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

-(bool) LoadShader: (NSString*) shaderFile;
-(void) DestroyShader;
-(GLint) validateProgram:(GLuint )prog;
-(void)loadTexture;
-(void)loadUniforms;

@end

