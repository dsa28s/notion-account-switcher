// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/StartUp.m
// Description : Login Item wrapper (Objc)
// Author: Dora Lee <lee@sanghun.io>

#import "StartUp.h"

@implementation NSObject (StartUp)
+ (void)startUpLogin {
     NSURL *bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
     LSSharedFileListInsertItemURL(LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL),
                                  kLSSharedFileListItemLast,
                                  NULL,
                                  NULL,
                                  (__bridge CFURLRef)bundleURL,
                                  NULL,
                                  NULL);
}
@end
