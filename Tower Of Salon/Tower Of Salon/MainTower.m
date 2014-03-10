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
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 1;
        self.motionManager.gyroUpdateInterval = 1;
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingHeading];
        
        theGame = _game;
        maxHP = 1000;
        atkRange = 460;
        upgradeAtk = 0;
        upgradeSpeed = 0;
        upgradeHP = 0;
        canAttack = false;
        
        // receivable vars
        atkType = 2;
        AtkUpgraded = 0;
        SpdUpgraded = 0;
        HPUpgraded = 0;
        
        switch (atkType) {
            case 1: // arrow
                atkPower = 300;
                atkSpeed = 2;
                mySprite = [CCSprite spriteWithImageNamed:@"maintowerarrow.png"];
                break;
            case 2: // laser
                atkPower = 3;
                atkSpeed = .05;
                mySprite = [CCSprite spriteWithImageNamed:@"maintowerlaser.png"];
                break;
            default: // bullet
                atkPower = 120;
                atkSpeed = 1;
                mySprite = [CCSprite spriteWithImageNamed:@"maintowerbullet.png"];
                break;
        }
        
        while (upgradeAtk<AtkUpgraded) [self upgradeTowerAtk];
        while (upgradeSpeed<SpdUpgraded) [self upgradeTowerSpeed];
        while (upgradeHP<HPUpgraded) [self upgradeTowerHP];
        
        currentHP = maxHP;
        
        healthBar = [[CCDrawNode alloc] init];
        healthBar.contentSize = CGSizeMake(MAIN_TOWER_HEALTH_BAR_WIDTH, MAIN_TOWER_HEALTH_BAR_HEIGHT);
        [self addChild:healthBar];
        
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
    
    
    // this rotate turret to enemy
    /*
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
    */
    
    // this rotate turret to compass direction
    
    mySprite.rotation = [self.locationManager heading].magneticHeading;
    
    
}
-(void)attackEnemy {
    [self schedule:@selector(shootWeapon) interval:atkSpeed];
}
-(void)chosenEnemyForAttack:(Enemy *)enemy {
    chosenEnemy = nil;
    //if (!canAttack) return;
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
        [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.4 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
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
        [bullet runAction:[CCActionSequence actions:[CCActionMoveTo actionWithDuration:0.25 position:chosenEnemy.mySprite.position],[CCActionCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCActionRemove action],nil]];
    }
}

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

-(void)upgradeTowerAtk {
    atkPower *= 1.25;
    upgradeAtk++;
}

-(void)upgradeTowerHP {
    maxHP *= 1.5;
    upgradeHP++;
}

-(void)upgradeTowerSpeed {
    atkSpeed *= 0.9;
    upgradeSpeed++;
}

-(void)disableAttack {
    canAttack = false;
}
-(void)enableAttack {
    canAttack = true;
}

-(void)setUpgradeAtk:(int)atk {
    AtkUpgraded = atk;
}
-(void)setUpgradeSpd:(int)spd {
    SpdUpgraded = spd;
}
-(void)setUpgradeHP:(int)hp {
    HPUpgraded = hp;
}

@end
