//
//  AudioManager.h
//  YYFocus
//
//  Created by jztx on 2017/7/24.
//  Copyright © 2017年 九指天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// 强弱引用
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

/********************************************** AudioManagerDelegate ************************************************/

typedef NS_ENUM(NSInteger,AudioPlayerState) {
    AudioPlayerStateDefault = 98,          // 默认状态，初始状态
    AudioPlayerStateReadyToPlay = 99,      // 准备就绪
    AudioPlayerStatePlaying = 100,         // 播放状态
    AudioPlayerStatePaused = 101,          // 暂停状态
    AudioPlayerStateFinishPlay = 102       // 播放完毕状态
};

@class AudioManager,AudioItem;
@protocol AudioManagerDelegate <NSObject>

@optional

/**
 代理实现这个方法，得到单例中的播放器播放进度，展示在UI上
 
 @param audioManager 单例
 @param currentTime 单例中的播放器播放进度
 @param totalDuration 总时长
 */
- (void)audioManager:(AudioManager *)audioManager currentTime:(double)currentTime totalDuration:(double)totalDuration;


/**
 音频播放完毕(告诉代理需要刷新UI)
 
 @param audioManager 音频播放器单例
 */
- (void)audioManagerPlayFinished:(AudioManager *)audioManager;


/**
 根据单例中现在的播放状态，决定音频视图对应UI样式
 
 @param audioManager 音频播放器单例
 @param state 音频播放器状态
 */
- (void)audioManager:(AudioManager *)audioManager styleWithAudioPlayerState:(AudioPlayerState)state;

@end


/***************************************************** AudioManager ************************************************/

@interface AudioManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedAudioManager;

@property (nonatomic, strong) AVPlayer * player; ///< 播放器

@property (nonatomic, strong) AVPlayerItem * songItem;

@property (nonatomic, weak) id<AudioManagerDelegate> delegate; ///< 单例的代理，这个单例的代理会在程序的运行中根据情况不断改变

@property (nonatomic, assign) AudioPlayerState audioPlayerState;  ///< 当前的播放状态

@property (nonatomic, assign) BOOL playToEnd; ///< 是否播放完毕

@property (nonatomic, strong) AudioItem * audioItem; ///< 单例中的音频模型

@property (nonatomic, assign) double currentTime; ///< 当前播放的进度

@property (nonatomic, assign) double totalTime;  ///< 总时长

@property (nonatomic, assign) BOOL hasObserveProgress;


/**
 给单例一个音频模型，让其初始化播放器
 
 @param audioItem 音频模型
 */
- (void)setupPlayerWithAudioItem:(AudioItem *)audioItem;


/**
 从指定位置处播放(用户拖拽进度条的时候调用单例的这个方法)
 
 @param seekToTime 从多少秒处开始播放
 */
- (void)seekToTimePlay:(double)seekToTime;


/**
 音频播放器播放
 */
- (void)play;


/**
 音频播放器暂停
 */
- (void)pause;


/**
 重播
 */
- (void)replayAudio;


/**
 销毁,调用这个方法后，代理的样式也会随之还原
 */
- (void)destrory;

@end
