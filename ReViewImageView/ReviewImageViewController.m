//
//  ReviewImageViewController.m
//  ReViewImageView
//
//  Created by 李伟超 on 14-10-31.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import "ReviewImageViewController.h"
#import "XHImageViewer.h"

@interface ReviewImageViewController ()<XHImageViewerDelegate>{
    NSMutableArray *_imageViews;
}

@end

@implementation ReviewImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(120, 200, 80, 40)];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"查看" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    UIImageView *imageView1 = [[UIImageView alloc] init];
    NSURL *_url = [[NSURL alloc] initWithString:@"http://app.jingan.gov.cn/content/xinwzx/jingan/detail/t_ca3fc91614e67ddb4e84f7f0e1372321.jpg"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:_url];
    imageView1.image = [UIImage imageWithData:data];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    NSURL *_url2 = [[NSURL alloc] initWithString:@"http://www.jingan.gov.cn/newscenter/jobnews/201410/W020141024576266359059.jpg"];
    NSData *data2 = [[NSData alloc] initWithContentsOfURL:_url2];
    imageView2.image = [UIImage imageWithData:data2];
    
    _imageViews = [NSMutableArray arrayWithObjects:imageView1,imageView2, nil];
}

- (void)loadView {
    [super loadView];
}

- (void)buttonAction:(id)sender {
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    [imageViewer showWithImageViews:_imageViews selectedView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XHImageViewerDelegate

- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView {
//    NSInteger index = [_imageViews indexOfObject:selectedView];
//    NSLog(@"index : %d", index);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
