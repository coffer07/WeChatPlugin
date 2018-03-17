//
//  TKAutoReplyWindowController.m
//  WeChatPlugin
//
//  Created by TK on 2017/4/19.
//  Copyright © 2017年 tk. All rights reserved.
//

#import "TKAutoReplyWindowController.h"
#import "WeChatPlugin.h"

@interface TKAutoReplyWindowController ()
@property (weak) IBOutlet NSTextField *dateTextField;
@property (weak) IBOutlet NSTextField *sizeTextField;
@property (weak) IBOutlet NSTextField *keywordTextField;
@property (weak) IBOutlet NSTextField *cardIDTextField;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSTextField *phoneNumberTextField;

@end

@implementation TKAutoReplyWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.title = @"抢鞋子";
    [self setup];
}

- (void)setup {
    TKWeChatPluginConfig *config = [TKWeChatPluginConfig sharedConfig];
    self.keywordTextField.stringValue = config.autoReplyKeyword != nil ? config.autoReplyKeyword : @"";
    self.sizeTextField.stringValue = config.autoReplySize != nil ? config.autoReplySize : @"";
    self.dateTextField.stringValue = config.autoReplyDate != nil ? config.autoReplyDate : @"";
    self.cardIDTextField.stringValue = config.autoReplyCardID != nil ? config.autoReplyCardID : @"";
    self.phoneNumberTextField.stringValue = config.autoReplyPhoneNumber != nil ? config.autoReplyPhoneNumber : @"";
}

- (IBAction)saveAutoReplySetting:(id)sender {
    [[TKWeChatPluginConfig sharedConfig] setAutoReplyEnable:YES];
    [[TKWeChatPluginConfig sharedConfig] setAutoReplyKeyword:self.keywordTextField.stringValue];
    [[TKWeChatPluginConfig sharedConfig] setAutoReplySize:self.sizeTextField.stringValue];
    [[TKWeChatPluginConfig sharedConfig] setAutoReplyCardID:self.cardIDTextField.stringValue];
    [[TKWeChatPluginConfig sharedConfig] setAutoReplyDate:self.dateTextField.stringValue];
    [[TKWeChatPluginConfig sharedConfig] setAutoReplyPhoneNumber:self.phoneNumberTextField.stringValue];
    if (self.startAutoReply) {
        self.startAutoReply();
    }
    [self close];
}

@end
