//
//  LKCrypto.h
//  LKCrypto
//
//  Created by Daniel Sandoval on 02/08/17.
//  Copyright © 2017 Loop CE. All rights reserved.
//

#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#else
#import <UIKit/UIKit.h>
#endif

//! Project version number for LKCrypto.
FOUNDATION_EXPORT double LKCryptoVersionNumber;

//! Project version string for LKCrypto.
FOUNDATION_EXPORT const unsigned char LKCryptoVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LKCrypto/PublicHeader.h>

#import "LKSpeckUtil.h"
#import "LKCryptoMessages.h"
