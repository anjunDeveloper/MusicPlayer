//
//  ToolBar.h
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/4/2.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomSlider : UISlider

@end


/**
 工具条：进度、时间显示、上一曲、下一曲、播放暂停等
 */
@interface ToolBar : UIView<AudioManagerDelegate>

/** 播放按钮 */
@property (nonatomic, strong) UIButton * playBtn;

/** 滑动条 */
@property (nonatomic, strong) CustomSlider * slider;

/** 播放进度 */
@property (nonatomic, strong) UILabel * currentProgressLabel;

/** 总时长 */
@property (nonatomic, strong) UILabel * totalProgressLabel;

/** 是否正在播放 */
@property (nonatomic,assign, getter=isPlaying) BOOL playing;

/** 点击上一曲回调 */
@property (nonatomic, copy) void (^clickLastHandler)(void);

/** 点击下一曲回调 */
@property (nonatomic, copy) void (^clickNextHandler)(void);

/** 播放完成的回调 */
@property (nonatomic, copy) void (^didFinishPlay)(void);

/** 歌曲总时长 */
@property (nonatomic, assign) double duration;

@end

NS_ASSUME_NONNULL_END
