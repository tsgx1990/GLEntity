# GLEntity
interconversion between entity and dictionary


// 规则1：
   entity的属性名的命名规则为 column_ + key名

// 规则2：
   如果字典中有字典，需要将该字典设为一个entity属性

// 规则3：
   如果字典里有一个数组且数组元素是字典，则需要将该数组设为一个存储entity的数组；如果这个数组元素不是字典，则将该数组设为entity的一个字符串属性，用于存储该数组的json串

// 规则4：
   字典中包含字典的情况下，假如外层字典对应的entity类名为 "Entity"，内字典的key名为 "key"，则内层字典的entity类名命名规则为："Entity_key"

// 规则5：
   字典中包含数组（且该数组元素为字典）的情况下，数组中的字典元素对应的entity类名的命名规则，和字典中包含字典的情况相同

// 规则6：
   对于需要设置为外键的属性，属性名前面必须加前缀 foreign_

// 规则7：
   entity类的属性类型和它实际存储数据的类型一定要一致，不能出现类似这种情况：属性类型为Entity类，但是实际存储的却是一个数组。

// 规则8：
   foreign属性和column属性都不要设为readonly

// 默认1：
   一个entity类对应的表名默认为 table_ + entity类名，可以重写 + (NSString*)tableName 方法重新给表命名，但是一般情况下不必这么做

// 默认2：
   表中的字段名默认和entity的属性名相同，可以重写 + (NSMutableDictionary*)propertyColumnMap 改变二者之间的对应关系
