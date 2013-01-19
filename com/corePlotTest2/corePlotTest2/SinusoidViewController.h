//
//  expViewController.h
//  corePlotTest2
//
//  Created by Osazuwa Omigie on 2012-10-30.
//  Copyright (c) 2012 Osazuwa Omigie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinusoidViewController : UIViewController<CPTPlotDataSource,CPTPlotSpaceDelegate>{
    NSMutableArray *samples;
    __weak IBOutlet UILabel *lineEqu_label;
    __weak IBOutlet UIImageView *locomotionPoints;
    BOOL lineBeingDragged;
    int mode;
    double amplitude;
    double phase;
    double frequency;
}
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (weak, nonatomic) IBOutlet UISlider *slopeChanger;
@property (weak, nonatomic) IBOutlet UILabel *lineEqu_label;
@property(nonatomic) BOOL lineBeingDragged;
@property(atomic) int mode;
@property(atomic) double amplitude;
@property(atomic) double phase;
@property(atomic) double frequency;


@end
