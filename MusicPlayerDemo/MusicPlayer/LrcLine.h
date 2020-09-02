//
//  LrcLine.h
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 该模型对应每一行歌词
 */
@interface LrcLine : NSObject

/** 时间(单位：秒) */
@property (nonatomic, assign) NSTimeInterval time;

/** 歌词 */
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithLrcString:(NSString *)lrcString;

+ (instancetype)lrclineWithLrcString:(NSString *)lrcString;

@end

NS_ASSUME_NONNULL_END
