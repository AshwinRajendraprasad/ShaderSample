//
//  GLUniform.h
//  ShaderSample
//
//  Created by Mamunul on 9/29/15.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLUniform : NSObject


@property(readwrite) GLint uniformId;
@property(readwrite) GLint uniformLocation;
@property(readwrite,copy) NSString *uniformName;

@property(readwrite,copy) NSObject *uniformData;



-(void)loadUniform;
@end
