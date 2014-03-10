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

    [self getUserData];
    
    // done
	return self;
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
            
            HelloWorldScene *hScene = [[HelloWorldScene alloc] init];
            [hScene setBaseValue:diamond :attack :hp :speed];
            [[CCDirector sharedDirector] replaceScene:hScene];
            
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
