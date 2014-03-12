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

const float ENEMY_HEALTH_BAR_WIDTH = 40.0f;
const float ENEMY_HEALTH_BAR_HEIGHT = 4.0f;

@implementation Enemy

@synthesize mySprite;
@synthesize theGame;

+(id)nodeWithTheGame:(HelloWorldScene *)_game enemy:(NSInteger)enemy wave:(NSInteger)wave{
    return [[self alloc] initWithTheGame:_game enemy:enemy wave:wave];
}

-(id)initWithTheGame:(HelloWorldScene *)_game enemy:(NSInteger)enemy wave:(NSInteger)wave{
    if((self = [super init])) {
        
        attackedBy = [[NSMutableArray alloc] initWithCapacity:5];
        
        theGame = _game;
        
        NSLog(@"%d enemy with id: %@", enemy, mySprite.init);
        mySprite = [theGame getSprite:enemy];
        
        //added assets
        if(enemy == 0) {
            maxHP = 40+(5* wave);
            walkingSpeed = 1.0;
            type = 0;
        } else if (enemy == 1) {
            maxHP = 100+(10*wave);
            walkingSpeed = 2.5;
            type = 1;
        } else {
            maxHP = 250+(20*wave);
            walkingSpeed = 3.5;
            type = 2;
        }
        
        NSLog(@"!");
        
        [self addChild:mySprite];
        currentHP = maxHP;
        active = NO;
        
        NSLog(@"1!");
        Waypoint *waypoint = (Waypoint *)[theGame.waypoints objectAtIndex:([theGame.waypoints count] -1)];
        destinationWaypoint = waypoint.nextWayPoint;
        
        
        NSLog(@"2!");
        CGPoint pos = waypoint.myPosition;
        myPosition = pos;
        
        
        NSLog(@"3!");
        healthBar = [[CCDrawNode alloc] init];
        healthBar.contentSize = CGSizeMake(ENEMY_HEALTH_BAR_WIDTH, ENEMY_HEALTH_BAR_HEIGHT);
        [self addChild:healthBar];
        
        
        NSLog(@"4!");
        [mySprite setPosition:pos];
        [theGame addChild:self];
        //[self scheduleUpdate];
        
        NSLog(@"Ahhhhhhhh");
    }
    
    return self;
}

-(void)doActivate {
    active = YES;
}

-(void)update:(CCTime)delta {
    
    if(!active)
        return;
    
    healthBar.position = ccp(myPosition.x - ENEMY_HEALTH_BAR_WIDTH/2.0f + 0.5f, myPosition.y - mySprite.contentSize.height/2.0f -15.0f + 0.5f);
    [self drawHealthBar:healthBar hp:currentHP];
    
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
    float rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y, -normalized.x));
    mySprite.flipX = (rotation>90&&rotation<270)?true:false;
    myPosition = ccp(myPosition.x+normalized.x * movementSpeed,myPosition.y+normalized.y * movementSpeed);
    [mySprite setPosition:myPosition];
}

-(void)getRemoved {
    
    for(Tower *attacker in attackedBy) {
        [attacker targetKilled];
    }
    
    [self.parent removeChild:self cleanup:YES];
    
    // notify that enemy is killed
    [theGame enemyGotKilled];
    
    [theGame.enemies removeObject:self];
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
        if(type == 0) {
            
            NSLog(@"Kill skel");
            [theGame awardGold:200];
        } else if(type == 1) {
            
            NSLog(@"Kill hydra");
            [theGame awardGold:350];
            if(arc4random()%100 > 95) {
                [theGame awardDiamond:1];
                NSLog(@"Kill hydra get diamond");
            }
        } else {
            [theGame awardGold:600];
            NSLog(@"Kill boss");
            [self bossDead];
            if(arc4random()%100 < 80) {
                [theGame awardDiamond:1];
                NSLog(@"Kill boss get diamond");
            }
        }
        [self getRemoved];
    }
}

-(void)drawHealthBar:(CCDrawNode *)node hp:(int)hp {
    [node clear];
    
    CGPoint verts[4];
    verts[0] = ccp(0.0f, 0.0f);
    verts[1] = ccp(0.0f, ENEMY_HEALTH_BAR_HEIGHT - 1.0f);
    verts[2] = ccp(ENEMY_HEALTH_BAR_WIDTH - 1.0f, ENEMY_HEALTH_BAR_HEIGHT - 1.0f);
    verts[3] = ccp(ENEMY_HEALTH_BAR_WIDTH - 1.0f, 0.0f);
    
    //ccColor4F clearColor = ccc4f(0.0f, 0.0f, 0.0f, 0.0f);
    //ccColor4F borderColor = ccc4f(35.0f/255.0f, 28.0f/255.0f, 40.0f/255.0f, 1.0f);
    //ccColor4F fillColor = ccc4f(113.0f/255.0f, 202.0f/255.0f, 53.0f/255.0f, 1.0f);
    
    CCColor *clearColors = [CCColor redColor];
    CCColor *borderColors = [CCColor blackColor];
    CCColor *fillColors = [CCColor greenColor];
    
    [node drawPolyWithVerts:verts count:4 fillColor:clearColors borderWidth:1.0f borderColor:borderColors];
    
    verts[0].x += 0.5f;
    verts[0].y += 0.5f;
    verts[1].x += 0.5f;
    verts[1].y -= 0.5f;
    verts[2].x = (ENEMY_HEALTH_BAR_WIDTH - 2.0f)*currentHP/maxHP + 0.5f;
    verts[2].y -= 0.5f;
    verts[3].x = verts[2].x;
    verts[3].y += 0.5f;
    
    [node drawPolyWithVerts:verts count:4 fillColor:fillColors borderWidth:0.0f borderColor:clearColors];
}

-(void)drawBossCircle {
    bossCircle = [[CCDrawNode alloc] init];
}

-(void)bossDead {
    NSLog(@"BossDead");
    for (Tower *towerAround in theGame.towers) {
        if([theGame circle:mySprite.position withRadius:400 collisionWithCircle:towerAround.mySprite.position collisionCircleRadius:400]) {
            [towerAround receiveDamage:100];
        }
    }
}

@end
