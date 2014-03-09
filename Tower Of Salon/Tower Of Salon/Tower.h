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

#define TOWER_COST 300

@class HelloWorldScene, Enemy;

@interface Tower : CCNode {
    int atkRange;
    int atkPower;
    float atkSpeed;
    int maxHP;
    int currentHP;
    BOOL isAttacking;
    Enemy *chosenEnemy;
    CCDrawNode *healthBar;
}

@property (nonatomic,weak) HelloWorldScene *theGame;
@property (nonatomic,strong) CCSprite *mySprite;

+(id)nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(id)initWithTheGame:(HelloWorldScene *)_game location:(CGPoint) location;
-(void)targetKilled;

@end
