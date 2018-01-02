//
//  ViewController.m
//  TheLastHair
//
//  Created by UDONKONET on 2018/01/02.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

#import "ViewController.h"
@import GoogleMobileAds;
static NSString *const kBannerAdUnitID = @"ca-app-pub-3324877759270339/9650414539";

@interface ViewController ()<GADInterstitialDelegate>

// 広告
@property (weak, nonatomic) IBOutlet UIView *adView;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //バナー
    self.bannerView.adUnitID = kBannerAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
