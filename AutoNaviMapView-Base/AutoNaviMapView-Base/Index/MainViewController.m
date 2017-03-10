//
//  MainViewController.m
//  AutoNaviMapView-Base
//
//  Created by dingping on 2017/2/13.
//  Copyright © 2017年 dingping. All rights reserved.
//


#import "MainViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "CustomAnnotationView.h"

#import "SearchViewController.h"


@interface MainViewController ()<MAMapViewDelegate>
@property (nonatomic, strong) MAPointAnnotation *userAnnotation;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic ,strong) CLGeocoder *geocoder;  // 地理编码对象
@property (nonatomic, strong) UIButton *gpsLocationBtn;
@property (nonatomic, strong) NSMutableArray *pointArr;           // 大头针数组

@property (nonatomic, strong) UILabel *searchView;


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
    
    CGFloat paddingX = 25;
    CGFloat paddingY = 40;
    CGFloat gpsWidth = 45;
    CGFloat gpsHeight = 45;
    
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;

    self.gpsLocationBtn.frame = CGRectMake(paddingX, screenH - paddingY*3, gpsWidth, gpsHeight);
    self.searchView.frame = CGRectMake(0, screenH-60, screenW, 60);
    
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
