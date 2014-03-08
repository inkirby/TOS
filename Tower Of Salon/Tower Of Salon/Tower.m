//
//  Tower.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "Tower.h"
#import "Enemy.h"

#define HEALTH_BAR_WIDTH 20
#define HEALTH_BAR_ORIGIN -10

@implementation Tower

@synthesize mySprite;
@synthesize theGame;

+(id) nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    return [[self alloc] initWithTheGame:_game location:location];
}

-(id) initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    if( (self = [super init])) {
        theGame = _game;
        atkRange = 70;
        atkPower = 10;
        atkSpeed = 1;
        
        maxHP = 50;
        currentHP = maxHP;
        
        mySprite = [CCSprite spriteWithImageNamed:@"tower.png"];
        [self addChild:mySprite];
        [mySprite setPosition:location];
        [theGame addChild:self];
        
        //[self scheduleUpdate];
        NSLog(@"init tower");
        
    }
    return self;
}

-(void)update:(CCTime)delta {
    
    if(chosenEnemy) {
        CGPoint normalized = ccpNormalize(ccp(chosenEnemy.mySprite.position.x-mySprite.position.x,chosenEnemy.mySprite.position.y-mySprite.position.y));
        mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y, -normalized.x))+90;
        
        if(![theGame circle:mySprite.position withRadius:atkRange collisionWithCircle:chosenEnemy.mySprite.position collisionCircleRadius:1]) {
            [self lostSightOfEnemy];
        }
    } else {
        for(Enemy *enemy in theGame.enemies) {
            if([theGame circle:mySprite.position withRadius:atkRange collisionWithCircle:enemy.mySprite.position collisionCircleRadius:1]) {
                [self chosenEnemyForAttack:enemy];
                break;
            }
        }
    }
}
-(void)attackEnemy {
    [self schedule:@selector(shootWeapon) interval:atkSpeed];
}
-(void)chosenEnemyForAttack:(Enemy *)enemy {
    chosenEnemy = nil;
    chosenEnemy = enemy;
    [self attackEnemy];
    [enemy getAttacked:self];
}
-(void)shootWeapon {
    CCSprite *bullet = [CCSprite spriteWithImageNamed:@"bullet.png"];
    [theGame addChild:bullet];
    [bullet setPosition:mySprite.position];
    [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.1 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
    
}
//-(void)removeBullet:(CCSprite *)bullet {
//    [bullet removeFromParentAndCleanup:YES];
//}
-(void)damageEnemy {
    [chosenEnemy getDamaged:atkPower];
}
-(void)targetKilled {
    if(chosenEnemy) {
        chosenEnemy = nil;
    }
    [self unschedule:@selector(shootWeapon)];
}
-(void)lostSightOfEnemy {
    [chosenEnemy gotLostSight:self];
    if(chosenEnemy) {
        chosenEnemy = nil;
    }
    [self unschedule:@selector(shootWeapon)];
}

-(void)draw {
    
    ccDrawColor4B(255,255,255,255);
    ccDrawCircle(mySprite.position,atkRange,360,30,false);
    
    CGPoint myPosition = mySprite.position;
    
//    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN,
//                        myPosition.y+16),
//                    ccp(myPosition.x+HEALTH_BAR_ORIGIN+HEALTH_BAR_WIDTH,
//                        myPosition.y+14),
//                    ccc4f(1.0, 0, 0, 1.0));
//    
//    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN,
//                        myPosition.y+16),
//                    ccp(myPosition.x+HEALTH_BAR_ORIGIN + (float)(currentHP * HEALTH_BAR_WIDTH)/maxHP,
//                        myPosition.y+14),
//                    ccc4f(0, 1.0, 0, 1.0));
    
    [super draw];
}

@end
