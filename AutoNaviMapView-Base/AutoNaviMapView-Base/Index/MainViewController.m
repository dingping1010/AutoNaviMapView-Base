//
//  MainViewController.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/2/13.
//  Copyright © 2017年 dingping. All rights reserved.
//


#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height


#import "MainViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "CustomAnnotationView.h"
#import "SearchViewController.h"
#import "NaviViewController.h"

#import "Masonry.h"
#import <pop/POP.h>

@interface MainViewController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAPointAnnotation *userAnnotation;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSMutableArray *pointArr;
@property (nonatomic, strong) UILabel *searchView;
@property (nonatomic, strong) UIView *testView;    // 用来测试动画

/**
 定位经纬度
 */
@property (nonatomic, assign)CLLocationCoordinate2D currentLocation;

/**
  地理编码对象
 */
@property (nonatomic ,strong) CLGeocoder *geocoder;

/**
 回到定位位置
 */
@property (nonatomic, strong) UIButton *gpsLocationBtn;


/**
  导航
 */
@property (nonatomic, strong) UIButton *navButton;



@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页地图";
    UIButton *leftBarButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 40, 40)];
    leftBarButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [leftBarButton setImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(pushToMenu) forControlEvents:UIControlEventTouchUpInside];

    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.gpsLocationBtn];
    [self.view addSubview:self.searchView];
    [self.view addSubview:self.navButton];
    
    CGFloat paddingX = 25;
    CGFloat paddingY = 40;
    CGFloat gpsWidth = 45;
    CGFloat gpsHeight = 45;

    self.gpsLocationBtn.frame = CGRectMake(paddingX, screenH - paddingY*3, gpsWidth, gpsHeight);
    self.searchView.frame = CGRectMake(0, screenH-60, screenW, 60);
    
    [_navButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-paddingX);
        make.bottom.equalTo(self.view).offset(-70);
        make.width.height.equalTo(@60);
    }];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, screenH, screenW, 200)];
    self.testView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.testView];
}

- (void)moveAction:(id)sender
{
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBounds];
    
//    NSInteger height = CGRectGetHeight(self.view.bounds);
//    NSInteger width = CGRectGetWidth(self.view.bounds);
    
//    CGFloat centerX = arc4random() % width;
//    CGFloat centerY = arc4random() % height;
    
//    CGFloat centerX = screenW / 2;
//    CGFloat centerY = screenH / 2;
//    
//    if (self.testView.frame.size.width == screenW) {
//        anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 100, 100)];
//    } else {
//        anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, screenW, 200)];
//    }
    
//    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
    
//    [self.testView pop_addAnimation:anim forKey:@"center"];
}

- (void)pushToMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

// 添加大头针，在需要的地方添加大头针
- (void)addAnnotationWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude
{
    if(self.pointArr) {
        [self.mapView removeAnnotations:self.pointArr];
        [self.pointArr removeAllObjects];
    }
    
    CustomAnnotation *anno = [[CustomAnnotation alloc] init];
    anno.title = @"自定义大头针1号";
    anno.subtitle = @"我的名字叫啦啦";
    anno.coordinate = CLLocationCoordinate2DMake(latitude , longitude);
    anno.icon = @"userLocation_icon";
    
    // 添加大头针
    [self.mapView addAnnotation:anno];
    [self.pointArr addObject:anno];
}

- (MAAnnotationView *)createSystemAnnotationWithMapView:(MAMapView *)mapView Annotaion:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

- (void)gpsAction:(id)sender
{
    self.mapView.showsUserLocation = YES;
    [self.mapView setZoomLevel:(17.2f) animated:YES];
}


/**
  点击导航
 */
- (void)navButtonDidSelected:(UIButton *)navButton
{
//    [self moveAction:navButton];
    
    if(self.currentLocation.latitude <= 0 || self.currentLocation.longitude <=0) {
        return;
    }
    
    NaviViewController *naviVC = [[NaviViewController alloc]init];
    naviVC.startPointLat = 22.541089;
    naviVC.startPointLog = 113.981109;
    
    // 测试 正式依据正式即可
    naviVC.endPointLat = 22.5515;
    naviVC.endPointLog = 113.9543;
    
    [self.navigationController pushViewController:naviVC animated:YES];
}

- (void)searchViewDidClick:(UITapGestureRecognizer *)tapGes
{
    SearchViewController *searchVC = [[SearchViewController alloc]init];
    searchVC.cityName = @"深圳";
    [self presentViewController:searchVC animated:YES completion:nil];
}

// 当大头针被加入到地图中的时候就会调用这个方法
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    // 自定义大头针
    if ([annotation isKindOfClass:[CustomAnnotation class]]) {
        CustomAnnotationView *annoView = [CustomAnnotationView annotationViewWithMap:mapView];
        annoView.canShowCallout= YES;
        annoView.draggable = YES;
        annoView.annotation = annotation;
        return annoView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation) {
        CLLocation *newLocation = userLocation.location;
        
        //判断时间
        NSTimeInterval locationAge = [newLocation.timestamp timeIntervalSinceNow];
        if (locationAge > 5.0) {
            return;
        }
        //判断水平精度是否有效
        if(newLocation.horizontalAccuracy >0 && newLocation.horizontalAccuracy < 150) {
            CLLocationCoordinate2D myCoorDinate = [newLocation coordinate];
            _mapView.centerCoordinate = myCoorDinate;
            _mapView.showsUserLocation = NO;
            
            self.currentLocation = myCoorDinate;
            
            [self addAnnotationWithLatitude:myCoorDinate.latitude Longitude:myCoorDinate.longitude];
            
            // 反地理编码，根据定位到的经纬度转换成城市街道名称等信息
            [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = [placemarks firstObject];
                NSLog(@"获取地理位置成功 name = %@ locality = %@", placemark.name, placemark.locality);
                userLocation.title = placemark.name;
                userLocation.subtitle = placemark.locality;
            }];
        }
    }
}

#pragma mark - init -
- (MAMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(22.547,114.085947);
        _mapView.showsCompass = NO;
        _mapView.mapType = MAMapTypeStandard;
        _mapView.showsScale = NO;
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeNone;
        _mapView.delegate = self;
        _mapView.rotateEnabled = YES;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_mapView setZoomLevel:(17.2f) animated:YES];
        _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
        _mapView.centerCoordinate = CLLocationCoordinate2DMake(22.547,114.085947);
    }
    return _mapView;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (UIButton*)gpsLocationBtn
{
    if (!_gpsLocationBtn) {
        UIButton * ret = [[UIButton alloc] init];
        ret.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [ret setImage:[UIImage imageNamed:@"GPS_location"] forState:UIControlStateNormal];
        [ret addTarget:self action:@selector(gpsAction:) forControlEvents:UIControlEventTouchUpInside];
        _gpsLocationBtn = ret;
    }
    return _gpsLocationBtn;
}

- (UIButton*)navButton
{
    if (!_navButton) {
        UIButton *navButton = [[UIButton alloc] init];
        navButton.backgroundColor = [UIColor orangeColor];
        [navButton setTitle:@"点我导航" forState:UIControlStateNormal];
        navButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [navButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [navButton addTarget:self action:@selector(navButtonDidSelected:) forControlEvents:UIControlEventTouchUpInside];
        navButton.clipsToBounds = YES;
        navButton.layer.cornerRadius = 30.f;
        _navButton = navButton;
    }
    return _navButton;
}

- (NSMutableArray *)pointArr
{
    if(!_pointArr) {
        _pointArr = [[NSMutableArray alloc]init];
    }
    return _pointArr;
}

- (UILabel *)searchView
{
    if(!_searchView) {
        _searchView = [[UILabel alloc]init];
        _searchView.text = @"你想要搜索的地方";
        _searchView.font = [UIFont systemFontOfSize:17];
        _searchView.textAlignment = NSTextAlignmentCenter;
        _searchView.clipsToBounds = YES;
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.layer.cornerRadius = 5.f;
        _searchView.textColor = [UIColor blackColor];
        _searchView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchViewDidClick:)];
        [_searchView addGestureRecognizer:tapGes];
    }
    return  _searchView;
}


@end
