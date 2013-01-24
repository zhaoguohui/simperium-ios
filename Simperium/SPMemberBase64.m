//
//  SPMemberBase64.m
//  Simperium
//
//  Created by Michael Johnston on 11-11-24.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import "SPMemberBase64.h"
#import "NSData+Simperium.h"
#import "NSString+Simperium.h"

@implementation SPMemberBase64

-(id)defaultValue {
	return nil;
}

-(id)fromJSON:(id)value {
	if (![value isKindOfClass:[NSString class]])
		return value;
    
	// Convert from NSString (base64) to NSData
    NSData *data = [NSData decodeBase64WithString:value];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    
    //NSLog(@"Simperium transforming base64 (%@) %@ from %@", keyName, obj, value);
    
    // A nil value will be encoded as an empty string, so check for that
    if (obj == nil || ([obj isKindOfClass:[NSString class]] && [obj length] == 0))
        return nil;
    
    //NSAssert2(obj != nil, @"Simperium error: Transformable %@ couldn't be parsed from base64: %@", keyName, value);
    
    return obj;
}

-(id)toJSON:(id)value {
    if (value == nil)
        return @"";
    
    // Convert from a Transformable class to a base64 string
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    NSString *base64 = [NSString sp_encodeBase64WithData:data];
    //NSLog(@"Simperium transformed base64 (%@) %@ to %@", keyName, value, base64);
	return base64;
}

-(id)getValueFromDictionary:(NSDictionary *)dict key:(NSString *)key object:(id<SPDiffable>)object {
    id value = [dict objectForKey: key];
    value = [self fromJSON: value];
    return value;
}

-(void)setValue:(id)value forKey:(NSString *)key inDictionary:(NSMutableDictionary *)dict {
    id convertedValue = [self toJSON: value];
    [dict setValue:convertedValue forKey:key];
}

-(NSDictionary *)diff:(id)thisValue otherValue:(id)otherValue {	
    
    if ([thisValue isEqual: otherValue])
        return [NSDictionary dictionary];
    
    // Some binary data, like UIImages, won't detect equality with isEqual:
    // Therefore, compare base64 instead; this can be very slow
    // TODO: think of better ways to handle this
    NSString *thisStr = [self toJSON:thisValue];
    NSString *otherStr = [self toJSON:otherValue];
    if ([thisStr compare:otherStr] == NSOrderedSame)
        return [NSDictionary dictionary];
    
	// Construct the diff in the expected format
	return [NSDictionary dictionaryWithObjectsAndKeys:
			OP_REPLACE, OP_OP,
			[self toJSON: otherValue], OP_VALUE, nil];
}

-(id)applyDiff:(id)thisValue otherValue:(id)otherValue {
	
	return otherValue;
}

@end
