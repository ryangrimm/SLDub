//
//  SLViewController.m
//  SLDub-Example
//
//  Created by Ryan Grimm on 9/8/14.
//  Copyright (c) 2014 Swell Lines LLC. All rights reserved.
//

#import "SLViewController.h"
#import "SLDub.h"

@interface SLViewController ()

@end

@implementation SLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *sampleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sample.jpg"]];
    sampleView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    sampleView.frame = self.view.bounds;
    sampleView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:sampleView];

    SLDubView *help = [[SLDubView alloc] initWithFrame:self.view.bounds];
    help.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:help];

    SLDubItem *item = [[SLDubItem alloc] init];
    item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 215, 115, 115)];
    item.description = @"Rob";
    item.sizeDescriptionToText = YES;
    item.textAlignment = NSTextAlignmentCenter;
    item.descriptionRect = CGRectMake(10, 50, 100, 50);
    item.connectionCornerRadius = 25;

    [help forItem:item setTapBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You touched a portal" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }];

    [item addToHelpView:help];


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        item.description = @"Joe";
        item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 170, 60, 60)];
        [item render:YES];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        item.description = @"A big ass bag so we can drag all our shit up thousands of feet of rock. Hauling gear can suck.";
        item.portalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(150, 115, 60, 60)];
        item.descriptionRect = CGRectMake(10, 250, 225, 50);
        [item render:YES];
    });
}

@end
