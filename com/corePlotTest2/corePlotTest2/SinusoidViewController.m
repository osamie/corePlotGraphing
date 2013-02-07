//
//  SinusoidViewController.m
//  corePlotTest2
//
//  Created by Osazuwa Omigie on 2012-10-30.
//  Copyright (c) 2012 Osazuwa Omigie. All rights reserved.
//

#import "SinusoidViewController.h"

#define START_POINT -4.0
#define END_POINT 4.0
#define NUM_SAMPLES 180

#define MARKER_START -2.0
#define MARKER_END  2.0

#define X_VAL @"X_VAL"
#define Y_VAL @"Y_VAL"

#define DEFAULT_AMPLITUDE 1
#define DEFAULT_FREQUENCY 2.3
#define DEFAULT_PHASE 0

//MODES
#define AMPLITUDE_SHIFT 1
#define FREQUENCY_SHIFT 2
#define PHASE_SHIFT 3


@implementation SinusoidViewController
@synthesize lineBeingDragged;
@synthesize mode;
@synthesize lineEqu_label;
@synthesize phase;
@synthesize amplitude;
@synthesize frequency;
@synthesize markerXVal;


-(id)init{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", [self class]);
        lineBeingDragged = NO;
        markerXVal = 0.0;
    }
    return self;
}


/*
 Generates data for plotting sin graph
 */
-(void) generateSineDataSamples:(double)graphAmplitude frequency:(double)graphFrequency phase:(double)graphPhase
{
	double length = (END_POINT - START_POINT);
    int numSamples = NUM_SAMPLES;
    
	double delta = length / (numSamples - 1);
    
	samples = [[NSMutableArray alloc] initWithCapacity:numSamples]; //initialize data array
    markerSamples = [[NSMutableArray alloc] initWithCapacity:numSamples]; //initialize marker data array
    
    for (int i = 0; i < numSamples; i++){
		double x = START_POINT + (delta * i);
		double y = [self getSineFunction:x amplitude:graphAmplitude frequency:graphFrequency phase:graphPhase];
		NSDictionary *sample = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithDouble:x],X_VAL,
								[NSNumber numberWithDouble:y],Y_VAL,
								nil];
        
		[samples addObject:sample];
	}
}

/*
   Generate data for plotting the straight line marker on the graph
 */
-(void) generateMarkerDataSamples:(double)xVal
{
    double endPoint = MARKER_END;
    double startPoint = MARKER_START;
    double length = endPoint-startPoint;//(END_POINT - START_POINT);
    int numSamples = NUM_SAMPLES;
    
	double delta = length / (numSamples - 1);
    
	markerSamples = [[NSMutableArray alloc] initWithCapacity:numSamples]; //initialize data array
    for (int i = 0; i < numSamples; i++){
		double x = xVal;//START_POINT + (delta * i);
		double y = startPoint + (delta * i);
        
		NSDictionary *sample = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithDouble:x],X_VAL,
								[NSNumber numberWithDouble:y],Y_VAL,
								nil];
        
		[markerSamples addObject:sample];
	}
    
}

/*
 * Returns the y value of a given x on the SINE graph
 */
-(double)getSineFunction:(double)xVal amplitude:(double)sineAmplitude frequency:(double)sineFrequency phase:(double)sinePhase
{
    return sineAmplitude * (sin((sineFrequency*xVal))+sinePhase);
}


- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)location{
    CGPoint newCoord = [self convertToGraphCoord:location];
    int yy = newCoord.y;
    CGRect range = CGRectMake(markerXVal-0.55, yy-0.55, 1.5, 1.5);
    
    int plotIndex = 1; //Only 1 plot on the graph
    BOOL isInLine = CGRectContainsPoint(range,newCoord);

    NSLog(@"CoordX:%f CoordY:%f isInLine? = %i\n",newCoord.x, newCoord.y, isInLine);
//    NSLog(@"Amplitude:%f Phase:%f Frequency:%f",[self amplitude],[self phase],[self frequency]);

    if((isInLine) && (yy >= MARKER_START) && (yy <= MARKER_END)){
        //store the location of the touch at this point...used in determining mode
        lineBeingDragged=YES;
        [self applyHighLightPlotColor:(CPTScatterPlot *)[self.hostView.hostedGraph plotAtIndex:plotIndex]];
        NSLog(@"X coord %f",markerXVal);
        return NO;
    }
    lineBeingDragged=NO;
    return NO;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)location{
    
    CGPoint newCoord = [self convertToGraphCoord:location];
    if (lineBeingDragged && (newCoord.y > 0)) {
        /*TODO: determine the mode(phase_shift,amplitude_shift or freq_shift) based on the direction of the drag motion.*/
        mode = AMPLITUDE_SHIFT; //hard-coded mode
        
        [self moveMarker:newCoord];
        lineBeingDragged = YES;

        return NO;
    }
    lineBeingDragged = NO;
    mode=-1;//previous mode should be deselected
    return NO;
}

- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)location
{
    int plotIndex = 1; //specify the index of the plot to be affected here
    lineBeingDragged = NO;
    [self applyDefaultPlotColor:(CPTScatterPlot *)[self.hostView.hostedGraph plotAtIndex:plotIndex]];
    [self applyPlotColor:(CPTScatterPlot *)[self.hostView.hostedGraph plotAtIndex:plotIndex] color:[CPTColor magentaColor]];
//    markerXVal = location.x;

    
    return YES;
}

/*
 this method should be called only when there is touchdown and drag operation on the plotted line
 */
-(void) moveGraph:(CGPoint)location curMode:(int)curMode{
//    NSLog(@"PLOT TOUCHED AT locationX:%f, locationY:%f",location.x,location.y);
    
    switch(curMode){
        case PHASE_SHIFT:
        {
            NSLog(@"shifting the graph's PHASE\n");
            break;
        }
        case AMPLITUDE_SHIFT:
        {
            NSLog(@"shifting the graph's AMPLITUDE from:%f To:%f \n",self.amplitude,location.y);
        
            [self generateSineDataSamples:location.y frequency:[self frequency] phase:[self phase]];
            
            self.amplitude = location.y;
            
            CPTGraph *graph = self.hostView.hostedGraph;
            [graph reloadData];
            break;
        }
        case FREQUENCY_SHIFT:
        {
            NSLog(@"shifting the graph's FREQUENCY\n");
            break;
        }
        default:
        {
            NSLog(@"Incorrect mode specified! mode:%i",curMode);
        }
    }
}

-(void) moveMarker:(CGPoint)location{
    [self generateMarkerDataSamples:location.x];
    [self.hostView.hostedGraph reloadData];
    markerXVal = location.x;
}


-(void)updateGraph:(int)slope graphViewBounds:(CGRect)viewBounds lineMoverPoint:(CGPoint)moverPoint{
    CPTGraph *graph = self.hostView.hostedGraph;
    [graph reloadData];
    
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

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
{
	return NUM_SAMPLES;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
			   recordIndex:(NSUInteger)index;
{
	NSDictionary *sample;
	
    if ( [plot.identifier isEqual:@"MarkerPlot"] ){
       sample = [markerSamples objectAtIndex:index];
    }else{
        sample = [samples objectAtIndex:index];
    }
    
	if (fieldEnum == CPTScatterPlotFieldX){
        return [sample valueForKey:X_VAL];
    }
	else{
        return [sample valueForKey:Y_VAL];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect viewBounds = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 95);
    [self setupGraph:CGPointMake(0.0,0.0) graphViewBounds:viewBounds];
}

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
    CPTGraphHostingView *hostingView = self.hostView;
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
    
    [dataSourceLinePlot setIdentifier:@"SinePlot"];
	[graph addPlot:dataSourceLinePlot];
    
    //------------------setup marker plot-------------------
    CPTScatterPlot *markerLinePlot = [[CPTScatterPlot alloc] init];
	markerLinePlot.dataSource = self;
    
    [self applyDefaultPlotColor:markerLinePlot];
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 2.0;
	lineStyle.lineColor = [CPTColor magentaColor];
    markerLinePlot.dataLineStyle = lineStyle;

    [markerLinePlot setIdentifier:@"MarkerPlot"];
	[graph addPlot:markerLinePlot];
    
}

-(void) applyHighLightPlotColor:(CPTScatterPlot*) plot{
    [self applyPlotColor:plot color:[CPTColor grayColor]];
}

-(void) applyDefaultPlotColor:(CPTScatterPlot*) plot{
    [self applyPlotColor:plot color:[CPTColor orangeColor]];
}

-(void) applyPlotColor:(CPTScatterPlot*) plot color:(CPTColor *)color{
    CPTMutableLineStyle *hightlightLineStyle = [CPTMutableLineStyle lineStyle];
	hightlightLineStyle.lineWidth = 3.0;
	hightlightLineStyle.lineColor = color;
    plot.dataLineStyle = hightlightLineStyle;
}

-(void)setupGraph:(CGPoint)point1 graphViewBounds:(CGRect)viewBounds{
    self.frequency = DEFAULT_FREQUENCY;
    self.phase = DEFAULT_PHASE;
    self.amplitude = DEFAULT_AMPLITUDE;
    
    [self generateSineDataSamples:[self amplitude] frequency:[self frequency] phase:[self phase]];
    [self generateMarkerDataSamples:markerXVal];
    [self configureHost:viewBounds];
    [self configureGraph];
    [self configurePlots];
}

@end