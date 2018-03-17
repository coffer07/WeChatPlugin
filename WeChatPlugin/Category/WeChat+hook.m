//
//  WeChat+hook.m
//  WeChatPlugin
//
//  Created by TK on 2017/4/19.
//  Copyright © 2017年 tk. All rights reserved.
//

#import "WeChat+hook.h"
#import "WeChatPlugin.h"
#import "TKAutoReplyWindowController.h"
#import <objc/runtime.h>

static char tkAutoReplyWindowControllerKey;     //  自动回复窗口的关联 key

static NSString * const chatUserId = @"wxid_tksmdepx8cso12";   //@"gh_37efc885cc57";

@implementation NSObject (WeChatHook)

+ (void)hookWeChat {
    //      微信消息同步
    tk_hookMethod(objc_getClass("MessageService"), @selector(OnSyncBatchAddMsgs:isFirstSync:), [self class], @selector(hook_OnSyncBatchAddMsgs:isFirstSync:));
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addAssistantMenuItem];
    });
    
    [self scheduledTask];
}

- (void)scheduledTask {
    if ([TKWeChatPluginConfig sharedConfig].tkTimer != nil) {
        dispatch_source_cancel([TKWeChatPluginConfig sharedConfig].tkTimer);
    }
    NSString *dateStr = [[TKWeChatPluginConfig sharedConfig] autoReplyDate];
    NSString *keyword = [[TKWeChatPluginConfig sharedConfig] autoReplyKeyword];
    if (![dateStr isEqualToString:@""] && ![keyword isEqualToString:@""]) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [TKWeChatPluginConfig sharedConfig].tkTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer([TKWeChatPluginConfig sharedConfig].tkTimer, DISPATCH_TIME_NOW, 1.0*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler([TKWeChatPluginConfig sharedConfig].tkTimer, ^{
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *formdate = [format dateFromString:dateStr];
            NSTimeInterval timeInterger = [formdate timeIntervalSinceDate:[NSDate date]];
            if (timeInterger < 1.0 && timeInterger >= 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
                    WCContactData *selfContact = [contactStorage GetSelfContact];
                    MessageService *service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
                    
                    [service SendTextMessage:selfContact.m_nsUsrName toUsrName:chatUserId msgText:keyword atUserList:nil];
                });
            }else if (timeInterger < 0){
                dispatch_source_cancel([TKWeChatPluginConfig sharedConfig].tkTimer);
            }
        });
        dispatch_resume([TKWeChatPluginConfig sharedConfig].tkTimer);
    }
}



/**
 hook 微信消息同步
 
 */
- (void)hook_OnSyncBatchAddMsgs:(NSArray *)msgs isFirstSync:(BOOL)arg2 {
    [self hook_OnSyncBatchAddMsgs:msgs isFirstSync:arg2];
    if ([[TKWeChatPluginConfig sharedConfig] autoReplyEnable]) {
        [msgs enumerateObjectsUsingBlock:^(AddMsg *addMsg, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSDate *now = [NSDate date];
            NSTimeInterval nowSecond = now.timeIntervalSince1970;
            if (nowSecond - addMsg.createTime > 180) {      // 若是3分钟前的消息，则不进行自动回复
                return;
            }
            if ([addMsg.fromUserName.string containsString:@"@chatroom"]) {                 // 过滤群聊消息
                return ;
            }
            // 只回复一个人的消息
            if (![addMsg.fromUserName.string isEqualToString: chatUserId]) {
                return;
            }

            ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
            WCContactData *selfContact = [contactStorage GetSelfContact];
            
            if (addMsg.msgType == 1 || addMsg.msgType == 3) {
                MessageService *service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
                NSString *autoReplyText = [[TKWeChatPluginConfig sharedConfig] getAutoReplyMsg:addMsg.content.string];
                if (![autoReplyText isEqualToString:@""]) {
                    [service SendTextMessage:selfContact.m_nsUsrName toUsrName:addMsg.fromUserName.string msgText:autoReplyText atUserList:nil];
                }
            }
        }];
    }
}

+ (void)addAssistantMenuItem {
    //        自动回复
    NSMenuItem *autoReplyItem = [[NSMenuItem alloc] initWithTitle:@"adidasoriginals" action:@selector(onAutoReply:) keyEquivalent:@"k"];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"微信小助手"];
    [subMenu addItem:autoReplyItem];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:@"微信小助手"];
    [menuItem setSubmenu:subMenu];
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

/**
 菜单栏-帮助-自动回复 设置
 
 @param autoReplyItem 自动回复设置的item
 */
- (void)onAutoReply:(NSMenuItem *)autoReplyItem {
    if (!autoReplyItem) return;
    
    WeChat *wechat = [objc_getClass("WeChat") sharedInstance];
    TKAutoReplyWindowController *autoReplyWC = objc_getAssociatedObject(wechat, &tkAutoReplyWindowControllerKey);
    [autoReplyWC setStartAutoReply:^{
        autoReplyItem.state = YES;
        [self scheduledTask];
    }];
    
    if (autoReplyItem.state) {
        autoReplyItem.state = NO;
        [[TKWeChatPluginConfig sharedConfig] setAutoReplyEnable:NO];
        if (autoReplyWC) {
            [autoReplyWC close];
        }
        return;
    }
    
    if (!autoReplyWC) {
        autoReplyWC = [[TKAutoReplyWindowController alloc] initWithWindowNibName:@"TKAutoReplyWindowController"];
        objc_setAssociatedObject(wechat, &tkAutoReplyWindowControllerKey, autoReplyWC, OBJC_ASSOCIATION_RETAIN);
    }
    
    [autoReplyWC showWindow:autoReplyWC];
    [autoReplyWC.window center];
    [autoReplyWC.window makeKeyWindow];
}

@end
