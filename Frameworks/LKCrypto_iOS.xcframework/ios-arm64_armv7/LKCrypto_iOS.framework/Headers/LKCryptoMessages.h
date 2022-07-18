//
//  LKCryptoMessages.h
//  BLETEst
//
//  Created by Matheus Pedreira on 5/31/16.
//  Copyright © 2016 Matrpedreira. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class contains methods that manage security messages. It contains static methods for using diferrent
 cryptographic types.
 */
@interface LKCryptoMessages : NSObject

/**
 *  Method applies SHA256 on the key with a spinning strategy using the row count.
 *
 *  @param key      The key that is going to be secured.
 *  @param rowCount The row count used for rowling the SHA256.
 *
 *  @return NSData with the cryptographic hash created from the key.
 */
+ (NSData*) sha256ForKey: (NSData*)key withRowCount: (UInt32)rowCount;

/**
 *  Applies hMAC using a key to a message.
 *
 *  @param message Message to be secured.
 *  @param data    Key to secure the data.
 *
 *  @return NSData protected with hMAC.
 */
+ (NSData*) hMacForMessage: (NSData*)message withKey: (NSData*)data;

/**
 *  Generates a random key.
 *
 *  @return The data correspondent to the random key
 */
+ (NSData*) generateKey;

/**
 *  Generates a random salt with given size
 *  @param size Size of data to be generated
 *  @return The data correspondent to the random key
 */

+ (NSData*) generateSaltWithSize:(NSInteger) size;
/**
 *  Check if message hMAC is correct
 *
 *  @param message LK Authenticated message
 *  @param key     Key for door
 *  @param rollCount Roll count for door
 *  @return true if valid and false if invalid
 */
+ (Boolean) checkIFHMACOK:(NSData*) message  withKey: (NSData*)key withRollCount:(UInt32)rollCount;

@end
