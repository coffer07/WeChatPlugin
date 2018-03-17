//
//  TKWeChatPluginConfig.m
//  WeChatPlugin
//
//  Created by TK on 2017/4/19.
//  Copyright © 2017年 tk. All rights reserved.
//

#import "TKWeChatPluginConfig.h"

static NSString * const kTKAutoReplyEnableKey = @"kTKAutoReplyEnableKey";
static NSString * const kTKAutoReplyKeywordKey = @"kTKAutoReplyKeywordKey";
static NSString * const kTKAutoReplyDateKey = @"kTKAutoReplyDateKey";
static NSString * const kTKAutoReplySizeKey = @"kTKAutoReplySizeKey";
static NSString * const kTKAutoReplyCardIDKey = @"kTKAutoReplyCardIDKey";
static NSString * const kTKAutoReplyPhoneNumberKey = @"kTKAutoReplyPhoneNumberKey";

@implementation TKWeChatPluginConfig

+ (instancetype)sharedConfig {
    static TKWeChatPluginConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[TKWeChatPluginConfig alloc] init];
    });
    
    return config;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _autoReplyEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kTKAutoReplyEnableKey];
        _autoReplyKeyword = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyKeywordKey];
        _autoReplyDate = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyDateKey];
        _autoReplySize = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplySizeKey];
        _autoReplyCardID = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyCardIDKey];
        _autoReplyPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kTKAutoReplyPhoneNumberKey];
    }
    return self;
}

- (NSString *)getAutoReplyMsg: (NSString *)msg {
    if ([msg containsString:@"请稍等"]) {
        return _autoReplyKeyword;
    }else if ([msg containsString:@"请严格按照"]) {
        NSArray *list = [msg componentsSeparatedByString:@"\n"];
        NSString *replyStr = @"";
        for (NSString *str in list) {
            if ([str containsString: @"例如："]) {
                replyStr = [str substringFromIndex:3];
                break;
            }
        }
        replyStr = [replyStr stringByReplacingOccurrencesOfString:@"A" withString:_autoReplySize];
        replyStr = [replyStr stringByReplacingOccurrencesOfString:@"123456789987654321" withString:_autoReplyCardID];
        replyStr = [replyStr stringByReplacingOccurrencesOfString:@"18812346789" withString:_autoReplyPhoneNumber];
        return replyStr;
    }else if ([msg containsString:@"=?"]) {
        
    }
    
    return @"";
}

- (void)setAutoReplyEnable:(BOOL)autoReplyEnable {
    _autoReplyEnable = autoReplyEnable;
    [[NSUserDefaults standardUserDefaults] setBool:autoReplyEnable forKey:kTKAutoReplyEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyKeyword:(NSString *)autoReplyKeyword {
    _autoReplyKeyword = autoReplyKeyword;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyKeyword forKey:kTKAutoReplyKeywordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyDate:(NSString *)autoReplyDate {
    _autoReplyDate = autoReplyDate;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyDate forKey:kTKAutoReplyDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplySize:(NSString *)autoReplySize {
    _autoReplySize = autoReplySize;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplySize forKey:kTKAutoReplySizeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyCardID:(NSString *)autoReplyCardID {
    _autoReplyCardID = autoReplyCardID;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyCardID forKey:kTKAutoReplyCardIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReplyPhoneNumber:(NSString *)autoReplyPhoneNumber {
    _autoReplyPhoneNumber = autoReplyPhoneNumber;
    [[NSUserDefaults standardUserDefaults] setObject:autoReplyPhoneNumber forKey:kTKAutoReplyPhoneNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
