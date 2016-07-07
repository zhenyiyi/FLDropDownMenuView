//
//  FLDropDownMenuView.m
//  FLDropDownMenuView
//
//  Created by fenglin on 7/7/16.
//  Copyright © 2016 fenglin. All rights reserved.
//

#import "FLDropDownMenuView.h"

#define MB_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;

#define kFLScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kFLScreenHeight  [UIScreen mainScreen].bounds.size.height
static const NSUInteger FLDropdownMenuViewHeaderHeight = 44;

@interface FLDropDownMenuView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy)   NSArray<NSString *> *items;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, assign) BOOL isMenuShow;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *wrapperView;

@end


@implementation FLDropDownMenuView

#pragma mark -- life cycle --

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSArray*)items
{
    if (self = [super initWithFrame:frame])
    {
        _width = [UIScreen mainScreen].bounds.size.width;
        _animationDuration = 0.3;
        _backgroundAlpha = 0.3;
        _cellHeight = 44;
        _isMenuShow = NO;
        _selectedIndex = 0;
        _items = items;
        _title = title;
        [self addSubview:self.titleButton];
        [self addSubview:self.arrowImageView];
        [self.wrapperView addSubview:self.backgroundView];
        [self.wrapperView addSubview:self.tableView];
        
    }
    
    return self;
}

- (void)layoutSubviews{
    
    CGSize curSize = MB_MULTILINE_TEXTSIZE(self.items[_selectedIndex], self.titleFont, CGSizeMake(self.frame.size.width, FLDropdownMenuViewHeaderHeight), nil);
    CGFloat titleButtonX = (self.frame.size.width - (curSize.width + 12)) /2.0;
    CGFloat titleButtonY = (FLDropdownMenuViewHeaderHeight - curSize.height) /2.0;
    
    _titleButton.frame = CGRectMake(titleButtonX, titleButtonY, curSize.width, curSize.height);
    
    _arrowImageView.frame = CGRectMake(self.titleButton.frame.origin.x + self.titleButton.frame.size.width + 5, FLDropdownMenuViewHeaderHeight - 12 *2, 12, 7);
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window)
    {
        [self.window addSubview:self.wrapperView];
        
        self.wrapperView.hidden = YES;
    }
    else
    {
        // 避免不能销毁的问题
        [self.wrapperView removeFromSuperview];
    }
}



#pragma mark -- UITableViewDataSource --

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
//    cell.tintColor = self.cellAccessoryCheckmarkColor;
    cell.backgroundColor = self.cellColor;
    cell.textLabel.font = self.textFont;
    cell.textLabel.textColor = self.textColor;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.row == self.selectedIndex) {
        cell.textLabel.textColor = self.selectedColor;
    }
    return cell;
}

#pragma mark -- UITableViewDataDelegate --

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedAtIndex)
    {
        self.selectedAtIndex((int)indexPath.row);
    }
}

#pragma mark -- handle actions --

- (void)handleTapOnTitleButton:(UIButton *)button
{
    self.isMenuShow = !self.isMenuShow;
}

- (void)orientChange:(NSNotification *)notif
{
    NSLog(@"change orientation");
}

#pragma mark -- helper methods --

- (void)showMenu
{
    self.titleButton.enabled = NO;
    self.tableView.tableHeaderView = [[UIView alloc] init];
    [self.tableView layoutIfNeeded];
    
    self.wrapperView.hidden = NO;
    self.backgroundView.alpha = 0.0;
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
                     }];
    
    [UIView animateWithDuration:self.animationDuration * 1.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.tableView layoutIfNeeded];
                         self.backgroundView.alpha = self.backgroundAlpha;
                         self.titleButton.enabled = YES;
                     } completion:nil];
}

- (void)hideMenu
{
    self.titleButton.enabled = NO;
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.arrowImageView.transform = CGAffineTransformRotate(self.arrowImageView.transform, M_PI);
                     }];
    
    [UIView animateWithDuration:self.animationDuration * 1.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.tableView layoutIfNeeded];
                         self.backgroundView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.wrapperView.hidden = YES;
                         [self.tableView reloadData];
                         self.titleButton.enabled = YES;
                     }];
}

#pragma mark -- getter and setter --

- (UIColor *)cellColor
{
    if (!_cellColor)
    {
        _cellColor = [UIColor whiteColor];
//        _cellColor = [UIColor colorWithRed:0.296 green:0.613 blue:1.000 alpha:1.000];
    }
    
    return _cellColor;
}

@synthesize cellSeparatorColor = _cellSeparatorColor;
- (UIColor *)cellSeparatorColor
{
    if (!_cellSeparatorColor)
    {
//        _cellSeparatorColor = [UIColor whiteColor];
        _cellSeparatorColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
    }
    
    return _cellSeparatorColor;
}

- (void)setCellSeparatorColor:(UIColor *)cellSeparatorColor
{
    if (_tableView)
    {
        _tableView.separatorColor = cellSeparatorColor;
    }
    _cellSeparatorColor = cellSeparatorColor;
}

- (UIColor *)cellAccessoryCheckmarkColor
{
    if (!_cellAccessoryCheckmarkColor)
    {
        _cellAccessoryCheckmarkColor = [UIColor whiteColor];
    }
    
    return _cellAccessoryCheckmarkColor;
}


@synthesize textColor = _textColor;
- (UIColor *)textColor
{
    if (!_textColor)
    {
        _textColor = [UIColor colorWithRed:25/255.0 green:24/255.0 blue:39/255.0 alpha:1];
    }
    
    return _textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_titleButton)
    {
        [_titleButton setTitleColor:textColor forState:UIControlStateNormal];
    }
    _textColor = textColor;
}

-(UIColor *)selectedColor{
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:31/255.0 green:163/255.0 blue:189/255.0 alpha:1];
    }
    return _selectedColor;
}

@synthesize textFont = _textFont;
- (UIFont *)textFont
{
    if(!_textFont)
    {
        _textFont = [UIFont systemFontOfSize:17];
    }
    
    return _textFont;
}

- (void)setTextFont:(UIFont *)textFont
{
    if (_titleButton)
    {
        [_titleButton.titleLabel setFont:textFont];;
    }
    _textFont = textFont;
}


- (UIColor *)titleColor{
    if (!_titleColor) {
        _titleColor = [UIColor lightTextColor];
    }
    return _titleColor;
}
@synthesize titleFont = _titleFont;

- (UIFont *)titleFont
{
    if(!_titleFont)
    {
        _titleFont = [UIFont systemFontOfSize:20];
    }
    return _titleFont;
}

- (void)setTitleFont:(UIFont *)titleFont{
    if (_titleButton)
    {
        [_titleButton.titleLabel setFont:titleFont];;
    }
    _titleFont = titleFont;
}



- (UIButton *)titleButton
{
    if (!_titleButton)
    {
        _titleButton = [[UIButton alloc] init];
        [_titleButton setTitle:[self.items objectAtIndex:0] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(handleTapOnTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [_titleButton.titleLabel setFont:self.titleFont];
        [_titleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleButton setTitleColor:self.titleColor forState:UIControlStateNormal];
    }
    
    return _titleButton;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView)
    {
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"arrow_down_icon" ofType:@"bundle"];
        NSString *imgPath = [bundlePath stringByAppendingPathComponent:@"arrow_down_icon.png"];
        UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
        _arrowImageView = [[UIImageView alloc] initWithImage:image];
    }
    
    return _arrowImageView;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = self.cellSeparatorColor;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
        _tableView.frame = CGRectMake(0, 0, _width, _cellHeight * _items.count);
    }
    
    return _tableView;
}

- (UIView *)wrapperView
{
    if (!_wrapperView)
    {
        _wrapperView = [[UIView alloc] init];
        _wrapperView.frame = CGRectMake(0, 64, kFLScreenWidth, kFLScreenHeight);
        _wrapperView.clipsToBounds = YES;
    }
    
    return _wrapperView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.frame = self.wrapperView.bounds;
        _backgroundView.alpha = self.backgroundAlpha;
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTitleButton:)]];
    }
    
    return _backgroundView;
}

- (void)setIsMenuShow:(BOOL)isMenuShow
{
    if (_isMenuShow != isMenuShow)
    {
        _isMenuShow = isMenuShow;
        
        if (isMenuShow)
        {
            [self showMenu];
        }
        else
        {
            [self hideMenu];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex)
    {
        _selectedIndex = selectedIndex;
        [_titleButton setTitle:[_items objectAtIndex:selectedIndex] forState:UIControlStateNormal];
    }
    
    self.isMenuShow = NO;
}

- (void)setWidth:(CGFloat)width
{
    if (width < 80.0)
    {
        NSLog(@"width should be set larger than 80, otherwise it will be set to be equal to window width");
        
        return;
    }
    
    _width = width;
}



@end
