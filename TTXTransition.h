//
//  TTXTransition.h
//  TTXTransition
//
//  Created by molon on 7/8/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTXTransition : NSObject

+ (void)validatePanBackGesture;

@end

@interface UIView(__TTXTransition)

//使得此view不响应拖返
@property (nonatomic, assign) BOOL disableTTXTransition;

@end

@interface UINavigationController(DisableTTXTransition)

- (void)enabledTTXTransition:(BOOL)enabled;

@end
