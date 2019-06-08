//
//  IFInnerVideoVC.m
//  IMDemo
//
//  Created by HappyWork on 2019/2/20.
//  Copyright © 2019  Admin. All rights reserved.
//

#import "IFInnerVideoVC.h"

#import "CallingVoipView.h"
#import "ReceiveVoipView.h"
#import "VoipConversationView.h"

#import "VideoSetParameters.h"

@interface IFInnerVideoVC () <CallingVoipViewDelegate, ReceiveVoipViewDelegate, VoipConversationViewDelegate>
@property (weak, nonatomic) CallingVoipView *callingView;
@property (weak, nonatomic) VoipConversationView *conversationView;
@property (weak, nonatomic) ReceiveVoipView *receiveView;

@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, assign) IFInnerConversationStatus conversationStatus;

@end

@implementation IFInnerVideoVC

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createUI];
    
    [[XHClient sharedClient].voipP2PManager setVideoConfig:[VideoSetParameters locaParameters]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_conversationStatus == IFInnerConversationStatus_Calling) {
        
        //设置用于视频显示的View
        [[XHClient sharedClient].voipP2PManager setupView:self.conversationView.selfView targetView:self.conversationView.targetView];
        
        [[XHClient sharedClient].voipP2PManager call:self.targetId completion:^(NSError *error) {
            if (error) {
                [self showError:error];
                [self backup];
            }
        }];
    }
}


- (void)setConversationStatus:(IFInnerConversationStatus)conversationStatus {
    _conversationStatus = conversationStatus;
    
    NSLog(@"HappyTest setConversationStatus %d", conversationStatus);
    [self refreshUI];

    if (conversationStatus == IFInnerConversationStatus_Conversation) {


    
    } else if (conversationStatus == IFInnerConversationStatus_Calling) {
        
//        //设置用于视频显示的View
//        [[XHClient sharedClient].voipP2PManager setupView:self.conversationView.selfView targetView:self.conversationView.targetView];
//        
//        [[XHClient sharedClient].voipP2PManager call:self.targetId completion:^(NSError *error) {
//            if (error) {
//                [self showError:error];
//                [self backup];
//            }
//        }];
    }
    NSLog(@"HappyTest setConversationStatus end");
}


#pragma mark - UI

- (void)createUI {
    self.callingView = [CallingVoipView instanceFromNIB];
    self.callingView.hidden = NO;
    self.receiveView = [ReceiveVoipView instanceFromNIB];
    self.receiveView.hidden = YES;
    self.conversationView = [VoipConversationView instanceFromNIB];
    self.conversationView.hidden = YES;
    
    self.callingView.delegate = self;
    self.receiveView.delegate = self;
    self.conversationView.delegate = self;
    
    self.callingView.frame = self.view.bounds;
    self.receiveView.frame = self.view.bounds;
    self.conversationView.frame = self.view.bounds;
    
    [self.view addSubview:self.callingView];
    [self.view addSubview:self.receiveView];
    [self.view addSubview:self.conversationView];
}

- (void)refreshUI {
    NSLog(@"caimj refreshUI");
    self.callingView.hidden = YES;
    self.receiveView.hidden = YES;
    self.conversationView.hidden = YES;
    
    switch (_conversationStatus) {
        case IFInnerConversationStatus_Calling:
            NSLog(@"show IFInnerConversationStatus_Calling");
            self.callingView.hidden = NO;
            break;
        case IFInnerConversationStatus_Receiving:
            NSLog(@"show IFInnerConversationStatus_Receiving");
            self.receiveView.hidden = NO;
            break;
        case IFInnerConversationStatus_Conversation:
            NSLog(@"show IFInnerConversationStatus_Conversation");
            self.conversationView.hidden = NO;
            break;
        default:
            self.callingView.hidden = NO;
            break;
    }
}


#pragma mark - delegate
#pragma mark - CallingVoipViewDelegate
//取消呼叫
- (void)callingVoipViewDidCancel:(CallingVoipView*) voipConversationView
{
    __weak typeof(self)weakSelf = self;
    [[XHClient sharedClient].voipP2PManager cancel:self.targetId completion:^(NSError *error) {
        [weakSelf backup];
    }];
}

#pragma mark - ReceiveVoipViewDelegate
//拒绝来电
- (void)receiveVoipViewDidRefuse:(ReceiveVoipView*) receiveVoipView
{
    __weak typeof(self)weakSelf = self;
    [[XHClient sharedClient].voipP2PManager refuse:self.targetId completion:^(NSError *error) {
        [weakSelf backup];
    }];
}

//同意来电
- (void)receiveVoipViewDidAgree:(ReceiveVoipView*) receiveVoipView
{
    __weak typeof(self)weakSelf = self;
    
    //设置用于视频显示的View
    [[XHClient sharedClient].voipP2PManager setupView:self.conversationView.selfView targetView:self.conversationView.targetView];
    
    [[XHClient sharedClient].voipP2PManager accept:self.targetId completion:^(NSError *error) {
        if (error) {
            [weakSelf showError:error];
            [weakSelf backup];
        }else {
            [weakSelf updateConversationState:IFInnerConversationStatus_Conversation];
        }
    }];
}

#pragma mark - VoipConversationViewDelegate
//挂断
- (void)voipConversationViewDidHangup:(VoipConversationView *)voipConversationView
{
    __weak typeof(self)weakSelf = self;
    [[XHClient sharedClient].voipP2PManager hangup:self.targetId completion:^(NSError *error) {
        if (error) {
            [weakSelf showError:error];
        }
        [weakSelf backup];
    }];
}

//切换摄像头
- (void)voipConversationViewSwitchCamera:(VoipConversationView*) voipConversationView
{
    [[XHClient sharedClient].voipP2PManager switchCamera];
}

//录屏
- (void)voipConversationViewRecordScreen:(VoipConversationView *)voipConversationView
{
    
}


#pragma mark - other
- (void)updateConversationState:(IFInnerConversationStatus)status {
    self.conversationStatus = status;
}

- (void)configureTargetId:(NSString *)targetId status:(IFInnerConversationStatus)status {
    _targetId = targetId;
    self.conversationStatus = status;
}

- (void)backup {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showError:(NSError *)error {
    NSString *errorMsg = error.localizedDescription.length ? error.localizedDescription:@"未知错误";
    int errorCode = (int)error.code;
    NSString *errorAlert = [NSString stringWithFormat:@"%d, %@", errorCode, errorMsg];
    
    [UIView ilg_makeToast:errorAlert];
}

@end
