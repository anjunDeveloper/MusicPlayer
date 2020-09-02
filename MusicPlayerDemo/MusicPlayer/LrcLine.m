//
//  LrcLine.m
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import "LrcLine.h"

@implementation LrcLine

- (instancetype)initWithLrcString:(NSString *)lrcString
{
    if (self = [super init]) {
        // e.g.
        // [01:47.46]宁愿用这一生等你发现
        self.text = [[lrcString componentsSeparatedByString:@"]"] lastObject];
        // [01:47.46
        NSString *timeString = [[[lrcString componentsSeparatedByString:@"]"] firstObject] substringFromIndex:1];
        self.time = [self timeWithString:timeString];
    }
    return self;
}

- (NSTimeInterval)timeWithString:(NSString *)timeString
{
    // 01:47.46
    NSInteger min = [[[timeString componentsSeparatedByString:@":"] firstObject] integerValue];
    // 47.46
    NSInteger second = [[[[[timeString componentsSeparatedByString:@":"] lastObject] componentsSeparatedByString:@"."] firstObject] integerValue];
    NSInteger haomiao = [[[[[timeString componentsSeparatedByString:@":"] lastObject] componentsSeparatedByString:@"."] lastObject] integerValue];
    
    return min * 60 + second + haomiao * 0.01;
}

+ (instancetype)lrclineWithLrcString:(NSString *)lrcString
{
    return [[self alloc] initWithLrcString:lrcString];
}

@end
