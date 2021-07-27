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
import TrixTypes "../trixTypes/lib";



module {

    public type DRouteEvent = {
        eventType : Text;
        source : Principal;
        data : TrixTypes.Workspace;
    };

    //field 0 : name - text
    //field 1 : source - principal
    //field n-2...data
    public type DRouteEventStable = [TrixTypes.AddressedChunk];

};