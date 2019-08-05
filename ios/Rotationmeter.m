//  Rotationmeter.m


#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "Rotationmeter.h"

@implementation Rotationmeter

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"Rotationmeter");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_REMAP_METHOD(isAvailable,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    return [self isAvailableWithResolver:resolve
                                rejecter:reject];
}

- (void) isAvailableWithResolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject {
    if([self->_motionManager isDeviceMotionAvailable])
    {
        /* Start the deviceMotion if it is not active already */
        if([self->_motionManager isDeviceMotionActive] == NO)
        {
            resolve(@YES);
        } else {
            reject(@"-1", @"DeviceMotion is not active", nil);
        }
    }
    else
    {
        reject(@"-1", @"DeviceMotion is not available", nil);
    }
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    NSLog(@"setUpdateInterval: %f", interval);
    double intervalInSeconds = interval / 1000;

    [self->_motionManager setDeviceMotionUpdateInterval:intervalInSeconds];
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    double interval = self->_motionManager.deviceMotionUpdateInterval;
    NSLog(@"getUpdateInterval: %f", interval);
    cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getData:(RCTResponseSenderBlock) cb) {
    double roll = self->_motionManager.deviceMotion.attitude.roll;
    double pitch = self->_motionManager.deviceMotion.attitude.pitch;
    double azimut = self->_motionManager.deviceMotion.attitude.yaw;
    double timestamp = self->_motionManager.deviceMotion.timestamp;

    NSLog(@"getData: %f, %f, %f, %f", roll, pitch, azimut, timestamp);

    cb(@[[NSNull null], @{
             @"roll" : [NSNumber numberWithDouble:roll],
             @"pitch" : [NSNumber numberWithDouble:pitch],
             @"azimut" : [NSNumber numberWithDouble:azimut],
             @"timestamp" : [NSNumber numberWithDouble:timestamp]
             }]
       );
}

RCT_EXPORT_METHOD(startUpdates) {
    NSLog(@"startUpdates");
    [self->_motionManager startDeviceMotionUpdates];

    /* Receive the deviceMotion data on this block */
    [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMDeviceMotion *deviceMotionData, NSError *error)
     {
         double roll = deviceMotionData.attitude.roll;
         double pitch = deviceMotionData.attitude.pitch;
         double azimut = deviceMotionData.attitude.yaw;
         double timestamp = deviceMotionData.timestamp;
         NSLog(@"startDeviceMotionUpdates: %f, %f, %f, %f", roll, pitch, azimut, timestamp);

         [self.bridge.eventDispatcher sendDeviceEventWithName:@"Rotationmeter" body:@{
                                                                                      @"roll" : [NSNumber numberWithDouble:roll],
                                                                                      @"pitch" : [NSNumber numberWithDouble:pitch],
                                                                                      @"azimut" : [NSNumber numberWithDouble:azimut],
                                                                                      @"timestamp" : [NSNumber numberWithDouble:timestamp]
                                                                                      }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    NSLog(@"stopUpdates");
    [self->_motionManager stopDeviceMotionUpdates];
}

@end
