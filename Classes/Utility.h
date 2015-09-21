//
//  Utility.h
//  GLES2Sample
//
//  Created by Mamunul on 9/19/15.
//
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+(UIImage *) imageFromCVImageBufferRef:(CVImageBufferRef)imageBuffer;
+(UIImage *)getBlurImage:(UIImage *)image;
+(UIImage *) ImageFromPixel:(void *)data width:(GLint)width height:(GLint)height orientation:(UIImageOrientation)orientation;
@end
