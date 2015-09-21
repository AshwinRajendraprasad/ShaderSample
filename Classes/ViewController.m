//
//  ViewController.m
//  GLES2Sample
//
//  Created by Mamunul on 9/19/15.
//
//

#import "ViewController.h"


@interface ViewController (){

	NSString *_sessionPreset;
	
	AVCaptureSession *_session;
	CVImageBufferRef pixelBuffer2;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// meshFactor controls the ending ripple mesh size.
		// For example mesh width = screenWidth / meshFactor.
		// It's chosen based on both screen resolution and device size.
		
		
		// Choosing bigger preset for bigger screen.
		_sessionPreset = AVCaptureSessionPreset1280x720;
	}
	else
	{
		
		_sessionPreset = AVCaptureSessionPresetPhoto;
	}
	
	[self setupAVCapture];
	
	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	
	NSData *texData2 = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oil" ofType:@"jpg"]];
	UIImage *image2 = [[UIImage alloc] initWithData:texData2];
	
	NSArray *textureArray = [NSArray arrayWithObjects:image,image2, nil];
	
	NSArray *shaderArray = [NSArray arrayWithObjects:@"horzBlurShader",@"horzBlurShader",nil];
	
	renderer = [[ShaderRenderer alloc] initWithShader:shaderArray onScreen:YES textures:Nil Attributes:Nil];
	
	renderer.width = 640;
	renderer.height = 852;
	
	((EAGLView *)glkView).renderer = renderer;
	

}

- (void)setupAVCapture
{
	
	//-- Setup Capture Session.
	_session = [[AVCaptureSession alloc] init];
	[_session beginConfiguration];
	
	//-- Set preset session size.
	[_session setSessionPreset:_sessionPreset];
	
	//-- Creata a video device and input from that Device.  Add the input to the capture session.
	AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(videoDevice == nil)
		assert(0);
	
	//-- Add the device to the session.
	NSError *error;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	if(error)
		assert(0);
	
	[_session addInput:input];
	
	//-- Create the output for the capture session.
	AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
	[dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
	
	//-- Set to YUV420.
	[dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
															 forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview
	
	// Set dispatch to be on the main thread so OpenGL can do things with the data
	[dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	
	[_session addOutput:dataOutput];
	[_session commitConfiguration];
	
	
	
	[_session startRunning];
	
	
	
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
	
	CVImageBufferRef pixelBuffer;
	pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

	CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	
	size_t width = CVPixelBufferGetWidth(pixelBuffer);
	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	
//	UIImage *image = [Utility imageFromCVImageBufferRef:pixelBuffer];

	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	
//		UIImage *image = [UIImage imageNamed:@"image.jpg"];
	
//	UIImage *image2 = [Utility getBlurImage:image];
	
	
	NSMutableDictionary *uniforms = [[NSMutableDictionary alloc] init];
	
	float blurRadius = 10.0;
	
	CGPoint cgpoint = CGPointMake(1.0, 0.0);
	
	[uniforms setValue:[NSString stringWithFormat:@"%zu",width] forKey:@"width"];
	[uniforms setValue:[NSString stringWithFormat:@"%zu",height] forKey:@"height"];
	[uniforms setValue:[NSString stringWithFormat:@"%f",blurRadius] forKey:@"radius"];
    [uniforms setValue:[NSValue valueWithCGPoint:cgpoint] forKey:@"dir"];
	
	
	struct TextureInput texureInput;
	
	texureInput.pixelBuffer = pixelBuffer;
	
	texureInput.image = image;
	
	[renderer renderWithTextures:texureInput Uniforms:uniforms];
	
	UIImage *img = [renderer getRenderedImage];

	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	
	[texData release];
	
	
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
