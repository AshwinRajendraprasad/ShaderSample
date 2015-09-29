//
//  GLTexture.h
//  ShaderSample
//
//  Created by Mamunul on 9/29/15.
//
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

enum TexureType{


	Image,
	CVImageBuffer

};

@interface GLTexture : NSObject
{


}

@property(readwrite) GLint textureId;
@property(readwrite) GLint textureLocation;
@property(readwrite,copy) NSString *textureName;
@property(readwrite) enum TexureType textureType;
@property(readwrite,copy) UIImage *textureImage;
@property(readwrite) CVImageBufferRef textureImageBuffer;

-(void)loadTexture;

@end
