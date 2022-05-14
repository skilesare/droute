import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Types "types";

shared (deployer) actor class  DRouteRegistration() = this {


    public shared(msg) func get_publishing_canisters_request_droute(instances : Nat) : () {
        //allocate the publishing canisters
        //one shot them back to the requestor
        let publisherActor : Types.PublisherCanisterActor = actor(Principal.toText(msg.caller));

        //for now we are just going to have the reg canister do everything
        let confirmAllocation = publisherActor.get_publishing_canisters_confirm_droute([Principal.fromActor(this)]);
    };

    public query(msg) func getMetrics_reg_droute() : async Types.DRouteRegMetrics{
        return {
            time = Time.now();
        };
    };

    public shared(msg) func getMetrics_reg_secure_droute() : async Types.DRouteRegMetrics{
        return {
            time = Time.now();
        };
    };

};