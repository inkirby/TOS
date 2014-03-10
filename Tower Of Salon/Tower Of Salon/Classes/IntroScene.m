//
//  IntroScene.m
//  Tower Of Salon
//
//  Created by Pisitsak Sriwimol on 3/5/2557 BE.
//  Copyright Pisitsak Sriwimol 2557. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "HelloWorldScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    [self getUserData];
    
//    // Hello world
//    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Chalkduster" fontSize:36.0f];
//    label.positionType = CCPositionTypeNormalized;
//    label.color = [CCColor redColor];
//    label.position = ccp(0.5f, 0.5f); // Middle of screen
//    [self addChild:label];
//    
//    // Helloworld scene button
//    CCButton *helloWorldButton = [CCButton buttonWithTitle:@"[ Start ]" fontName:@"Verdana-Bold" fontSize:18.0f];
//    helloWorldButton.positionType = CCPositionTypeNormalized;
//    helloWorldButton.position = ccp(0.5f, 0.35f);
//    [self addChild:helloWorldButton];
    
    // done
	return self;
}
-(void)setLabel {
    NSString *diamondS = [NSString stringWithFormat:@"Diamond = %d",diamond];

    [diamondL setString:@""];
    diamondL = [CCLabelTTF labelWithString:diamondS fontName:@"Verdana-Bold" fontSize:18.0f];
    diamondL.positionType = CCPositionTypeNormalized;
    diamondL.color = [CCColor blueColor];
    diamondL.position = ccp(0.5f,0.7f);
    [self addChild:diamondL];
    
    NSString *attackS = [NSString stringWithFormat:@"Attack = %d",attack];
    
    [attckL setString:@""];
    attckL = [CCLabelTTF labelWithString:attackS fontName:@"Verdana-Bold" fontSize:18.0f];
    attckL.positionType = CCPositionTypeNormalized;
    attckL.color = [CCColor whiteColor];
    attckL.position = ccp(0.5f,0.6f);
    [self addChild:attckL];
    
    NSString *hpS = [NSString stringWithFormat:@"HP = %d",hp];
    
    [hpL setString:@""];
    hpL = [CCLabelTTF labelWithString:hpS fontName:@"Verdana-Bold" fontSize:18.0f];
    hpL.positionType = CCPositionTypeNormalized;
    hpL.color = [CCColor whiteColor];
    hpL.position = ccp(0.5f,0.5f);
    [self addChild:hpL];
    
    NSString *speedS = [NSString stringWithFormat:@"Speed = %d",speed];
    
    [speedL setString:@""];
    speedL = [CCLabelTTF labelWithString:speedS fontName:@"Verdana-Bold" fontSize:18.0f];
    speedL.positionType = CCPositionTypeNormalized;
    speedL.color = [CCColor whiteColor];
    speedL.position = ccp(0.5f,0.4f);
    [self addChild:speedL];
}
-(void)setButton {
    CCButton *attackP = [CCButton buttonWithTitle:@"[+]" fontName:@"Verdana-Bold" fontSize:18.0f];
    attackP.positionType = CCPositionTypeNormalized;
    attackP.color = [CCColor whiteColor];
    attackP.position = ccp(0.2f,0.6f);
    [self addChild:attackP];
    [attackP setTarget:self selector:@selector(upAttack)];
    
    CCButton *hpP = [CCButton buttonWithTitle:@"[+]" fontName:@"Verdana-Bold" fontSize:18.0f];
    hpP.positionType = CCPositionTypeNormalized;
    hpP.color = [CCColor whiteColor];
    hpP.position = ccp(0.2f,0.5f);
    [self addChild:hpP];
    [hpP setTarget:self selector:@selector(upHP)];
    
    CCButton *speedP = [CCButton buttonWithTitle:@"[+]" fontName:@"Verdana-Bold" fontSize:18.0f];
    speedP.positionType = CCPositionTypeNormalized;
    speedP.color = [CCColor whiteColor];
    speedP.position = ccp(0.2f,0.4f);
    [self addChild:speedP];
    [speedP setTarget:self selector:@selector(upSpeed)];
    
    CCButton *startGame = [CCButton buttonWithTitle:@"[Start Game]" fontName:@"Verdana-Bold" fontSize:18.0f];
    startGame.positionType = CCPositionTypeNormalized;
    startGame.color = [CCColor redColor];
    startGame.position = ccp(0.5f,0.3f);
    [self addChild:startGame];
    [startGame setTarget:self selector:@selector(startingGame)];
}
-(void)upAttack {
    if(diamond > 0) {
        attack++;
        diamond--;
        [self setLabel];
    }
}
-(void)upHP {
    if(diamond > 0) {
        hp++;
        diamond--;
        [self setLabel];
    }
}
-(void)upSpeed {
    if(diamond > 0) {
        speed++;
        diamond--;
        [self setLabel];
    }
}
-(void)startingGame {
    HelloWorldScene *hScene = [[HelloWorldScene alloc] init];
    [hScene setBaseValue:diamond :attack :hp :speed];
    
    [[CCDirector sharedDirector] replaceScene:hScene];
}
-(void)getUserData {
    
    NSLog(@"start service");
    
    NSString *uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"%@",uid);
    
    NSString *post = [NSString stringWithFormat:@"&UID=%@",uid];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    ;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://egco-towerofsalon.meximas.com/db_addandcheckuser.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    if (conn) {
        self->receivedData = [[NSMutableData data] retain];
    }
    
    NSLog(@"end service");
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    sleep(5);
    [receivedData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if(receivedData) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self->receivedData options:NSJSONReadingMutableLeaves error:nil];
        
        if([(NSString *)[dic objectForKey:@"success"] integerValue] == 1) {
        
            diamond = [(NSString *)[dic objectForKey:@"diamond"] integerValue];
            attack = [(NSString *)[dic objectForKey:@"attack"] integerValue];
            hp = [(NSString *)[dic objectForKey:@"hp"] integerValue];
            speed = [(NSString *)[dic objectForKey:@"speed"] integerValue];
        
            NSLog(@"%d %d %d %d",diamond,attack,hp,speed);
            [self setLabel];
            [self setButton];
            
        } else {
            NSLog(@"Error");
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------
// -----------------------------------------------------------------------
@end
