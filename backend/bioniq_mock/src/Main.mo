// import Array "mo:base/Array";
// import Buffer "mo:base/Buffer";
// import D "mo:base/Debug";
// import Error "mo:base/Error";
import Principal "mo:base/Principal";
// import Text "mo:base/Text";
// import Nat "mo:base/Nat";
// import Nat64 "mo:base/Nat64";
// import Bool "mo:base/Bool";

import Types "Types";
// import Utils "Utils";

actor class BioniqMock() {

    // The Charles ctrlb_canister

    // Development version on subnet jtdsg-3h6gi-hs7o5-z2soi-43w3z-soyl3-ajnp3-ekni5-sw553-5kw67-nqe
    private var charlesCtrlbCanister = actor ("6t3lq-3aaaa-aaaaj-qnfyq-cai") : Types.CharlesCtrlbCanister;

    // Function to verify that canister is up & running
    public shared func health() : async Types.StatusCodeRecordResult {
        return #Ok({ status_code = 200 });
    };

    // Admin function to verify that caller is a controller of this canister
    public shared (msg) func amiController() : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        return #Ok({ status_code = 200 });
    };

    // Admin function to verify the bioniq canister id's principal as the llm ctrlb_canister receives it
    public shared (msg) func whoamiToCharles() : async Principal {
        assert Principal.isController(msg.caller);

        
        let principal : Principal = await charlesCtrlbCanister.whoami();
        return principal;
    };

    // Admin function to verify that bioniq canister is whitelisted in the llm ctrlb_canister
    public shared (msg) func isWhitelistLogicOk() : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };

        try {
            let statusCodeRecordResult : Types.StatusCodeRecordResult = await charlesCtrlbCanister.amiWhitelisted();
            switch (statusCodeRecordResult) {
                case (#Err(_)) { return statusCodeRecordResult };
                case (_) {
                    // If it's not an error, do nothing
                };
            };
        } catch (_) {
            // Handle errors, such as llm canister not responding
            return #Err(#Other("Failed to retrieve whitelist info for Charles ctrlb_canister = " # Principal.toText(Principal.fromActor(charlesCtrlbCanister))));
        };
        return #Ok({ status_code = 200 });
    };

    public shared (msg) func StoryUpdate(storyInputRecord: Types.StoryInputRecord) : async Types.StoryOutputRecordResult {
        // Protect it...
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };

        let storyOutputRecordResult = await charlesCtrlbCanister.StoryUpdate(storyInputRecord);
        return storyOutputRecordResult;
    };    
};
