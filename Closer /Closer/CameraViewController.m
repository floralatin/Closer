//
//  CameraViewController.m
//  Closer
//
//  Created by zhangkai on 16/3/17.
//  Copyright © 2016年 Closer_All. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *focusCursor;
- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)flashAutoButton:(UIButton *)sender;
- (IBAction)flashOnButton:(UIButton *)sender;
- (IBAction)flashOffButton:(UIButton *)sender;
- (IBAction)exchangeButton:(UIButton *)sender;
- (IBAction)sureButton:(UIButton *)sender;
- (IBAction)cancleButton:(UIButton *)sender;


@property(nonatomic,strong)AVCaptureSession  *captureSession;
@property(nonatomic,strong)AVCaptureDeviceInput  *captureDeviceInput;
@property(nonatomic,strong)AVCaptureStillImageOutput  *captureStillImageOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer  *captureVideoPreviewLayer;
@property(nonatomic,strong)UIImage  *lastImage;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
   
    [self initAllDecive];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
#pragma mark -初始化

-(void)initAllDecive{
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
    }
    
    //获得输入设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题.");
        return;
    }
    
    //获得输入对象
    NSError* error=nil;
    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得输入设备对象出错%@",error);
        return;
    }
    //初始或输出设备
    _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outPutSetting=@{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outPutSetting];
    
    
    //将设备添加到输入会话
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    //将设备添加到输出回话
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    //创建预览层
    _captureVideoPreviewLayer =[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    CALayer *layer=self.viewContainer.layer;
    layer.masksToBounds=YES;
    _captureVideoPreviewLayer.frame=layer.bounds;
    //填充模式
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    //将 视频预览层添加到界面中
    //[layer addSublayer:_captureVideoPreviewLayer];
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    //添加通知
    [self addNotifationToCaptureDevice:captureDevice];
    
    [self addGenstureRecognizer];
    
    [self setFlashModeButtonStatus];
}
#pragma mark  - 遍历设备列表并从中取出想要的设备
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
#pragma mark - 添加通知
-(void)addNotifationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

#pragma mark - 添加手势
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesturer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [self.viewContainer addGestureRecognizer:tapGesturer];
}

-(void)tapGestureAction:(UITapGestureRecognizer*)tapGesturer{
    CGPoint point=[tapGesturer locationInView:self.viewContainer];
    CGPoint cameraPoint=[self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
      [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)setFocusCursorWithPoint:(CGPoint)cameraPoint{
    self.focusCursor.center=cameraPoint;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=0.8;
    [UIView animateWithDuration:0.5 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        self.focusCursor.alpha=1.0;
    } ];
}
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
#pragma mark - 闪光灯模式
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *device=[self.captureDeviceInput device];
    AVCaptureFlashMode  flashMode=device.flashMode;
    if ([device isFlashAvailable]) {
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
                NSLog(@"自动模式");
                break;
            case AVCaptureFlashModeOn:
            NSLog(@"打开模式");
                break;
            case AVCaptureFlashModeOff:
            NSLog(@"关闭模式");
                break;
            default:
                break;
        }
    }
}

#pragma  mark - 拍照
- (IBAction)takePhoto:(UIButton *)sender {
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput
     captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        if (imageDataSampleBuffer) {
            
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lastImage=[[UIImage alloc]init];
                self.lastImage=[UIImage imageWithData:imageData];
            });
            self.focusCursor.alpha=0.0;
            [self.captureSession stopRunning];
        }
    }];
    
}
- (IBAction)flashAutoButton:(UIButton *)sender {
    
    [self setFlashMode:AVCaptureFlashModeAuto];
}

- (IBAction)flashOnButton:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOn];
}

- (IBAction)flashOffButton:(UIButton *)sender {
    [self setFlashMode:AVCaptureFlashModeOff];
}


- (IBAction)sureButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.lastImage!=nil) {
        UIImageWriteToSavedPhotosAlbum(self.lastImage, nil, nil, nil);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(sendImage:)]) {
            [self.delegate sendImage:self.lastImage];
        }
    }
}
- (IBAction)cancleButton:(UIButton *)sender {
    self.lastImage=nil;
    [self.captureSession startRunning];
}



#pragma mark - 交换前后相机

- (IBAction)exchangeButton:(UIButton *)sender {
    
    
}

@end
