//
//  ShaderProperties.h
//  ShaderSample
//
//  Created by Mamunul on 9/30/15.
//
//

#import <Foundation/Foundation.h>
#import "GLShader.h"

@interface ShaderProperties : NSObject

@property(readwrite,copy) NSString *fileName;
@property(readwrite,retain,nonatomic) NSArray *textureArray;
@property(readwrite,retain,nonatomic) NSArray *uniformArray;
@property(readwrite,retain) GLShader *shader;

@end
