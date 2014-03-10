//
//  MainTower.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/8/2557 BE.
//  Copyright (c) 2557 Pisitsak Sriwimol. All rights reserved.
//

#import "MainTower.h"
#import "Enemy.h"

const float MAIN_TOWER_HEALTH_BAR_WIDTH = 40.0f;
const float MAIN_TOWER_HEALTH_BAR_HEIGHT = 4.0f;

@implementation MainTower

@synthesize mySprite;
@synthesize theGame;

+(id) nodeWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    return [[self alloc] initWithTheGame:_game location:location];
}

-(id) initWithTheGame:(HelloWorldScene *)_game location:(CGPoint)location {
    if( (self = [super init])) {
        theGame = _game;
        maxHP = 1000;
        atkRange = 460;
        
        // receivable vars
        atkType = 1;
        upgrade = 0;
        
        switch (atkType) {
            case 1: // arrow
                atkPower = 300;
                atkSpeed = 2;
                break;
            case 2: // laser
                atkPower = 3;
                atkSpeed = .05;
                break;
            default: // bullet
                atkPower = 120;
                atkSpeed = 1;
                break;
        }
        
        currentHP = maxHP;
        
        
        healthBar = [[CCDrawNode alloc] init];
        healthBar.contentSize = CGSizeMake(MAIN_TOWER_HEALTH_BAR_WIDTH, MAIN_TOWER_HEALTH_BAR_HEIGHT);
        [self addChild:healthBar];
        
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
    
    healthBar.position = ccp(mySprite.position.x - MAIN_TOWER_HEALTH_BAR_WIDTH/2.0f + 0.5f, mySprite.position.y - mySprite.contentSize.height/2.0f - 10.0f + 0.5f);
    
    [self drawHealthBar:healthBar hp:currentHP];
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
    if (atkType == 1) { //arrow
        CCSprite *bullet = [CCSprite spriteWithImageNamed:@"arrow.png"];
        CGPoint normalized = ccpNormalize(ccp(chosenEnemy.mySprite.position.x-mySprite.position.x,chosenEnemy.mySprite.position.y-mySprite.position.y));
        bullet.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y, -normalized.x))-90;
        [theGame addChild:bullet];
        [bullet setPosition:mySprite.position];
        [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.25 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
    }else if (atkType == 2) {   //laser
        CCSprite *bullet = [CCSprite spriteWithImageNamed:@"laser.png"];
        CGPoint normalized = ccpNormalize(ccp(chosenEnemy.mySprite.position.x-mySprite.position.x,chosenEnemy.mySprite.position.y-mySprite.position.y));
        bullet.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y, -normalized.x))-90;
        [theGame addChild:bullet];
        [bullet setPosition:mySprite.position];
        [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.12 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
    }else{  //bullet
        CCSprite *bullet = [CCSprite spriteWithImageNamed:@"bullet.png"];
        [theGame addChild:bullet];
        [bullet setPosition:mySprite.position];
        [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.2 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
    }
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

-(BOOL)isUpgradable {
    if(upgrade > 9) {
        return NO;
    }
    return YES;
}

-(void)upgradeTower {
    atkPower += 1+(atkPower*.3f);
    maxHP += 100;
}

-(void)drawHealthBar:(CCDrawNode *)node hp:(int)hp {
    [node clear];
    
    CGPoint verts[4];
    verts[0] = ccp(0.0f, 0.0f);
    verts[1] = ccp(0.0f, MAIN_TOWER_HEALTH_BAR_HEIGHT - 1.0f);
    verts[2] = ccp(MAIN_TOWER_HEALTH_BAR_WIDTH - 1.0f, MAIN_TOWER_HEALTH_BAR_HEIGHT - 1.0f);
    verts[3] = ccp(MAIN_TOWER_HEALTH_BAR_WIDTH - 1.0f, 0.0f);
    
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
    verts[2].x = (MAIN_TOWER_HEALTH_BAR_WIDTH - 2.0f)*currentHP/maxHP + 0.5f;
    verts[2].y -= 0.5f;
    verts[3].x = verts[2].x;
    verts[3].y += 0.5f;
    
    [node drawPolyWithVerts:verts count:4 fillColor:fillColors borderWidth:0.0f borderColor:clearColors];
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
