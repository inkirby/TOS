//
//  HelloWorldScene.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/5/2557 BE.
//  Copyright Pisitsak Sriwimol 2557. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "Tower.h"
#import "MainTower.h"
#import "Waypoint.h"
#import "Enemy.h"

#define ARC4RANDOM_MAX 0x100000000

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation HelloWorldScene
{
    CCSprite *_sprite;
    MainTower *mtower;
}
@synthesize towers;
@synthesize waypoints;
@synthesize enemies;

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    NSLog(@"Call Scene");
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    NSLog(@"init helloworld");
    
    currentSpritePos = 0;
    tskeleton = [[NSMutableArray alloc] init];
    thydra = [[NSMutableArray alloc] init];
    tboss = [[NSMutableArray alloc] init];
    for (int i=0; i<15; i++) {
        skeleton = nil;
        hydra = nil;
        boss = nil;
        skeleton = [CCSprite spriteWithImageNamed:@"skeleton.png"];
        hydra =[CCSprite spriteWithImageNamed:@"hydra.png"];
        boss = [CCSprite spriteWithImageNamed:@"boss.png"];
        [tskeleton addObject:skeleton];
        [thydra addObject:hydra];
        [tboss addObject:boss];
    }
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    
    CCSprite *background = [CCSprite spriteWithImageNamed:@"bg.png"];
    [self addChild:background];
    [background setPosition:ccp(winSize.width/2, winSize.height/2)];
    
    playerHP = 5;
    playerGold = 1000;
    playerDiamond = 0;
    enemyNum = 0;
    
    [self loadTowerPositions];
    [self addWaypoints];
    enemies = [[NSMutableArray alloc] init];
    towers = [[NSMutableArray alloc] init];
    
    ui_wave_lbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"WAVE: %d",wave] fntFile:@"font_red_14.fnt"];
    [self addChild:ui_wave_lbl z:10];
    [ui_wave_lbl setPosition:ccp(400,winSize.height-12)];
    [ui_wave_lbl setAnchorPoint:ccp(0,0.5)];

    ui_hp_lbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"HP: %d",playerHP] fntFile:@"font_red_14.fnt"];
    [self addChild:ui_hp_lbl z:10];
    [ui_hp_lbl setPosition:ccp(35,winSize.height-12)];
    
    ui_gold_lbl = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"GOLD: %d",playerGold]
                                         fntFile:@"font_red_14.fnt"];
    [self addChild:ui_gold_lbl z:10];
    [ui_gold_lbl setPosition:ccp(135,winSize.height-12)];
    [ui_gold_lbl setAnchorPoint:ccp(0,0.5)];
    
    
    CCSprite *mtowerBase = [CCSprite spriteWithImageNamed:@"open_spot.png"];
    [self addChild:mtowerBase];
    [mtowerBase setPosition:ccp(424, 50)];
    
    mtower = [MainTower nodeWithTheGame:self location:mtowerBase.position];
    mtowerBase.userObject = (__bridge id)((__bridge void *)(mtower));
    
    [self loadWave:10];
    
    // done
	return self;
}

- (void)loadTowerPositions {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TowersPosition" ofType:@"plist"];
    NSArray *towerPositions = [NSArray arrayWithContentsOfFile:plistPath];
    
    towerBases = [[NSMutableArray alloc] initWithCapacity:10];
    
    for(NSDictionary *towerPos in towerPositions) {
        CCSprite *towerBase = [CCSprite spriteWithImageNamed:@"open_spot.png"];
        [self addChild:towerBase];
        [towerBase setPosition:ccp([[towerPos objectForKey:@"x"] intValue], [[towerPos objectForKey:@"y"] intValue])];
        [towerBases addObject:towerBase];
    }
    
}
-(BOOL)canBuyTower {
    return playerGold - TOWER_COST >= 0 ? YES : NO;
}
-(void)addWaypoints{
    waypoints = [[NSMutableArray alloc] init];
    
    Waypoint * waypoint1 = [Waypoint nodeWithTheGame:self location:ccp(420,35)];
    [waypoints addObject:waypoint1];
    
    Waypoint * waypoint2 = [Waypoint nodeWithTheGame:self location:ccp(35,35)];
    [waypoints addObject:waypoint2];
    waypoint2.nextWayPoint =waypoint1;
    
    Waypoint * waypoint3 = [Waypoint nodeWithTheGame:self location:ccp(35,130)];
    [waypoints addObject:waypoint3];
    waypoint3.nextWayPoint =waypoint2;
    
    Waypoint * waypoint4 = [Waypoint nodeWithTheGame:self location:ccp(445,130)];
    [waypoints addObject:waypoint4];
    waypoint4.nextWayPoint =waypoint3;
    
    Waypoint * waypoint5 = [Waypoint nodeWithTheGame:self location:ccp(445,220)];
    [waypoints addObject:waypoint5];
    waypoint5.nextWayPoint =waypoint4;
    
    Waypoint * waypoint6 = [Waypoint nodeWithTheGame:self location:ccp(-40,220)];
    [waypoints addObject:waypoint6];
    waypoint6.nextWayPoint =waypoint5;
}
-(BOOL)circle:(CGPoint)circlePoint withRadius:(float)radius collisionWithCircle:(CGPoint)circlePointTwo collisionCircleRadius:(float)radiusTwo {
    float xdif = circlePoint.x - circlePointTwo.x;
    float ydif = circlePoint.y - circlePointTwo.y;
    
    float distance = sqrt(xdif*xdif + ydif*ydif);
    
    if(distance <= radius+radiusTwo) {
        return YES;
    }
    return NO;
    
}
-(BOOL)loadWave:(int)NumOfEnemy {
    
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Waves" ofType:@"plist"];
//    NSArray *waveData = [NSArray arrayWithContentsOfFile:plistPath];
    
//    if(wave >= [waveData count]) {
//        return NO;
//    }
    
    NSLog(@"wave=%d",wave);
    
//    NSArray *currentWaveData = [NSArray arrayWithArray:[waveData objectAtIndex:wave]];
//    for(NSDictionary *enemyData in currentWaveData) {
//        Enemy *enemy = [Enemy nodeWithTheGame:self enemy:[enemyData objectForKey:@"data"]];
//        [enemies addObject:enemy];
//        [enemy scheduleOnce:@selector(doActivate) delay:[[enemyData objectForKey:@"spawnTime"] floatValue]];
//    }
    
    float time = 3;
    isBossOut = false;
    for(int i=0;i<NumOfEnemy+20+arc4random()%(wave+1);i++) {
        int temp = arc4random()%100;
        if(temp > 95) {
            if(!isBossOut) {
                // boss
                Enemy *enemy = [Enemy nodeWithTheGame:self enemy:2 wave:wave];
                [enemies addObject:enemy];
                [enemy scheduleOnce:@selector(doActivate) delay:time];
                isBossOut = true;
                NSLog(@"boss is out");
            } else {
                Enemy *enemy = [Enemy nodeWithTheGame:self enemy:1 wave:wave];
                [enemies addObject:enemy];
                [enemy scheduleOnce:@selector(doActivate) delay:time];
            }
        } else if (temp > 60) {
            // hydra
            Enemy *enemy = [Enemy nodeWithTheGame:self enemy:1 wave:wave];
            [enemies addObject:enemy];
            [enemy scheduleOnce:@selector(doActivate) delay:time];
        } else {
            // skeleton
            Enemy *enemy = [Enemy nodeWithTheGame:self enemy:0 wave:wave];
            [enemies addObject:enemy];
            [enemy scheduleOnce:@selector(doActivate) delay:time];
        }
        
        time += ((double)arc4random() / ARC4RANDOM_MAX);
        enemyNum++;
    }
    
    NSLog(@"enemy =%lu",(unsigned long)[enemies count]);
    
    wave++;
    [ui_wave_lbl setString:[NSString stringWithFormat:@"WAVE: %d",wave]];
    
    if (isBossOut) [mtower enableAttack];
    else [mtower disableAttack];
    
    return YES;
}

-(void)enemyGotKilled {
    enemyNum--;
    if (enemyNum <= 0) {
        if(gameEnded) {
            
        } else {
            [self loadWave:10];
        }
    }
}

-(void)getHpDamage {
    playerHP--;
    [ui_hp_lbl setString:[NSString stringWithFormat:@"HP: %d",playerHP]];
    if (playerHP <=0) {
        [self doGameOver];
    }
}
-(void)doGameOver {
    if(!gameEnded) {
        gameEnded = YES;
        NSLog(@"Game Over");
        [self updateUserData];
    }
}
-(void)awardGold:(int)gold {
    playerGold += gold;
    [ui_gold_lbl setString:[NSString stringWithFormat:@"GOLD: %d",playerGold]];
}
-(void)awardDiamond:(int)tdiamond {
    playerDiamond += tdiamond;
}
-(void)setBaseValue:(NSInteger)tdiamond :(NSInteger)tattack :(NSInteger)thp :(NSInteger)tspeed {
    diamond = tdiamond;
    attack = tattack;
    hp = thp;
    speed = tspeed;
    
    [mtower setUpgradeAtk:attack];
    [mtower setUpgradeSpd:speed];
    
    for(int i=0;i<hp;i++) {
        playerHP += 1;
    }
    [ui_hp_lbl setString:[NSString stringWithFormat:@"HP: %d",playerHP]];
    
}

-(void)updateUserData {
    
    NSLog(@"start update service");
    
    NSString *uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"%@",uid);
    
    NSString *post = [NSString stringWithFormat:@"&UID=%@&Diamond=%d&Attack=%ld&HP=%ld&Speed=%ld",uid,(diamond+playerDiamond),(long)attack,(long)hp,(long)speed];
    NSLog(@"string = %@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    ;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://egco-towerofsalon.meximas.com/db_updateuser.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    if (conn) {
        self->receivedData = [[NSMutableData data] retain];
        NSLog(@"conn");
    }
    
    NSLog(@"end service");
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"Finish");
    NSLog(@"data == %@",[[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding]);
    
    IntroScene *iScene = [[IntroScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:iScene];
    
}


// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
    [super dealloc];
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

//-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//    CGPoint touchLoc = [touch locationInNode:self];
//    
//    // Log touch location
//    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
//    
//    // Move our sprite to touch location
//    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:1.0f position:touchLoc];
//    [_sprite runAction:actionMove];
//}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    for(CCSprite *towerBase in towerBases) {
        if(CGRectContainsPoint([towerBase boundingBox], location) && [self canBuyTower]) {
            NSLog(@"touch tower base");
            if(!towerBase.userObject) {
                    Tower *tower = [Tower nodeWithTheGame:self location:towerBase.position];
                    [towers addObject:tower];
                    NSLog(@"towers count = %lu",(unsigned long)[towers count]);
                    towerBase.userObject = (__bridge id)((__bridge void *)(tower));
                    playerGold -= TOWER_COST;
                
                    [ui_gold_lbl setString:[NSString stringWithFormat:@"GOLD: %d",playerGold]];
                    NSLog(@"buy tower");
                
            } else {
                for(Tower *tower in towers) {
                    if(CGPointEqualToPoint(tower.mySprite.position, towerBase.position)) {
                        if([tower isUpgradable]) {
                            [tower upgradeTower];
                            playerGold -= TOWER_COST;
                            [ui_gold_lbl setString:[NSString stringWithFormat:@"GOLD: %d",playerGold]];
                            NSLog(@"upgrade tower");
                        } else {
                            NSLog(@"cannot upgrade tower more");
                        }
                        break;
                    }
                }
            }
        }
    }

    
}

//-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInView:[touch view]];
//        location = [[CCDirector sharedDirector] convertToGL:location];
//        for(CCSprite *towerBase in towerBases) {
//            if(CGRectContainsPoint([towerBase boundingBox], location) && [self canBuyTower] && !towerBase.userObject) {
//                Tower *tower = [Tower nodeWithTheGame:self location:towerBase.position];
//                [towers addObject:tower];
//                towerBase.userObject = (__bridge id)((__bridge void *)(tower));
//                
//                NSLog(@"touch tower base");
//            }
//        }
//    }
//}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------



- (CCSprite*) getSprite:(int)spriteid {
    currentSpritePos++;
    if (currentSpritePos>10) currentSpritePos = 0;
    /*
    switch (spriteid) {
        case 0:
            skeleton = [CCSprite spriteWithImageNamed:@"skeleton.png"];
            [tskeleton removeObjectAtIndex:currentSpritePos];
            [tskeleton insertObject:skeleton atIndex:currentSpritePos];
            return currentSpritePos==0?[tskeleton objectAtIndex:10]:[tskeleton objectAtIndex:currentSpritePos-1];
        case 1:
            hydra =[CCSprite spriteWithImageNamed:@"hydra.png"];
            [thydra removeObjectAtIndex:currentSpritePos];
            [thydra insertObject:hydra atIndex:currentSpritePos];
            return currentSpritePos==0?[thydra objectAtIndex:10]:[thydra objectAtIndex:currentSpritePos-1];
        default:
            boss = [CCSprite spriteWithImageNamed:@"boss.png"];
            [tboss removeObjectAtIndex:currentSpritePos];
            [tboss insertObject:boss atIndex:currentSpritePos];
            return currentSpritePos==0?[tboss objectAtIndex:10]:[tboss objectAtIndex:currentSpritePos-1];
    }
     */
    CCSprite *tsprite;
    
    switch (spriteid) {
        case 0:
            tsprite = skeleton;
            skeleton = [CCSprite spriteWithImageNamed:@"skeleton.png"];
            return tsprite;
        case 1:
            tsprite = hydra;
            hydra = [CCSprite spriteWithImageNamed:@"hydra.png"];
            return tsprite;
        default:
            tsprite = boss;
            boss = [CCSprite spriteWithImageNamed:@"boss.png"];
            return tsprite;
    }
}

@end
