//
//  ImageViewController.h
//  ShaderSample
//
//  Created by Mamunul on 10/10/15.
//
//

#import <UIKit/UIKit.h>
#import "ShaderRenderer.h"
#import "EAGLView.h"
#import "Utility.h"
#import "GLTexture.h"
#import "GLUniform.h"
@interface ImageViewController : UIViewController<ShaderRendererDelegate>{


	IBOutlet UIImageView *imageView;

}

@end
