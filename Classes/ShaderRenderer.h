//#import "ESRenderer.h"

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include "GLShader.h"
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Utility.h"
#import "GLTexture.h"



@protocol ShaderRendererDelegate <NSObject>

-(void)renderedImage:(UIImage *)image;

@end


@interface ShaderRenderer : NSObject
{


	
}

@property(readwrite) int width;
@property(readwrite) int height;
@property(readwrite,strong,nonatomic) CAEAGLLayer *renderedLayer;
@property(weak,readwrite) id<ShaderRendererDelegate> delegate;

- (void)renderWithTextures:(NSArray *) shaderArray;

- (id) initWithShader:(NSArray *) shaderList  onScreen:(BOOL)isOnScreen2;
-(UIImage *)getRenderedImage;

@end

