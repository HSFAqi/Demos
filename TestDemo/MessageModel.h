//
//  MessageModel.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/4/13.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : NSObject

@property (nonatomic , copy)    NSString              *content;
@property (nonatomic , copy)    NSString              *id;
@property (nonatomic , assign)  NSInteger              creationTime;
@property (nonatomic , assign)  NSInteger              state;
@property (nonatomic , assign)  NSInteger              type;

@end

NS_ASSUME_NONNULL_END
