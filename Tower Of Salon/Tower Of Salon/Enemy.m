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

+(id)nodeWithTheGame:(HelloWorldScene *)_game enemy:(NSString *)enemy wave:(NSInteger)wave{
    return [[self alloc] initWithTheGame:_game enemy:enemy wave:wave];
}

-(id)initWithTheGame:(HelloWorldScene *)_game enemy:(NSString *)enemy wave:(NSInteger)wave{
    if((self = [super init])) {
        
        attackedBy = [[NSMutableArray alloc] initWithCapacity:5];
        
        theGame = _game;
        
        if([enemy  isEqualToString: @"skeleton"]) {
            mySprite = [CCSprite spriteWithImageNamed:@"enemy.png"];
            [self addChild:mySprite];
            maxHP = 40+(5* wave);
            walkingSpeed = 1.0;
            type = @"skeleton";
        } else if ([enemy isEqualToString:@"hydra"]) {
            mySprite = [CCSprite spriteWithImageNamed:@"enemy.png"];
            [self addChild:mySprite];
            maxHP = 100+(10*wave);
            walkingSpeed = 2.5;
            type = @"hydra";
        } else if ([enemy isEqualToString:@"boss"]) {
            mySprite = [CCSprite spriteWithImageNamed:@"enemy.png"];
            [self addChild:mySprite];
            maxHP = 250+(20*wave);
            walkingSpeed = 3.5;
            type = @"boss";
        }
        currentHP = maxHP;
        active = NO;
        
        Waypoint *waypoint = (Waypoint *)[theGame.waypoints objectAtIndex:([theGame.waypoints count] -1)];
        destinationWaypoint = waypoint.nextWayPoint;
        
        CGPoint pos = waypoint.myPosition;
        myPosition = pos;
        
        healthBar = [[CCDrawNode alloc] init];
        healthBar.contentSize = CGSizeMake(ENEMY_HEALTH_BAR_WIDTH, ENEMY_HEALTH_BAR_HEIGHT);
        [self addChild:healthBar];
        
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
        if([type compare:@"skeleton"]) {
            [theGame awardGold:200];
        } else if([type compare:@"hydra"]) {
            [theGame awardGold:350];
            if(arc4random()%100 > 95) {
                [theGame awardDiamond:1];
                NSLog(@"Kill hydra get diamond");
            }
        } else if([type compare:@"boss"]) {
            [theGame awardGold:600];
            NSLog(@"Kill boss");
            [self drawBossCircle];
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

@end
