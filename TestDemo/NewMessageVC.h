//
//  NewMessageVC.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/4/13.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewMessageVC : UIViewController

@property (nonatomic, copy) void(^(newMessageSuccessBlock))(void);

@end

NS_ASSUME_NONNULL_END
