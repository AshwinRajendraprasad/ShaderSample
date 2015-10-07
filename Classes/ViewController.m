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
	
	
	[self getShader];
	
	
	shaderArray = [self getShader];// [NSArray arrayWithObjects:@"horzBlurShader",@"shader",nil];
	
	renderer = [[ShaderRenderer alloc] initWithShader:shaderArray onScreen:YES];
	
	renderer.width = 640;
	renderer.height = 852;
	
	((EAGLView *)glkView).renderer = renderer;
	

}

-(NSArray *) getShader{
	
	
	NSArray *textureArray = [self getShader1Texures];
	
	NSArray *uniformArray = [self getShader1Uniforms:YES];
	
	
	ShaderProperties *shader1 = [[ShaderProperties alloc] init];
	
	shader1.shader = [[GLShader alloc] init];
	
	shader1.fileName = @"shader";
	shader1.textureArray = textureArray;
	shader1.uniformArray = uniformArray;
	
	NSArray *texture2Array = [self getShader2Texures];
	
	
	ShaderProperties *shader2 = [[ShaderProperties alloc] init];
	shader2.shader = [[GLShader alloc] init];
	shader2.fileName = @"horzBlurShader";
	shader2.textureArray = textureArray;
	shader2.uniformArray = uniformArray;
	
	NSArray *uniformArray2 = [self getShader1Uniforms:NO];
	
	ShaderProperties *shader3 = [[ShaderProperties alloc] init];
	shader3.shader = [[GLShader alloc] init];
	shader3.fileName = @"horzBlurShader";
	shader3.textureArray = texture2Array;
	shader3.uniformArray = uniformArray2;

	
	NSArray *array = [[NSArray alloc] initWithObjects:shader2,shader3,nil];
	
	return array;
	
}


-(NSArray *) getShader1Texures{
	
	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
	UIImage *image = [[UIImage alloc] initWithData:texData];
	NSData *texData2 = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oil" ofType:@"jpg"]];
	UIImage *image2 = [[UIImage alloc] initWithData:texData2];
	
	GLTexture *texture1 = [[GLTexture alloc] init];
	
	[texture1 setTextureName:@"s_overlay"];
	[texture1 setTextureId:1];
	[texture1 setTextureType:Image];
	[texture1 setTextureImage:image];
	
	
	
	GLTexture *texture2 = [[GLTexture alloc] init];
	
	[texture2 setTextureName:@"s_texture"];
	[texture2 setTextureId:2];
	[texture2 setTextureType:CVImageBuffer];
	//	[texture2 setTextureImage:image2];
	
	NSArray *array = [NSArray arrayWithObjects:texture1, texture2, nil];
	
	
	return array;
	
}

-(NSArray *) getShader2Texures{
	
	
	GLTexture *texture1 = [[GLTexture alloc] init];
	
	[texture1 setTextureName:@"s_texture"];
	[texture1 setTextureId:1];
	[texture1 setTextureType:FrameBuffer];

	
	NSArray *array = [NSArray arrayWithObjects:texture1, nil];
	
	
	return array;
	
}

-(NSArray *) getShader1Uniforms:(BOOL)isHblur{
	
	CGPoint cgpoint = CGPointMake(1.0, 0.0);
	float blurRadius = 6.0;
	
	if (isHblur) {
		
		
		cgpoint = CGPointMake(0.0, 1.0);
		
	}
	
	GLUniform *uniform1 = [[GLUniform alloc] init];
	
	[uniform1 setUniformName:@"width"];
	[uniform1 setUniformDataType:Float_Type];
	
	GLUniform *uniform2 = [[GLUniform alloc] init];
	
	[uniform2 setUniformName:@"height"];
	[uniform2 setUniformDataType:Float_Type];
	
	GLUniform *uniform3 = [[GLUniform alloc] init];
	
	[uniform3 setUniformName:@"radius"];
	[uniform3 setUniformData:[NSNumber numberWithFloat:blurRadius]];
	[uniform3 setUniformDataType:Float_Type];
	
	GLUniform *uniform4 = [[GLUniform alloc] init];
	
	[uniform4 setUniformName:@"dir"];
	
	
	[uniform4 setUniformData:[NSValue valueWithCGPoint:cgpoint]];
	[uniform4 setUniformDataType:Point_Type];
	
	GLUniform *uniform5 = [[GLUniform alloc] init];
	
	[uniform5 setUniformName:@"contentTransform"];

	[uniform5 setUniformDataType:Matrix4_Type];
	
	
	NSArray *array = [NSArray arrayWithObjects:uniform1, uniform2,uniform3,uniform4,uniform5, nil];
	
	
	return array;
	
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
	
	
	for (ShaderProperties *shaderProperties in shaderArray) {
		
		
		for (GLUniform *uni in shaderProperties.uniformArray) {
			
			
			if ([uni.uniformName isEqualToString:@"width"]) {
				[uni setUniformData:[NSNumber numberWithFloat:width]];
			}else if ([uni.uniformName isEqualToString:@"height"]){
				[uni setUniformData:[NSNumber numberWithFloat:height]];
				
			}
			
		}
		
		for (GLTexture *texture in shaderProperties.textureArray) {
			if(texture.textureType == CVImageBuffer)
				[texture setTextureImageBuffer:pixelBuffer];
		}
		
		
	}
	
	[renderer renderWithTextures:shaderArray];
	
	
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	
	
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
