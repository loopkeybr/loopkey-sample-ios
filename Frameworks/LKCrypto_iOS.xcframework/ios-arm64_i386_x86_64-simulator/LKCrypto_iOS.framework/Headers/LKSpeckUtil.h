//
//  LKSpeckUtil.h
//  indigo
//
//  Created by Daniel Sandoval on 7/26/16.
//  Copyright © 2016 Loop EC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKSpeckUtil : NSObject

+ (NSData* _Nonnull) cipher:(NSData* _Nonnull) message withKey:(NSData* _Nonnull) key;

+ (NSData* _Nonnull) decipher:(NSData* _Nonnull) ciphertext withKey:(NSData* _Nonnull) key;

@end
