//
//  AudioItem.h
//  YYFocus
//
//  Created by 安俊 on 17/7/6.
//  Copyright © 2017年 九指天下. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AudioItem : NSObject

/** 音频文件标题 */
@property (nonatomic, copy) NSString * title;

/** 音频文件时长 */
@property (nonatomic, assign) NSTimeInterval duration;

/** 音频地址 */
@property (nonatomic, copy) NSString * audioURLStr;

/** 是否是播放本地文件 */
@property (nonatomic, assign,getter = isLocalFile) BOOL LocalFile;

@property (nonatomic, assign) BOOL isWavFile;

/** 音频上传地址 */
@property (nonatomic, copy) NSString * audioSendURLStr;

/** 对应本地的歌词文件名 */
@property (nonatomic, copy) NSString * fileName;

/** N行歌词模型构成的数组 */
@property (nonatomic, copy) NSArray * lrcLineArr;

/** 歌手名 */
@property (nonatomic, copy) NSString * singer;

/** 歌手头像 */
@property (nonatomic, strong) UIImage * singerIcon;


@end
