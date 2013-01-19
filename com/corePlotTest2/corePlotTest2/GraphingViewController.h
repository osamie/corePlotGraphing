//
//  SecondViewController.h
//  corePlotTest2
//
//  Created by Osazuwa Omigie on 2012-10-16.
//  Copyright (c) 2012 Osazuwa Omigie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphingViewController : UIViewController<CPTPlotDataSource,CPTPlotSpaceDelegate>{
    NSMutableArray *samples;
    __weak IBOutlet UISlider *slopeChanger;
    __weak IBOutlet UILabel *lineEqu_label;
    __weak IBOutlet UIImageView *locomotionPoints;
    
    BOOL lineBeingDragged;
    
    //CGRect *viewBounds;
}
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (weak, nonatomic) IBOutlet UISlider *slopeChanger;
@property (weak, nonatomic) IBOutlet UILabel *lineEqu_label;

@property(readwrite) double graphSlope;
@property(nonatomic) BOOL lineBeingDragged;

-(void)changeGraphSlope:(int)slope;
//-(void) moveGraph(CGPoint)location;
//@property(nonatomic,retain) CGRect viewBounds;

@end




