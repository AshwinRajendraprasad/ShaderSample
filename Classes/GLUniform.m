//
//  GLUniform.m
//  ShaderSample
//
//  Created by Mamunul on 9/29/15.
//
//

#import "GLUniform.h"


@implementation GLUniform
@synthesize uniformName,uniformId,uniformLocation,uniformData,uniformDataType;

-(void)loadUniform{

	
	switch (uniformDataType) {
		case Float_Type:
			glUniform1f(uniformLocation, [(NSNumber *)uniformData floatValue]);
			break;
			
		case Point_Type:{
			CGPoint direction = [(NSValue *)uniformData CGPointValue];
			glUniform2f(uniformLocation, direction.x, direction.y);
		}
			break;
			
		case Matrix4_Type:{
			 GLKMatrix4 mt = [((GLKEffectPropertyTransform *)uniformData) projectionMatrix];

			
			glUniformMatrix4fv(uniformLocation,  1, GL_FALSE, mt.m);
		}
			break;
			
		default:
			break;
	}
	
	
	
}

@end
