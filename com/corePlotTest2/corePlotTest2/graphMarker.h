//
//  graphMarker.h
//  corePlotTest2
//
//  Created by Osazuwa Omigie on 2013-02-07.
//  Copyright (c) 2013 Osazuwa Omigie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinusoidViewController.h"
@interface graphMarker : NSObject<CPTPlotDataSource,CPTPlotSpaceDelegate>{
    
}

-(id)initWithXposition:(double)xVal parentDelegate:() p;

@end
