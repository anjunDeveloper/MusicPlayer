//
//  LrcTool.m
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import "LrcTool.h"
#import "LrcLine.h"

@implementation LrcTool

+ (NSArray *)lrcToolWithLrcname:(NSString *)lrcname
{
    // 1.获取歌词的路径
    NSString *lrcFilePath = [[NSBundle mainBundle] pathForResource:lrcname ofType:nil];
    
    // 2.加载对应的歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:lrcFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *lrcArray = [lrcString componentsSeparatedByString:@"\n"];
    
    // 3.遍历每一句歌词
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *lrclineString in lrcArray) {
        // 3.1.过滤掉一些不需要的行号
        if ([lrclineString hasPrefix:@"[ti:"] || [lrclineString hasPrefix:@"[ar:"] || [lrclineString hasPrefix:@"[al:"] || ![lrclineString hasPrefix:@"["]) {
            continue;
        }
        
        // 3.2.将每一句歌词转成模型对象
        LrcLine *lrcline = [LrcLine lrclineWithLrcString:lrclineString];
        
        [tempArray addObject:lrcline];
    }
    
    return tempArray;
}

@end
