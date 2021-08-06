///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import MerkleTree "../dRouteUtilities/MerkleTree";
import MetaTree "../metatree/lib";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import PipelinifyTypes "mo:pipelinify/pipelinify/PipelinifyTypes";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrixTypes "../trixTypes";


module {

    public type GetWitnessRequest = {
        principal: Principal.Principal;
    };

    public type GetWitnessResponse = {
        #noRecord;
    };


    ////////////////////////
    //
    // Errors
    //
    // Subscriptions
    // 1 - No valid destinations in DestinationSet


};
