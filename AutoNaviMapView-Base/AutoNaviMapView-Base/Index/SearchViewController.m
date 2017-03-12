//
//  SearchViewController.m
//  pianke
//
//  Created by dingping on 2017/3/9.
//  Copyright © 2017年 dingping. All rights reserved.
//
#define kScreenW  [UIScreen mainScreen].bounds.size.width
#define kScreenH  [UIScreen mainScreen].bounds.size.height
#define kusedAddress  @"usedAddress"

#import "SearchViewController.h"
#import "SearchBarView.h"
#import "AdressModel.h"

#import <AMapSearchKit/AMapSearchKit.h>

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AMapSearchDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SearchBarView *searchBar;

@property (nonatomic, strong) NSMutableArray *historyArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AdressModel *addressModel;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    
    _dataArray = [NSMutableArray new];
    _historyArray =[NSMutableArray new];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self initArrayData];
}


#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *str = [self.searchBar.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(str.length) { // 搜索中
        return self.dataArray.count;
    }
    else {
        return self.historyArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([self class]);
    AdressModel *model;
    NSString *str = [self.searchBar.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(str.length) { // 搜索中
         model = self.dataArray[indexPath.row];
    }
    else {
        model = self.historyArray[indexPath.row];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.text = model.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AdressModel *model;
    NSString *str = [self.searchBar.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(str.length) { // 搜索中
        model = self.dataArray[indexPath.row];
    }
    else {
        model = self.historyArray[indexPath.row];
    }
    [self updateUsedAddress:model];
}

/** 保存点击的地址为历史记录 */
-(void)updateUsedAddress:(AdressModel *)modle
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kusedAddress stringByAppendingString:self.cityName];
    NSArray *temp = [userDefaults objectForKey:key];
    
    BOOL isContains = NO;
    
    for (int i = 0; i < [temp count]; i++) {
        NSData *data = temp[i];
        AdressModel *usedaddress = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([modle.uid isEqualToString:usedaddress.uid]) {
            isContains = YES;
            [self.historyArray removeObjectAtIndex:i];
            break;
        }
    }
    if (isContains) {
        [self.historyArray insertObject:modle atIndex:0];
    }
    else {
        if ([self.historyArray count] < 15) {
            if ([self.historyArray count] == 0) {
                [self.historyArray addObject:modle];
            }
            else {
                [self.historyArray insertObject:modle atIndex:0];
            }
        }
        else {
            [self.historyArray removeLastObject];
            [self.historyArray insertObject:modle atIndex:0];
        }
    }
    
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (AdressModel *modle in self.historyArray) {
        NSData *addressData = [NSKeyedArchiver archivedDataWithRootObject:modle];
        [tempArray addObject:addressData];
    }
    [userDefaults setObject:[NSArray arrayWithArray:tempArray] forKey:key];
    [userDefaults synchronize];
}

/** 监听文本框的改变 */
- (void)textFieldDidChange:(UITextField *)textField
{
    if (_searchBar.searchTextField.text.length > 0) {
        _searchBar.searchImageView.selected = YES;
    }
    else {
        _searchBar.searchImageView.selected = NO;
    }
    
    NSString *str = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (str.length) { // 获取搜索结果
        self.addrssKeyWord = str;
    }
    else {
        [_tableView reloadData];
    }
}

#pragma mark AMapSearchDelegate
//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0) {
        return;
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (AMapTip *tip in response.tips) {
        AdressModel *ads = [[AdressModel alloc]init];
        ads.uid = tip.uid;
        ads.name = tip.name;
        ads.district = tip.district;
        ads.address = tip.address;
        ads.adcode = tip.adcode;
        ads.latitude = tip.location.latitude;
        ads.longitude = tip.location.longitude;
        
        [tempArray addObject:ads];
    }
    self.dataArray = [tempArray copy];
    [_tableView reloadData];
}

//请求失败
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.domain);
}


-(void)setAddrssKeyWord:(NSString *)addrssKeyWord
{
    _addrssKeyWord = addrssKeyWord;
    
    //发起输入提示搜索
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = addrssKeyWord;
    tipsRequest.city = self.cityName;
    tipsRequest.cityLimit = YES;
    [_search AMapInputTipsSearch: tipsRequest];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark - sel
- (void)dismissVC:(UIButton *)button
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initArrayData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [kusedAddress stringByAppendingString:self.cityName];
    NSArray *address = [userDefaults objectForKey:key];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSData *data in address) {
        AdressModel *usedaddress = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [tempArray addObject:usedaddress];
    }
    self.historyArray = tempArray;
    [self.tableView reloadData];
}

#pragma mark - init -
- (SearchBarView *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[SearchBarView alloc] initWithFrame:CGRectMake(0, 10, kScreenW, 50)];
        _searchBar.searchTextField.delegate = self;
        [_searchBar.closeButton addTarget:self action:@selector(dismissVC:) forControlEvents:UIControlEventTouchUpInside];
        [_searchBar.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _searchBar;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, kScreenW, kScreenH - 220/3) style:UITableViewStylePlain];
        tableview.backgroundColor = [UIColor whiteColor];
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView = tableview;
    }
    return _tableView;
}



@end
