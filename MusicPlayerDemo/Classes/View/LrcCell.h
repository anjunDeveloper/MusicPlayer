//
//  LrcCell.h
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LrcLabel,LrcLine;

@interface LrcCell : UITableViewCell

/** 歌词的label */
@property (nonatomic, weak, readonly) LrcLabel *lrcLabel;

@property (nonatomic, strong) LrcLine * lineModel;


@end

NS_ASSUME_NONNULL_END
