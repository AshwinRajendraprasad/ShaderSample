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

@interface ShaderRenderer (PrivateMethods)
//- (BOOL)loadShader:(NSString *) shader WithTextures:(NSArray *) textures Attributes:(NSArray *) attributes;
@end

@implementation ShaderRenderer

@synthesize width,height;

// Create an ES 2.0 context
- (id) initWithShader:(NSArray *) shaderList onScreen:(BOOL)isOnScreen2 textures:(NSArray *) texures Attributes:(NSArray *) attrib
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		shaders  = [[GLShader alloc] init];
		if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShader:shaderList WithTextures:texures Uniforms:Nil])
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
		isOnScreen=isOnScreen2;
	}
	
	return self;
}

- (void)renderWithTextures:(struct TextureInput) textureInput Uniforms:(NSDictionary *) uniforms
{
	
	
	
	[EAGLContext setCurrentContext:context];
	
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glViewport(0, 0, backingWidth, backingHeight);
	
	glClearColor(0.5f, 0.4f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glUseProgram(shaders.prog);
	
	[self loadTextureOnRender:textureInput];
	
	[self loadAttributesOnRender:uniforms];
	
	
	glActiveTexture (GL_TEXTURE0);
	glBindTexture (GL_TEXTURE_2D, 1);
	glUniform1i (g_Uniforms[kUniformTexColor], 0);
	glActiveTexture (GL_TEXTURE1);
	glBindTexture (GL_TEXTURE_2D, 2);
	glUniform1i (g_Uniforms[kUniformTexNormal], 1);
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	glFinish ();
	
	
	
	
	if(isOnScreen)
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
-(void) LoadTexture:(GLint) texID FromFrameBuffer:(GLint) frameBuffer AndColorBuffer:(GLint) colorRenderBuffer{


	// Offscreen position framebuffer object

	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	

	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
	
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, backingWidth, backingHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
	
	// Offscreen position framebuffer texture target

	glBindTexture(GL_TEXTURE_2D, colorRenderBuffer);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, backingWidth, backingHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorRenderBuffer, 0);



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


- (BOOL)loadShader:(NSArray *) shaderList WithTextures:(NSArray *) textures Uniforms:(NSDictionary *) uniforms {
	
	
	
	
	// create shader program
	if (![shaders LoadShader:shaderList])
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
	
	int i = 1;
	for (UIImage *image in imageArray) {
		[self LoadTexture:i Image:image];
		i++;
	}
	
	
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


-(void)loadAttributesOnRender:(NSDictionary *) uniforms{
	
	
	NSValue *dir = [uniforms objectForKey:@"dir"];
	
	CGPoint direction = [dir CGPointValue];
	

	glUniform1f(g_Uniforms[kUniformWidth], [[uniforms objectForKey:@"width"] floatValue]);
	glUniform1f(g_Uniforms[kUniformHeight], [[uniforms objectForKey:@"height"] floatValue]);
	glUniform1f(g_Uniforms[kUniformRadius], [[uniforms objectForKey:@"radius"] floatValue]);

	glUniform2f(g_Uniforms[kUniformDir], direction.x, direction.y);
}



- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	if(isOnScreen)
		[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
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
