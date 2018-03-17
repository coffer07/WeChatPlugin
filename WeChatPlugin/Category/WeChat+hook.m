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

static char tkAutoReplyWindowControllerKey;     //  自动回复窗口的关联 key

@implementation NSObject (WeChatHook)

+ (void)hookWeChat {
    //      微信消息同步
    tk_hookMethod(objc_getClass("MessageService"), @selector(OnSyncBatchAddMsgs:isFirstSync:), [self class], @selector(hook_OnSyncBatchAddMsgs:isFirstSync:));
    
    [self addAssistantMenuItem]
    
}

/**
 hook 微信消息同步
 
 */
- (void)hook_OnSyncBatchAddMsgs:(NSArray *)msgs isFirstSync:(BOOL)arg2 {
    [self hook_OnSyncBatchAddMsgs:msgs isFirstSync:arg2];
    
    if ([[TKWeChatPluginConfig sharedConfig] autoReplyEnable]) {
        [msgs enumerateObjectsUsingBlock:^(AddMsg *addMsg, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([addMsg.fromUserName.string containsString:@"@chatroom"]) {                 // 过滤群聊消息
                return ;
            }
            
            ContactStorage *contactStorage = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("ContactStorage")];
            WCContactData *selfContact = [contactStorage GetSelfContact];
            
            if ([addMsg.fromUserName.string isEqualToString:selfContact.m_nsUsrName]) {     // 过滤自己发送的消息
                return ;
            }
            
            if (addMsg.msgType == 1 || addMsg.msgType == 3) {
                MessageService *service = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("MessageService")];
                NSString *keyword = [[TKWeChatPluginConfig sharedConfig] autoReplyKeyword];
                if ([keyword isEqualToString:@""] || [addMsg.content.string isEqualToString:keyword]) {
                    [service SendTextMessage:selfContact.m_nsUsrName toUsrName:addMsg.fromUserName.string msgText:[[TKWeChatPluginConfig sharedConfig] autoReplyText] atUserList:nil];
                }
            }
        }];
    }
}

+ (void)addAssistantMenuItem {

    //        自动回复
    NSMenuItem *autoReplyItem = [[NSMenuItem alloc] initWithTitle:@"自动回复设置" action:@selector(onAutoReply:) keyEquivalent:@"k"];
    
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
