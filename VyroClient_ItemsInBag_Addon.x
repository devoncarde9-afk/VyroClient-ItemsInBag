// VyroClient Items in Bag Spawner Addon - FIXED
// Adds a new section to spawn items inside bags

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>

@interface ACPanView : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
- (void)setupUI;
- (void)addItemsInBagSection; // Declare the method
@end

// IL2CPP functions
extern void SpawnItem(void *itemName, int quantity, float x, float y, float z, int colorHue, int colorSat);
extern void* il2cpp_string_new(const char *str);

static void spawn(NSString *item, int qty) {
    void *str = il2cpp_string_new([item UTF8String]);
    SpawnItem(str, qty, 0, 0, 0, 0, 0);
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

static UIViewController* getRootViewController(void) {
    UIViewController *rootVC = nil;
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                rootVC = scene.windows.firstObject.rootViewController;
                if (rootVC) break;
            }
        }
    }
    
    if (!rootVC) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        #pragma clang diagnostic pop
    }
    
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    
    return rootVC;
}

static const void *kBagSectionAdded = &kBagSectionAdded;

%hook ACPanView

- (void)setupUI {
    %orig;
    
    // Guard against double-injection
    if (objc_getAssociatedObject(self, kBagSectionAdded)) return;
    objc_setAssociatedObject(self, kBagSectionAdded, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self addItemsInBagSection];
    });
}

%new
- (void)addItemsInBagSection {
    UIView *contentView = self.contentView;
    UIScrollView *scrollView = self.scrollView;
    
    if (!contentView || !scrollView) {
        NSLog(@"[ItemsInBag] ERROR: contentView or scrollView is nil");
        return;
    }
    
    CGFloat W = contentView.bounds.size.width;
    if (W <= 0) W = UIScreen.mainScreen.bounds.size.width - 40;
    
    // Find bottom of existing content
    CGFloat y = 0;
    for (UIView *sub in contentView.subviews) {
        CGFloat maxY = CGRectGetMaxY(sub.frame);
        if (maxY > y) y = maxY;
    }
    y += 20;
    
    CGFloat pad = 15, bH = 50, gap = 10;
    
    // Divider
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(pad, y, W-pad*2, 2)];
    div.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    [contentView addSubview:div];
    y += 12;
    
    // Header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(pad, y, W-pad*2, 38)];
    header.text = @"🎒 ITEMS IN BAG SPAWNER";
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont boldSystemFontOfSize:16];
    header.textAlignment = NSTextAlignmentCenter;
    header.backgroundColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:0.95];
    header.layer.cornerRadius = 10;
    header.clipsToBounds = YES;
    [contentView addSubview:header];
    y += 44;
    
    // Description
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(pad, y, W-pad*2, 40)];
    desc.text = @"Spawn any item inside a random bag!";
    desc.textColor = [UIColor colorWithWhite:0.85 alpha:1];
    desc.font = [UIFont systemFontOfSize:12];
    desc.textAlignment = NSTextAlignmentCenter;
    desc.numberOfLines = 2;
    [contentView addSubview:desc];
    y += 46;
    
    // Spawn Item in Bag button
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(pad, y, W-pad*2, bH);
    spawnBtn.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.9 alpha:1];
    [spawnBtn setTitle:@"🎒 Spawn Item IN Bag" forState:UIControlStateNormal];
    [spawnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    spawnBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    spawnBtn.layer.cornerRadius = 12;
    spawnBtn.clipsToBounds = YES;
    [spawnBtn addTarget:self action:@selector(openItemInBagSpawner) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:spawnBtn];
    y += bH + gap;
    
    // All Bags button
    UIButton *allBagsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    allBagsBtn.frame = CGRectMake(pad, y, W-pad*2, bH);
    allBagsBtn.backgroundColor = [UIColor colorWithRed:0.9 green:0.4 blue:0.7 alpha:1];
    [allBagsBtn setTitle:@"🎒 Spawn All Bags (17)" forState:UIControlStateNormal];
    [allBagsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    allBagsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    allBagsBtn.layer.cornerRadius = 12;
    allBagsBtn.clipsToBounds = YES;
    [allBagsBtn addTarget:self action:@selector(spawnAllBags) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:allBagsBtn];
    y += bH + gap;
    
    // Random Bag x5 button
    UIButton *randomBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    randomBtn.frame = CGRectMake(pad, y, W-pad*2, bH);
    randomBtn.backgroundColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1];
    [randomBtn setTitle:@"🎲 Random Bag x5" forState:UIControlStateNormal];
    [randomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    randomBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    randomBtn.layer.cornerRadius = 12;
    randomBtn.clipsToBounds = YES;
    [randomBtn addTarget:self action:@selector(spawnRandomBags) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:randomBtn];
    y += bH + 20;
    
    // Update scroll content size
    CGSize currentSize = scrollView.contentSize;
    scrollView.contentSize = CGSizeMake(currentSize.width, MAX(y, currentSize.height));
    
    NSLog(@"[ItemsInBag] ✅ Section added successfully at y=%.0f", y);
}

%new
- (void)openItemInBagSpawner {
    NSLog(@"[ItemsInBag] Opening item in bag spawner");
    
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"🎒 Spawn Item IN Bag" 
        message:@"Enter the item name to spawn inside a random bag\n\nExample: item_shotgun" 
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"item_shotgun";
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn in Random Bag" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *itemName = alert.textFields[0].text;
            if (itemName && itemName.length > 0) {
                NSArray *bags = allBags();
                NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
                spawn(randomBag, 1);
                spawnLater(itemName, 1, 0.05);
                NSLog(@"[ItemsInBag] Spawned %@ in %@", itemName, randomBag);
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn 5x" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *itemName = alert.textFields[0].text;
            if (itemName && itemName.length > 0) {
                for (int i = 0; i < 5; i++) {
                    NSArray *bags = allBags();
                    NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
                    spawnLater(randomBag, 1, i * 0.15);
                    spawnLater(itemName, 1, i * 0.15 + 0.05);
                }
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *rootVC = getRootViewController();
    if (rootVC) {
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

%new
- (void)spawnAllBags {
    NSArray *bags = allBags();
    for (NSInteger i = 0; i < bags.count; i++) {
        spawnLater(bags[i], 1, i * 0.08);
    }
    NSLog(@"[ItemsInBag] Spawning all %lu bags", (unsigned long)bags.count);
}

%new
- (void)spawnRandomBags {
    NSArray *bags = allBags();
    for (int i = 0; i < 5; i++) {
        NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
        spawnLater(randomBag, 1, i * 0.12);
    }
    NSLog(@"[ItemsInBag] Spawning 5 random bags");
}

%end

%ctor {
    NSLog(@"[ItemsInBag] ✅ Items in Bag Spawner addon loaded");
    NSLog(@"[ItemsInBag] Targeting: com.woostergames.animalcompany");
}
