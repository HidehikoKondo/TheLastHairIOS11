//
//  ViewController.m
//  TheLastHair
//
//  Created by UDONKONET on 2018/01/02.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@import GoogleMobileAds;
static NSString *const kBannerAdUnitID = @"ca-app-pub-3324877759270339/9650414539";

@interface ViewController ()<GADInterstitialDelegate>

// 広告
@property (weak, nonatomic) IBOutlet UIView *adView;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView2;

@end

@implementation ViewController{
    NSUserDefaults *score;  //スコア保存用
    NSUserDefaults *newapp; //新アプリダイアログの表示判断用。xmlのnoを保存。
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //バナー
    self.bannerView.adUnitID = kBannerAdUnitID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    self.bannerView2.adUnitID = kBannerAdUnitID;
    self.bannerView2.rootViewController = self;
    [self.bannerView2 loadRequest:[GADRequest request]];
    
    //ゲームセンター
    NSLog(@"ゲームセンター対応チェック%d",isGameCenterAPIAvailable());
    //ゲームセンター対応の有効なバージョンならログイン画面を出す
    if(isGameCenterAPIAvailable() == 1){
        [self authenticateLocalPlayer];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ゲームセンター
//ゲームセンター関係の処理

//ゲームセンターに接続できるかどうかの確認処理
BOOL isGameCenterAPIAvailable()
{
    // GKLocalPlayerクラスが存在するかどうかをチェックする
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) !=
    nil;
    // デバイスはiOS 4.1以降で動作していなければならない
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (localPlayerClassAvailable && osVersionSupported);
}

//Gamecenterに接続する処理
- (void) authenticateLocalPlayer
{
    //バージョン確認
    NSString *version = [[UIDevice currentDevice]systemVersion];
    NSLog(@"Version %@", version);
    
    // iOS 6
    if([ version floatValue] >= 6.0) {
        GKLocalPlayer* player = [GKLocalPlayer localPlayer];
        player.authenticateHandler = ^(UIViewController* ui, NSError* error )
        {
            if( nil != ui )
            {
                [self presentViewController:ui animated:YES completion:nil];
            }
            else if( player.isAuthenticated )
            {
                // 認証に成功
                NSLog(@"ios6:認証OK");
            }
            else
            {
                // 認証に失敗
                NSLog(@"ios6:認証NG");
            }
        };
    }else{
        //ios5.1以前
        GKLocalPlayer* player = [GKLocalPlayer localPlayer];
        [player authenticateWithCompletionHandler:^(NSError* error)
         {
             if( player.isAuthenticated )
             {
                 // 認証に成功
                 NSLog(@"ios5:認証OK");
                 
             }
             else
             {
                 // 認証に失敗
                 NSLog(@"ios5:認証NG");
                 
             }
         }];
        
        
    }
}


//リーダーボードを立ち上げる
//UIButtonなどにアクションを関連づけて使用します。
//ランキングを表示する画面が表示されます。
# pragma -mark SOUND
//音を再生するメソッド
-(void) playSound:(NSString *)filename{
    //OK音再生
    SystemSoundID soundID;
    NSURL* soundURL = [[NSBundle mainBundle] URLForResource:filename
                                              withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound (soundID);
}

-(IBAction)showBord
{
    //音再生
    [self playSound:@"ok"];
    
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentViewController: leaderboardController animated: YES completion:nil];
    }
}

//リーダーボードで完了を押した時に呼ばれる（リーダーボードを閉じる処理）
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Dismiss completed");
        //[self interstitalAdd:nil];
    }];
    
}



-(void)sendLeaderboard{
    //リーダーボードに値を送信
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"ItazuraRanking"];
    NSInteger scoreR;
    //scoreRにゲームのスコアtapCountを格納
    scoreR = [score integerForKey:@"SCORE"];
    scoreReporter.value = scoreR;
    
    //scoreRepoterにハイスコアを格納
    //ハイスコアを送信
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // 報告エラーの処理
            NSLog(@"error %@",error);
        }else{
            // リーダーボードに値を送信
            NSLog(@"リーダーボードに値を送信");
        }
    }];
}



@end
