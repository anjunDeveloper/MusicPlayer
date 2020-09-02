//
//  ToolBar.m
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/4/2.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import "ToolBar.h"
#import "Masonry.h"
#import "AudioManager.h"

@implementation CustomSlider

// 控制slider的宽和高，这个方法才是真正的改变slider滑道高度的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, (CGRectGetHeight(self.frame)-3)/2.0, CGRectGetWidth(self.frame), 2);
}

@end

@interface ToolBar ()

/** 是否已经停止拖拽 */
@property (nonatomic, assign) BOOL didEndDragging;

@end

@implementation ToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI{

    self.didEndDragging = YES;
    
    // 中间的播放按钮
    UIButton * playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn = playBtn;
//    playBtn.backgroundColor = [UIColor yellowColor];
    [playBtn setTitle:@"点击播放" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-35);
        make.centerX.mas_equalTo(0);
    }];
    
    // 上一曲
    UIButton * playLastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    playLastBtn.backgroundColor = [UIColor yellowColor];
    [playLastBtn setTitle:@"上一曲" forState:UIControlStateNormal];
    [playLastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playLastBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [playLastBtn addTarget:self action:@selector(playLastAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playLastBtn];
    [playLastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(playBtn);
        make.right.mas_equalTo(playBtn.mas_left).offset(-40);
    }];
    
    // 下一曲
    UIButton * playNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    playNextBtn.backgroundColor = [UIColor yellowColor];
    [playNextBtn setTitle:@"下一曲" forState:UIControlStateNormal];
    [playNextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playNextBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [playNextBtn addTarget:self action:@selector(playNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playNextBtn];
    [playNextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(playBtn);
        make.left.mas_equalTo(playBtn.mas_right).offset(40);
    }];
    
    // 进度条
    CustomSlider * slider = [[CustomSlider alloc] init];
    [slider setThumbImage:[UIImage imageNamed:@"kr-video-player-point"] forState:UIControlStateNormal];
    [slider setMinimumTrackTintColor:[UIColor redColor]]; // 滑过的颜色
    [slider setMaximumTrackTintColor:[UIColor purpleColor]]; // 底色
    [slider addTarget:self action:@selector(sliderValueChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
//    [slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];

    self.slider = slider;
    [self addSubview:slider];
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(80);
        make.right.mas_equalTo(-80);
        make.bottom.mas_equalTo(playBtn.mas_top).offset(-30);
        make.top.mas_equalTo(20);
    }];
    
    // 已播放时长label
    UILabel * currentProgressLabel = [[UILabel alloc] init];
    self.currentProgressLabel = currentProgressLabel;
    currentProgressLabel.text = @"00:00";
    currentProgressLabel.font = [UIFont systemFontOfSize:12];
    currentProgressLabel.textColor = [UIColor whiteColor];
    currentProgressLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:currentProgressLabel];
    [currentProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(slider.mas_left).offset(10);
        make.centerY.mas_equalTo(slider);
    }];
    
    // 总时长label
    UILabel * totalProgressLabel = [[UILabel alloc] init];
    self.totalProgressLabel = totalProgressLabel;
    totalProgressLabel.text = @"00:00";
    totalProgressLabel.font = [UIFont systemFontOfSize:12];
    totalProgressLabel.textColor = [UIColor whiteColor];
    totalProgressLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:totalProgressLabel];
    [totalProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(slider.mas_right).offset(10);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(slider);
    }];
}

#pragma mark - action method

// 播放/暂停
- (void)playAction:(UIButton *)btn{
    AudioManager * manager = [AudioManager sharedAudioManager];
    if(manager.audioPlayerState == AudioPlayerStatePlaying){
        // 执行暂停
        [manager pause];
    }else{
        // 执行播放
        [manager play];
    }
}

// 上一曲
- (void)playLastAction:(UIButton *)btn{
    if(self.clickLastHandler){
        self.clickLastHandler();
    }
}

// 下一曲
- (void)playNextAction:(UIButton *)btn{
    if(self.clickNextHandler){
        self.clickNextHandler();
    }
}

// 滑块滑动事件
- (void)sliderValueChanged:(UISlider *)slider{
    double currentTime = slider.value;
    self.currentProgressLabel.text = [self getTimeStrByDuration:currentTime];
}

- (void)sliderValueChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch * touchEvent = [[event allTouches] anyObject];
    switch(touchEvent.phase) {
        case UITouchPhaseBegan:
            NSLog(@"开始拖动");
            break;
        case UITouchPhaseMoved:
            self.didEndDragging = NO;
            break;
        case UITouchPhaseEnded:
            self.didEndDragging = YES;
            break;
        default:
            break;
    }
    
    double currentTime = slider.value;
    self.currentProgressLabel.text = [self getTimeStrByDuration:currentTime];
}

// 终止滑动
- (void)sliderTouchUpInSide:(UISlider *)slider{
    double currentTime = slider.value;
    AudioManager * manager = [AudioManager sharedAudioManager];
    [manager seekToTimePlay:currentTime];
}

#pragma mark - AudioManagerDelegate

// 一秒调用一次，表示进度,用来展示进度UI
- (void)audioManager:(AudioManager *)audioManager currentTime:(double)currentTime totalDuration:(double)totalDuration{
    
    if(totalDuration && self.duration != totalDuration){
        self.duration = totalDuration;
    }
    
    // 当前播放时间
    if(self.didEndDragging){
        self.currentProgressLabel.text = [self getTimeStrByDuration:currentTime];
    }
    
    // 总时间
    self.totalProgressLabel.text = [self getTimeStrByDuration:totalDuration];
    
    if(self.duration > 0 && self.didEndDragging){
        self.slider.value = currentTime;
    }
}

// 根据当前播放状态展示对应的UI
- (void)audioManager:(AudioManager *)audioManager styleWithAudioPlayerState:(AudioPlayerState)state{
    if(state == AudioPlayerStatePlaying){
        [self.playBtn setTitle:@"点我暂停" forState:UIControlStateNormal];
    }else{
        [self.playBtn setTitle:@"点我播放" forState:UIControlStateNormal];
    }
}

// 播放完成回调
- (void)audioManagerPlayFinished:(AudioManager *)audioManager{
    self.slider.value = 0;
    self.currentProgressLabel.text = @"00:00";
    
    if(self.didFinishPlay){
        self.didFinishPlay();
    }
}

#pragma mark - helper method

// 根据时长得到一个字符串，如210秒 --> 03:30
- (NSString *)getTimeStrByDuration:(double)duration
{
    if(isnan(duration)) duration = 0;
    
    double totalMinute = floor(duration/60); // 向下取(总时长的分钟数)
    double totalSecond = fmod(duration, 60); // 取余数(总时长的秒数)
    
    return [NSString stringWithFormat:@"%02.0f:%02.0f",totalMinute,totalSecond];
}

- (void)setDuration:(double)duration{
    _duration = duration;
    
    self.slider.maximumValue = duration;
}

@end
