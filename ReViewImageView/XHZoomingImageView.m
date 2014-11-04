//
//  XHZoomingImageView.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHZoomingImageView.h"

@interface XHZoomingImageView () <UIScrollViewDelegate>

@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation XHZoomingImageView {
    UILabel *promptLable;
    
    BOOL isProtrait;
}

- (void)_setup {
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [_scrollView addSubview:_containerView];
    
    [self addSubview:_scrollView];
    
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        [_toolBar setShadowImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *zoomOut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomOut.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)];
        UIBarButtonItem *zoomIn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomIn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)];
        UIBarButtonItem *Save = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(savePhoto)];
        UIBarButtonItem *leftRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftRotation)];
        UIBarButtonItem *rightRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightRotation)];
        
        NSArray *Items = @[leftRotate,flexibleSpace,zoomOut,flexibleSpace,zoomIn,flexibleSpace,rightRotate,flexibleSpace,Save];
        [_toolBar setItems:Items animated:YES];
    }
    [self insertSubview:_toolBar aboveSubview:_containerView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [_scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [_scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    isProtrait = YES;
}

- (void)awakeFromNib {
    [self _setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _setup];
    }
    return self;
}

- (void)dealloc {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

#pragma mark- Properties

- (UIImage *)image {
    return _imageView.image;
}

- (void)setImage:(UIImage *)image {
    if(self.imageView == nil){
        self.imageView = [UIImageView new];
        self.imageView.clipsToBounds = YES;
    }
    self.imageView.image = image;
}

- (void)setImageView:(UIImageView *)imageView {
    if(imageView != _imageView){
        [_imageView removeObserver:self forKeyPath:@"image"];
        [_imageView removeFromSuperview];
        
        _imageView = imageView;
        _imageView.frame = _imageView.bounds;
        
        [_imageView addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        [_containerView addSubview:_imageView];
        
        _scrollView.zoomScale = 1;
        _scrollView.contentOffset = CGPointZero;
        _containerView.bounds = _imageView.bounds;
        
        [self resetZoomScale];
        [self handleTap:nil];
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
    }
}

- (BOOL)isViewing {
    return (_scrollView.zoomScale != _scrollView.minimumZoomScale);
}

#pragma mark- observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object==self.imageView){
        [self imageDidChange];
    }
}

- (void)imageDidChange {
    
    if (isProtrait) {
        
        CGSize size = (self.imageView.image) ? self.imageView.image.size : self.bounds.size;
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
        CGFloat W = ratio * size.width;
        CGFloat H = ratio * size.height;
        self.imageView.frame = CGRectMake(0, 0, W, H);
        
        _scrollView.zoomScale = 1;
        _scrollView.contentOffset = CGPointZero;
        _containerView.bounds = _imageView.bounds;
        
        [self resetZoomScale];
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
        
    }else {
        CGSize size = (self.imageView.image) ? self.imageView.image.size : self.bounds.size;
        CGFloat ratio = MIN(_scrollView.frame.size.width / size.height, _scrollView.frame.size.height / size.width);
        CGFloat W = ratio * size.width;
        CGFloat H = ratio * size.height;
        self.imageView.frame = CGRectMake(0, 0, W, H);
        
        _scrollView.zoomScale = 1;
        _scrollView.contentOffset = CGPointZero;
        _containerView.bounds = _imageView.bounds;
        
        [self resetZoomScale];
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
    }
}

#pragma mark- Scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _containerView.frame.size.width;
    CGFloat H = _containerView.frame.size.height;
    
    CGRect rct = _containerView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _containerView.frame = rct;
}

- (void)resetZoomScale {
    CGFloat Rw = _scrollView.frame.size.width / self.imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / self.imageView.frame.size.height;
    
    CGFloat scale = 1;
    
    if (isProtrait) {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    }else {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.height));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.width));
    }
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
}

#pragma mark - Tap gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"\n\n-------------------------------------------------------\n\n");
    
    NSLog(@"C_frame :%@",NSStringFromCGRect(_containerView.frame));
    NSLog(@"C_bounds:%@",NSStringFromCGRect(_containerView.bounds));
    NSLog(@"ImageView:%@",NSStringFromCGRect(_imageView.frame));
    NSLog(@"ImageView bounds:%@",NSStringFromCGRect(_imageView.bounds));
    NSLog(@"\n contentInset:%@,\n contentSize:%@ ,\n frmae:%@ \n\n\n\n",NSStringFromUIEdgeInsets(_scrollView.contentInset),NSStringFromCGSize(_scrollView.contentSize),NSStringFromCGRect(_scrollView.frame));
}

- (void)didDoubleTap:(UITapGestureRecognizer*)gesture {
    if (_scrollView.zoomScale != _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:_toolBar];
    if (touchPoint.y >= 0 && touchPoint.y <= _toolBar.frame.size.height) {
        return NO;
    }
    return YES;
}

#pragma mark - toolBar Action

- (void)leftRotation {
    NSLog(@"\n\n\n左转");

    _imageView.transform = CGAffineTransformRotate(_imageView.transform, - M_PI_2);
    
    if (isProtrait) {
        
        isProtrait = NO;
        
    }else {
        isProtrait = YES;
    }
    
    [self imageDidChange];
    _imageView.frame = _containerView.bounds;
}

- (void)rightRotation {
    NSLog(@"右转");
    
    _imageView.transform = CGAffineTransformRotate(_imageView.transform, M_PI_2);
    
    isProtrait = isProtrait ? NO : YES;
    
    [self imageDidChange];
    _imageView.frame = _containerView.bounds;
}

- (void)zoomOut {
    
    if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
        [self showPrompt:@"已缩小到最小比例"];
        return;
    }
    
    if (_scrollView.zoomScale - 0.5 >= _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:(_scrollView.zoomScale - 0.5) animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

- (void)zoomIn {
    NSLog(@"放大");
    
    if (_scrollView.zoomScale == _scrollView.maximumZoomScale) {
        [self showPrompt:@"已放大到最大比例"];
        return;
    }
    
    if (_scrollView.zoomScale + 0.5 <= _scrollView.maximumZoomScale) {
        [_scrollView setZoomScale:(_scrollView.zoomScale + 0.5) animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

- (void)savePhoto {
    NSLog(@"保存");
}

#pragma mark prompt

- (void)showPrompt:(NSString *)message {
    [self canPerformAction:@selector(hiddenPrompt) withSender:nil];
    if (promptLable == nil) {
        promptLable = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 180)/2, self.frame.size.height - 100, 180, 40)];
        promptLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        promptLable.backgroundColor = [UIColor blackColor];
        promptLable.textAlignment = NSTextAlignmentCenter;
        promptLable.textColor = [UIColor whiteColor];
        
        promptLable.layer.shadowColor = [UIColor blackColor].CGColor;
        promptLable.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        promptLable.layer.shadowOpacity = 3;
        promptLable.layer.shadowRadius = 10.0;
        promptLable.layer.cornerRadius = 20.0;
        
        [self insertSubview:promptLable aboveSubview:_scrollView];
    }
    promptLable.hidden = NO;
    promptLable.text = message;
    [self performSelector:@selector(hiddenPrompt) withObject:nil afterDelay:1.5f];
}

- (void)hiddenPrompt {
    promptLable.hidden = YES;
}


@end
