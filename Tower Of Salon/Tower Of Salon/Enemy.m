//
//  Enemy.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "Enemy.h"
#import "Tower.h"
#import "Waypoint.h"

#define HEALTH_BAR_WIDTH 20
#define HEALTH_BAR_ORIGIN -10

@implementation Enemy

@synthesize mySprite;
@synthesize theGame;

+(id)nodeWithTheGame:(HelloWorldScene *)_game {
    return [[self alloc] initWithTheGame:_game];
}

-(id)initWithTheGame:(HelloWorldScene *)_game {
    if((self = [super init])) {
        
        attackedBy = [[NSMutableArray alloc] initWithCapacity:5];
        
        theGame = _game;
        maxHP = 40;
        currentHP = maxHP;
        
        active = NO;
        
        walkingSpeed = 2.5;
        
        mySprite = [CCSprite spriteWithImageNamed:@"enemy.png"];
        [self addChild:mySprite];
        
        Waypoint *waypoint = (Waypoint *)[theGame.waypoints objectAtIndex:([theGame.waypoints count] -1)];
        destinationWaypoint = waypoint.nextWayPoint;
        
        CGPoint pos = waypoint.myPosition;
        myPosition = pos;
        
        [mySprite setPosition:pos];
        [theGame addChild:self];
        //[self scheduleUpdate];
    }
    
    return self;
}

-(void)doActivate {
    active = YES;
}

-(void)update:(CCTime)delta {
    
    if(!active)
        return;
    if([theGame circle:myPosition withRadius:1 collisionWithCircle:destinationWaypoint.myPosition collisionCircleRadius:1]) {
        if(destinationWaypoint.nextWayPoint) {
            destinationWaypoint = destinationWaypoint.nextWayPoint;
        } else {
            // Reached the end
            [theGame getHpDamage];
            [self getRemoved];
            return;
        }
    }
    
    CGPoint targetPoint = destinationWaypoint.myPosition;
    float movementSpeed = walkingSpeed;
    
    CGPoint normalized = ccpNormalize(ccp(targetPoint.x-myPosition.x,targetPoint.y-myPosition.y));
    mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y, -normalized.x));
    myPosition = ccp(myPosition.x+normalized.x * movementSpeed,myPosition.y+normalized.y * movementSpeed);
    [mySprite setPosition:myPosition];
}

-(void)getRemoved {
    
    for(Tower *attacker in attackedBy) {
        [attacker targetKilled];
    }
    
    [self.parent removeChild:self cleanup:YES];
    [theGame.enemies removeObject:self];
    
    // notify that enemy is killed
    [theGame enemyGotKilled];
}

-(void)getAttacked:(Tower *)attacker {
    [attackedBy addObject:attacker];
}
-(void)gotLostSight:(Tower *)attacker {
    [attackedBy removeObject:attacker];
}
-(void)getDamaged:(int)damage {
    currentHP -= damage;
    if(currentHP <= 0) {
        NSLog(@"Kill enemy");
        [theGame awardGold:200];
        [self getRemoved];
    }
}

-(void)draw {
    
    
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
}

@end
