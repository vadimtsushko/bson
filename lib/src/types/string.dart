part of bson;
class BsonString extends BsonObject{
  String data;
  List<int> _utfData;
  List<int> get utfData{
    if (_utfData == null){
      _utfData = UTF8.encode(data);
    }
    return _utfData;
  }
  BsonString(this.data);
  get value=>data;
  byteLength()=>utfData.length+1+4;
  int get typeByte => _BSON_DATA_STRING;
  packValue(BsonBinary buffer){
     buffer.writeInt(utfData.length+1);
     buffer.byteList.setRange(buffer.offset,buffer.offset+utfData.length,utfData);
     buffer.offset += utfData.length;
     buffer.writeByte(0);
  }
  unpackValue(BsonBinary buffer){
     int size = buffer.readInt32()-1;
     data = UTF8.decode(buffer.byteList.getRange(buffer.offset, buffer.offset+size).toList());
     buffer.offset += size+1;
  }
}
class BsonCode extends BsonString{
  get value=>this;
  int get typeByte => _BSON_DATA_CODE;
  BsonCode(String dataValue):super(dataValue);
  String toString()=>"BsonCode('$data')";
}
class BsonCString extends BsonString{
  bool useKeyCash;
  int get typeByte{
   throw "Function typeByte of BsonCString must not be called";
  }
  BsonCString(String data, [this.useKeyCash = true]): super(data);
  List<int> get utfData{
    if (useKeyCash){
      return _Statics.getKeyUtf8(data) as List<int>;
    }
    else {
      return super.utfData;
    }
  }

  byteLength()=>utfData.length+1;
  packValue(BsonBinary buffer){
     buffer.byteList.setRange(buffer.offset,buffer.offset+utfData.length,utfData);
     buffer.offset += utfData.length;
     buffer.writeByte(0);
  }
}