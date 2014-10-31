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

@implementation XHZoomingImageView

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
    [self insertSubview:_toolBar aboveSubview:_scrollView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [_scrollView addGestureRecognizer:doubleTap];
    
    
    NSLog(@"%@",self.superview.gestureRecognizers);
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
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
    }
//    _containerView.transform = CGAffineTransformRotate(_containerView.transform, M_PI_2);
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
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
}

#pragma mark - doubleTap

- (void)didDoubleTap:(UITapGestureRecognizer*)sender {
    NSLog(@"doubleTap");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:_toolBar];
    if (touchPoint.y >= 0 && touchPoint.y <= _toolBar.frame.size.height) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UITapGestureRecognizer")]) {
        return NO;
    }
    return YES;
}

#pragma mark - toolBar Action

- (void)leftRotation {
    NSLog(@"左转");
}

- (void)rightRotation {
    NSLog(@"右转");
}

- (void)zoomOut {
    NSLog(@"缩小");
}

- (void)zoomIn {
    NSLog(@"放大");
}

- (void)savePhoto {
    NSLog(@"保存");
}


@end
