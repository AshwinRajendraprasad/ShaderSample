//
//  ImageViewController.m
//  ShaderSample
//
//  Created by Mamunul on 10/10/15.
//
//

#import "ImageViewController.h"

@interface ImageViewController (){
	UIImage *image ;

}

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dream_village" ofType:@"jpg"]];
	image = [[UIImage alloc] initWithData:texData];
	NSArray *shaderArray = [self getShader];// [NSArray arrayWithObjects:@"horzBlurShader",@"shader",nil];
	
	ShaderRenderer *renderer = [[ShaderRenderer alloc] initWithShader:shaderArray onScreen:NO];
	renderer.width = image.size.width;
	renderer.height = image.size.height;
	renderer.delegate = self;
	
	[renderer renderWithTextures:shaderArray];
}

-(void)renderedImage:(UIImage *)image{
	
	imageView.image = image;

	NSLog(@"test : %@",NSStringFromCGSize(image.size));

}
-(NSArray *) getShader{
	
	
	NSArray *textureArray1 = [self getShader1Texures];
	
	NSArray *uniformArray = [self getShader1Uniforms:YES];
	
	
	//	ShaderProperties *shader1 = [[ShaderProperties alloc] init];
	
	GLShader *shader1 = [[GLShader alloc] init];
	
	shader1.vertexShaderFileName = @"shader";
	shader1.fragmentShaderFileName = @"shader";
	shader1.textureArray = textureArray1;
	shader1.uniformArray = uniformArray;
	
	
	NSArray *textureArray2 = [self getShader2Texures];
	
	//	ShaderProperties *shader2 = [[ShaderProperties alloc] init];
	GLShader *shader2 = [[GLShader alloc] init];
	shader2.vertexShaderFileName = @"horzBlurShader";
	shader2.fragmentShaderFileName = @"horzBlurShader";
	shader2.textureArray = textureArray2;
	shader2.uniformArray = uniformArray;
	
	NSArray *uniformArray2 = [self getShader1Uniforms:NO];
	NSArray *textureArray3 = [self getShaderTexures3];
	
	//	ShaderProperties *shader3 = [[ShaderProperties alloc] init];
	GLShader *shader3 = [[GLShader alloc] init];
	shader3.vertexShaderFileName = @"horzBlurShader";
	shader3.fragmentShaderFileName = @"horzBlurShader";
	shader3.textureArray = textureArray3;
	shader3.uniformArray = uniformArray2;
	
	
	NSArray *textureArray4 = [self getShader4Texures];
	
	GLShader *shader4 = [[GLShader alloc] init];
	shader4.vertexShaderFileName = @"horzBlurShader";
	shader4.fragmentShaderFileName = @"BeautySkinNatural";
	shader4.textureArray = textureArray4;
	shader4.uniformArray = uniformArray2;
	
	NSArray *array = [[NSArray alloc] initWithObjects:shader2,shader3,shader4,nil];
	
	return array;
	
}

-(NSArray *) getShader2Texures{

	GLTexture *texture2 = [[GLTexture alloc] init];
	
	[texture2 setTextureName:@"s_texture"];
	[texture2 setTextureId:1];
	[texture2 setTextureType:Image];
		[texture2 setTextureImage:image];
	
	
	NSArray *array = [NSArray arrayWithObjects:texture2, nil];
	
	
	return array;
	
}

-(NSArray *) getShader1Texures{
	
//	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
//	UIImage *image = [[UIImage alloc] initWithData:texData];
//	NSData *texData2 = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oil" ofType:@"jpg"]];
//	UIImage *image2 = [[UIImage alloc] initWithData:texData2];
	
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

-(NSArray *) getShaderTexures3{
	
	
	GLTexture *texture1 = [[GLTexture alloc] init];
	
	[texture1 setTextureName:@"s_texture"];
	[texture1 setTextureId:1];
	[texture1 setTextureType:FrameBuffer];
	
	
	NSArray *array = [NSArray arrayWithObjects:texture1, nil];
	
	
	return array;
	
}

-(NSArray *) getShader4Texures{
//	NSData *texData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
//	UIImage *image = [[UIImage alloc] initWithData:texData];
	
	GLTexture *texture1 = [[GLTexture alloc] init];
	
	[texture1 setTextureName:@"s_overlay"];
	[texture1 setTextureId:1];
	[texture1 setTextureType:FrameBuffer];
	
	
	GLTexture *texture2 = [[GLTexture alloc] init];
	
	[texture2 setTextureName:@"s_texture"];
	[texture2 setTextureId:2];
	[texture2 setTextureType:Image];
		[texture2 setTextureImage:image];
	
	NSArray *array = [NSArray arrayWithObjects:texture1, texture2, nil];
	
	
	return array;
	
}

-(NSArray *) getShader1Uniforms:(BOOL)isHblur{
	
	CGPoint cgpoint = CGPointMake(1.0, 0.0);
	float blurRadius = 6.0;
	
	if (isHblur) {
		
		
		cgpoint = CGPointMake(0.0, 1.0);
		
	}
//	image.size.width;
//	renderer.height = image.size.height;
	GLUniform *uniform1 = [[GLUniform alloc] init];
	
	[uniform1 setUniformName:@"width"];
	[uniform1 setUniformDataType:Float_Type];
	[uniform1 setUniformData:[NSNumber numberWithFloat:image.size.width]];
	
	
	GLUniform *uniform2 = [[GLUniform alloc] init];
	
	[uniform2 setUniformName:@"height"];
	[uniform2 setUniformDataType:Float_Type];
	[uniform2 setUniformData:[NSNumber numberWithFloat:image.size.height]];
	
	
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
