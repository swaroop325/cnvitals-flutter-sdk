#import "CnvitalsPlugin.h"
#import <CNVitalsiOS/CNVitalsiOS.h>
@interface CnvitalsPlugin()<HeartRateDetectionModelDelegate>
@property (copy, nonatomic) NSString *mainCallbackId;
@property (nonatomic, assign) bool detecting;
@property (nonatomic, assign) int bpms;
@property (nonatomic, assign) int so2;
@property (nonatomic, assign) int rr;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;
@property (nonatomic, strong) NSString *ppgdata;
@property (nonatomic, strong) NSString *ecgdata;
@property(strong, nonatomic) UIViewController *viewController;
@property(strong, nonatomic) FlutterResult callbackResult;
@end

@implementation CnvitalsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"cnvitals"
                                     binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    
    
    CnvitalsPlugin* instance = [[CnvitalsPlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}


- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getVitals" isEqualToString:call.method]) {
        NSError *error;
        
        NSString *api_key = call.arguments[@"api_key"];
        NSString *scan_token = call.arguments[@"scan_token"];
        NSString *user_id = call.arguments[@"user_id"];
        NSDictionary *postDict = @{@"api_key":api_key, @"scan_token":scan_token,@"user_id":user_id };
        _callbackResult = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"bodyvitals" bundle:nil];
            BodyVitalsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"BodyVitalsViewController"];
            vc.api_details = postDict;
            if (@available(iOS 13.0, *)) {
                [vc setModalInPresentation:YES];
            } else {
                // Fallback on earlier versions
            }
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            [self.viewController presentViewController:nav animated:YES completion:^{
                vc.delegate = self;
            }];
        });
        
        //    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)heartRateStart{
    self.bpms = 0;
    self.so2 = 0;
    self.rr = 0;
}

- (void)heartRateUpdate:(int)bpm{
    self.bpms = bpm;
}

- (void)Spo2Update:(int)so2{
    self.so2 = so2;
}

- (void)RespirationUpdate:(int)rr{
    self.rr = rr;
}

- (void)setPPGData:(NSString *)ppgData{
    self.ppgdata = ppgData;
}

- (void)setECGData:(NSString *)ecgData{
    self.ecgdata = ecgData;
}

- (void)heartRateEnd{
    self.detecting = false;
    
    NSString* myHeartRate = [NSString stringWithFormat:@"%i", self.bpms];
    NSString* myso2 = [NSString stringWithFormat:@"%i", self.so2];
    NSString* myRespirationRate = [NSString stringWithFormat:@"%i", self.rr];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:myHeartRate forKey:@"bpm"];
    [dict setValue:myso2 forKey:@"O2R"];
    [dict setValue:myRespirationRate forKey:@"breath"];
    [dict setValue:self.ppgdata forKey:@"ppgdata"];
    [dict setValue:self.ecgdata forKey:@"ecgdata"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Got an error: %@", error);
        jsonString = @"";
    }
    
    _callbackResult([@"iOS " stringByAppendingString:jsonString]);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)heartRateMeasurementFailed:(NSString *)message{
    self.detecting = false;
    _callbackResult([@"iOS " stringByAppendingString:message]);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
