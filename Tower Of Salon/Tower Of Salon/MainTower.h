//
//  MainTower.h
//  Tower Of Salon
//
//  Created by Chanthat Onsawang on 10/03/14.
//  Copyright (c) 2014 Pisitsak Sriwimol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CCNode.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

#define MAIN_TOWER_COST 1

@class HelloWorldScene, Enemy;

@interface MainTower : CCNode {
    int atkPower;
    float atkSpeed;
    int maxHP;
    
    int atkType; // 0 - bullet, 1 - arrow, 2 - laser
    int upgradeAtk;
    int upgradeSpeed;
    int upgradeHP;
    
    int AtkUpgraded;
    int SpdUpgraded;
    int HPUpgraded;
    
    int atkRange;
    int currentHP;
    BOOL isAttacking;
    BOOL canAttack;
    Enemy *chosenEnemy;
    CCDrawNode *healthBar;
}

@property (nonatomic,weak) HelloWorldScene *theGame;
@property (nonatomic,strong) CCSprite *mySprite;
@property (nonatomic,strong) CCSprite *laserGuide;

@property (nonatomic,strong) CLLocationManager *locationManager;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(void)targetKilled;
-(void)disableAttack;
-(void)enableAttack;
-(void)setUpgradeAtk:(int)atk;
-(void)setUpgradeSpd:(int)spd;
-(void)setUpgradeHP:(int)hp;

@end
