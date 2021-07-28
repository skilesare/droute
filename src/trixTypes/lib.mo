///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import String "mo:base/Text";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Char "mo:base/Char";
import Blob "mo:base/Blob";


module {

    //a data chunk should be no larger than 2MB so that it can be
    public type DataChunk = Buffer.Buffer<Nat8>;
    public type DataZone = Buffer.Buffer<DataChunk>;
    public type Workspace = Buffer.Buffer<DataZone>;

    public type AddressedChunk = (Nat, Nat, [Nat8]);

    public type AddressedChunkArray = [(Nat, Nat, [Nat8])];

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

    //creates a buffer of type Nat8 from an array of Nat8
    public func toBufferNat8(x : [Nat8]) : Buffer.Buffer<Nat8> {
        let theBuffer = Buffer.Buffer<Nat8>(x.size());
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

    public func principalToBytes(_principal: Principal.Principal) : [Nat8]{
        return textToBytes(Principal.toText(_principal));
    };

    //todo: this should go to Blob once they add Principal.fromBlob
    public func bytesToPrincipal(_bytes: [Nat8]) : Principal.Principal{
        return Principal.fromText(bytesToText(_bytes));
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

    public func workspaceToAddressedChunkArray(x : Workspace) : AddressedChunkArray {
        var currentZone = 0;
        var currentChunk = 0;
        let result = Array.tabulate<AddressedChunk>(countAddressedChunksInWorkspace(x), func(thisChunk){
            let thisChunk = (currentZone, currentChunk, x.get(currentZone).get(currentChunk).toArray());
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
                thisZone.put(thisChunk.1, toBufferNat8(thisChunk.2));
            } else {
                //append zone

                for (newChunk in Iter.range(thisZone.size(), thisChunk.1)){
                    Debug.print("growing chunk by 1 " # debug_show(newChunk) # " " # debug_show(thisChunk.1) ) ;
                    let newBuffer = if(thisChunk.1 == newChunk){
                        //we know the size
                            //Debug.print("calling to buffer " # debug_show(thisChunk.2));
                            toBufferNat8(thisChunk.2);
                        } else {
                            Buffer.Buffer<Nat8>(1)
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
        for(thisZone in dz.vals()){
            size += thisZone.size();
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
                    if(foundBytes + thisItem.size() > _maxChunkSize)
                    {
                        //Debug.print("went over bytes");

                        currentChunk += 1;
                        zoneTracker := thisZone;
                        chunkTracker := thisChunk;
                        //Debug.print("setting new vars" # " " # debug_show(currentChunk) # " " # debug_show(zoneTracker) # " " # debug_show(chunkTracker));
                        continue chunking;
                    };
                    //Debug.print("adding some bytes");
                    foundBytes += thisItem.size();
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
                    Debug.print("size " # debug_show(thisItem.size()) # " " # debug_show(_maxChunkSize)# " " # debug_show(foundBytes)) ;
                    if(foundBytes + thisItem.size() > _maxChunkSize)
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
                        resultBuffer.add((thisZone, thisChunk, thisItem.toArray()));

                    };
                    //Debug.print("adding some bytes");
                    foundBytes += thisItem.size();
                };
            };
            Debug.print("got to end");
            return (#eof, resultBuffer);
        };
        //todo: throw error
        return (#eof, resultBuffer);
    };



};