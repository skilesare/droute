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
import Prelude "mo:base/Prelude";
import Blob "mo:base/Blob";

import Buffer "mo:base/Buffer";

import Array "mo:base/Array";
import Debug "mo:base/Debug";

import HashMap "mo:base/HashMap";
import TrixTypes "../TrixTypes";
import SHA256 "../dRouteUtilities/SHA256";
import MerkleTree "../dRouteUtilities/MerkleTree";
import CertifiedData "mo:base/CertifiedData";

import PipelinifyTypes "mo:pipelinify/pipelinify/PipelinifyTypes";

module {
    type AddressedChunkArray = TrixTypes.AddressedChunkArray;


    public type Entry = {
        primaryID: Nat;
        marker: Nat;
        data: AddressedChunkArray;
    };

    public type ReadResponse = {
        #data : {
            data: [Entry];
            lastID: ?Nat;
            lastMarker: ?Nat;
        };
        #pointer : {
            canister: Principal;
        };
    };

    public type WitnessResponse = {
        #finalWitness: MerkleTree.Witness;
        #pointer : {
            canister: Principal;
            witness: MerkleTree.Witness;
        }
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
        //todo: add the container's merkle tree to the config;

        //need to start at 1 instead of 0 becuase we can't do -1 and first item will not be detected
        var nonce : Nat = 1;

        func bigNatToNat32(n : Nat) : Nat32{
            Nat32.fromNat(Nat.rem(n, 4_294_967_295));
        };

        //todo: we realluy need a sha256 Hashmap
        var namespaceMap : HashMap.HashMap<Nat,[Entry]> = HashMap.HashMap<Nat,[Entry]>(1, Nat.equal, bigNatToNat32);
        var certifiedTree = MerkleTree.empty();
        let natToBytes = TrixTypes.natToBytes;
        let h = MerkleTree.h;
        let h2 = MerkleTree.h2;
        let h3 = MerkleTree.h3;

        func certify(namespace: Nat, primaryID: Nat, marker: Nat, data: AddressedChunkArray){
            Debug.print("certifying namespace:" # debug_show(namespace) # " primary:" # debug_show(primaryID) # " Marker:" # debug_show(marker));
            let key = h2("\0dmetatree-cert",
                h3(
                    Blob.fromArray(
                        natToBytes(namespace)),
                    Blob.fromArray(
                        natToBytes(primaryID)),
                    Blob.fromArray(
                        natToBytes(marker))));
            Debug.print("writing key " # debug_show(key));
            let value = h(Blob.fromArray(TrixTypes.flattenAddressedChunkArray(data)));
            certifiedTree := MerkleTree.put(certifiedTree, key, value);
            CertifiedData.set(MerkleTree.treeHash(certifiedTree));
        };

        public func getWitness(namespace: Nat, primaryID: Nat, marker: Nat) : WitnessResponse{
            //todo: what if the witness is on a different canister - combine them
            Debug.print("in get witness namespace" # debug_show(namespace) # " Primary:" # debug_show(primaryID) # " marker:" # debug_show(marker));
            let key = h2("\0dmetatree-cert",
                h3(
                    Blob.fromArray(
                        natToBytes(namespace)),
                    Blob.fromArray(
                        natToBytes(primaryID)),
                    Blob.fromArray(
                        natToBytes(marker))));

            Debug.print("key " # debug_show(key));

            //todo: check to see if the witness i son this canister or not
            let witness = MerkleTree.reveal(certifiedTree, key);
            return #finalWitness(witness);
        };

        public func getWitnessByNamespace(namespace: Text, primaryID: Nat, marker: Nat) :  WitnessResponse {
            getWitness(namespaceToHash(namespace), primaryID, marker);
        };

        func namespaceToHash(namespace: Text) : Nat{
            return TrixTypes.bytesToNat(SHA256.sha256(TrixTypes.textToBytes(namespace)))
        };

        public func write(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify : Bool) : async Nat{
            //todo: write to metatree service
            let marker = nonce;
            nonce += 1;
            let namespaceHash = namespaceToHash(namespace);

            let currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            switch(currentList, dataConfig){
                case(null, #dataIncluded(data)){
                    Debug.print("no list for namespace " # namespace);
                    namespaceMap.put(namespaceHash, [{primaryID = primaryID; marker = marker; data = data.data}]);
                    if(bCertify == true){
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(?currentList, #dataIncluded(data)){
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
                                    data = data.data
                                };
                            };

                        } else {
                            //Debug.print("bIn is true inserting one back");
                            return currentList[idx - 1];
                        };
                    });
                    Debug.print("inserting new array" # debug_show(newArray.size()));
                    namespaceMap.put(namespaceHash, newArray);
                    if(bCertify == true){
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(_,_){
                    return Prelude.nyi();
                }
            };

            return marker;

        };


        public func writeAndIndex(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool, index: [MetaTreeIndex]) : async Nat{
            //todo: write to metatree service
            switch(dataConfig){
                case(#dataIncluded(data)){
                    let marker  = await write(namespace, primaryID, dataConfig, bCertify);
                    Debug.print(
                        "wrote initial item to log...now doing index"
                    );

                    for(thisIndex in index.vals()){
                        Debug.print(debug_show(thisIndex));
                        let metaData = calcIndexMeta(thisIndex, data.data);
                        let newNamespace = thisIndex.namespace # ".__index." # metaData.postFix;
                        //not currently awaiting the markers.
                        //todo: need to change to writing a pointer to original data...or maybe it is an index config
                        //todo: inspect the index to see if it needs to be cerified
                        let aMarker = write(newNamespace, metaData.primaryID, dataConfig, false);
                    };
                    return marker;
                };
                case(_){
                    return Prelude.nyi();
                };
            };

        };




        public func replace(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool) : async Nat{
            //todo: write to metatree service
            let marker = 1; //we use 1 with replace because it is always unique
            Debug.print("in replace " # namespace # debug_show(primaryID));
            let namespaceHash = TrixTypes.bytesToNat(SHA256.sha256(TrixTypes.textToBytes(namespace)));
            Debug.print("namespaceHash" # debug_show(namespaceHash));

            //var currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            switch(dataConfig){
                case(#dataIncluded(data)){
                    Debug.print(debug_show(data));
                    Debug.print("namespace " # namespace);
                    namespaceMap.put(namespaceHash, [{primaryID = primaryID; marker = marker; data = data.data}]);
                    //todo: need to remove indexes where this item is pointed to
                    if(bCertify == true){
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(_){
                    Debug.print("NYI");
                    return Prelude.nyi();
                };
            };


            return marker;

        };

        public func replaceAndIndex(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool, index: [MetaTreeIndex]) : async Nat{
            //todo: write to metatree service
            switch(dataConfig){
                case(#dataIncluded(data)){
                    let marker  = await replace(namespace, primaryID, dataConfig, bCertify);
                    Debug.print(
                        "wrote initial item to log...now doing index"
                    );

                    for(thisIndex in index.vals()){
                        Debug.print(debug_show(thisIndex));
                        let metaData = calcIndexMeta(thisIndex, data.data);
                        let newNamespace = thisIndex.namespace # ".__index." # metaData.postFix;
                        //not currently awaiting the markers.
                        //todo: need to erase old index
                        //todo: need to add pointers to original data instead
                        let aMarker = replace(newNamespace, metaData.primaryID, dataConfig, false);
                    };
                    return marker;
                };
                case(_){
                    Prelude.nyi()
                }
            };

        };

        public func __resetTest() : async Bool{
            //todo: restrict to controller
            namespaceMap := HashMap.HashMap<Nat,[Entry]>(1, Nat.equal, bigNatToNat32);
            certifiedTree := MerkleTree.empty();

            return true;

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



        public func read(namespace : Text) :  ReadResponse{
            return  readFilterPage(namespace, null, null, 0, 0);
        };

        public func readPage(namespace : Text, lastID : Nat, lastMarker : Nat) :  ReadResponse{
            return  readFilterPage(namespace, null, null, lastID, lastMarker);
        };

        public func readFilter(namespace : Text, minID : ?Nat, maxID : ?Nat) :  ReadResponse{
            return  readFilterPage(namespace, minID, maxID, 0, 0);
        };

        public func readUnique(namespace : Text, primaryID : Nat) :  ReadResponse{
            return  readFilterPage(namespace, null, null, 0, 0);
        };

        public func readFilterPage(namespace : Text, minID : ?Nat, maxID : ?Nat, lastID : Nat, lastMarker: Nat) : ReadResponse {

            let namespaceHash = TrixTypes.bytesToNat(SHA256.sha256(TrixTypes.textToBytes(namespace)));
            Debug.print("getting logs for hash " # debug_show(namespaceHash) # " " # namespace);
            //todo: makesure there isn't a pointer to another canister

            let currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            //Debug.print("found a List");
            switch(currentList){
                case(null){
                    Debug.print("no logs");
                    return #data({
                        data = [];
                        lastID = null;
                        lastMarker = null;
                    });
                };
                case(?currentList){
                    //todo: this wont work for large lists
                    Debug.print("logs exist" # debug_show(currentList));
                    var resultSize = 0;
                    let responseBuffer = Buffer.Buffer<Entry>(16);
                    if(currentList.size() == 0){
                        Debug.print("no logs size");
                        return #data({
                        data = [];
                        lastID = null;
                        lastMarker = null;
                        });
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
                            Debug.print("no min max");
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
                            Debug.print("min no max");
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
                            Debug.print("min and max");
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

                    return #data({
                        data = responseBuffer.toArray();
                        lastID = ?lastItem.primaryID;
                        lastMarker = ?lastItem.marker;
                    });

                };
            };
        }

        //todo: US 6; handle upgrades
    };



};