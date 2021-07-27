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
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat16 "mo:base/Nat16";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import DRouteTypes "../dRouteTypes/lib";
import TrixTypes "../trixTypes/lib";


module {

    public func createEvent(_eventType : Text, _source : Principal, _data : TrixTypes.Workspace) : DRouteTypes.DRouteEvent{
        let result : DRouteTypes.DRouteEvent = {
            eventType = _eventType;
            source = _source;
            data = _data;
          };
        return result;

    };

    public func toStableEvent(_event : DRouteTypes.DRouteEvent) : TrixTypes.AddressedChunkArray{
        let fullBuffer : TrixTypes.AddressedChunkBuffer = Buffer.Buffer<TrixTypes.AddressedChunk>(_event.data.size()+2);
        let textBytes : [Nat8] = TrixTypes.textToBytes(_event.eventType);
        let principalBytes = TrixTypes.principalToBytes(_event.source);
        fullBuffer.add((0: Nat,0: Nat, textBytes));
        fullBuffer.add((1: Nat,0: Nat, principalBytes));

        var zoneTracker : Nat = 2;
        for(thisZone : TrixTypes.DataZone in _event.data.vals()){
          var chunkTracker : Nat = 0;
          for(thisChunk : TrixTypes.DataChunk in thisZone.vals()){
            fullBuffer.add((zoneTracker, chunkTracker, thisChunk.toArray()));
            chunkTracker += 1;
          };
          zoneTracker += 1;
        };

        return fullBuffer.toArray();

    }




};