//
//  SecondViewController.m
//  corePlotTest2
//
//  Created by Osazuwa Omigie on 2012-10-16.
//  Copyright (c) 2012 Osazuwa Omigie. All rights reserved.
//

#import "GraphingViewController.h"
#define START_POINT -4.0
#define END_POINT 4.0
#define NUM_SAMPLES 150

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

@implementation GraphingViewController

@synthesize slopeChanger;
@synthesize lineEqu_label;
@synthesize graphSlope;
@synthesize lineBeingDragged;
//@synthesize viewBounds;


-(id)init{
    
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", [self class]);
        graphSlope = 0;
        lineBeingDragged = NO;
        
    }
    return self;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)location

{
    CGPoint newCoord = [self convertToGraphCoord:location];
    int yy = newCoord.y;
    double xx = newCoord.x;
    int plotIndex = 0; //specify the index of the plot to be affected here
    BOOL isInLine = (yy == (int)(graphSlope * xx));
    if(isInLine){
        //store the location of the touch at this point...used in determining mode
        lineBeingDragged=YES;
        [self applyHighLightPlotColor:(CPTScatterPlot *)[self.hostView.hostedGraph plotAtIndex:plotIndex]];
        return NO;
    }
    lineBeingDragged=NO;
    return NO;
    
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)location{

    if (lineBeingDragged){
        [self moveGraph:location];
        lineBeingDragged = YES;
        return NO;
    }
    lineBeingDragged = NO;
    return NO;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)location

{
    int plotIndex = 0; //specify the index of the plot to be affected here
    lineBeingDragged = NO;
    [self applyDefaultPlotColor:(CPTScatterPlot *)[self.hostView.hostedGraph plotAtIndex:plotIndex]];
    return YES;
}


/*
 this method should be called only when there is touchdown and drag operation on the graph
*/
-(void) moveGraph:(CGPoint)location{
    NSLog(@"PLOT TOUCHED AT locationX:%f, locationY:%f",location.x,location.y);
    
    //line touched boolean
    NSLog(@"TOUCH STARTED");
    CGPoint newCoord = [self convertToGraphCoord:location];
    graphSlope = [self calculateSlope:newCoord.x y2:newCoord.y];
    
    [self changeGraphSlope:graphSlope point1:newCoord];
    
}




-(CGPoint)convertToGraphCoord:(CGPoint)screenCoord{
    NSDecimal plotPoint[2];
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    //converts the location to the coordinate system of the plot area
    CGPoint graphPoint = [graph convertPoint:screenCoord toLayer:graph.plotAreaFrame.plotArea];
    [plotSpace plotPoint:plotPoint forPlotAreaViewPoint:graphPoint];
    
    screenCoord.x = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateX]] doubleValue];
    screenCoord.y = [[NSDecimalNumber decimalNumberWithDecimal:plotPoint[CPTCoordinateY]] doubleValue];

    return screenCoord;
}



-(void)changeGraphSlope:(double)slope point1:(CGPoint)point1{
    NSLog(@"locomotion points: %f , %f \n",point1.x,point1.y);

    //NSString *str = [NSString stringWithFormat:@"slope value: %i",slope];
    NSLog(@"slope value: %.2f",slope);
    
    CGRect viewBounds = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-48);
    
    [self updateGraph:slope graphViewBounds:viewBounds lineMoverPoint:point1];
    
    lineEqu_label.text = [NSString stringWithFormat:@"  Equation: y=%.2fx",(double)slope];
}


/*
 Generates data for plotting graph
 @param: 
 */
-(void) generateDataSamples: (CGPoint)point1 yIntercept:(double)yIntercept
{ 
	double length = (END_POINT - START_POINT);  
	double delta = length / (NUM_SAMPLES - 1); 
	samples = [[NSMutableArray alloc] initWithCapacity:NUM_SAMPLES]; //initialize data array
    double y2 = point1.y;
    double y1 = 0;
    double x1 = 0;
    double x2 = point1.x;
    double slope = (y2-y1)/(x2-x1);
    
    for (int i = 0; i < NUM_SAMPLES; i++){
		double x = START_POINT + (delta * i);
		double y = (slope*x);  /* Straight line equation: y= mx + c */
        
		NSDictionary *sample = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithDouble:x],X_VAL,
								[NSNumber numberWithDouble:y],Y_VAL,
								nil];
        
		[samples addObject:sample];
	}
}


//Later, this will need to accept 2 POINTS e.g {x1,y1} and {x2,y2} and determine their slope
-(double) calculateSlope : (double)x2 y2:(double)y2{
    double x1 =0,y1=0;
    double rise = y2-y1;
    double run = x2-x1;
    
    if (run != 0){
        return rise/run;
    }
    return 0;
    
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
{
	return NUM_SAMPLES;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
			   recordIndex:(NSUInteger)index;
{
	NSDictionary *sample = [samples objectAtIndex:index];
	
	if (fieldEnum == CPTScatterPlotFieldX)
		return [sample valueForKey:X_VAL];
	else
		return [sample valueForKey:Y_VAL];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect viewBounds = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 95);
    [self setupGraph:CGPointMake(0.0,0.0) graphViewBounds:viewBounds];
}

/*
 
 [self configureHost]; 
 [self configureGraph]; 
 [self configurePlots]; 
 [self configureAxes];
 
 -separate makeGraph from updateGraph
 -updateGraph should only rewrite the mutable data array for the existing graph
 -updateGraph: [graph reloadData]  will update the graph on the screen rather than removing and adding a new hosting view.
*/


-(void) configureHost:(CGRect)viewBounds{
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:viewBounds];
//    self.hostView.allowPinchScaling = YES;
    
    [self.view addSubview:self.hostView];
}

-(void) configureGraph{
    //creating graph
    CPTGraphHostingView *hostingView = self.hostView;
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
	hostingView.hostedGraph = graph;

}

-(void) configurePlots{
//    int slope = (int)slopeChanger.value;
    CPTGraphHostingView *hostingView = self.hostView;

    
    [self generateDataSamples:CGPointZero yIntercept:0.0];
	
	double yAxisStart = START_POINT;
	double yAxisLength = END_POINT - START_POINT;
	
	double maxX = [[samples valueForKeyPath:@"@max.X_VAL"] doubleValue];
	double xAxisStart = -maxX;
	double xAxisLength = 2 * maxX;
	
    
    
	//Get graph and plot spaces and set axis
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    [plotSpace setDelegate:self];
    [plotSpace setAllowsUserInteraction:YES];
    
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xAxisStart)
                                                    length:CPTDecimalFromDouble(xAxisLength)];
	
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(yAxisStart)
                                                    length:CPTDecimalFromDouble(yAxisLength)];
	
	CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
	dataSourceLinePlot.dataSource = self;
    
    
    CPTMutableLineStyle *majorAxisStyle = [CPTMutableLineStyle lineStyle];
    majorAxisStyle.lineWidth = 0.1;
    
    CPTMutableLineStyle *minorAxisStyle = [CPTMutableLineStyle lineStyle];
    minorAxisStyle.lineWidth = 0.1;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)hostingView.hostedGraph.axisSet;
    
    //x-axis styling
    axisSet.xAxis.majorGridLineStyle = majorAxisStyle;
    axisSet.xAxis.minorGridLineStyle = minorAxisStyle;
    
    //y-axis styling
    axisSet.yAxis.majorGridLineStyle = majorAxisStyle;
    axisSet.yAxis.minorGridLineStyle = minorAxisStyle;
    
    [self applyDefaultPlotColor:dataSourceLinePlot];
	[graph addPlot:dataSourceLinePlot];
    
}

-(void) applyHighLightPlotColor:(CPTScatterPlot*) plot{
    CPTMutableLineStyle *hightlightLineStyle = [CPTMutableLineStyle lineStyle];
	hightlightLineStyle.lineWidth = 4.0;
	hightlightLineStyle.lineColor = [CPTColor lightGrayColor];
    plot.dataLineStyle = hightlightLineStyle;
}

-(void) applyDefaultPlotColor:(CPTScatterPlot*) plot{
    CPTMutableLineStyle *hightlightLineStyle = [CPTMutableLineStyle lineStyle];
	hightlightLineStyle.lineWidth = 4.0;
	hightlightLineStyle.lineColor = [CPTColor blueColor];
    plot.dataLineStyle = hightlightLineStyle;
}

-(void)updateGraph:(int)slope graphViewBounds:(CGRect)viewBounds lineMoverPoint:(CGPoint)moverPoint{
     NSLog(@"upating graph");
    //[self configureHost:viewBounds];
    [self generateDataSamples:moverPoint yIntercept:0.0 ];
     CPTGraph *graph = self.hostView.hostedGraph;
    [graph reloadData];
    //locomotionPoints.center = moverPoint; //locomotion point needs to stay still
}

-(void)setupGraph:(CGPoint)point1 graphViewBounds:(CGRect)viewBounds{
    [self generateDataSamples:CGPointZero yIntercept:0.0];
    [self configureHost:viewBounds];
    
    [self configureGraph];
[self configurePlots];
    [self changeGraphSlope:graphSlope point1:point1];
}

@end