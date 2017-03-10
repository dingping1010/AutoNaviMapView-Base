//
//  SearchBarView.m
//  pianke
//
//  Created by dingping on 2017/3/9.
//  Copyright © 2017年 dingping. All rights reserved.
//

#import "SearchBarView.h"
#import "Masonry.h"

@implementation SearchBarView
- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}


#pragma mark - init
- (void)setupSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.searchImageView];
    [self addSubview:self.searchTextField];
    [self addSubview:self.closeButton];
    
    UIView *lineView = [UIView new];
    

    lineView.backgroundColor = [UIColor blackColor];
    [self addSubview:lineView];
    
    UIView *superview = self;
    
    [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superview).offset(30);
        make.centerY.equalTo(superview);
        make.width.height.equalTo(@(30));
    }];

    [_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(superview);
        make.left.equalTo(_searchImageView.mas_right).offset(30);
        make.right.equalTo(_closeButton.mas_left).offset(-5);
        
    }];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superview).offset(-30);
        make.centerY.equalTo(superview);
        make.width.height.equalTo(@40);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(superview);
        make.left.equalTo(superview).offset(15);
        make.right.equalTo(superview).offset(-15);
        make.height.equalTo(@3);
    }];
}

- (UIButton *)searchImageView
{
    if (!_searchImageView) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"searchButtonNormal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"searchButtonSelected"] forState:UIControlStateSelected];
        _searchImageView = button;
    }
    return _searchImageView;
}

- (UITextField *)searchTextField {
    if (!_searchTextField) {
        UITextField *field = [[UITextField alloc] init];
        field.placeholder = @"Search";//attr enable
        field.font = [UIFont systemFontOfSize:13];
        field.returnKeyType = UIReturnKeySearch;
        _searchTextField = field;
    }
    return _searchTextField;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"searchButtonNormal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"searchCloseButton"] forState:UIControlStateNormal];
        _closeButton = button;
    }
    return _closeButton;
}
@end
