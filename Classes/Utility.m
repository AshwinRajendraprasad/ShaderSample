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
 void myProviderReleaseData (void *info,const void *data,size_t size)
{
	free((void*)data);
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

+(UIImage *) ImageFromPixel:(void *)data width:(GLint)width height:(GLint)height orientation:(UIImageOrientation)orientation{

	size_t size = width * height * 4;

	size_t bitsPerComponent         = 8;
	size_t bitsPerPixel             = 32;
	size_t bytesPerRow              = width * bitsPerPixel / bitsPerComponent;
	
	CGColorSpaceRef colorspace      = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo         =  kCGBitmapByteOrderDefault;
	CGDataProviderRef provider      = CGDataProviderCreateWithData(NULL, data, size, NULL);
	
	CGImageRef newImageRef = CGImageCreate (
											width,
											height,
											bitsPerComponent,
											bitsPerPixel,
											bytesPerRow,
											colorspace,
											bitmapInfo,
											provider,
											NULL,
											false,
											kCGRenderingIntentDefault
											);

	CGContextRef context = CGBitmapContextCreate(data,width,height,bitsPerComponent,bytesPerRow,colorspace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGContextDrawImage(context, CGRectMake(0,0,width,height),newImageRef);
	UIImage *newImage2 = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
	
	free(data);
	CGContextRelease(context);
	CGColorSpaceRelease(colorspace);
	CGDataProviderRelease(provider);
	CGImageRelease(newImageRef);
	
	
	return newImage2;

}


@end
