//
//  Tower.h
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "CCNode.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"
#import <CoreMotion/CoreMotion.h>

#define TOWER_COST 300

@class HelloWorldScene, Enemy;

@interface Tower : CCNode {
    int atkRange;
    int atkPower;
    float atkSpeed;
    int maxHP;
    int currentHP;
    int upgrade;
    BOOL isAttacking;
    Enemy *chosenEnemy;
    CCDrawNode *healthBar;
}

@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic,weak) HelloWorldScene *theGame;
@property (nonatomic,strong) CCSprite *mySprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(void)targetKilled;
-(void)upgradeTower;
-(BOOL)isUpgradable;
-(void)receiveDamage:(int)damage;

@end
