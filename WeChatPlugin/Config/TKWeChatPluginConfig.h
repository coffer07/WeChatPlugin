//
//  TKWeChatPluginConfig.h
//  WeChatPlugin
//
//  Created by TK on 2017/4/19.
//  Copyright © 2017年 tk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKWeChatPluginConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic, retain) dispatch_source_t tkTimer;

@property (nonatomic, assign) BOOL autoReplyEnable;             /**<    是否开启自动回复  */
@property (nonatomic, copy) NSString *autoReplyDate;            //      固定时间开始回复
@property (nonatomic, copy) NSString *autoReplyKeyword;         //      固定时间回复内容
@property (nonatomic, copy) NSString *autoReplySize;            //      尺码大小
@property (nonatomic, copy) NSString *autoReplyCardID;          //      身份证号码
@property (nonatomic, copy) NSString *autoReplyPhoneNumber;     //      手机号

- (NSString *)getAutoReplyMsg: (NSString *)msg;

@end
