const String NAME = "name";
const String TYPE_DEVICE = "typeDevice";
const String BRAND = "brand";
const String MODEL = "model";
const String MASTER = "master";
const String MANAGER = "manager";
const String AFTER = "after";
const String AFTERINTIME = "afterintime";
const String TELEGRAM = "telegram";
const String IMAGES = "images";
const String DEADLINE = "deadline";
const String HOW_KNOW = "howKnow";
const String PROBLEM = "problem";
const String PHONES = "phones";
const String COMPLETE_SET = "completeSet";
const String EMAIL = "email";
const String APPEARANCE = "appearance";
const String INN = "inn";
const String KPP = "kpp";
const String OGRN = "ogrn";
const String BANK_BIK = "bankBik";
const String BANK_SWIFT = "bankSwift";
const String COUNTERAGENT_NODE = "counteragentNode";
const String ORDER_NODE = "orderNode";
const String ADDRESS = "address";
const String DIRECTOR = "director";
const String SERIAL_NUMBER = "serialNumber";
const String CONTRACT = "contract";
const String PASSPORT_OFFICE = "passportOffice";
const String PASSPORT_CODE_OFFICE = "passportCodeOffice";
const String BIRTHPLACE = "birthplace";
const String BANK_NAME = "bankName";
const String BANK_COR = "bankCor";
const String BANK_ACCOUNT = "bankAccount";
const String SN = "sn";
const String PREPAYMENT = "prepayment";
const String IS_URGENT = "isUrgent";
const String APPROXIMATE_PRICE = "approximatePrice";
const String SELECTEL_ID = "selectelId";
const String COLOR = "color";
const String PASSPORT_DATE = "passportDate";
const String BIRTH_DATE = "birthdate";

const String NUMBER = "number";
const String MONEY = "money";
const String DATE = "date";
const String DATE_TIME = "dateTime";
const String BOOLEAN = "boolean";
const String STRING = "string";
const String TEXT = "text";
const String ENUM = "enum";
const String MULTIPLE = "multiple";

const String COUNTERAGENT = "counteragent";
const String TYPE_ORDER = "typeOrder";

class TypeOrder {

  String name;
  int workPercent;
  int productPercent;
  String id;
  String statusId;
  bool isPayRequired;

  TypeOrder.fromJson(Map json) {
    name = json['name'];
    workPercent = json['workPercent'];
    productPercent = json['productPercent'];
    id = json['id'];
    statusId = json['statusId'];
    isPayRequired = json['isPayRequired'];
  }

  @override
  toString() => '$name $id';

}

class FieldInfo {

  String id;
  String name;
  String description;
  dynamic defaultValue;
  dynamic value;
  List<String> items;
  String position;
  String dataType;
  String type;
  bool isRequired;
  bool isOnlyDictionary;
  bool isBlock;
  String groupDescription;

  String errorMessage;

  FieldInfo({
    this.value,
    this.name,
    this.description,
    this.defaultValue,
    this.isBlock,
    this.isOnlyDictionary,
    this.id,
    this.items,
    this.type,
    this.isRequired,
    this.position,
    this.dataType,
    this.groupDescription,
  });

  FieldInfo.fromJson(Map json) {
    id = json['fieldId'];
    name = json['name'];
    description = json['description'];
    defaultValue = (name == NAME && json['defaultValue'] != null && json['defaultValue']['id'] != null) ?
      Counteragent.fromJson(json['defaultValue']) : json['defaultValue'];
    items = json['items'] != null
        ? (json['items'] as List).map((e) => e.toString()).toList()
        : null;
    position = json['place'];
    dataType = json['dataType'];
    type = json['type'];
    isRequired = json['isRequired'] == true;
    isOnlyDictionary = json['isOnlyDictionary'] == true;
    groupDescription = json['groupDescription'];
    isBlock = false;
  }

  @override
  toString() => '$id $name $type $isRequired $value';

}

class Counteragent {

  int rating;
  String name;
  List<String> phones;
  String id;
  String origName;

  Counteragent.fromJson(Map json) {
    rating = json['rating'];
    name = json['name'];

    phones = json['phones'] != null
        ? (json['phones'] as List).map((e) => e.toString()).toList()
        : null;
    id = json['id'];
    origName = json['origName'];
  }
}

class HowKnow {

  String id;
  String name;
  bool isRepeat;

  HowKnow({
    this.name,
    this.id,
    this.isRepeat,
  });

  HowKnow.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    isRepeat = json['isRepeat'] != null ? json['isRepeat'] : false;
  }


  HowKnow copyWith({String name}) => HowKnow(
    name: name ?? this.name,
    isRepeat: isRepeat,
    id: id,
  );

}

class TypeDevice {

  String id;
  String name;
  String origName;

  TypeDevice({
    this.name,
    this.id,
    this.origName,
  });

  TypeDevice.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    origName = json['origName'];
  }

  TypeDevice copyWith({String name}) => TypeDevice(
    name: name ?? this.name,
    origName: origName,
    id: id,
  );

}

class Brand {

  String id;
  String name;
  String origName;
  int modelCount;

  Brand({
    this.name,
    this.id,
    this.origName,
    this.modelCount,
  });

  Brand.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    origName = json['origName'];
    modelCount = json['modelCount'];
  }

  Brand copyWith({String name}) => Brand(
    name: name ?? this.name,
    origName: origName,
    modelCount: modelCount,
    id: id,
  );


}

class CompleteSet {

  String id;
  String name;
  String origName;

  CompleteSet({
    this.name,
    this.id,
    this.origName,
  });

  CompleteSet.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    origName = json['origName'];
  }

  CompleteSet copyWith({String name}) => CompleteSet(
    name: name ?? this.name,
    origName: origName,
    id: id,
  );

}

class Problem {

  String id;
  String name;
  String origName;

  Problem({
    this.name,
    this.id,
    this.origName,
  });

  Problem.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    origName = json['origName'];
  }

  Problem copyWith({String name}) => Problem(
    name: name ?? this.name,
    origName: origName,
    id: id,
  );

}

class ManagerMaster {

  String id;
  String name;
  String origName;
  bool isMyself;
  String inn;

  ManagerMaster({
    this.name,
    this.id,
    this.origName,
    this.inn,
    this.isMyself
  });

  ManagerMaster.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    origName = json['origName'];
    isMyself = json['isMyself'];
    inn = json['inn'];
  }


  ManagerMaster copyWith({String name}) => ManagerMaster(
    name: name ?? this.name,
    origName: origName,
    id: id,
  );


}

class Model {

  String id;
  String name;
  String brandDeviceId;
  String typeDeviceId;
  String origName;

  Model({
    this.id,
    this.name,
    this.brandDeviceId,
    this.typeDeviceId,
    this.origName,
  });

  Model.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    brandDeviceId = json['brandDeviceId'];
    typeDeviceId = json['typeDeviceId'];
    origName = json['origName'];
  }

  Model copyWith({String name}) => Model(
    name: name ?? this.name,
    origName: origName,
    id: id,
  );


}

class CashRegister {

  String name;
  dynamic cashMoney;
  dynamic bankMoney;
  dynamic bankPercent;
  bool isEnableCash;
  bool isEnableBank;
  bool isEnableNegative;
  bool isEnableInternalMove;
  String shopId;
  String id;
  bool isDefault;

  CashRegister({
    this.id,
    this.name,
    this.shopId,
    this.bankMoney,
    this.bankPercent,
    this.cashMoney,
    this.isDefault,
    this.isEnableBank,
    this.isEnableCash,
    this.isEnableInternalMove,
    this.isEnableNegative,
  });

  CashRegister.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    shopId = json['shopId'];
    bankMoney = json['bankMoney'];
    bankPercent = json['bankPercent'];
    cashMoney = json['cashMoney'];
    cashMoney = json['cashMoney'];
    isDefault = json['isDefault'];
    isEnableBank = json['isEnableBank'];
    isEnableCash = json['isEnableCash'];
    isEnableInternalMove = json['isEnableInternalMove'];
    isEnableNegative = json['isEnableNegative'];
  }
}