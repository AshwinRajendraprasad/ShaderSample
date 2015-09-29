//
//  GLUniform.m
//  ShaderSample
//
//  Created by Mamunul on 9/29/15.
//
//

#import "GLUniform.h"

@implementation GLUniform
@synthesize uniformName,uniformId,uniformLocation,uniformData;

-(void)loadUniform{
	
	
	if ([uniformData isKindOfClass:[NSValue class]]) {
		
		
		
		if([uniformData isKindOfClass:[NSNumber class]]){
			
			
			glUniform1f(uniformLocation, [(NSNumber *)uniformData floatValue]);
			
		}else{
			CGPoint direction = [(NSValue *)uniformData CGPointValue];
			glUniform2f(uniformLocation, direction.x, direction.y);
			
		}
		
	}
	
	
	
}

@end
