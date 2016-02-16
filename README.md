#GLEntity
##简介

用于数据模型和字典之间的相互转换，以及sqlite数据库的存取操作。
##使用说明

构建的数据模型需要继承自GLBaseEntity类。
	
####规则

1. 模型的属性的命名规则为字典的key名加上column_前缀。


2. 当字典嵌套字典时，则需要设一个entity类型的属性用于存储该内层字典。


3. 当字典里嵌套数组时，如果数组元素是字典，则设一个存储entity对象的数组属性用于存储该数组；如果数组元素不是字典，则设为一个字符串属性用于存储该数组的json串。

4. 当字典嵌套字典时，内层字典转换成数据模型，类名命名规则为，外层字典的类名和内层字典的key名用下划线连接。<br />比如：外层字典对应的数据模型类名为“Entity”，内层字典的key名为“key”，则内层字典数据模型的类名应为：“Entity_key”。

5. 当字典嵌套数组且数组元素为字典时，数组中字典元素对应的数据模型类的命名规则和字典嵌套字典的命名规则相同。

6. 对于需要设置为外键的属性，属性名前面必须加前缀 foreign_。

7. 数据模型类的属性类型和它实际存储数据的类型一定要一致，不能出现类似这种情况：属性为entity类型，但是实际存储的却是一个数组。

8. 带foreign_和column_前缀的属性不要设为readOnly。


####特别说明

* 一个数据模型类对应的表名默认情况下是类名加上table_前缀。也可以重写GLEntity类的 +(NSString*)tableName 方法重新给表命名，但是为了防止表名重复，不建议这么做。

* 数据库表中的字段名默认和数据模型类的属性名相同。也可以重写GLEntity类的 +(NSMutableDictionary*)propertyColumnMap 方法该变二者之间的对应关系。

####举例

对于下面这个字典，或者以这样的字典作为元素的数组

	NSDictionary* dict = @{@"name":@"lgl",
                           @"birthday":@{@"year":@"1990",
                                         @"month":@"07",
                                         @"day":@"01"},
                           @"age":@"11",
                           @"sisters":@[@{@"name":@"xcc", @"age":@"45"},
                                        @{@"name":@"xyj", @"age":@"30"}],
                           @"phones":@[@"android", @"apple"]};

构建的数据模型为：

Perosn类：
	
	#import "GLBaseEntity.h"
	#import "Person_birthday.h"
	#import "Person_sisters.h"

	@interface Person : GLBaseEntity
	
	@property (nonatomic) int column_age;
	@property (nonatomic, strong) NSString* column_name;
	@property (nonatomic, strong) Person_birthday* column_birthday;
	@property (nonatomic, strong) NSArray* column_sisters;
	@property (nonatomic, strong) NSString* column_phones;
	
	@end	
                           
Person_birthday类：	

	#import "GLBaseEntity.h"

	@interface Person_birthday : GLBaseEntity
	
	// 外键，为使用方便，可以重写其getter方法
	@property (nonatomic, strong) NSString* foreign_name;
	
	@property (nonatomic, strong) NSString* column_year;
	@property (nonatomic, strong) NSString* column_month;
	@property (nonatomic, strong) NSString* column_day;
	
	@end
             
Person_sisters类：

	#import "GLBaseEntity.h"

	@interface Person_sisters : GLBaseEntity
	
	@property (nonatomic, strong) NSString* foreign_name;
	
	@property (nonatomic, strong) NSString* column_name;
	@property (nonatomic, strong) NSString* column_age;
	
	@end              


详细使用方法请参见源码示例。
##安装说明

1. 在Podfile文件中添加 pod "GLEntity"
2. 运行 pod install 或 pod update
