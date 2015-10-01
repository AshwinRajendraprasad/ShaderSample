#import "ShaderRenderer.h"
#import "GLShader.h"

@interface ShaderRenderer ()
{
	
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
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
		
	}
	
	isOnScreenRender=isOnScreen2;
	
	
	return self;
}

- (void)renderWithTextures:(NSArray *) shaderArray
{
	
	shaderList = shaderArray;

	[EAGLContext setCurrentContext:context];
	
	for (int i = 0; i<[shaderList count];i++) {
		
		ShaderProperties *shaderProperties = [shaderList objectAtIndex:i];
		UIImage *img;
		
		GLShader *shader = [shaderProperties shader];
		
		
		if([shaderList count] > 1 && i != 0){
			[shader loadTextureFromFrameBuffer:defaultFramebuffer Width:width Height:height];
		}else{
			//			NSLog(@"load texture from image");
			[shader loadTexture];
		}
		
		if(i != [shaderList count] -1 ||([shaderList count] == 1 && !isOnScreenRender)){
			
			[self renderOnFrameBuffer:shaderProperties];
			
		}else{
			
			[self renderOnLayer:shaderProperties];
			
		}
		
		
	}
	
	//	NSLog(@"finish rendering");
	
}

-(void)renderOnFrameBuffer:(ShaderProperties *)shaderProperties{
	
	
	GLShader *shader = [shaderProperties shader];
	
	[self configRenderBufferFromFrameBuffer];

	glViewport(0, 0, backingWidth, backingHeight);
	
	glUseProgram(shader.prog);
	
	[shader loadUniforms];
	
	for (int i = 0; i<[shader.textureArray count]; i++) {
		GLTexture *texture = [shader.textureArray objectAtIndex:i];
		
		glActiveTexture (GL_TEXTURE0+i);
		glBindTexture (GL_TEXTURE_2D, texture.textureId);
		glUniform1i (texture.textureLocation, i);
		
	}
	
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glFinish ();
	
	UIImage *img = [self getRenderedImage];
	
	NSLog(@"");
	
}

-(void)renderOnLayer:(ShaderProperties *)shaderProperties{
	
	
	GLShader *shader = [shaderProperties shader];
	
	[self configRenderBufferFromLayer];
	
	glViewport(0, 0, backingWidth, backingHeight);
	
	
	glUseProgram(shader.prog);
	
	[shader loadUniforms];
	
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


-(UIImage *)getRenderedImage{
	
	size_t size = backingWidth * backingHeight * 4;
	GLvoid *pixels = malloc(size);
	//	NSLog(@"t9.2");
	glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
	//	NSLog(@"t9.3");
	glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	UIImage *image = [Utility ImageFromPixel:pixels width:backingWidth height:backingHeight orientation:UIImageOrientationDown];
	
	
	//	free(pixels);
	return image;
}



- (BOOL)loadShader{
	
	
	for (ShaderProperties *shaderProperties in shaderList) {
		GLShader *shader  = [shaderProperties shader];
		
		// create shader program
		if (![shader compileShader:shaderProperties.fileName])
		{
			return NO;
		}
		
		[shader loadTexture];
		
		[shader loadUniforms];
		
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


- (BOOL) configRenderBufferFromFrameBuffer
{
	
	
	
	backingWidth = width;
	backingHeight = height;
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, backingWidth, backingHeight);
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
	
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
	
	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	
	for (ShaderProperties *shaderProperties in shaderList) {
		[shaderProperties.shader destroyShader];
	}
	
	// tear down context
	if ([EAGLContext currentContext] == context)
		[EAGLContext setCurrentContext:nil];
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
