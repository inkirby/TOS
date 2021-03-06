//
//  IntroScene.h
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/5/2557 BE.
//  Copyright Pisitsak Sriwimol 2557. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The intro scene
 *  Note, that scenes should now be based on CCScene, and not CCLayer, as previous versions
 *  Main usage for CCLayer now, is to make colored backgrounds (rectangles)
 *
 */
@interface IntroScene : CCScene {
    NSURLConnection *conn;
    NSMutableData *receivedData;
    NSInteger diamond;
    NSInteger attack;
    NSInteger hp;
    NSInteger speed;
    
    CCLabelTTF *diamondL;
    CCLabelTTF *attckL;
    CCLabelTTF *hpL;
    CCLabelTTF *speedL;
}

// -----------------------------------------------------------------------

+ (IntroScene *)scene;
- (id)init;
- (void)getUserData;

// -----------------------------------------------------------------------
@end