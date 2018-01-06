//
//  GameViewController.m
//  TheLastHair
//
//  Created by UDONKONET on 2018/01/03.
//  Copyright © 2018年 UDONKONET. All rights reserved.
//

#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define MAXHAIR     999999999  //最大値制限
#define ANGRY       250         //怒られる確率
#define COMBO       100         //海平コンボの確率
#define REVIEW      50          //レビューしろアラートを表示するプレイ回数

@interface GameViewController (){
    int nuitaFlg;           //髪の毛を抜いたかどうかの判定
    bool umiheiFlg;          //海平コンボ発動かどうかの判定
    bool umiheiDidEndFlg;    //海平コンボを表示＆計算したかどうかのフラグ
    bool namiheiDidEndFlg;    //波平時の表示＆計算したかどうかのフラグ
    int unplugedNumber;     //抜いた本数
    int gameoverFlg;
    int umiheirnd;
    int angryrnd;
    NSUserDefaults *score;  //スコア保存用
    NSUserDefaults *playCount;  //ゲームをプレイした回数　レビュー以来のアラートの表示に利用
    int playCountBefore;        //プレイ回数の前回値
    
    CGPoint touchBeginPoint;
    float hairY;
    bool isAnimating;
    
}
//@property (weak, nonatomic) IBOutlet UIImageView *hairImageView;
//@property (weak, nonatomic) IBOutlet UILabel *unplugLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *umiheiComboImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *namiheiFaceImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *namiheiHeadImageView;
//@property (weak, nonatomic) IBOutlet UIImageView *bakamonImageView;
//@property (weak, nonatomic) IBOutlet UIView *gameOverView;
//@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
//@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *fingerImageView;

@property (weak, nonatomic) IBOutlet UIImageView *fingerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hairImageView;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *unplugLabel;
@property (weak, nonatomic) IBOutlet UIImageView *umiheiComboImageView;
@property (weak, nonatomic) IBOutlet UIImageView *namihei;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    //ゲームオーバー画面の角丸設定
    self.gameOverView.layer.cornerRadius = 10;
    
    //ゲームオーバーフラグを下げる
    gameoverFlg =0;
    
    //抜いたフラグを下げる
    nuitaFlg = 0;
    
    //海平コンボを表示＆計算したかどうかのフラグを下げる
    umiheiDidEndFlg = NO;
    
    //波平時の表示＆計算したかどうかのフラグ下げる
    namiheiDidEndFlg = NO;
    
    //毛を表示
    self.hairImageView.hidden = NO;
    
    
    //ハイスコアを読み出し
    score = [NSUserDefaults standardUserDefaults];
    
    //プレイ回数を読み出し
    playCount = [NSUserDefaults standardUserDefaults];
    //userdefaultに保存した値を前回値として読み出し
    playCountBefore = [playCount integerForKey:@"play"];
    
    //抜いた数を0クリア
    unplugedNumber = 0;
    self.unplugLabel.text = [NSString stringWithFormat:@"%d本抜き",unplugedNumber];
    
    //毛を１８０度回転
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-180.0f * (M_PI / 180.0f));
    //[self.hairImageView setTransform:rotation];
    
    
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    //髪の初期位置とサイズ
    self.hairImageView.frame = CGRectMake(self.hairImageView.frame.origin.x,
                                          self.namihei.frame.origin.y - 30,
                                          self.hairImageView.frame.size.width,
                                          50);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gameover{
    NSLog(@"ゲームオーバー");
}

#pragma mark - タッチイベント
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //タッチイベントの設定
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    NSInteger taps = [touch tapCount];
    [super touchesBegan:touches withEvent:event];
    NSLog(@"タップ開始 %f, %f  タップ数：%d",location.x, location.y, taps);
    
    touchBeginPoint = location;
    
    
}


//ドラッグ中に繰り返し発生
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if( gameoverFlg ==0){
        //怒り発動の確率設定
        angryrnd = rand()% ANGRY;
        //怒りが0になったらゲームオーバー
        if(angryrnd == 0){
            [self gameover];
        }
        
        UITouch *touch = [touches anyObject];
        //ドラッグ前の位置
        CGPoint oldLocation = [touch previousLocationInView:self.view];
        //ドラッグ後の位置
        CGPoint newLocation = [touch locationInView:self.view];
        [super touchesMoved:touches withEvent:event];
        
        
        //毛を引っ張ります
        NSLog(@"指の動き：%f , %f から %f, %f", oldLocation.x, oldLocation.y, newLocation.x, newLocation.y);
        
        
        float height = 50 + touchBeginPoint.y - newLocation.y;
        if(height < 50){
            height = 50;
        }
        
        NSLog(@"差分：%f ｙポジション:%f", touchBeginPoint.y - newLocation.y, self.hairImageView.frame.origin.y);
        self.hairImageView.frame = CGRectMake(self.hairImageView.frame.origin.x,
                                              (self.namihei.frame.origin.y + 30) - height - 10 ,
                                              self.hairImageView.frame.size.width,
                                              height);
        
        self.fingerImageView.frame = CGRectMake(self.hairImageView.frame.origin.x - self.fingerImageView.frame.size.width * 0.2,
                                                self.hairImageView.frame.origin.y - self.fingerImageView.frame.size.height + 20,
                                                self.fingerImageView.frame.size.width,
                                                self.fingerImageView.frame.size.height
                                                );
        
        [self.fingerImageView setHidden:NO];
        
    }
    //    //ゲームオーバーじゃないときだけタッチイベントが有効
    //    if( gameoverFlg ==0){
    //
    //        //怒り発動の確率設定
    //        angryrnd = rand()% ANGRY;
    //        NSLog(@"ばかもん：%d",angryrnd);
    //        //怒りが0になったらゲームオーバー
    //        if(angryrnd == 0){
    //            [self gameover];
    //        }
    //
    //
    //        //タッチイベント設定
    //        UITouch *touch = [touches anyObject];
    //        //ドラッグ前の位置
    //        CGPoint oldLocation = [touch previousLocationInView:self.view];
    //        //ドラッグ後の位置
    //        CGPoint newLocation = [touch locationInView:self.view];
    //        [super touchesMoved:touches withEvent:event];
    //
    //
    //        //毛を引っ張ります
    //        NSLog(@"指の動き：%f , %f から %f, %f", oldLocation.x, oldLocation.y, newLocation.x, newLocation.y);
    //
    //        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    //
    //
    //        //ドラッグした位置をもとに、指のY座標を変更
    //        [self.fingerImageView setCenter:CGPointMake(screenSize.width * 0.5 + self.fingerImageView.frame.size.width * 0.3,
    //                                                    self.hairImageView.frame.origin.y + (-1)*(90+oldLocation.y-newLocation.y) + 10)];
    //
    //        //指を表示
    //        if(gameoverFlg == 0){
    //            self.fingerImageView.hidden = NO;
    //        }
    //
    //        //ドラッグした位置をもとに、画像の高さとY座標を変更（伸び縮み）
    //        [self.hairImageView setFrame:CGRectMake(screenSize.width * 0.5 ,
    //                                           self.hairImageView.frame.origin.y + (-1)*(oldLocation.y-newLocation.y),
    //                                           self.hairImageView.frame.size.width,
    //                                           self.hairImageView.frame.size.height + (oldLocation.y-newLocation.y))];
    //
    //        //毛が縮みます　高さが２０以下、Y座標が200以上、抜けてない時は高さとY座標を固定する（縮みすぎないようにする）
    //        if(self.hairImageView.frame.size.height <=20 && self.hairImageView.frame.origin.y >=200 && nuitaFlg == 0){
    //            [self.hairImageView setFrame:CGRectMake(self.hairImageView.frame.origin.x,
    //                                                    self.namihei.frame.origin.y + 20,
    //                                                    self.hairImageView.frame.size.width,
    //                                                    20)];
    //        }
    //
    //
    //        //毛が抜けます　Y座標が40以下になった、または抜いた後は毛の高さを70に固定（のばしていた画像を一定の大きさに固定する事によって抜けたように見せる）
    //        if(self.hairImageView.frame.origin.y <=50 || nuitaFlg == 1){
    //            [self.hairImageView setFrame:CGRectMake(screenSize.width * 0.5,
    //                                                    self.hairImageView.frame.origin.y,
    //                                                    self.hairImageView.frame.size.width,
    //                                                    100)];
    //            NSLog(@"100以下だよ");
    //            nuitaFlg = 1;
    //
    //            //抜けているかどうかの判定
    //            if(nuitaFlg == 1){
    //                if (umiheiFlg == YES) {                      //脱毛コンボ発動！脱毛を計算＆アニメが終わっていなければ実行
    //                    if(umiheiDidEndFlg == NO){                  //海平を計算＆アニメが終わっていなければ実行
    //
    //                        NSLog(@"海平コンボ発動！！ポイント２倍");
    //                        unplugedNumber *= 2;                     //ポイントを２倍！
    //                        umiheiDidEndFlg = YES;                    //計算＆アニメーション終了
    //
    //                        //アニメーション
    //                        [self.umiheiComboImageView setHidden:NO];
    //                        [self.umiheiComboImageView setAlpha:1];
    //                        [UIView beginAnimations:nil context:nil];
    //                        [UIView setAnimationDuration:3.0];
    //                        [self.umiheiComboImageView setAlpha:0];
    //                        [UIView commitAnimations];
    //
    //                        //ラベルに表示
    //                        //max9999999999
    //                        if(unplugedNumber > MAXHAIR){
    //                            unplugedNumber = MAXHAIR;
    //                        }
    //                        self.unplugLabel.text = [NSString stringWithFormat:@"%d本抜き",unplugedNumber];
    //                        self.unplugLabel.textColor = [UIColor redColor];
    //
    //                        //バイブレーション発生
    //                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //                        //海平コンボ音再生
    //                        [self playSound:@"combo"];
    //                    }
    //                }else{
    //                    if(namiheiDidEndFlg == NO){
    //                        namiheiDidEndFlg = YES;
    //                        //通常時の計算＋ラベル表示＋音再生
    //                        unplugedNumber++;                        //抜いた本数を加算
    //                        //max9999999999
    //                        if(unplugedNumber > MAXHAIR){
    //                            unplugedNumber = MAXHAIR;
    //                        }
    //
    //                        //抜いた音再生
    //                        [self playSound:@"miss"];
    //
    //                        //ラベルに表示
    //                        self.unplugLabel.text = [NSString stringWithFormat:@"%d本抜き",unplugedNumber];
    //                        self.unplugLabel.textColor = [UIColor blackColor];
    //                    }
    //                }
    //            }
    //        }
    //    }
}


//タッチイベント終了時の処理
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    //指を非表示
    self.fingerImageView.hidden = YES;
    //    [self.fingerImageView setCenter:CGPointMake(214,88)];
    
    //ゲームオーバーじゃないときだけ実行
    if(gameoverFlg == 0){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        [super touchesEnded:touches withEvent:event];
        
        //umiheiDidEndFlgを戻す
        umiheiDidEndFlg = NO;
        namiheiDidEndFlg = NO;
        
        
        //抜けたかどうかの判定
        if(nuitaFlg == 1){
            //脱毛コンボ発動？ 100分の１の確率で発動
            umiheirnd = rand()%COMBO;
            if(umiheirnd == 0){
                umiheiFlg = YES;
                [self.hairImageView setImage:[UIImage imageNamed:@"hairtwin.png"]];  //２本ヘアーを表示
            }else{
                [self.hairImageView setImage:[UIImage imageNamed:@"hair.png"]];      //１本ヘアーを表示
                umiheiFlg = NO;
            }
            
            //アニメーション ニョキッと生えてきます
            [self.hairImageView setFrame:CGRectMake(screenSize.width * 0.5 ,
                                                    self.namihei.frame.origin.y + 20,
                                                    25,
                                                    10)];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [self.hairImageView setFrame:CGRectMake(screenSize.width * 0.5,
                                                    self.namihei.frame.origin.y - 30,
                                                    25,
                                                    60)];
            [UIView commitAnimations];
        }else{
            //失敗再生
            [self playSound:@"unplug"];
            
            if (!isAnimating) {
                isAnimating = YES; // 二重実行を防ぐためにフラグを立てる。
                
                //アニメーション 上下にふわふわ動きます。
                [self.hairImageView setFrame:CGRectMake(self.hairImageView.frame.origin.x,
                                                        self.namihei.frame.origin.y - 30,
                                                        self.hairImageView.frame.size.width,
                                                        50)];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDuration:0.07];
                [UIView setAnimationRepeatCount:4];
                [UIView setAnimationRepeatAutoreverses:YES];
                [self.hairImageView setFrame:CGRectMake(self.hairImageView.frame.origin.x,
                                                        self.namihei.frame.origin.y - 30 - 20,
                                                        self.hairImageView.frame.size.width,
                                                        70)];
                [UIView commitAnimations];
            }else{
                //髪の初期位置
                self.hairImageView.frame = CGRectMake(self.hairImageView.frame.origin.x,
                                                      self.namihei.frame.origin.y - 30,
                                                      self.hairImageView.frame.size.width,
                                                      50);

            }
        }
        //抜いたフラグをたてる
        nuitaFlg = 0;
        NSLog(@"タップ終了 %f, %f", location.x, location.y);
    }
}

// アニメーションの終了時にコールされる。
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    isAnimating = NO; // ここでフラグを落とす。
}

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


# pragma -mark UI
//戻るボタン
- (IBAction)backButton:(id)sender {
    
    
    //終わり音再生
    [self playSound:@"back"];
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
