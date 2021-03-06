//
//  HackUtils.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/25/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HackUtils : NSObject

+ (NSArray *)findElementsByClass:(NSString *)className inView:(NSView *)view;
+ (void)printViews:(NSView *)containerView;
+ (void)printMethods:(id)object;
@end

