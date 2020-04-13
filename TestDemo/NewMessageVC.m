//
//  NewMessageVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/4/13.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NewMessageVC.h"
#import "UITextView+JKPlaceHolder.h"

@interface NewMessageVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation NewMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"新增消息";
    [self.contentTextView jk_addPlaceHolder:@"请输入消息内容..."];
}
// 点击提交
- (IBAction)submitEvent:(UIButton *)sender {
    if ([self.nameTextField.text isEqualToString:@""]) {
        NSLog(@"请输入用户名");
        return;
    }
    if ([self.contentTextView.text isEqualToString:@""]) {
        NSLog(@"请输入内容");
        return;
    }
    NSString *url = @"https://3evjrl4n5d.execute-api.us-west-1.amazonaws.com/dev/message";
    NSDictionary *param = @{@"id":self.nameTextField.text, @"content":self.contentTextView.text};
    NSString *json = [param yy_modelToJSONString];
    MJWeakSelf
    [self postBodyWithUrl:url json:json callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.newMessageSuccessBlock) {
                    weakSelf.newMessageSuccessBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
            NSLog(@"提交成功!");
        }
    }];
}
/// 使用body传数据
- (NSURLSessionTask *)postBodyWithUrl:(NSString *)url json:(id)json callback:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    // request
    NSError *requestError = nil;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:nil error:&requestError];
    // body
    NSData *postData = [json dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [manager.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (callback) {
            callback(data, response, error);
        }
    }];
    [dataTask resume];
    return dataTask;
}


@end
