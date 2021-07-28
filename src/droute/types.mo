import Principal "mo:base/Principal";

module {

    //Types

    public type EventRegistration = {
        eventName: Text;
        validSources: {
            #whitelist: [Principal];
            #blacklist: [Principal];
            #dynamic: {
                canister: Text;
            };
        };
    };

    public type NamespaceRight = {
        namespace: Text;
        controllers: [Principal];
        authorized: [Principal];
    };


};
