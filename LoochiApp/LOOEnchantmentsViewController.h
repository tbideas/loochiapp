//
//  LOOEnchantmentsViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 10/5/12.
//
//

#import <UIKit/UIKit.h>
#import "LOOLightClient.h"

@interface LOOEnchantmentsViewController : UICollectionViewController<LOOLightClient>

@property (nonatomic, retain) LOOLamp *lamp;

@end
