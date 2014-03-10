//
//  MainTower.h
//  Tower Of Salon
//
//  Created by Chanthat Onsawang on 10/03/14.
//  Copyright (c) 2014 Pisitsak Sriwimol. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCNode.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

#define MAIN_TOWER_COST 1

@class HelloWorldScene, Enemy;

@interface MainTower : CCNode {
    int atkRange;
    int atkPower;
    float atkSpeed;
    int maxHP;
    int currentHP;
    int upgrade;
    BOOL isAttacking;
    
    int atkType; // 0 - bullet, 1 - arrow, 2 - laser
    
    Enemy *chosenEnemy;
    CCDrawNode *healthBar;
}

@property (nonatomic,weak) HelloWorldScene *theGame;
@property (nonatomic,strong) CCSprite *mySprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(void)targetKilled;
-(void)upgradeTower;
-(BOOL)isUpgradable;

@end
