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
#import "ES2Renderer.h"
#import "EAGLView.h"
#import "Utility.h"

@interface ViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

{


	IBOutlet UIView *glkView;
	
	id <ESRenderer> renderer;

}

@end
