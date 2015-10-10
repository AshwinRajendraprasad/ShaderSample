#import "ShaderRenderer.h"
#import "GLShader.h"

@interface ShaderRenderer ()
{
	
	GLuint renderFrameBuffer[2];
	
	EAGLContext *context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	//	GLShader *shaders;
	BOOL isOnScreenRender;
	
	NSArray * shaderList;
	
	GLuint textureId[2] ;
	
	GLvoid *pixels ;
	
	GLKMatrix4 m ;
}
@end

@implementation ShaderRenderer

@synthesize width,height,renderedLayer;

// Create an ES 2.0 context
- (id) initWithShader:(NSArray *) shaderArray onScreen:(BOOL)isOnScreen2
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		shaderList = shaderArray;
		
		if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShader])
		{
			[self release];
			return nil;
		}
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		
		
		//		glGenTextures(1, &textureId);
		textureId[0] = 13;
		textureId[1] = 14;
		
		glGenFramebuffers(2, renderFrameBuffer);
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
	}
	
	isOnScreenRender=isOnScreen2;
	
	
	return self;
}



-(void)genFrameBuffer:(GLuint) frameBuffer ToRenderInTex:(GLuint) texture{
	
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	glBindTexture(GL_TEXTURE_2D, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_BGRA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
}


- (void)renderWithTextures:(NSArray *) shaderArray
{
	
	shaderList = shaderArray;
	
	[EAGLContext setCurrentContext:context];
	m = GLKMatrix4Identity;
	GLKMatrix4 contentModeTransform = GLKMatrix4MakeOrtho(-1.f, 1.f, -1.f, 1.f, -1.f, 1.f);
	GLKMatrix4 contentTransform = GLKMatrix4Multiply(GLKMatrix4MakeScale(-1, 1, 1), GLKMatrix4MakeRotation(-M_PI_2, 0, 0, 1));
	for (int i = 0; i<[shaderList count];i++) {
		int fr = i%2;
//		ShaderProperties *shaderProperties = [shaderList objectAtIndex:i];
		//		UIImage *img;
		
		GLShader *shader = [shaderList objectAtIndex:i];
		
		int prev = (fr+1)%2;
		if([shaderList count] > 1 && i != 0){
			[shader loadTextureFromFrameBuffer:renderFrameBuffer[prev] Tex:textureId[prev] Width:width Height:height];
		}else{
			//			NSLog(@"load texture from image");
			[shader loadTexture];
		}
		
		if(i != [shaderList count] -1 ||([shaderList count] == 1 && !isOnScreenRender)){
			//			glClear(GL_COLOR_BUFFER_BIT);
			
			
			
			[self genFrameBuffer:renderFrameBuffer[fr] ToRenderInTex:textureId[fr]];
			
			[self renderOnFrameBuffer:renderFrameBuffer[fr] WithShader:shader];
			m = GLKMatrix4Multiply(contentModeTransform, contentTransform);
		}else{
			
			
			
			[self renderOnLayer:shader];
			
		}
		
	}
	
}

-(void)renderOnFrameBuffer:(GLint) frameBuffer WithShader:(GLShader *)shader{
	
	
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	
//	GLShader *shader = [shaderProperties shader];
	
	[self configRenderBufferFromFrameBuffer:frameBuffer];
	
	glViewport(0, 0, backingWidth, backingHeight);
	
	
	glUseProgram(shader.prog);
	
	[shader loadUniformsWithTransform:m];
	
	for (int i = 0; i<[shader.textureArray count]; i++) {
		GLTexture *texture = [shader.textureArray objectAtIndex:i];
		
		glActiveTexture (GL_TEXTURE0+i);
		glBindTexture (GL_TEXTURE_2D, texture.textureId);
		glUniform1i (texture.textureLocation, i);
		
	}
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glFinish ();
	
//	UIImage *img = [self getRenderedImageFromFrameBuffer:frameBuffer];
	
	NSLog(@"");
	
}

-(void)renderOnLayer:(GLShader *)shader{
	
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
//	GLShader *shader = [shaderProperties shader];
	
	[self configRenderBufferFromLayer];
	
	glViewport(0, 0, backingWidth, backingHeight);
	
	
	glUseProgram(shader.prog);
	
	[shader loadUniformsWithTransform:m];
	
	for (int i = 0; i<[shader.textureArray count]; i++) {
		GLTexture *texture = [shader.textureArray objectAtIndex:i];
		
		glActiveTexture (GL_TEXTURE0+i);
		glBindTexture (GL_TEXTURE_2D, texture.textureId);
		glUniform1i (texture.textureLocation, i);
		
	}
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glFinish ();
	
	[context presentRenderbuffer:GL_RENDERBUFFER];
	
}


-(UIImage *)getRenderedImageFromFrameBuffer:(GLint) frameBuffer{
	
	size_t size = backingWidth * backingHeight * 4;
	
	pixels = malloc(size);
	//	NSLog(@"t9.2");
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	//	NSLog(@"t9.3");
	glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	UIImage *image = [Utility ImageFromPixel:pixels width:backingWidth height:backingHeight orientation:UIImageOrientationDown];
	//		free (pixels);
	return image;
}



- (BOOL)loadShader{
	
	
	for (GLShader *shader in shaderList) {
//		GLShader *shader  = [shaderProperties shader];
		
		// create shader program
		if (![shader compileShader])
		{
			return NO;
		}
		
		[shader loadTexture];
		
		[shader loadUniformsWithTransform:m];
		
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


- (BOOL) configRenderBufferFromFrameBuffer:(GLint) frameBuffer
{
	
	backingWidth = width;
	backingHeight = height;
	
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, backingWidth, backingHeight);
	
	//	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	//	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		return NO;
	}
	
	return YES;
}

-(void)setRenderedLayer:(CAEAGLLayer *)renderedLayer2{
	
	
	renderedLayer = renderedLayer2;
	
	[self configRenderBufferFromLayer];
	
}

-(void) configRenderBufferFromLayer{
	//	backingWidth = width;
	//	backingHeight = height;
	
	[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:renderedLayer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		//		return NO;
	}
	
}

- (void) dealloc
{
	// tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	
	if (renderFrameBuffer)
	{
		glDeleteFramebuffers(2, renderFrameBuffer);
		renderFrameBuffer[0] = 0;
		renderFrameBuffer[1] = 0;
	}
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	for (GLShader *shader in shaderList) {
		[shader destroyShader];
	}
	
	// tear down context
	if ([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
