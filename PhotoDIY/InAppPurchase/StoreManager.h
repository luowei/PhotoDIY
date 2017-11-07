#import <StoreKit/StoreKit.h>

/*
 Abstract:
 Model class to represent a product/purchase.
 */

@interface MyModel : NSObject

// Products/Purchases are organized by category
@property(nonatomic, copy) NSString *name;
//  List of products/purchases
@property(nonatomic, strong) NSArray<SKProduct *> *elements;

// Create a model object
- (instancetype)initWithName:(NSString *)name elements:(NSArray<SKProduct *> *)elements NS_DESIGNATED_INITIALIZER;

@end



/*
 Retrieves product information from the App Store using SKRequestDelegate,
         SKProductsRequestDelegate,SKProductsResponse, and SKProductsRequest.
         Notifies its observer with a list of products available for sale along with
         a list of invalid product identifiers. Logs an error message if the product 
         request failed.
*/

// Provide notification about the product request
extern NSString *const IAPProductRequestNotification;


@interface StoreManager : NSObject

typedef NS_ENUM(NSInteger, IAPProductRequestStatus) {
    IAPProductsFound,// Indicates that there are some valid products
    IAPIdentifiersNotFound, // indicates that are some invalid product identifiers
    IAPProductRequestResponse, // Returns valid products and invalid product identifiers
    IAPRequestFailed // Indicates that the product request failed
};

// Provide the status of the product request
@property(nonatomic) IAPProductRequestStatus status;

// Keep track of all valid products. These products are available for sale in the App Store
@property(nonatomic, strong) NSMutableArray<SKProduct *> *availableProducts;

// Keep track of all invalid product identifiers
@property(nonatomic, strong) NSMutableArray<NSString *> *invalidProductIds;

// Keep track of all valid products (these products are available for sale in the App Store) and of all invalid product identifiers
@property(nonatomic, strong) NSMutableArray<MyModel *> *responseModels;

// Indicates the cause of the product request failure
@property(nonatomic, copy) NSString *errorMessage;

+ (StoreManager *)sharedInstance;

// Query the App Store about the given product identifiers
- (void)fetchProductInformationForIds:(NSArray<NSString *> *)productIds;

// Return the product's title matching a given product identifier
- (NSString *)titleMatchingProductIdentifier:(NSString *)identifier;

@end
