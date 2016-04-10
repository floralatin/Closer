//
//  LHVideoViewController.m
//  Closer
//
//  Created by 李辉 on 16/3/21.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "LHVideoViewController.h"
void YUV420spRotate90(UInt8 *  dst, UInt8* src, size_t srcWidth, size_t srcHeight);

@interface LHVideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,EMCallManagerDelegate>{
    
     UInt8 *imageDataBuffer;
}
@property(nonatomic,strong)AVCaptureSession*session;

@property (weak, nonatomic) IBOutlet UIView *bigView;

@property (weak, nonatomic) IBOutlet UIView *smallView;
@property(nonatomic,strong)OpenGLView20*openGLView;
@property(nonatomic,strong)AVCaptureDeviceInput*captureInput;
@property(nonatomic,strong)AVCaptureVideoDataOutput*captureOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer*smallCaptureLayer;



//@property(nonatomic,assign)CVImageBufferRef *imageDataBuffer;


@end

@implementation LHVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _session = [[AVCaptureSession alloc] init];
    //开启
    [_session startRunning];
    
    _openGLView=[[OpenGLView20 alloc]initWithFrame:CGRectMake(0, 0, _bigView.frame.size.width, _bigView.frame.size.height)];
    [_bigView addSubview:_openGLView];
    _bigView.backgroundColor=[UIColor clearColor];
    _openGLView.sessionPreset = AVCaptureSessionPreset352x288;
    [_session setSessionPreset:_openGLView.sessionPreset];
    

    //创建配置输入设备；
    [self setinView];
    
    [self output];
    
    [self setsmallWindow];
    
      
    self.callSession.displayView = _openGLView;
    // Do any additional setup after loading the view from its nib.
}

-(void)setinView{
    AVCaptureDevice *device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *tmp in devices)
    {
        if (tmp.position == AVCaptureDevicePositionFront)
        {
            device = tmp;
            break;
        }
    }
    
    NSError *error = nil;
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [_session beginConfiguration];
    if(!error){
        [_session addInput:_captureInput];
    }
}

-(void)output{
   
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureOutput.videoSettings = _openGLView.outputSettings;
  
    _captureOutput.minFrameDuration = CMTimeMake(1, 15);
    _captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t outQueue = dispatch_queue_create("com.gh.cecall", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:outQueue];
    [_session addOutput:_captureOutput];
    [_session commitConfiguration];
}


-(void)setsmallWindow{
    
    _smallCaptureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _smallCaptureLayer.frame = CGRectMake(0, 0, _smallView.frame.size.width,_smallView.frame.size.height);
    _smallCaptureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_smallView.layer addSublayer:_smallCaptureLayer];
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
      fromConnection:(AVCaptureConnection *)connection
{
    if (self.callSession.status != eCallSessionStatusAccepted) {
        return;
    }
#warning 捕捉数据输出，根据自己需求可随意更改
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess)
    {
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        UInt8 *bufferPtr1 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
        
       size_t width = CVPixelBufferGetWidth(imageBuffer);
       size_t height = CVPixelBufferGetHeight(imageBuffer);
        size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
        
        if (imageDataBuffer == nil) {
            imageDataBuffer = (UInt8 *)malloc(width * height * 3 / 2);
        }
        UInt8 *pY = bufferPtr;
        UInt8 *pUV = bufferPtr1;
        UInt8 *pU = imageDataBuffer + width * height;
        UInt8 *pV = pU + width * height / 4;
        for(int i =0; i < height; i++)
        {
            memcpy(imageDataBuffer + i * width, pY + i * bytesrow0, width);
        }
        
        for(int j = 0; j < height / 2; j++)
        {
            for(int i = 0; i < width / 2; i++)
            {
                *(pU++) = pUV[i<<1];
                *(pV++) = pUV[(i<<1) + 1];
            }
            pUV += bytesrow1;
        }
        
        YUV420spRotate90(bufferPtr, imageDataBuffer, width, height);
        [[EaseMob sharedInstance].callManager processPreviewData:(char *)bufferPtr width:(int)width height:(int)height];
        
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
}


void YUV420spRotate90(UInt8 *  dst, UInt8* src, size_t srcWidth, size_t srcHeight)
{
    size_t wh = srcWidth * srcHeight;
    size_t uvHeight = srcHeight >> 1;//uvHeight = height / 2
    size_t uvWidth = srcWidth>>1;
    size_t uvwh = wh>>2;
    //旋转Y
    int k = 0;
    for(int i = 0; i < srcWidth; i++) {
       unsigned long long int nPos = wh-srcWidth;
        for(int j = 0; j < srcHeight; j++) {
            dst[k] = src[nPos + i];
            k++;
            nPos -= srcWidth;
        }
    }
    for(int i = 0; i < uvWidth; i++) {
        unsigned long long int nPos = wh+uvwh-uvWidth;
        for(int j = 0; j < uvHeight; j++) {
            dst[k] = src[nPos + i];
            dst[k+uvwh] = src[nPos + i+uvwh];
            k++;
            nPos -= uvWidth;
        }
    }
}




-(void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error{
    [self matchingReson:reason];
    
}
-(void)matchingReson:(EMCallStatusChangedReason)reason{
    switch (reason) {
        case eCallReasonNull:
            [ self alertMessage:@"正常挂断"];
            
            break;
        case eCallReasonOffline:
            [ self alertMessage:@"对方不在线"];
            break;
        case eCallReasonNoResponse:
            [ self alertMessage:@"对方没有响应"];
            break;
        case eCallReasonHangup:
          
            [ self alertMessage:@"对方挂断"];
            break;
        case eCallReasonReject:
            
            [ self alertMessage:@"对方拒接"];
            
            break;
        case eCallReasonBusy:
            [ self alertMessage:@"对方忙碌"];
            break;
        case eCallReasonFailure:
            [ self alertMessage:@"连接失败"];
            break;
        default:
            break;
    }
}
-(void)alertMessage:(NSString*)message{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    }];
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
