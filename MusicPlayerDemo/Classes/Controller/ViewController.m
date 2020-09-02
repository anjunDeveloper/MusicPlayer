//
//  ViewController.m
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/26.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "AudioItem.h"
#import "LrcTool.h"
#import "LrcCell.h"
#import "LrcLine.h"
#import "LrcLabel.h"
#import "ToolBar.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


/** 歌词展示的区域 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 下方的工具条 */
@property (weak, nonatomic) IBOutlet ToolBar *toolView;

@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) AudioManager * manager;

/** 当前正在播放的歌词的下标 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 歌词的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

/** 是否能自动滚动歌词 */
@property (nonatomic, assign) BOOL canAutoScroll;

/** 正在播放的歌曲索引 */
@property (nonatomic, assign) NSInteger playingIndex;

/** 歌手名数组(仅供模拟使用) */
@property (nonatomic, copy) NSArray * singersArr;

@end

@implementation ViewController

/*
 待优化的问题:
 
 1.显示锁屏信息的方法，什么时候调用最合适呢?
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playingIndex = 1;
    
    self.canAutoScroll = YES;
    
    // 注册cell
    [self.tableView registerClass:LrcCell.class forCellReuseIdentifier:@"LrcCell"];
    
    // 歌曲数据初始化
    [self setupDataSource];
    
    // 监听回调
    [self observeHandler];
    
    // 远端音频资源
    __unused NSString * audioUrl = @"http://ra01.sycdn.kuwo.cn/resource/n3/32/56/3260586875.mp3";
    
    // 设置当前需要播放的歌曲
    [self changeAudioItemWithFileName:[self.dataArr objectAtIndex:self.playingIndex] atIndex:self.playingIndex];
    
    // 歌词定时器
    [self addLrcTimer];
    
    // 刷新表单
    [self.tableView reloadData];
    
    // 开启远程控制
    [self createRemoteCommandCenter];
}

#pragma mark - private method

- (void)setupDataSource{
    self.singersArr = @[@"邓紫棋",@"周杰伦",@"林俊杰"];
    self.dataArr = [NSMutableArray arrayWithObjects:@"14945107",@"10736444",@"309769", nil];
}

// 生成歌词数据源
- (void)setupLrc{
    
    AudioItem * item = self.manager.audioItem;
    
    // 得到歌词
    item.lrcLineArr = [LrcTool lrcToolWithLrcname:item.fileName];
}

- (void)addLrcTimer
{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

- (void)updateLrc{
    
    self.currentTime = CMTimeGetSeconds(self.manager.player.currentTime);
    
    NSLog(@"------------当前播放时间:%f",self.currentTime);
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    
    // 1.和数组中歌词的时间对比,找出应该显示的歌词
    NSInteger count = self.manager.audioItem.lrcLineArr.count;
    for (int i = 0; i < count; i++) {
        // 2.取出当前句的歌词
        LrcLine *lrcline = self.manager.audioItem.lrcLineArr[i];
        
        // 3.取出下一句歌词
        NSInteger nextIndex = i + 1;
        if (nextIndex > count - 1) return;
        LrcLine *nextLrcline = self.self.manager.audioItem.lrcLineArr[nextIndex];
        
        // 4.让当前播放时间和当前句歌词的时间和下一句歌词的时间对比,如果当前时间大于等于当前句歌词的时间,并且小于下一句歌词的时间,显示该句歌词
        // 03:25.84
        /*
         [00:48.15]你是我的小呀小苹果儿
         [00:51.92]怎么爱你都不嫌多
         
         [00:48.15]-->[00:51.92]
         [00:51.92] - [00:48.15] / [00:51.92] - [00:48.15]
         */
        if (currentTime >= lrcline.time && currentTime < nextLrcline.time && self.currentIndex != i) {
            // 4.1.获取前一句播放歌词的NSIndexPath
            NSMutableArray *indexs = [NSMutableArray array];
            if (self.currentIndex < count - 1) {
                NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
                [indexs addObject:previousIndexPath];
            }

            // 4.2.记录当前播放句的下标值
            self.currentIndex = i;

            // 4.3.获取当前句的NSIndexPath
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexs addObject:indexPath];

            // 4.4.刷新歌词
            [self.tableView reloadRowsAtIndexPaths:indexs withRowAnimation:UITableViewRowAnimationNone];
            
            // 4.5.让tableView的当前播放的句,滚动中间位置
            if(self.canAutoScroll){
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
            
        }

        // 如果正在更新某一句歌词
        if (self.currentIndex == i) {
            // 1.取出i位置的cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LrcCell *cell = (LrcCell *)[self.tableView cellForRowAtIndexPath:indexPath];

            // 2.更新cell中的lrcLabel的进度
            cell.lrcLabel.progress = (currentTime - lrcline.time) / (nextLrcline.time - lrcline.time);
            
#warning 这个更新锁频信息的时机、频率还需要斟酌!!!
            if(cell.lrcLabel.text.length){
                // 锁屏信息
                [self showLockScreenTotaltime:self.manager.totalTime andCurrentTime:self.currentTime currentLrc:cell.lrcLabel.text];
            }
        }
    }
}

//锁屏界面开启和监控远程控制事件
- (void)createRemoteCommandCenter{

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 允许耳机控制播放和暂停
    commandCenter.togglePlayPauseCommand.enabled = YES;
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPause)];
    
    // 暂停
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.manager pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 播放
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.manager play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 上一曲
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playLastSong];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 下一曲
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self playNextSong];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 快进
    //    MPSkipIntervalCommand *skipBackwardIntervalCommand = commandCenter.skipForwardCommand;
    //    skipBackwardIntervalCommand.preferredIntervals = @[@(54)];
    //    skipBackwardIntervalCommand.enabled = YES;
    //    [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
    
    // 在控制台拖动进度条调节进度（仿QQ音乐的效果）
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        CMTime totlaTime = self.manager.player.currentItem.duration;
        
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        
        [self.manager.player seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale) completionHandler:^(BOOL finished) {
        }];
        
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

// 方法实现需要加上MPRemoteCommandHandlerStatus回调
- (MPRemoteCommandHandlerStatus)playOrPause{
    if(self.manager.audioPlayerState == AudioPlayerStatePlaying){
        // 当前正在播放，点击就暂停
        [self.manager pause];
    }else{
        // 当前处于暂停,点击就播放
        [self.manager play];
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)skipBackwardEvent:(MPSkipIntervalCommandEvent *)skipEvent
{
    NSLog(@"快进了 %f秒", skipEvent.interval);
}

// 展示锁屏歌曲信息：图片、歌词、进度、歌曲名、演唱者、专辑、（歌词是绘制在图片上的）
- (void)showLockScreenTotaltime:(float)totalTime andCurrentTime:(float)currentTime currentLrc:(NSString *)currentLrc{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if(playingInfoCenter){
        
        // setObject:forKey: 保证value有值，否则会crash
        NSMutableDictionary * songDict = [[NSMutableDictionary alloc] init];
        
        AudioItem * item = self.manager.audioItem;
        
        // 设置歌曲题目
        [songDict setObject:item.title forKey:MPMediaItemPropertyTitle];
        
        // 设置歌手名
//        [songDict setObject:item.singer forKey:MPMediaItemPropertyArtist];
        
        // 设置专辑名
        [songDict setObject:@"专辑名" forKey:MPMediaItemPropertyAlbumTitle];
        
        // 设置歌曲时长
        [songDict setObject:[NSNumber numberWithDouble:totalTime]  forKey:MPMediaItemPropertyPlaybackDuration];
        
        // 设置已经播放时长
        [songDict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        UIImage * lrcImage = [UIImage imageNamed:@"WechatIMG15.jpeg"];
        
        // 设置显示的海报图片
        
        [songDict setObject:[[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(70, 70) requestHandler:^UIImage * _Nonnull(CGSize size) {
            
            
            return lrcImage;
        }] forKey:MPMediaItemPropertyArtwork];
        
        // 设置歌词
        [songDict setObject:currentLrc forKey:MPMediaItemPropertyAlbumTitle];
        
        // 加入正在播放媒体的信息中心
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songDict];
    }
}

#pragma mark - action method

- (void)observeHandler{
    
    WEAKSELF
    [self.toolView setClickLastHandler:^{
        STRONGSELF
        [strongSelf playLastSong];
    }];
    
    [self.toolView setClickNextHandler:^{
        STRONGSELF
        [strongSelf playNextSong];
    }];
    
    [self.toolView setDidFinishPlay:^{
        STRONGSELF
        [strongSelf playNextSong];
    }];
}

/**
 播放上一曲
 */
- (void)playLastSong{
    // tableview归位
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    
    // 生成上一首歌曲对应的模型
    self.playingIndex --;
    
    if(self.playingIndex < 0){
        self.playingIndex = self.dataArr.count - 1;
    }

    [self changeAudioItemWithFileName:[self.dataArr objectAtIndex:self.playingIndex] atIndex:self.playingIndex];
    [self.manager play];
    
    // 刷新表单
    [self.tableView reloadData];
}

/**
 播放下一曲
 */
- (void)playNextSong{
    // tableview归位
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    
    // 生成下一首歌曲对应的模型
    self.playingIndex ++;
    
    if(self.playingIndex > self.dataArr.count -1){
        self.playingIndex = 0;
    }
    
    [self changeAudioItemWithFileName:[self.dataArr objectAtIndex:self.playingIndex] atIndex:self.playingIndex];
    [self.manager play];
    
    // 刷新表单
    [self.tableView reloadData];
}

// 给manager设置数据源
- (void)changeAudioItemWithFileName:(NSString *)fileName atIndex:(NSInteger)index{
    // 本地音频资源路径
    NSString * localAudioPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.mp3",fileName] ofType:nil];
    
    self.manager = [AudioManager sharedAudioManager];
    self.manager.delegate = self.toolView;
    AudioItem * audioItem = [[AudioItem alloc] init];
    
    [self configAudioItemInfoWithIndex:index audioItem:audioItem];
    
    // 表明是本地文件
    audioItem.LocalFile = YES;
    
    audioItem.audioURLStr = localAudioPath;
    audioItem.fileName = [NSString stringWithFormat:@"%@.lrc",fileName];

    // 初始化player
    [self.manager setupPlayerWithAudioItem:audioItem];
    
    // 更新界面信息
    [self updateUI];
    
    // 歌词初始化
    [self setupLrc];
}

- (void)configAudioItemInfoWithIndex:(NSInteger)index audioItem:(AudioItem *)item{
    if(index == 0){
        item.singer = @"邓紫棋";
        item.title = @"泡沫";
        item.singerIcon = [UIImage imageNamed:@"dzq"];
    }else if (index == 1){
        item.singer = @"周杰伦";
        item.title = @"简单爱";
        item.singerIcon = [UIImage imageNamed:@"jay"];
    }else if (index ==2){
        item.singer = @"林俊杰";
        item.title = @"一千年以后";
        item.singerIcon = [UIImage imageNamed:@"jj"];
    }
}

- (void)updateUI{
    self.backgroundImageView.image = self.manager.audioItem.singerIcon;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LrcLine * line = [[AudioManager sharedAudioManager].audioItem.lrcLineArr objectAtIndex:indexPath.row];
    
    LrcCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LrcCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lineModel = line;
    
    if (indexPath.row == self.currentIndex) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:18];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:14.0];
        cell.lrcLabel.progress = 0;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [AudioManager sharedAudioManager].audioItem.lrcLineArr.count;
}

// 点击某句歌词
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 去除点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 找到对应的模型，取出时间
    LrcLine * line = [self.manager.audioItem.lrcLineArr objectAtIndex:indexPath.row];
    
    // 从该时间处开始播放
    [self.manager seekToTimePlay:line.time];
    
    self.canAutoScroll = YES;
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.canAutoScroll = NO;
}

// 这里我们设置，手指放开一秒后，让其可以自动滚动歌词
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.canAutoScroll = YES;
}

#pragma mark - lazy load

- (NSMutableArray *)dataArr{
    if(!_dataArr){
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

#pragma mark - 状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
