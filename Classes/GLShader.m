#import "GLShader.h"


const char* kShaderAttribNames[kAttrCount] = {
	"a_position",
	"a_texCoord",
};


@implementation GLShader

@synthesize vertShader,fragShader,prog;




/* Create and compile a shader from the provided source(s) */
-(GLint) compileShader: (GLint *)shader  type:(GLenum) type defines:( const char*) defines file:(NSString *)file
{
	GLint status;
	
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return NO;
	}
	
    *shader = glCreateShader(type);				// create shader
    glShaderSource(*shader, 1, &source, NULL);	// set source code in the shader
    glCompileShader(*shader);					// compile shader
	
#if defined(DEBUG)
	GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE)
	{
		NSLog(@"Failed to compile shader:\n");
		NSLog(@"%s", source);
	}
	
	return status;
}


//-(bool) LoadShader: (NSString*) file cc:(struct Shader* )oshader;


-(bool) LoadShader: (NSArray*) shaderFileList
{
	prog = vertShader = fragShader = 0;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	NSString *file = [shaderFileList objectAtIndex:0];
	
	
	prog = glCreateProgram();
	
		vertShaderPathname = [[NSBundle mainBundle] pathForResource:file ofType:@"vsh"];

	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER defines:"#define VERTEX\n" file:vertShaderPathname]) {
		
		[self DestroyShader];
		return false;
	}
		fragShaderPathname = [[NSBundle mainBundle] pathForResource:file ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER defines:"#define FRAGMENT\n" file:fragShaderPathname]) {
			[self DestroyShader];
		return false;
	}
	
	// attach vertex shader to program
	glAttachShader(prog, vertShader);
	
	// attach fragment shader to program
	glAttachShader(prog, fragShader);
	
	for (int i = 0; i < kAttrCount; ++i)
		glBindAttribLocation (prog, i, kShaderAttribNames[i]);
	
	glLinkProgram(prog);
	
#if defined(DEBUG)
	GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
	GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
		NSLog(@"Failed to link program %d", prog);
	
	return true;
}


//-(GLint) validateProgram:(GLuint )prog;
-(void) DestroyShader
{
	if (vertShader) {
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
		glDeleteShader(fragShader);
		fragShader = 0;
	}
	if (prog) {
		glDeleteProgram(prog);
		prog = 0;
	}
}

/* Validate a program (for i.e. inconsistent samplers) */
-(GLint) validateProgram:(GLuint )prog2
{
	GLint logLength, status;
	
	glValidateProgram(prog2);
    glGetProgramiv(prog2, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog2, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog2, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE)
		NSLog(@"Failed to validate program %d", prog2);
	
	return status;
}
@end