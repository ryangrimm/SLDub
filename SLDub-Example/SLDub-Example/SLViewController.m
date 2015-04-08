//
//  SLViewController.m
//  SLDub-Example
//
//  Created by Ryan Grimm on 9/8/14.
//  Copyright (c) 2014 Swell Lines LLC. All rights reserved.
//

#import "SLViewController.h"
#import "SLDub.h"

#import "UIImage+SLDub.h"
#import "SLDubImagePunch.h"

@interface SLViewController ()

@end

@implementation SLViewController

- (void)viewDidLoad
{
    // http://losingfight.com/blog/2007/08/28/how-to-implement-a-magic-wand-tool/
    // https://bitbucket.org/andyfinnell/magicwand/src/3b00c6fb18c7e1d0dc28b9d80b09015a28118d6b/PathBuilder.m?at=default
//    UIImage *circle = [UIImage imageNamed:@"big-drawn-circle"];
//    UIBezierPath *path = [circle pathFromInnerAlpha:0.5];

    /*
    UIImage *circle = [UIImage imageNamed:@"big-drawn-circle"];
    SLDubImagePunch *punch = [[SLDubImagePunch alloc] initWithImage:circle threshold:0.5];
    [punch process];
    UIImage *mask = [UIImage imageWithCGImage:[punch createMask] scale:circle.scale orientation:UIImageOrientationUp];
    UIImageView *maskView = [[UIImageView alloc] initWithImage:mask];
*/

    [super viewDidLoad];
    UIImageView *sampleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample.jpg"]];
    sampleView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    sampleView.frame = self.view.bounds;
    sampleView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:sampleView];

    SLDubView *help = [[SLDubView alloc] initWithFrame:self.view.bounds];
    help.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    help.animationDuration = 0.5;
    [self.view addSubview:help];

    SLDubItem *item = [[SLDubItem alloc] init];
    item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 215, 115, 115)];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Rob\nSleeping like a baby"];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:20] range:NSMakeRange(0, 4)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(4, 20)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 24)];
    item.message = attributedString;
    item.sizeMessageToText = YES;
    item.textAlignment = NSTextAlignmentCenter;
    item.messageRect = CGRectMake(10, 150, 100, 50);
    item.connectionCornerRadius = 25;

    [help forItem:item setTapBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You touched a portal" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }];

    [item addToHelpView:help];

//    [self.view addSubview:maskView];


/*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        item.message = @"Joe";
        item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 170, 60, 60)];
        [item render:YES];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        item.message = @"A big ass bag so we can drag all our shit up thousands of feet of rock. Hauling gear can suck.";
        item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 115, 60, 60)];
        item.messageRect = CGRectMake(10, 250, 225, 50);
        [item render:YES];
    });
 */
}

@end
