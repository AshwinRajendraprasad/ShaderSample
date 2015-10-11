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
#import <GLKit/GLKit.h>

@interface GLUniform : NSObject

enum UniformDataType{


	Point_Type,
	Float_Type,
	Matrix4_Type,

};


@property(readwrite) GLint uniformId;
@property(readwrite) GLint uniformLocation;
@property(readwrite,copy) NSString *uniformName;

@property(readwrite,strong) NSObject *uniformData;

@property(readwrite) enum UniformDataType uniformDataType;

-(void)loadUniform;
@end
