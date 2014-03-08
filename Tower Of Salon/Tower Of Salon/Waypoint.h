//
//  Waypoint.h
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@interface Waypoint : CCNode {
    HelloWorldScene *theGame;
}

@property (nonatomic,readwrite) CGPoint myPosition;
@property (nonatomic,assign) Waypoint *nextWayPoint;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location;

@end
