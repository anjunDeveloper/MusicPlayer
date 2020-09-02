//
//  AudioManager.m
//  YYFocus
//
//  Created by jztx on 2017/7/24.
//  Copyright © 2017年 九指天下. All rights reserved.
//

#import "AudioManager.h"
#import "AudioItem.h"



// 音频管理单例

@interface AudioManager ()

/** 播放进度监听 */
@property (nonatomic, strong) id playbackTimeObserver;

@end

@implementation AudioManager

+ (instancetype)sharedAudioManager
{
	 static AudioManager * instance = nil;
	 static dispatch_once_t onceToken;
	 dispatch_once(&onceToken, ^{
		  instance = [[self alloc] init];
	 });
	 return instance;
}

// 设置音频会话
- (void)setAudioSession{
	 AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	 
	 NSError *sessionError;
	 // 设置为播放模式,否则播放的声音会很小
	 [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
	 [audioSession setActive:YES error:nil];
}

- (void)setupPlayerWithAudioItem:(AudioItem *)audioItem
{
    [self removeCurrentTimeObserver];
    
	 _audioItem = audioItem;

	 [self setAudioSession];
	 
	 if(audioItem.isLocalFile)
	 {
		  // 本地mp3文件或者wav文件，都以这种方式初始化
		  NSURL *sourceMovieUrl = [NSURL fileURLWithPath:audioItem.audioURLStr];
		  AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
		  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
		  _songItem = playerItem;
		  _player = [[AVPlayer alloc] initWithPlayerItem:_songItem];
	 }else{
		  // 网络音频资源 
		  NSURL * url  = [NSURL URLWithString:audioItem.audioURLStr];
		  AVPlayerItem * songItem = [[AVPlayerItem alloc] initWithURL:url];
		  _songItem = songItem;
		  _player = [[AVPlayer alloc] initWithPlayerItem:_songItem];
	 }
	 
	 // 给AVPlayerItem添加"播放完成"通知
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

// 监听播放进度
- (void)observePlayTime
{
	 self.hasObserveProgress = YES;
	 WEAKSELF
	 if(self.playbackTimeObserver)
	 {
		  [self.player removeTimeObserver:self.playbackTimeObserver]; // 先移除
		  self.playbackTimeObserver = nil;
	 }
	 
    // 这里一定需要用一个属性强引用这个返回值，add与remove是成对使用的，见官方文档说明：https://developer.apple.com/documentation/avfoundation/avplayer/1385829-addperiodictimeobserverforinterv
	 self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
		  double current = weakSelf.songItem.currentTime.value/weakSelf.songItem.currentTime.timescale; // 已经播放时长
		  CMTime duration = weakSelf.songItem.duration; // 获取视频总长度
         
         double timescale = duration.timescale;
         
         double total;
         if(timescale == 0){
             total = 0;
         }else{
             total = weakSelf.audioItem.duration == 0 ? duration.value / duration.timescale : weakSelf.audioItem.duration;// 转换成秒
         }
         
         if(self.totalTime == 0){
             weakSelf.totalTime = total;
         }
         
		  if(isnan(current)) current = 0;
		  
		  if(weakSelf.player.currentItem.status == AVPlayerStatusReadyToPlay)
		  {
			   if (current) {
					weakSelf.currentTime = current;
					
					// 进度显示
					if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioManager:currentTime:totalDuration:)])
					{
						 [weakSelf.delegate audioManager:weakSelf currentTime:current totalDuration:floor(total)];
					}
					
					// 播放、暂停按钮样式
					if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioManager:styleWithAudioPlayerState:)])
					{
						 [weakSelf.delegate audioManager:weakSelf styleWithAudioPlayerState:weakSelf.audioPlayerState];
					}
			   }
		  }
	 }];
}

#pragma mark - 基本方法
// 播放
- (void)play
{
    // 网络异常直接弹框return即可
    

	 [self observePlayTime];
	 
	 // 发送一个通知，这个通知用于停掉列表中正在播放的视频
//     [[NSNotificationCenter defaultCenter] postNotificationName:keyClickedAudioNotification object:nil];
	 
	 [self.player play];
	 
	 // 更改播放器状态
	 self.audioPlayerState = AudioPlayerStatePlaying;
	 
	 if(self.delegate && [self.delegate respondsToSelector:@selector(audioManager:styleWithAudioPlayerState:)])
	 {
		  [self.delegate audioManager:self styleWithAudioPlayerState:self.audioPlayerState];
	 }
}

// 暂停
- (void)pause
{
	 [self.player pause];
	 
	 self.currentTime = CMTimeGetSeconds(self.player.currentTime);
	 
	 // 更改播放器状态
	 self.audioPlayerState = AudioPlayerStatePaused;
	 
	 if(self.delegate && [self.delegate respondsToSelector:@selector(audioManager:styleWithAudioPlayerState:)])
	 {
		  [self.delegate audioManager:self styleWithAudioPlayerState:self.audioPlayerState];
	 }
}

// 重播
- (void)replayAudio
{
	 WEAKSELF
	 weakSelf.playToEnd = NO;
	 [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
		  [weakSelf play];
	 }];
}

#pragma mark - 音频播放完毕
- (void)playbackFinished:(NSNotification *)notice
{
	 // 更改播放器状态
	 self.audioPlayerState = AudioPlayerStateFinishPlay;
	 
	 self.playToEnd = YES;
	 // 通知代理需要刷新自己的UI效果，进度条归位，显示时间还原
	 if(self.delegate && [self.delegate respondsToSelector:@selector(audioManagerPlayFinished:)])
	 {
		  [self.delegate audioManagerPlayFinished:self];
	 }
}

#pragma mark - 从指定处开始播放
- (void)seekToTimePlay:(double)seekToTime
{
	 WEAKSELF
	 CMTime currentCMTime = CMTimeMake(seekToTime, 1);
	 if(self.player.currentItem.status == AVPlayerStatusReadyToPlay)
	 {
		  [self.player seekToTime:currentCMTime completionHandler:^(BOOL finished) {
			   
			   // 继续播放
			   [weakSelf play];
		  }];
	 }
}

#pragma mark - 销毁
- (void)destrory
{
	 [self.player pause];
    
	 // 通知代理需要刷新自己的UI效果，进度条归位，显示时间还原
	 if(self.delegate && [self.delegate respondsToSelector:@selector(audioManagerPlayFinished:)])
	 {
		  [self.delegate audioManagerPlayFinished:self];
	 }
	 
	 self.audioItem = nil;
     [self removeCurrentTimeObserver];
	 self.player = nil;
	 self.songItem = nil;
	 self.delegate = nil;
	 self.currentTime = 0;
	 self.playToEnd = NO;
	 self.hasObserveProgress = NO;
	 
}

- (void)removeCurrentTimeObserver{
    if(self.playbackTimeObserver)
    {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
}

@end
