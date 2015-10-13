//
//  GLTexture.m
//  ShaderSample
//
//  Created by Mamunul on 9/29/15.
//
//

#import "GLTexture.h"

@implementation GLTexture

@synthesize textureType,textureName,textureLocation,textureId,textureImage,textureImageBuffer;

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
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	CGContextRelease(cgcontext);
	
	free(imageData);
	//	[image release];
	glBindTexture(GL_TEXTURE_2D, 0);
}


-(void)loadTexture{
	
	
	if (textureType == Image && textureImage != NULL) {
		[self LoadTexture:textureId Image:textureImage];
	}else if(textureType == CVImageBuffer && textureImageBuffer != NULL){
		
		[self LoadTexture:textureId ImageBuffer:textureImageBuffer];
		
	}else if(textureType == FrameBuffer){
		
		
		//		[self LoadTextureFromFrameBuffer: AndColorBuffer: Width: Height:];
	}
	
}

-(void)loadTextureFromFrameBuffer:(GLint) frameBuffer Width:(int) width Height:(int) height{
	

	glBindTexture(GL_TEXTURE_2D, textureId);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureId, 0);
	glBindTexture(GL_TEXTURE_2D, 0);

	
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
		
		NSLog(@"Loading frame buffer to texture error");
	
	}
}

-(void) LoadTexture: (GLint) texID ImageBuffer:(CVImageBufferRef ) pixelBuffer
{
	
//	size_t width = CVPixelBufferGetWidth(pixelBuffer);
//	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	glBindTexture (GL_TEXTURE_2D, texID);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
	int frameHeight = CVPixelBufferGetHeight(pixelBuffer);
	

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)bytesPerRow / 4, (GLsizei)frameHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(pixelBuffer));
	
	glBindTexture(GL_TEXTURE_2D, 0);
	
}
@end
