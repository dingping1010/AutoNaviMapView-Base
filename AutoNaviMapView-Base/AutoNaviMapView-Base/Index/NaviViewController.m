//
//  NaviViewController.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/3/10.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "NaviViewController.h"
#import "BDSSpeechSynthesizer.h"

@interface NaviViewController ()
<
AMapNaviWalkViewDelegate,
AMapNaviWalkManagerDelegate,
BDSSpeechSynthesizerDelegate
>
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property (nonatomic, strong) AMapNaviWalkView *walkMapView;
@property (nonatomic, strong) AMapNaviWalkManager *walkManager;


@end

@implementation NaviViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self initProperties];
    [self.view addSubview:self.walkMapView];
    [self initWalkManager];
    [self.walkManager calculateWalkRouteWithStartPoints:@[self.startPoint] endPoints:@[self.endPoint]];
    
    [self configureSDK];

}

- (void)initProperties
{
    self.startPoint = [AMapNaviPoint locationWithLatitude:self.startPointLat longitude:self.startPointLog];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:self.endPointLat longitude:self.endPointLog];
}

- (AMapNaviWalkView *)walkMapView
{
    if(!_walkMapView) {
        _walkMapView = [[AMapNaviWalkView alloc]initWithFrame:self.view.bounds];
        _walkMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _walkMapView.delegate = self;
        _walkMapView.showMoreButton = NO;
        _walkMapView.showMode = AMapNaviWalkViewShowModeNormal;
    }
    return  _walkMapView;
}

- (void)initWalkManager
{
    if (self.walkManager == nil) {
        self.walkManager = [[AMapNaviWalkManager alloc] init];
        [self.walkManager setDelegate:self];
        [self.walkManager addDataRepresentative:self.walkMapView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[BDSSpeechSynthesizer sharedInstance]pause];
    [[BDSSpeechSynthesizer sharedInstance] cancel];
}

- (void)configureSDK
{
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:@"tXe9kE0h8HMCywZPexGSi0gM" withSecretKey:@"353eb742572e06451cc1328b8c687a89"];
}



#pragma mark - AMapNaviWalkManagerDelegate
- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    [self.walkManager startGPSNavi];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"步行路径规划失败: %@", error);
}

- (void)walkViewCloseButtonClicked:(AMapNaviWalkView *)walkView
{
    [self.navigationController popViewControllerAnimated:YES];
    [[BDSSpeechSynthesizer sharedInstance] cancel];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"walkManagerplayNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    NSInteger sentenceID;
    NSError *err = nil;
    sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:soundString withError:&err];
}


@end
