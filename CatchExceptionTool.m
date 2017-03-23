//
//  CatchExceptionTool.m
//  测试程序
//
//  Created by 雨天记忆 on 2017/3/23.
//  Copyright © 2017年 雨天记忆. All rights reserved.
//
#import "CatchExceptionTool.h"

#define NSExceptionFile @"dcCrash.txt"

@implementation CatchExceptionTool

+ (void)installCatchAction{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

//获取沙盒路径
NSString *applicationDocumentsDirectory() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString * documentsDirectory  =[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:NSExceptionFile];
}

NSString *getCurrentSysTime(){
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strTime = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    return strTime;
}

void UncaughtExceptionHandler(NSException *exception){
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *strError = [NSString stringWithFormat:@"\n\n\n=============异常崩溃报告=============\nVersion:\n%@\nTime:\n %@\nName:\n%@\nreason:\n%@\ncallStackSymbols:\n%@", [NSString stringWithFormat:NSLocalizedString(@"V %@",nil),[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],getCurrentSysTime(),name,reason,[arr componentsJoinedByString:@"\n"]];
    
    NSString *path = applicationDocumentsDirectory();
    if ([[NSFileManager defaultManager]fileExistsAtPath:path])
    {
        NSString *lasterror = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        strError  = [NSString stringWithFormat:@"%@%@", lasterror, strError];
    }
    [strError writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableString *mailUrl = [[NSMutableString alloc]init];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"（里面填写收件人）"];
    [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
    //添加抄送
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"",nil];
    [mailUrl appendFormat:@"?cc=%@", [ccRecipients componentsJoinedByString:@","]];
    //添加密送
    NSArray *bccRecipients = [NSArray arrayWithObjects:@"", nil];
    [mailUrl appendFormat:@"&bcc=%@", [bccRecipients componentsJoinedByString:@","]];
    [mailUrl appendString:@"&subject=崩溃日志"];
    //添加邮件内容
    [mailUrl appendString:[NSString stringWithFormat:@"&body=%@", strError]];
    NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

@end
