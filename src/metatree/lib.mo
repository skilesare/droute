///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";

import Buffer "mo:base/Buffer";

import Array "mo:base/Array";
import Debug "mo:base/Debug";

import HashMap "mo:base/HashMap";
import TrixTypes "../TrixTypes";
import SHA256 "../dRouteUtilities/SHA256";


module {
    type AddressedChunkArray = TrixTypes.AddressedChunkArray;


    public type Entry = {
        primaryID: Nat;
        marker: Nat;
        data: AddressedChunkArray;
    };

    public type ReadResponse = {
        data: [Entry];
        lastID: ?Nat;
        lastMarker: ?Nat;
    };

    public type MetaTreeConfig = {
        #local;
    };

    public type MetaTreeIndex = {
        namespace : Text;
        dataZone: Nat;
        dataChunk: Nat;
        indexType: {
            #Nat;
            #Text;
            #Int;
            #Dyanamic : Principal;
        };
    };


    public class MetaTree(config: MetaTreeConfig){

        //need to start at 1 instead of 0 becuase we can't do -1 and first item will not be detected
        var nonce : Nat = 1;

        func bigNatToNat32(n : Nat) : Nat32{
            Nat32.fromNat(Nat.rem(n, 4_294_967_295));
        };

        var namespaceMap : HashMap.HashMap<Nat,[Entry]> = HashMap.HashMap<Nat,[Entry]>(1, Nat.equal, bigNatToNat32);

        public func write(namespace : Text, primaryID : Nat, data: AddressedChunkArray) : async Nat{
            //todo: write to metatree service
            let marker = nonce;
            nonce += 1;
            let namespaceHash = TrixTypes.bytesToNat(SHA256.sha256(TrixTypes.textToBytes(namespace)));

            let currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            switch(currentList){
                case(null){
                    Debug.print("no list for namespace " # namespace);
                    namespaceMap.put(namespaceHash, [{primaryID = primaryID; marker = marker; data = data}]);
                };
                case(?currentList){
                    Debug.print("found list for namespace " # namespace # " " #  debug_show(currentList.size()));
                    var bIn = false;
                    let currentListSize = currentList.size();
                    //todo: test inserting in the middle of the list.
                    let newArray = Array.tabulate<Entry>(currentListSize + 1, func(idx){
                        if(bIn == false){
                            Debug.print("bIn is false");

                            if(idx < currentListSize and (primaryID > currentList[idx].primaryID or (primaryID == currentList[idx].primaryID and marker > currentList[idx].marker))){
                                //Debug.print("keeping the same" # debug_show(idx));
                                return currentList[idx];
                            } else {

                                //Debug.print("found the place to insert and adding an item");
                                bIn := true;
                                return {
                                    primaryID = primaryID;
                                    marker = marker;
                                    data = data
                                };
                            };

                        } else {
                            //Debug.print("bIn is true inserting one back");
                            return currentList[idx - 1];
                        };
                    });
                    Debug.print("inserting new array" # debug_show(newArray.size()));
                    namespaceMap.put(namespaceHash, newArray);
                };
            };

            return marker;

        };


        public func writeAndIndex(namespace : Text, primaryID : Nat, data: AddressedChunkArray, index: [MetaTreeIndex]) : async Nat{
            //todo: write to metatree service
            let marker  = await write(namespace, primaryID, data);
            Debug.print(
                "wrote initial item to log...now doing index"
            );

            for(thisIndex in index.vals()){
                Debug.print(debug_show(thisIndex));
                let metaData = calcIndexMeta(thisIndex, data);
                let newNamespace = thisIndex.namespace # ".__index." # metaData.postFix;
                //not currently awaiting the markers.
                let aMarker = write(newNamespace, metaData.primaryID, data);
            };
            return marker;

        };

        func calcIndexMeta(index : MetaTreeIndex, data : AddressedChunkArray) : {primaryID : Nat; postFix : Text} {

            let meta = switch(index.indexType){
                case(#Nat){
                    let n = TrixTypes.bytesToNat(TrixTypes.getDataChunkFromAddressedChunkArray(data, index.dataZone, index.dataChunk));
                    {postFix = Nat.toText(n);
                     primaryID = n
                    };
                };
                case(#Int){
                    //todo: does not support negative ints. Maybe add a billionty to private id?
                    let n = TrixTypes.bytesToInt(TrixTypes.getDataChunkFromAddressedChunkArray(data, index.dataZone, index.dataChunk));

                    {postFix = Int.toText(n);
                    primaryID = Int.abs(n)};
                };
                case(#Text){
                    let n = SHA256.sha256(TrixTypes.getDataChunkFromAddressedChunkArray(data, index.dataZone, index.dataChunk));
                    {postFix = TrixTypes.bytesToText(n);
                    primaryID = TrixTypes.bytesToNat(n)};
                };
                case(_){
                    {postFix="Not Implemented";
                    primaryID=0};
                };
            };

            return meta;
        };


        var maxchunkSize : Nat = 2_000_000;



        public func read(namespace : Text) : async ReadResponse{
            return await readFilterPage(namespace, null, null, 0, 0);
        };

        public func readPage(namespace : Text, lastID : Nat, lastMarker : Nat) : async ReadResponse{
            return await readFilterPage(namespace, null, null, lastID, lastMarker);
        };

        public func readFilter(namespace : Text, minID : ?Nat, maxID : ?Nat) : async ReadResponse{
            return await readFilterPage(namespace, minID, maxID, 0, 0);
        };

        public func readFilterPage(namespace : Text, minID : ?Nat, maxID : ?Nat, lastID : Nat, lastMarker: Nat) : async ReadResponse {

            let namespaceHash = TrixTypes.bytesToNat(SHA256.sha256(TrixTypes.textToBytes(namespace)));
            Debug.print("getting logs for hash " # debug_show(namespaceHash) # " " # namespace);

            let currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            //Debug.print("found a List");
            switch(currentList){
                case(null){
                    Debug.print("no logs");
                    return {
                        data = [];
                        lastID = null;
                        lastMarker = null;
                    };
                };
                case(?currentList){
                    //todo: this wont work for large lists
                    var resultSize = 0;
                    let responseBuffer = Buffer.Buffer<Entry>(16);
                    if(currentList.size() == 0){
                        //Debug.print("no logs size");
                        return {
                        data = [];
                        lastID = null;
                        lastMarker = null;
                        };
                    };
                    switch(minID, maxID){
                        case(null, null){
                            //no filter
                            Debug.print("no filter" # debug_show(currentList.size()));
                            label buildResponse for(thisEntry in currentList.vals()){
                                //Debug.print(debug_show(lastID) # " " # debug_show(lastMarker) # " " # debug_show(thisEntry.primaryID) # " " # debug_show(thisEntry.marker));
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    //Debug.print("prcing entry " # debug_show(thisEntry));
                                    responseBuffer.add(thisEntry);
                                    resultSize += TrixTypes.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    //Debug.print("breaking because chunksize" # debug_show(resultSize));
                                    break buildResponse;
                                };
                            };
                        };
                        case(null, ?maxID){
                            label buildResponse for(thisEntry in currentList.vals()){
                                if(thisEntry.primaryID >= maxID){
                                    break buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += TrixTypes.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };
                        case(?minID, null){
                            label buildResponse for(thisEntry in currentList.vals()){
                                if(thisEntry.primaryID < minID){
                                    continue buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += TrixTypes.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };
                        case(?minID, ?maxID){
                            label buildResponse for(thisEntry in currentList.vals()){
                                if(thisEntry.primaryID < minID){
                                    continue buildResponse;
                                };
                                if(thisEntry.primaryID >= maxID){
                                    break buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += TrixTypes.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };

                    };

                    let lastItem = if(responseBuffer.size() > 0)
                            {responseBuffer.get(responseBuffer.size() - 1)}
                        else {{primaryID=0;marker=0;data=[];}};

                    return {
                        data = responseBuffer.toArray();
                        lastID = ?lastItem.primaryID;
                        lastMarker = ?lastItem.marker;
                    };

                };
            };
        }

        //todo: US 6; handle upgrades
    };



};