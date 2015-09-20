#ifndef SHADERS_H
#define SHADERS_H

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

enum ShaderAttrib {
	kAttrPosition = 0,
	kAttrUV,
	kAttrCount
};


@interface Shaders : NSObject
{



}


@property(readonly) GLint vertShader;
@property(readonly) GLint fragShader;
@property(readonly) GLint prog;

-(bool) LoadShader: (NSString*) file;
-(void) DestroyShader;
-(GLint) validateProgram:(GLuint )prog;


@end

#endif
