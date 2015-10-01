//
//  ViewController.h
//  GLES2Sample
//
//  Created by Mamunul on 9/19/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#import "ShaderRenderer.h"
#import "EAGLView.h"
#import "Utility.h"
#import "GLTexture.h"
#import "GLUniform.h"
#import "ShaderProperties.h"

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

{


	IBOutlet UIView *glkView;
	
	ShaderRenderer *renderer;
	NSArray *shaderArray;
}

@end
