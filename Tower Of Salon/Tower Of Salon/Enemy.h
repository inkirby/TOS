//
//  Enemy.h
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "HelloWorldScene.h"

@class HelloWorldScene, Waypoint, Tower;

@interface Enemy : CCNode {
    CGPoint myPosition;
    NSString *type;
    int maxHP;
    int currentHP;
    float walkingSpeed;
    Waypoint *destinationWaypoint;
    BOOL active;
    NSMutableArray *attackedBy;
    CCDrawNode *healthBar;
    CCDrawNode *bossCircle;
}

@property (nonatomic,assign) HelloWorldScene *theGame;
@property (nonatomic,assign) CCSprite *mySprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game enemy:(NSString *)enemy wave:(NSInteger)wave;
-(id)initWithTheGame:(HelloWorldScene *)_game enemy:(NSString *)enemy wave:(NSInteger)wave;
-(void)doActivate;
-(void)getRemoved;
-(void)getAttacked:(Tower *)attacker;
-(void)gotLostSight:(Tower *)attacker;
-(void)getDamaged:(int)damage;

@end
