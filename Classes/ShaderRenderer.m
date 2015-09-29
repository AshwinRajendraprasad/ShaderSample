#import "ShaderRenderer.h"
#import "GLShader.h"

// ---- profiler bits


enum {
	kUniformTexColor,
	kUniformTexNormal,
	kUniformHeight,
	kUniformWidth,
	kUniformRadius,
	kUniformDir,
	kUniformCount
};
static const char* kUniformNames[kUniformCount] = {
	"s_texture",
	"s_overlay",
	"height",
	"width",
	"radius",
	"dir",
};
static GLint g_Uniforms[kUniformCount];



@interface ShaderRenderer ()
//- (BOOL)loadShader:(NSString *) shader WithTextures:(NSArray *) textures Attributes:(NSArray *) attributes;
{
//	GLint textureUniforms[2];
//	
//	NSArray *textureNames;


}
@end

@implementation ShaderRenderer

@synthesize width,height;

// Create an ES 2.0 context
- (id) initWithShader:(NSArray *) shaderList onScreen:(BOOL)isOnScreen2 textures:(NSArray *) texures Uniforms:(NSArray *) uniforms
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShader:shaderList WithTextures:texures Uniforms:uniforms])
		{
			[self release];
			return nil;
		}
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
	}

	if([shaderList count ]>1)
		isOnScreenRender = NO;
	isOnScreenRender=isOnScreen2;


	
	return self;
}

- (void)renderWithTextures:(NSArray *) textures Uniforms:(NSArray *) uniforms
{
	
	
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glUseProgram(shaders.prog);
	
	shaders.textureArray = textures;
	
	[shaders loadTexture];
	
	[shaders setUniformArray:uniforms];

	[shaders loadUniforms];
	for (int i = 0; i<[shaders.textureArray count]; i++) {
		GLTexture *texture = [shaders.textureArray objectAtIndex:i];
		
		glActiveTexture (GL_TEXTURE0+i);
		glBindTexture (GL_TEXTURE_2D, texture.textureId);
		glUniform1i (texture.textureLocation, i);

	}

	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	glFinish ();
	
	
	
	
	if(isOnScreenRender)
	{
		[context presentRenderbuffer:GL_RENDERBUFFER];
	}
	
}

-(UIImage *)getRenderedImage{

	size_t size = backingWidth * backingHeight * 4;
	GLvoid *pixels = malloc(size);
	NSLog(@"t9.2");
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	NSLog(@"t9.3");
	glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	UIImage *image = [Utility ImageFromPixel:pixels width:backingWidth height:backingHeight orientation:UIImageOrientationDown];
	
	return image;
}



- (BOOL)loadShader:(NSArray *) shaderList WithTextures:(NSArray *) textures Uniforms:(NSArray *) uniforms {
	
	
	for (NSString *shader in shaderList) {
		shaders  = [[GLShader alloc] init];
		[shaders setTextureArray:textures];
		
		[shaders setUniformArray:uniforms];
		
		// create shader program
		if (![shaders LoadShader:shader])
		{
			return NO;
		}
		
		[shaders loadTexture];
		
		[shaders loadUniforms];
	
		[self loadAttributesOnInitialization];
		
	}
	
	
	
	
	return YES;
}





-(void) loadAttributesOnInitialization{
	
	static const GLfloat squareVertices[] = {
		-1.0f, -1.0f,
		1.0f, -1.0f,
		-1.0f,  1.0f,
		1.0f,  1.0f,
	};
	
	static const GLfloat textureVertices[] = {
		1.0f, 1.0f,
		1.0f, 0.0f,
		0.0f,  1.0f,
		0.0f,  0.0f,
	};
	
	glEnableVertexAttribArray(kAttrPosition);
	glVertexAttribPointer(kAttrPosition, 2, GL_FLOAT, 0, 0, squareVertices);
	
	glEnableVertexAttribArray(kAttrUV);
	glVertexAttribPointer(kAttrUV, 2, GL_FLOAT, 0, 0, textureVertices);
	
}


//-(void)loadUniformsOnRender:(NSDictionary *) uniforms{
//	
//	
//	NSValue *dir = [uniforms objectForKey:@"dir"];
//	
//	CGPoint direction = [dir CGPointValue];
//	
//
//	glUniform1f(g_Uniforms[kUniformWidth], [[uniforms objectForKey:@"width"] floatValue]);
//	glUniform1f(g_Uniforms[kUniformHeight], [[uniforms objectForKey:@"height"] floatValue]);
//	glUniform1f(g_Uniforms[kUniformRadius], [[uniforms objectForKey:@"radius"] floatValue]);
//
//	glUniform2f(g_Uniforms[kUniformDir], direction.x, direction.y);
//}



- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
	
	if (layer != Nil) {
		renderedLayer = layer;
	}
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	if(isOnScreenRender)
		[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:renderedLayer];
	else{
		backingWidth = width;
		backingHeight = height;
		glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, backingWidth, backingHeight);
	}
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}
	
	return YES;
}

- (void) dealloc
{
	// tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	
	[shaders DestroyShader];
	
	// tear down context
	if ([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
