//
//  Waypoint.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "Waypoint.h"

@implementation Waypoint

@synthesize myPosition;
@synthesize nextWayPoint;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    return [[self alloc] initWithTheGame:_game location:location];
}

-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    if((self = [super init])) {
        theGame = _game;
        [self setPosition:CGPointZero];
        myPosition = location;
        [theGame addChild:self];
    }
    return self;
}

-(void)draw {
    ccDrawColor4B(0,25,2,255);
    ccDrawCircle(myPosition,6,360,30,false);
    ccDrawCircle(myPosition,2,360,30,false);
    
    if(nextWayPoint) {
        ccDrawLine(myPosition,nextWayPoint.myPosition);
    }
    [super draw];
}

@end
