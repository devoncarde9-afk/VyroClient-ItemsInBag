// VyroClient Items in Bag - FINAL WORKING VERSION
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern void SpawnItem(void *itemName, int quantity, float x, float y, float z, int colorHue, int colorSat);
extern void* il2cpp_string_new(const char *str);

static void spawn(NSString *item, int qty) {
    @try {
        void *str = il2cpp_string_new([item UTF8String]);
        SpawnItem(str, qty, 0, 0, 0, 0, 0);
    } @catch (NSException *e) {
        NSLog(@"[ItemsInBag] Error: %@", e);
    }
}

static void spawnLater(NSString *item, int qty, double delay) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ spawn(item, qty); });
}

static NSArray* allBags(void) {
    return @[
        @"item_backpack", @"item_backpack_big", @"item_backpack_black", @"item_backpack_cube",
        @"item_backpack_gold", @"item_backpack_green", @"item_backpack_large_base",
        @"item_backpack_large_basketball", @"item_backpack_large_clover", @"item_backpack_mega",
        @"item_backpack_neon", @"item_backpack_pink", @"item_backpack_realistic",
        @"item_backpack_skull", @"item_backpack_small_base", @"item_backpack_white",
        @"item_backpack_with_flashlight"
    ];
}

@interface ACPanView : UIView
@end

// Try to find ACPanView and add buttons to it
static void tryAddButtons(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Find all windows
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            // Search for ACPanView
            for (UIView *view in window.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"ACPanView")]) {
                    NSLog(@"[ItemsInBag] Found ACPanView!");
                    
                    // Find scrollView or any view we can add to
                    UIView *targetView = nil;
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:[UIScrollView class]]) {
                            targetView = subview;
                            break;
                        }
                    }
                    
                    if (!targetView && view.subviews.count > 0) {
                        targetView = view.subviews[0];
                    }
                    
                    if (!targetView) {
                        targetView = view;
                    }
                    
                    // Find bottom of content
                    CGFloat y = 0;
                    CGFloat W = targetView.bounds.size.width;
                    if (W <= 0) W = UIScreen.mainScreen.bounds.size.width - 40;
                    
                    for (UIView *sub in targetView.subviews) {
                        CGFloat maxY = CGRectGetMaxY(sub.frame);
                        if (maxY > y) y = maxY;
                    }
                    y += 20;
                    
                    CGFloat pad = 15, bH = 50, gap = 10;
                    
                    // Add header
                    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(pad, y, W-pad*2, 38)];
                    header.text = @"🎒 ITEMS IN BAG";
                    header.textColor = [UIColor whiteColor];
                    header.font = [UIFont boldSystemFontOfSize:16];
                    header.textAlignment = NSTextAlignmentCenter;
                    header.backgroundColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:0.95];
                    header.layer.cornerRadius = 10;
                    header.clipsToBounds = YES;
                    header.tag = 99999; // Tag so we don't add twice
                    [targetView addSubview:header];
                    y += 44;
                    
                    // Button 1
                    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
                    btn1.frame = CGRectMake(pad, y, W-pad*2, bH);
                    btn1.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.9 alpha:1];
                    [btn1 setTitle:@"🎒 Spawn Item IN Bag" forState:UIControlStateNormal];
                    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                    btn1.layer.cornerRadius = 12;
                    [btn1 addTarget:btn1 action:@selector(showSpawnDialog) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn1];
                    y += bH + gap;
                    
                    // Button 2
                    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
                    btn2.frame = CGRectMake(pad, y, W-pad*2, bH);
                    btn2.backgroundColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.7 alpha:1];
                    [btn2 setTitle:@"🎒 All Bags (17)" forState:UIControlStateNormal];
                    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                    btn2.layer.cornerRadius = 12;
                    [btn2 addTarget:btn2 action:@selector(spawnAllBags) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn2];
                    y += bH + gap;
                    
                    // Button 3
                    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
                    btn3.frame = CGRectMake(pad, y, W-pad*2, bH);
                    btn3.backgroundColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1];
                    [btn3 setTitle:@"🎲 Random x5" forState:UIControlStateNormal];
                    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    btn3.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                    btn3.layer.cornerRadius = 12;
                    [btn3 addTarget:btn3 action:@selector(spawnRandomBags) forControlEvents:UIControlEventTouchUpInside];
                    [targetView addSubview:btn3];
                    y += bH + 20;
                    
                    // Update scroll size if it's a scrollview
                    if ([targetView isKindOfClass:[UIScrollView class]]) {
                        UIScrollView *sv = (UIScrollView*)targetView;
                        CGSize size = sv.contentSize;
                        sv.contentSize = CGSizeMake(size.width, MAX(y, size.height));
                    }
                    
                    NSLog(@"[ItemsInBag] ✅ Buttons added!");
                    return;
                }
            }
        }
        
        NSLog(@"[ItemsInBag] ACPanView not found, retrying...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            tryAddButtons();
        });
    });
}

@interface UIButton (ItemsInBagActions)
- (void)showSpawnDialog;
- (void)spawnAllBags;
- (void)spawnRandomBags;
@end

@implementation UIButton (ItemsInBagActions)

- (void)showSpawnDialog {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"🎒 Spawn Item IN Bag" 
        message:@"Enter item name (e.g., item_shotgun)" 
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *f) {
        f.placeholder = @"item_shotgun";
        f.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *item = alert.textFields[0].text;
            if (item.length > 0) {
                NSArray *bags = allBags();
                spawn(bags[arc4random_uniform((uint32_t)bags.count)], 1);
                spawnLater(item, 1, 0.05);
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn 5x" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *item = alert.textFields[0].text;
            if (item.length > 0) {
                for (int i = 0; i < 5; i++) {
                    NSArray *bags = allBags();
                    spawnLater(bags[arc4random_uniform((uint32_t)bags.count)], 1, i * 0.15);
                    spawnLater(item, 1, i * 0.15 + 0.05);
                }
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *vc = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

- (void)spawnAllBags {
    NSArray *bags = allBags();
    for (NSInteger i = 0; i < bags.count; i++) {
        spawnLater(bags[i], 1, i * 0.08);
    }
}

- (void)spawnRandomBags {
    NSArray *bags = allBags();
    for (int i = 0; i < 5; i++) {
        spawnLater(bags[arc4random_uniform((uint32_t)bags.count)], 1, i * 0.12);
    }
}

@end

%ctor {
    NSLog(@"[ItemsInBag] Loading...");
    // Wait 5 seconds for VyroClient to fully load
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        tryAddButtons();
    });
}
