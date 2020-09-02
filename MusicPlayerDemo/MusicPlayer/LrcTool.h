//
//  LrcTool.h
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 歌词解析器
 */
@interface LrcTool : NSObject

/**
 传递一个歌词文件名，得到一个数组，每个元素就是一行歌词

 @param lrcname 歌词文件名
 @return LrcLine模型数组
 */
+ (NSArray *)lrcToolWithLrcname:(NSString *)lrcname;

@end

NS_ASSUME_NONNULL_END
