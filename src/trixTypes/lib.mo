///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Prelude "mo:base/Prelude";
import Principal "mo:principal/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";


module {

    //a data chunk should be no larger than 2MB so that it can be
    public type DataChunk = TrixValueUnstable;
    public type DataZone = Buffer.Buffer<DataChunk>;
    public type Workspace = Buffer.Buffer<DataZone>;

    public type Property = {name : Text; value : TrixValue; immutable : Bool};
    public type PropertyUnstable = {name : Text; value : TrixValueUnstable; immutable : Bool};

    //stable
    public type TrixValue = {
        #Int : Int;
        #Int8: Int8;
        #Int16: Int16;
        #Int32: Int32;
        #Int64: Int64;
        #Nat : Nat;
        #Nat8 : Nat8;
        #Nat16 : Nat16;
        #Nat32 : Nat32;
        #Nat64 : Nat64;
        #Float : Float;
        #Text : Text;
        #Bool : Bool;
        #Blob : Blob;
        #Class : [Property];
        #Principal : Principal;

        #Floats: {
            #frozen: [Float];
            #thawed: [Float]; //need to thaw when going to TrixValueUnstable
         };
        #Bytes : {
            #frozen: [Nat8];
            #thawed: [Nat8]; //need to thaw when going to TrixValueUnstable
        };
        #Empty;
    };

    public type TrixValueUnstable = {
        #Int :  Int;
        #Int8: Int8;
        #Int16: Int16;
        #Int32: Int32;
        #Int64: Int64;
        #Nat : Nat;
        #Nat8 : Nat8;
        #Nat16 : Nat16;
        #Nat32 : Nat32;
        #Nat64 : Nat64;
        #Float : Float;
        #Text : Text;
        #Bool : Bool;
        #Blob : Blob;
        #Class : [PropertyUnstable];
        #Principal : Principal;
        #Floats : {
            #frozen: [Float];
            #thawed: Buffer.Buffer<Float>;
        };
        #Bytes : {
            #frozen: [Nat8];
            #thawed: Buffer.Buffer<Nat8>; //need to thaw when going to TrixValueUnstable
        };
        #Empty;
    };

    public type AddressedChunk = (Nat, Nat, TrixValue);

    public type AddressedChunkArray = [AddressedChunk];

    public type AddressedChunkBuffer = Buffer.Buffer<AddressedChunk>;

    public func nat32ToBytes(x : Nat32) : [Nat8] {
        [ Nat8.fromNat(Nat32.toNat((x >> 24) & (255))),
        Nat8.fromNat(Nat32.toNat((x >> 16) & (255))),
        Nat8.fromNat(Nat32.toNat((x >> 8) & (255))),
        Nat8.fromNat(Nat32.toNat((x & 255))) ];
    };

    /// Returns [Nat8] of size 4 of the Nat16
    public func nat16ToBytes(x : Nat16) : [Nat8] {
        [ Nat8.fromNat(Nat16.toNat((x >> 8) & (255))),
        Nat8.fromNat(Nat16.toNat((x & 255))) ];
    };

    public func bytesToNat16(bytes: [Nat8]) : Nat16{
        (Nat16.fromNat(Nat8.toNat(bytes[0])) << 8) +
        (Nat16.fromNat(Nat8.toNat(bytes[1])));
    };

    public func bytesToNat32(bytes: [Nat8]) : Nat32{
        (Nat32.fromNat(Nat8.toNat(bytes[0])) << 24) +
        (Nat32.fromNat(Nat8.toNat(bytes[1])) << 16) +
        (Nat32.fromNat(Nat8.toNat(bytes[2])) << 8) +
        (Nat32.fromNat(Nat8.toNat(bytes[3])));
    };

    public func bytesToNat64(bytes: [Nat8]) : Nat64{
        (Nat64.fromNat(Nat8.toNat(bytes[0])) << 56) +
        (Nat64.fromNat(Nat8.toNat(bytes[0])) << 48) +
        (Nat64.fromNat(Nat8.toNat(bytes[1])) << 40) +
        (Nat64.fromNat(Nat8.toNat(bytes[2])) << 32) +
        (Nat64.fromNat(Nat8.toNat(bytes[0])) << 24) +
        (Nat64.fromNat(Nat8.toNat(bytes[1])) << 16) +
        (Nat64.fromNat(Nat8.toNat(bytes[2])) << 8) +
        (Nat64.fromNat(Nat8.toNat(bytes[3])));
    };


    public func natToBytes(n : Nat) : [Nat8] {
        var a : Nat8 = 0;
        var b : Nat = n;
        var bytes = List.nil<Nat8>();
        var test = true;
        while test {
            a := Nat8.fromNat(b % 256);
            b := b / 256;
            bytes := List.push<Nat8>(a, bytes);
            test := b > 0;
        };
        List.toArray<Nat8>(bytes);
    };

    public func bytesToNat(bytes : [Nat8]) : Nat {
        var n : Nat = 0;
        var i = 0;
        Array.foldRight<Nat8, ()>(bytes, (), func (byte, _) {
            n += Nat8.toNat(byte) * 256 ** i;
            i += 1;
            return;
        });
        return n;
    };

    //public func valueToNat(val : TrixValue) : ?Nat {
    //    switch(val){
    //        case(#Nat(val)){?val};
    //        case(_){null};
    //    };
    //};

    public func valueToNat(val : TrixValue) : Nat {
        switch(val){
            case(#Nat(val)){val};
            case(_){assert(false);/*unreachable*/0;};
        };
    };

    public func valueToText(val : TrixValue) : Text {
        switch(val){
            case(#Text(val)){val};
            case(_){assert(false);/*unreachable*/"";};
        };
    };

    public func valueToPrincipal(val : TrixValue) : Principal {
        switch(val){
            case(#Principal(val)){val};
            case(_){assert(false);/*unreachable*/Principal.fromText("");};
        };
    };

    public func valueToBool(val : TrixValue) : Bool {
        switch(val){
            case(#Bool(val)){val};
            case(_){assert(false);/*unreachable*/false;};
        };
    };

    //unstable getters
    public func valueUnstableToNat(val : TrixValueUnstable) : Nat {
        switch(val){
            case(#Nat(val)){val};
            case(_){assert(false);/*unreachable*/0;};
        };
    };

    public func valueUnstableToText(val : TrixValueUnstable) : Text {
        switch(val){
            case(#Text(val)){val};
            case(_){assert(false);/*unreachable*/"";};
        };
    };

    public func valueUnstableToPrincipal(val : TrixValueUnstable) : Principal {
        switch(val){
            case(#Principal(val)){val};
            case(_){assert(false);/*unreachable*/Principal.fromText("");};
        };
    };

    public func valueUnstableToBool(val : TrixValueUnstable) : Bool {
        switch(val){
            case(#Bool(val)){val};
            case(_){assert(false);/*unreachable*/false;};
        };
    };

    public func cloneValueUnstable(val : TrixValueUnstable) : TrixValueUnstable{
        switch(val){
            case(#Class(val)){

                return #Class(Array.tabulate<PropertyUnstable>(val.size(), func(idx){
                    {name= val[idx].name; value=cloneValueUnstable(val[idx].value); immutable = val[idx].immutable};
                }));
            };
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){
                        #Bytes(#frozen(val));
                    };
                    case(#thawed(val)){
                        #Bytes(#thawed(val.clone()));
                    };
                }
            };
            case(_){
                val;
            }
        };
    };

    public func toBuffer<T>(x :[T]) : Buffer.Buffer<T>{
        let thisBuffer = Buffer.Buffer<T>(x.size());
        for(thisItem in x.vals()){
            thisBuffer.add(thisItem);
        };
        return thisBuffer;
    };



    public func toBufferValues(x : [TrixValue]) : Buffer.Buffer<TrixValue> {
        let theBuffer = Buffer.Buffer<TrixValue>(x.size());
        //Debug.print(debug_show(x) # " " # debug_show(x.size()));
        for (thisIndex in Iter.range(0,x.size() - 1)){
            theBuffer.add(x[thisIndex]);
        };
        return theBuffer;
    };

    public func textToByteBuffer(_text : Text) : Buffer.Buffer<Nat8>{
        let result : Buffer.Buffer<Nat8> = Buffer.Buffer<Nat8>((_text.size() * 4) +4);
        for(thisChar in _text.chars()){
            for(thisByte in nat32ToBytes(Char.toNat32(thisChar)).vals()){
                result.add(thisByte);
            };
        };
        return result;
    };

    public func textToBytes(_text : Text) : [Nat8]{
        return textToByteBuffer(_text).toArray();
    };


    public func bytesToText(_bytes : [Nat8]) : Text{
        var result : Text = "";
        var aChar : [var Nat8] = [var 0, 0, 0, 0];

        for(thisChar in Iter.range(0,_bytes.size())){
            if(thisChar > 0 and thisChar % 4 == 0){
                aChar[0] := _bytes[thisChar-4];
                aChar[1] := _bytes[thisChar-3];
                aChar[2] := _bytes[thisChar-2];
                aChar[3] := _bytes[thisChar-1];
                result := result # Char.toText(Char.fromNat32(bytesToNat32(Array.freeze<Nat8>(aChar))));
            };
        };
        return result;
    };

    public func principalToBytes(_principal: Principal) : [Nat8]{
        return Blob.toArray(Principal.toBlob(_principal));
    };

    //todo: this should go to Blob once they add Principal.fromBlob
    public func bytesToPrincipal(_bytes: [Nat8]) : Principal{
        return Principal.fromBlob(Blob.fromArray(_bytes));
    };

    public func boolToBytes(_bool : Bool) : [Nat8]{
        if(_bool == true){
            return [1:Nat8];
        } else {
            return [0:Nat8];
        };
    };

    public func bytesToBool(_bytes : [Nat8]) : Bool{
        if(_bytes[0] == 0){
            return false;
        } else {
            return true;
        };
    };

    public func intToBytes(n : Int) : [Nat8]{
        var a : Nat8 = 0;
        var c : Nat8 = if(n < 0){1}else{0};
        var b : Nat = Int.abs(n);
        var bytes = List.nil<Nat8>();
        var test = true;
        while test {
            a := Nat8.fromNat(b % 256);
            b := b / 256;
            bytes := List.push<Nat8>(a, bytes);
            test := b > 0;
        };

        Array.append<Nat8>([c],List.toArray<Nat8>(bytes));
    };

    public func bytesToInt(_bytes : [Nat8]) : Int{
        var n : Int = 0;
        var i = 0;
        let natBytes = Array.tabulate<Nat8>(_bytes.size() - 2, func(idx){_bytes[idx+1]});

        Array.foldRight<Nat8, ()>(natBytes, (), func (byte, _) {
            n += Nat8.toNat(byte) * 256 ** i;
            i += 1;
            return;
        });
        if(_bytes[0]==1){
            n *= -1;
        };
        return n;
    };

    public func countAddressedChunksInWorkspace(x : Workspace) : Nat{
        var chunks = 0;
        for (thisZone in Iter.range(0, x.size() - 1)){
            chunks += x.get(thisZone).size();
        };
        chunks;

    };

    public func emptyWorkspace() : Workspace {
        return Buffer.Buffer<DataZone>(1);
    };

    public func initWorkspace(size : Nat) : Workspace {
        return Buffer.Buffer<DataZone>(size);
    };

    public func stabalizeProperty(item : PropertyUnstable) : Property{
        return {
            name = item.name;
            value = stabalizeValue(item.value);
            immutable = item.immutable;
        }
    };

    public func destabalizeProperty(item : Property) : PropertyUnstable{
        return {
            name = item.name;
            value = destablizeValue(item.value);
            immutable = item.immutable;
        }
    };

    public func stabalizeValue(item : TrixValueUnstable) : TrixValue{
        switch(item){
            case(#Int(val)){#Int(val)};
            case(#Int8(val)){#Int8(val)};
            case(#Int16(val)){#Int16(val)};
            case(#Int32(val)){#Int32(val)};
            case(#Int64(val)){#Int64(val)};
            case(#Nat(val)){#Nat(val)};
            case(#Nat8(val)){#Nat8(val)};
            case(#Nat16(val)){#Nat16(val)};
            case(#Nat32(val)){#Nat32(val)};
            case(#Nat64(val)){#Nat64(val)};
            case(#Float(val)){#Float(val)};
            case(#Text(val)){#Text(val)};
            case(#Bool(val)){#Bool(val)};
            case(#Blob(val)){#Blob(val)};

            case(#Class(val)){
                #Class(
                    Array.tabulate<Property>(val.size(), func(idx){
                        stabalizeProperty(val[idx]);
                    }));
            };
            case(#Principal(val)){#Principal(val)};
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){#Bytes(#frozen(val))};
                    case(#thawed(val)){#Bytes(#thawed(val.toArray()))};
                };
            };
            case(#Floats(val)){
                switch(val){
                    case(#frozen(val)){#Floats(#frozen(val))};
                    case(#thawed(val)){#Floats(#thawed(val.toArray()))};
                };
            };
            case(#Empty){#Empty};
        }
    };

    public func destablizeValue(item : TrixValue) : TrixValueUnstable{
        switch(item){
            case(#Int(val)){#Int(val)};
            case(#Int8(val)){#Int8(val)};
            case(#Int16(val)){#Int16(val)};
            case(#Int32(val)){#Int32(val)};
            case(#Int64(val)){#Int64(val)};
            case(#Nat(val)){#Nat(val)};
            case(#Nat8(val)){#Nat8(val)};
            case(#Nat16(val)){#Nat16(val)};
            case(#Nat32(val)){#Nat32(val)};
            case(#Nat64(val)){#Nat64(val)};
            case(#Float(val)){#Float(val)};
            case(#Text(val)){#Text(val)};
            case(#Bool(val)){#Bool(val)};
            case(#Blob(val)){#Blob(val)};
            case(#Class(val)){
                #Class(
                    Array.tabulate<PropertyUnstable>(val.size(), func(idx){
                        destabalizeProperty(val[idx]);
                    }));
            };
            case(#Principal(val)){#Principal(val)};
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){#Bytes(#frozen(val))};
                    case(#thawed(val)){#Bytes(#thawed(toBuffer<Nat8>(val)))};
                };
            };
            case(#Floats(val)){
                switch(val){
                    case(#frozen(val)){#Floats(#frozen(val))};
                    case(#thawed(val)){#Floats(#thawed(toBuffer<Float>(val)))};
                };
            };
            case(#Empty){#Empty};
        }
    };
    public func getValueSize(item : TrixValue) : Nat{
        let varSize = switch(item){
            case(#Int(val)){
                var a : Nat = 0;
                var b : Nat = Int.abs(val);
                var test = true;
                while test {
                    a += 1;
                    b := b / 256;
                    test := b > 0;
                };
                a + 1;//add the sign
            };
            case(#Int8(val)){1};
            case(#Int16(val)){2};
            case(#Int32(val)){3};
            case(#Int64(val)){4};
            case(#Nat(val)){
                var a : Nat = 0;
                var b = val;
                var test = true;
                while test {
                    a += 1;
                    b := b / 256;
                    test := b > 0;
                };
                a;
            };
            case(#Nat8(val)){1};
            case(#Nat16(val)){2};
            case(#Nat32(val)){3};
            case(#Nat64(val)){4};
            case(#Float(val)){4};
            case(#Text(val)){val.size()*4};
            case(#Bool(val)){1};
            case(#Blob(val)){val.size()};
            case(#Class(val)){
                var size = 0;
                for(thisItem in val.vals()){
                    size += 1 + (thisItem.name.size() * 4) + getValueSize(thisItem.value);
                };
                return size;
            };
            case(#Principal(val)){principalToBytes(val).size()};//don't like this but need to confirm it is constant
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){val.size() + 2};
                    case(#thawed(val)){val.size() + 2};
                };
            };
            case(#Floats(val)){
                switch(val){
                    case(#frozen(val)){(val.size() * 4) + 2};
                    case(#thawed(val)){(val.size() * 4) + 2};
                };
            };
            case(#Empty){0};
        };

        return varSize + 2;
    };

    public func getValueUnstableSize(item : TrixValueUnstable) : Nat{
        let varSize = switch(item){
            case(#Int(val)){
                var a : Nat = 0;
                var b : Nat = Int.abs(val);
                var test = true;
                while test {
                    a += 1;
                    b := b / 256;
                    test := b > 0;
                };
                a + 1;//add the sign
            };
            case(#Int8(val)){1};
            case(#Int16(val)){2};
            case(#Int32(val)){3};
            case(#Int64(val)){4};
            case(#Nat(val)){
                var a : Nat = 0;
                var b = val;
                var test = true;
                while test {
                    a += 1;
                    b := b / 256;
                    test := b > 0;
                };
                a;
            };
            case(#Nat8(val)){1};
            case(#Nat16(val)){2};
            case(#Nat32(val)){3};
            case(#Nat64(val)){4};
            case(#Float(val)){4};
            case(#Text(val)){val.size()*4};
            case(#Bool(val)){1};
            case(#Blob(val)){val.size()};
            case(#Class(val)){
                var size = 0;
                for(thisItem in val.vals()){
                    size += 1 + (thisItem.name.size() * 4) + getValueUnstableSize(thisItem.value);
                };
                return size;
            };
            case(#Principal(val)){principalToBytes(val).size()};//don't like this but need to confirm it is constant
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){val.size() + 2};
                    case(#thawed(val)){val.size() + 2};
                };
            };
            case(#Floats(val)){
                switch(val){
                    case(#frozen(val)){(val.size() * 4) + 2};
                    case(#thawed(val)){(val.size() * 4) + 2};
                };
            };
            case(#Empty){0};
        };
        return varSize + 2;
    };

    public func stablizeValueArray(items : DataZone) : [TrixValue]{
        let finalItems = Buffer.Buffer<TrixValue>(items.size());
        for(thisItem in items.vals()){
            finalItems.add(stabalizeValue(thisItem));
        };
        return finalItems.toArray();


    };

    public func workspaceToAddressedChunkArray(x : Workspace) : AddressedChunkArray {
        var currentZone = 0;
        var currentChunk = 0;
        let result = Array.tabulate<AddressedChunk>(countAddressedChunksInWorkspace(x), func(thisChunk){
            let thisChunk = (currentZone, currentChunk, stabalizeValue(x.get(currentZone).get(currentChunk)));
            if(currentChunk == Nat.sub(x.get(currentZone).size(),1)){
                currentZone += 1;
                currentChunk := 0;
            } else {
                currentChunk += 1;
            };
            thisChunk;
        });

        return result;
    };

    public func workspaceDeepClone(x : Workspace) : Workspace {
        var currentZone = 0;
        var currentChunk = 0;
        let ws = Buffer.Buffer<DataZone>(x.size());
        for(thisZone in x.vals()){

            let tz = Buffer.Buffer<DataChunk>(thisZone.size());
            ws.add(tz);
            for(thisDataChunk in thisZone.vals()){
                tz.add(cloneValueUnstable(thisDataChunk));
            };

        };

        return ws;
    };



    public func fromAddressedChunks(x : AddressedChunkArray) : Workspace{
        //todo: not implemented
        let result = Buffer.Buffer<DataZone>(x.size());

        //let aZone = x[0].0;
        fileAddressedChunks(result, x);

        return result;
    };

    public func fileAddressedChunks(workspace: Workspace, x : AddressedChunkArray) {
        //todo: not implemented

        //let aZone = x[0].0;
        for (thisChunk : AddressedChunk in Array.vals<AddressedChunk>(x)){

            let resultSize : Nat = workspace.size();
            let targetZone = thisChunk.0 + 1;
            Debug.print("targetZone " # debug_show(targetZone) # " " # debug_show(resultSize));

            if(targetZone  <= resultSize){
                    //zone exists
                    Debug.print("doing nothing zone exists");
                } else {
                    //append zone
                    Debug.print("need to append zone");

                    for (thisIndex in Iter.range(resultSize, targetZone-1)){
                        Debug.print("growing zone by one");
                        workspace.add(Buffer.Buffer<DataChunk>(1));
                    };
                    //result.get(thisChunk.0);
                };

            Debug.print("getting zone");
            let thisZone = workspace.get(thisChunk.0);




            if(thisChunk.1 + 1  <= thisZone.size()){
                    //zone exists
                Debug.print("chunk exists, replacing");
                thisZone.put(thisChunk.1, destablizeValue(thisChunk.2));
            } else {
                //append zone

                for (newChunk in Iter.range(thisZone.size(), thisChunk.1)){
                    Debug.print("growing chunk by 1 " # debug_show(newChunk) # " " # debug_show(thisChunk.1) ) ;
                    let newBuffer = if(thisChunk.1 == newChunk){
                        //we know the size
                            //Debug.print("calling to buffer " # debug_show(thisChunk.2));
                            destablizeValue(thisChunk.2);
                        } else {
                            #Empty;
                        };
                    thisZone.add(newBuffer);
                };
                //return thisZone.get(thisChunk.1);
            };


        };

        Debug.print("Done and have result");

        return ;
    };

    public func getDataZoneSize(dz: DataZone) : Nat {
        var size : Nat = 0;
        for(thisChunk in dz.vals()){
            size += getValueUnstableSize(thisChunk);
        };
        return size;
    };

    public func getWorkspaceChunkSize(_workspace: Workspace,  _maxChunkSize : Nat) : Nat{
        var currentChunk : Nat = 0;
        var handBrake = 0;
        var zoneTracker = 0;
        var chunkTracker = 0;


        label chunking while (1==1){
            handBrake += 1;
            if(handBrake > 1000){ break chunking;};
            var foundBytes = 0;
            //calc bytes
            for(thisZone in Iter.range(zoneTracker, _workspace.size()-1)){
                for(thisChunk in Iter.range(chunkTracker, _workspace.get(thisZone).size()-1)){
                    //Debug.print("handling " # debug_show(thisZone) # " " # debug_show(thisChunk) );
                    let thisItem = _workspace.get(thisZone).get(thisChunk);
                    //Debug.print("size " # debug_show(thisItem.size()) # " " # debug_show(_maxChunkSize)# " " # debug_show(foundBytes)) ;
                    let newSize = foundBytes + getValueUnstableSize(thisItem);
                    if( newSize > _maxChunkSize)
                    {
                        //Debug.print("went over bytes");

                        currentChunk += 1;
                        zoneTracker := thisZone;
                        chunkTracker := thisChunk;
                        //Debug.print("setting new vars" # " " # debug_show(currentChunk) # " " # debug_show(zoneTracker) # " " # debug_show(chunkTracker));
                        continue chunking;
                    };
                    //Debug.print("adding some bytes");
                    foundBytes := newSize;
                };
            };

        };
        //todo: throw error
        currentChunk += 1;
        Debug.print("Getting Workspace Size" # debug_show(currentChunk));

        return currentChunk;


    };

    public func getWorkspaceChunk(_workspace: Workspace, _chunkID : Nat, _maxChunkSize : Nat) : ({#eof; #chunk} , AddressedChunkBuffer){
        var currentChunk : Nat = 0;
        var handBrake = 0;
        var zoneTracker = 0;
        var chunkTracker = 0;
        Debug.print("about to loop");
        let resultBuffer = Buffer.Buffer<AddressedChunk>(1);
        label chunking while (1==1){
            handBrake += 1;
            if(handBrake > 1000){ break chunking;};
            var foundBytes = 0;
            //calc bytes
            for(thisZone in Iter.range(zoneTracker, _workspace.size()-1)){
                for(thisChunk in Iter.range(chunkTracker, _workspace.get(thisZone).size()-1)){
                    Debug.print("handling " # debug_show(thisZone) # " " # debug_show(thisChunk) );
                    let thisItem = _workspace.get(thisZone).get(thisChunk);
                    //Debug.print("size " # debug_show(thisItem.size()) # " " # debug_show(_maxChunkSize)# " " # debug_show(foundBytes)) ;
                    let newSize = foundBytes + getValueUnstableSize(thisItem);
                    if( newSize > _maxChunkSize)
                    {
                        Debug.print("went over bytes");
                        if(currentChunk == _chunkID){
                            Debug.print("returning ok chunk " # debug_show(_chunkID));
                            return (#chunk, resultBuffer);
                        };
                        currentChunk += 1;
                        zoneTracker := thisZone;
                        chunkTracker := thisChunk;
                        Debug.print("setting new vars" # " " # debug_show(currentChunk) # " " # debug_show(zoneTracker) # " " # debug_show(chunkTracker));
                        continue chunking;
                    };
                    if(currentChunk == _chunkID){
                        //add it to our return
                        Debug.print("adding item for chunk" # debug_show(_chunkID));
                        resultBuffer.add((thisZone, thisChunk, stabalizeValue(thisItem)));

                    };
                    //Debug.print("adding some bytes");
                    foundBytes := newSize;
                };
            };
            Debug.print("got to end");
            return (#eof, resultBuffer);
        };
        //todo: throw error
        return (#eof, resultBuffer);
    };

    public func getAddressedChunkArraySize(item : AddressedChunkArray) : Nat{
        var size : Nat = 0;
        for(thisItem in item.vals()){
            size += getValueSize(thisItem.2) + 4 + 4; //todo: only works for up to 32 byte adresess...should be fine but verify and document.
        };
        return size;
    };

    public func getDataChunkFromAddressedChunkArray(item : AddressedChunkArray, dataZone: Nat, dataChunk: Nat) : TrixValue{
        var size : Nat = 0;
        for(thisItem in item.vals()){
            if(thisItem.0 == dataZone and thisItem.1 == dataChunk){
                return thisItem.2;
            }
        };
        return #Empty;
    };

    public func valueToBytes(val : TrixValue) : [Nat8]{
        switch(val){
            case(#Int(val)){intToBytes(val)};
            case(#Int8(val)){Prelude.nyi()};
            case(#Int16(val)){Prelude.nyi()};
            case(#Int32(val)){Prelude.nyi()};
            case(#Int64(val)){Prelude.nyi()};
            case(#Nat(val)){natToBytes(val)};
            case(#Nat8(val)){[val]};
            case(#Nat16(val)){nat16ToBytes(val)};
            case(#Nat32(val)){nat32ToBytes(val)};
            case(#Nat64(val)){Prelude.nyi()};
            case(#Float(val)){Prelude.nyi()};
            case(#Text(val)){textToBytes(val)};
            case(#Bool(val)){boolToBytes(val)};
            case(#Blob(val)){Blob.toArray(val)};
            case(#Class(val)){Prelude.nyi()};
            case(#Principal(val)){principalToBytes(val)};
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){val};
                    case(#thawed(val)){val};
                };
            };
            case(#Floats(val)){Prelude.nyi()};
            case(#Empty){[]};
        }
    };

    public func getClassProperty(val: TrixValue, name : Text) : Property{
        Debug.print("getting " # name # " from " # debug_show(val));
        switch(val){
            case(#Class(val)){
                for(thisItem in val.vals()){
                    if(thisItem.name == name){
                        return thisItem;
                    };
                };
                Debug.print("couldnt find name in class");
                assert(false);
                //unreachable
                return {name=""; value=#Empty; immutable=true};

            };
            case(_){
                 Debug.print("was not a class");
                assert(false);
                //unreachable
                return {name=""; value=#Empty; immutable=true};
            }

        };

    };

    //todo: make these for every value type
    //buffer
    //nat - 8 16 32 64
    // int - 8 16 32 64
    // float
    ///text
    // bool
    // blob
    public func valueStableAsBytesStable(val : TrixValue) : [Nat8]{
        switch (val){
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){val};
                    case(#thawed(val)){val};
                };
            };
            case(#Empty){
                [];
            };
            case(_){
                assert(false);
                //unreachable
                [];
            };
        };
    };

    public func valueStableAsNat16(val : TrixValue) : Nat16{
        switch (val){
            case(#Nat16(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueStableAsNat32(val : TrixValue) : Nat32{
        switch (val){
            case(#Nat32(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueStableAsNat64(val : TrixValue) : Nat64{
        switch (val){
            case(#Nat64(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueStableAsNat(val : TrixValue) : Nat{
        switch (val){
            case(#Nat(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueStableAsInt(val : TrixValue) : Int{
        switch (val){
            case(#Int(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueStableAsPrincipal(val : TrixValue) : Principal{
        switch (val){
            case(#Principal(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                Principal.fromText("");
            };
        };
    };

    public func valueStableAsText(val : TrixValue) : Text{
        switch (val){
            case(#Text(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                "";
            };
        };
    };

    public func valueStableAsBoolean(val : TrixValue) : Bool{
        switch (val){
            case(#Bool(val)){
                val;
            };
            case(_){
                assert(false);
                //unreachable
                false;
            };
        };
    };

    //todo: make these for every value type
    //buffer
    //nat - 8 16 32 64
    // int - 8 16 32 64
    // float
    ///text
    // bool
    // blob
    public func valueUnstableAsBytesStable(val : TrixValueUnstable) : [Nat8]{
        switch (val){
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){val};
                    case(#thawed(val)){val.toArray()}
                };
            };
            case(#Empty){
                [];
            };
            case(_){
                assert(false);
                //unreachable
                [];
            };
        };
    };

    public func valueUnstableAsBytesBuffer(val : TrixValueUnstable) : Buffer.Buffer<Nat8>{
        switch (val){
            case(#Bytes(val)){
                switch(val){
                    case(#frozen(val)){
                        assert(false);
                        //unreachable
                        Buffer.Buffer<Nat8>(1);
                    };
                    case(#thawed(val)){val};
                };
            };
            case(_){
                assert(false);
                //unreachable
                Buffer.Buffer<Nat8>(1);
            };
        };
    };

    public func valueUnstableAsFloatBuffer(val : TrixValueUnstable) : Buffer.Buffer<Float>{
        switch (val){
            case(#Floats(val)){
                switch(val){
                    case(#frozen(val)){
                        assert(false);
                        //unreachable
                        Buffer.Buffer<Float>(1);
                    };
                    case(#thawed(val)){val};
                };
            };
            case(_){
                assert(false);
                //unreachable
                Buffer.Buffer<Float>(1);
            };
        };
    };

    public func valueUnstableAsBoolean(val : TrixValueUnstable) : Bool{
        switch (val){
            case(#Bool(val)){
                val;
            };
            case(_){
                assert(false);
                //unreachable
                false;
            };
        };
    };

    public func byteBufferDataZoneToBuffer(dz : DataZone): Buffer.Buffer<Buffer.Buffer<Nat8>>{
        let result = Buffer.Buffer<Buffer.Buffer<Nat8>>(dz.size());
        for(thisItem in dz.vals()){
            result.add(valueUnstableAsBytesBuffer(thisItem));
        };
        return result;
    };

    public func byteBufferChunksToValueUnstableBufferDataZone(buffer : Buffer.Buffer<Buffer.Buffer<Nat8>>): DataZone{
        let result = Buffer.Buffer<TrixValueUnstable>(buffer.size());
        for(thisItem in buffer.vals()){
            result.add(#Bytes(#thawed(thisItem)));
        };
        return result;
    };

    public func initDataZone(val : TrixValueUnstable) : DataZone{
        let result = Buffer.Buffer<TrixValueUnstable>(1);
        result.add(val);
        return result;
    };

    public func valueUnstableAsNat16(val : TrixValueUnstable) : Nat16{
        switch (val){
            case(#Nat16(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueUnstableAsNat32(val : TrixValueUnstable) : Nat32{
        switch (val){
            case(#Nat32(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueUnstableAsNat64(val : TrixValueUnstable) : Nat64{
        switch (val){
            case(#Nat64(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueUnstableAsNat(val : TrixValueUnstable) : Nat{
        switch (val){
            case(#Nat(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueUnstableAsInt(val : TrixValueUnstable) : Int{
        switch (val){
            case(#Int(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                0;
            };
        };
    };

    public func valueUnstableAsPrincipal(val : TrixValueUnstable) : Principal{
        switch (val){
            case(#Principal(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                Principal.fromText("");
            };
        };
    };

    public func valueUnStableAsText(val : TrixValueUnstable) : Text{
        switch (val){
            case(#Text(val)){
                val
            };
            case(_){
                assert(false);
                //unreachable
                "";
            };
        };
    };

    public func flattenAddressedChunkArray(data : AddressedChunkArray) : [Nat8]{
        let accumulator : Buffer.Buffer<Nat8> = Buffer.Buffer<Nat8>(getAddressedChunkArraySize(data));
        for(thisItem in data.vals()){

            for(thisbyte in natToBytes(thisItem.0).vals()){
                accumulator.add(thisbyte);
            };
            for(thisbyte in natToBytes(thisItem.1).vals()){
                accumulator.add(thisbyte);
            };

                for(thisbyte in valueToBytes(thisItem.2).vals()){
                    accumulator.add(thisbyte);
                };

        };
        return accumulator.toArray();


    };


};