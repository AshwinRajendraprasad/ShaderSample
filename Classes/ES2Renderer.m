#import "ES2Renderer.h"
#import "Shaders.h"

// ---- profiler bits


enum {
	kUniformTexColor,
	kUniformTexNormal,
	
	kUniformCount
};
static const char* kUniformNames[kUniformCount] = {
	"s_texture",
	"s_overlay",
};
static GLint g_Uniforms[kUniformCount];

@interface ES2Renderer (PrivateMethods)
- (BOOL)loadShader:(NSString *) shader WithTextures:(NSArray *) textures Attributes:(NSArray *) attributes;
@end

@implementation ES2Renderer

// Create an ES 2.0 context
- (id <ESRenderer>) initWithShader:(NSString *) shader textures:(NSArray *) texures Attributes:(NSArray *) attrib
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		shaders  = [[Shaders alloc] init];
		if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShader:shader WithTextures:texures Attributes:Nil])
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
	
	return self;
}

- (void)renderWithTextures:(struct TextureInput) textureInput
{
	
	
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glUseProgram(shaders.prog);
	
	[self loadTextureOnRender:textureInput];
	
	[self loadAttributesOnRender];
	
	
	glActiveTexture (GL_TEXTURE0);
	glBindTexture (GL_TEXTURE_2D, 1);
	glUniform1i (g_Uniforms[kUniformTexColor], 0);
	glActiveTexture (GL_TEXTURE1);
	glBindTexture (GL_TEXTURE_2D, 2);
	glUniform1i (g_Uniforms[kUniformTexNormal], 1);
	
	
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	glFinish ();
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	
	[context presentRenderbuffer:GL_RENDERBUFFER];
	
	
}

-(void) LoadTexture: (GLint) texID Image:(UIImage*) image
{
	
	if (image == nil)
		return;
	
	GLuint width = CGImageGetWidth(image.CGImage);
	GLuint height = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = malloc( height * width * 4 );
	CGContextRef cgcontext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGColorSpaceRelease( colorSpace );
	CGContextClearRect( cgcontext, CGRectMake( 0, 0, width, height ) );
	CGContextTranslateCTM( cgcontext, 0, height - height );
	CGContextDrawImage( cgcontext, CGRectMake( 0, 0, width, height ), image.CGImage );
	
	glBindTexture (GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_NEAREST_MIPMAP_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_NEAREST_MIPMAP_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	CGContextRelease(cgcontext);
	
	free(imageData);
	[image release];
	
}

-(void) LoadTexture: (GLint) texID ImageBuffer:(CVImageBufferRef ) pixelBuffer
{



	size_t width = CVPixelBufferGetWidth(pixelBuffer);
	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	glBindTexture (GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
	int frameHeight = CVPixelBufferGetHeight(pixelBuffer);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)bytesPerRow / 4, (GLsizei)frameHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));

	
}


- (BOOL)loadShader:(NSString *) shader WithTextures:(NSArray *) textures Attributes:(NSArray *) attributes {
	
	
	
	
	// create shader program
	if (![shaders LoadShader:@"shader"])
	{
		return NO;
	}
	
	// get uniform locations
	for (int i = 0; i < kUniformCount; ++i)
		g_Uniforms[i] = glGetUniformLocation(shaders.prog, kUniformNames[i]);
	
	// create textures
	
	[self loadTextureOnInitilization:textures];
	
	
	[self loadAttributesOnInitialization];
	
	
	
	return YES;
}

-(void) loadTextureOnInitilization:(NSArray *)imageArray{
	
//	int i = 1;
//	for (UIImage *image in imageArray) {
//		[self LoadTexture:i Image:image];
//		i++;
//	}
	
	
}

-(void) loadTextureOnRender:(struct TextureInput) textureInput{
	
	
	[self LoadTexture:1 ImageBuffer:textureInput.pixelBuffer];
	
//	UIImage *image2 = [Utility imageFromCVImageBufferRef:textureInput.pixelBuffer];
	
	

	[self LoadTexture:2 Image:textureInput.image];
	
	
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


-(void)loadAttributesOnRender{
	
	
}



- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
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
