//
//  LrcCell.m
//  MusicPlayerDemo
//
//  Created by 安俊(平安科技智慧生活团队) on 2019/3/29.
//  Copyright © 2019年 安俊. All rights reserved.
//

#import "LrcCell.h"
#import "LrcLabel.h"
#import "Masonry.h"
#import "LrcLine.h"

@implementation LrcCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        LrcLabel *lrcLabel = [[LrcLabel alloc] init];
        lrcLabel.backgroundColor = [UIColor clearColor];
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.font = [UIFont systemFontOfSize:14.0];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lrcLabel];
        _lrcLabel = lrcLabel;
        lrcLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setLineModel:(LrcLine *)lineModel{
    _lineModel = lineModel;
    self.lrcLabel.text = lineModel.text;
}

@end
