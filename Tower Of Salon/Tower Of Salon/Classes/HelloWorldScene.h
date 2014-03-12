//
//  HelloWorldScene.h
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/5/2557 BE.
//  Copyright Pisitsak Sriwimol 2557. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "MainTower.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface HelloWorldScene : CCScene {
    NSMutableArray *towerBases;
    int wave;
    int playerHP;
    int playerGold;
    int playerDiamond;
    int enemyNum;
    BOOL gameEnded;
    BOOL isBossOut;
    
    int currentSpritePos;
    
    CCSprite *skeleton;
    CCSprite *hydra;
    CCSprite *boss;
    NSMutableArray *tskeleton;
    NSMutableArray *thydra;
    NSMutableArray *tboss;
    CCLabelBMFont *ui_hp_lbl;
    CCLabelBMFont *ui_gold_lbl;
    CCLabelBMFont *ui_wave_lbl;
    
    NSInteger diamond;
    NSInteger attack;
    NSInteger hp;
    NSInteger speed;
    
    NSMutableData *receivedData;
}

@property (nonatomic,strong) NSMutableArray *towers;
@property (nonatomic,strong) NSMutableArray *waypoints;
@property (nonatomic,strong) NSMutableArray *enemies;


// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene;
- (id)init;
-(BOOL)circle:(CGPoint)circlePoint withRadius:(float)radius
collisionWithCircle:(CGPoint)circlePointTwo collisionCircleRadius:(float)radiusTwo;
void ccFillPoly(CGPoint *poli,int points,BOOL closePolygon);
- (void) enemyGotKilled;
- (void) getHpDamage;
- (void) doGameOver;
- (void) awardGold:(int)gold;
- (void) awardDiamond:(int)diamond;
- (void) setBaseValue:(NSInteger)tdiamond :(NSInteger)tattack :(NSInteger)thp :(NSInteger)tspeed;

- (CCSprite*) getSprite:(int)spriteid;

// -----------------------------------------------------------------------
@end