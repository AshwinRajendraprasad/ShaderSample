

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

enum ShaderAttrib {
	kAttrPosition = 0,
	kAttrUV,
	kAttrCount
};


@interface GLShader : NSObject
{

}


@property(readonly) GLint vertShader;
@property(readonly) GLint fragShader;
@property(readonly) GLint prog;

-(bool) LoadShader: (NSArray*) shaderFileList;
-(void) DestroyShader;
-(GLint) validateProgram:(GLuint )prog;


@end

