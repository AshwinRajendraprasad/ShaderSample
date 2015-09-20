//
//  Utility.m
//  GLES2Sample
//
//  Created by Mamunul on 9/19/15.
//
//

#import "Utility.h"

@implementation Utility


+(UIImage *) imageFromCVImageBufferRef:(CVImageBufferRef)imageBuffer{
	
	/*Lock the image buffer*/
//	CVPixelBufferLockBaseAddress(imageBuffer,0);
	/*Get information about the image*/
	uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
	size_t width = CVPixelBufferGetWidth(imageBuffer);
	size_t height = CVPixelBufferGetHeight(imageBuffer);
	
	/*We unlock the  image buffer*/
//	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	/*Create a CGImageRef from the CVImageBufferRef*/
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGImageRef newImage = CGBitmapContextCreateImage(newContext);
	
	/*We release some components*/
	CGContextRelease(newContext);
	CGColorSpaceRelease(colorSpace);
	
	/*We display the result on the custom layer*/
	/*self.customLayer.contents = (id) newImage;*/
	
	/*We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly)*/
	UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
	
	
	/*We relase the CGImageRef*/
	CGImageRelease(newImage);
	
	return image;
	
}


+(UIImage *)getBlurImage:(UIImage *)image
{
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:
						@"inputImage", [[CIImage alloc] initWithImage:image],
						@"inputRadius", [NSNumber numberWithFloat:6.0f],
						nil];
	
	CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
	CIImage *result = [filter valueForKey:kCIOutputImageKey];
	CGImageRef processedCgImage = [context createCGImage:result fromRect:[[CIImage alloc] initWithImage:image].extent];
	UIImage *img = [[UIImage alloc] initWithCGImage:processedCgImage];
	CGImageRelease(processedCgImage);
	return img;
}
@end
