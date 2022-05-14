import PipelinifyTypes "mo:pipelinify/types";

module {

    public type DRoutePublisherInitArgs = {
        #StartUp: { //used when the actor is created
            reg_canister: Principal;
            self: Principal;
            onEventPublished: ?((EventInstance) -> ());
        };
        #Rehydrate: {  //used during an upgrade to pickup where the class left off
            reg_canister: Principal; 
            self: Principal;
            pending_publish: [(Blob, EventInstance)];
            onEventPublished: ?((EventInstance) -> ());
        };
    };

    public type EventPublishable = {
        eventType: Text;
        userID: Principal;
        dataConfig: PipelinifyTypes.DataConfig;
    };

    public type EventInstance = {
        event_id : Blob;
        timestamp: Int;
        event: EventPublishable;
    };

    public type PublishStatus = {
        #recieved;
        #delivery_confirmation : {
            target : Principal;
        };
        #delivery_complete;
    };

    public type EventPublishConfirmationRequest = {
        event_id: Blob;
        caller: Principal;
        status: PublishStatus;
    };

    public type PublisherStable = {
        pending_publish: ?[(Blob, EventInstance)];
    };

    public type RegCanisterActor = actor{
        get_publishing_canisters_request_droute : (instances : Nat) -> ();
    };

    public type PublishingCanisterActor = actor {
        publish_event_droute : (EventPublishable) -> ();
    };

    public type PublisherCanisterActor = actor {
        get_publishing_canisters_confirm_droute : ([Principal]) -> ();
    };

    public type DRouteRegMetrics = {
        time : Int;
    };

    public type DRouteError = {
        number : Nat32; 
        text: Text; 
        error: Errors; 
        flag_point: Text; caller: ?Principal};

    public type Errors = {
        #nyi;
        #cannot_find_event_instance
    };

    public func errors(the_error : Errors, flag_point: Text, caller: ?Principal) : DRouteError {
        switch(the_error){
            
            //
            case(#nyi){
                return {
                    number = 0; 
                    text = "not yet implemented";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };
            case(#cannot_find_event_instance){
                return {
                    number = 1; 
                    text = "cannot find event instanced";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };

            

            
            
        };
    };

}