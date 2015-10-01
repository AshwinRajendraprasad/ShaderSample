//
//  ShaderProperties.m
//  ShaderSample
//
//  Created by Mamunul on 9/30/15.
//
//

#import "ShaderProperties.h"

@implementation ShaderProperties
@synthesize uniformArray,fileName,textureArray,shader;


 -(void)setTextureArray:(NSArray *)textureArray2{

	
	 textureArray = textureArray2;

	 
	 shader.textureArray = textureArray;


}

-(void)setUniformArray:(NSArray *)uniformArray2{


	uniformArray = uniformArray2;
	
	
	shader.uniformArray = uniformArray;


}

@end
