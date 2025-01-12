import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";

import Types "Types";
import Utils "Utils";

actor class CtrlbCanister() {

    // Orthogonal Persisted Data storage

    // Save latest story that was generated for each storyID
    private var latestStoryOutputRecordResult = HashMap.HashMap<Types.StoryID, Types.StoryOutputRecordResult>(0, Text.equal, Text.hash);

    // Save what LLM is being used for this StoryID
    private var llmUsedByStoryID = HashMap.HashMap<Types.StoryID, Types.LLMCanister>(0, Text.equal, Text.hash);

    // For debug purposes, save latest story that was generated by this canister
    // private var latestStoryOutputRecordResult : Types.StoryOutputRecordResult = #Ok({
    //     storyID = "";
    //     storyPrompt = "";
    //     story = "";
    // });

    // Round-robin load balancer for LLM canisters to call
    private var roundRobinIndex : Nat = 0;
    private var roundRobinUseAll : Bool = true;
    private var roundRobinLLMs : Nat = 0; // Only used when roundRobinUseAll is false

    // Generate the array of values from 0 to 100000 in steps of 11
    let seedValues: [Nat64] = Array.tabulate(100000, func(index: Nat) : Nat64 {
        return Nat64.fromNat(index * 11);
    });

    // Variable to track the current index
    var currentSeedIndex: Nat = 0;

    // Function to get the next rng_seed
    private func getNextRngSeed(): Nat64 {
        let seed = seedValues[currentSeedIndex];
        // Update the index to the next value, cycling back to 0
        currentSeedIndex := (currentSeedIndex + 1) % seedValues.size();
        return seed;
    };

    // The llmCanisterIDs this ctrlb_canister can call
    private var llmCanisterIDs : Buffer.Buffer<Text> = Buffer.fromArray<Text>([]);

    // whitelisted principals to update NFTs
    private var whitelistedPrincipals : Buffer.Buffer<Principal> = Buffer.fromArray<Principal>([]);

    // -------------------------------------------------------------------------------
    // The C++ LLM canisters that can be called

    private var llmCanisters : Buffer.Buffer<Types.LLMCanister> = Buffer.fromArray([]);

    // Resets llmCanisterIDs, and then adds the argument as the first llmCanisterId
    public shared (msg) func set_llm_canister_id(llmCanisterIdRecord : Types.CanisterIDRecord) : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        llmCanisterIDs.clear();
        _add_llm_canister_id(llmCanisterIdRecord);
    };

    // Adds another llmCanisterIDs
    public shared (msg) func add_llm_canister_id(llmCanisterIdRecord : Types.CanisterIDRecord) : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        _add_llm_canister_id(llmCanisterIdRecord);
    };

    // Resets llmCanisterIDs, and then adds the argument as the first llmCanisterId
    private func _add_llm_canister_id(llmCanisterIdRecord : Types.CanisterIDRecord) : Types.StatusCodeRecordResult {
        let llmCanister = actor (llmCanisterIdRecord.canister_id) : Types.LLMCanister;
        D.print("Inside function _add_llm_canister_id. Adding llm: " # Principal.toText(Principal.fromActor(llmCanister)));
        llmCanisters.add(llmCanister);

        // Print content of the llmCanisters Buffer:
        D.print("Content of llmCanisters after addition: ");
        Buffer.iterate(
            llmCanisters,
            func(canister : Types.LLMCanister) : () {
                D.print("Canister ID: " # Principal.toText(Principal.fromActor(canister)));
            },
        );
        return #Ok({ status_code = 200 });
    };

    public shared query (msg) func WhitelistedPrincipals() : async [Principal] {
        assert Principal.isController(msg.caller);
        Buffer.toArray(whitelistedPrincipals);
    };

    public shared query (msg) func whoami() : async Principal {
        return msg.caller;
    };

    // Function to verify that canister is up & running
    public shared query func health() : async Types.StatusCodeRecordResult {
        return #Ok({ status_code = 200 });
    };

    // Function to verify that canister is ready for inference
    public shared func ready() : async Types.StatusCodeRecordResult {
        for (llmCanister in llmCanisters.vals()) {
            try {
                let statusCodeRecordResult : Types.StatusCodeRecordResult = await llmCanister.ready();
                switch (statusCodeRecordResult) {
                    case (#Err(_)) { return statusCodeRecordResult };
                    case (_) {
                        // If it's not an error, do nothing and continue the loop
                    };
                };
            } catch (_) {
                // Handle errors, such as llm canister not responding
                return #Err(#Other("Failed to call ready endpoint of llm canister = " # Principal.toText(Principal.fromActor(llmCanister))));
            };
        };
        return #Ok({ status_code = 200 });
    };

    // Admin function to verify that caller is a controller of this canister
    public shared query (msg) func amiController() : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        return #Ok({ status_code = 200 });
    };

    // Admin function to whitelist a principal for updating the NFTs by their token_id
    // (-) The bioniq launch canister must be whitelisted.
    public shared (msg) func whitelistPrincipal(principal : Principal) : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        whitelistedPrincipals.add(principal);
        return #Ok({ status_code = 200 });
    };

    // Admin function to verify that caller is whitelisted in this canister
    public shared query (msg) func amiWhitelisted() : async Types.StatusCodeRecordResult {
        if (not isWhitelisted(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        return #Ok({ status_code = 200 });
    };

    // Admin function to verify that ctrlb_canister is whitelisted in the llm canister
    public shared (msg) func isWhitelistLogicOk() : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };

        // Call all the llm canisters to verify that ctrlb_canister is whitelisted
        for (llmCanister in llmCanisters.vals()) {
            try {
                let statusCodeRecordResult : Types.StatusCodeRecordResult = await llmCanister.nft_ami_whitelisted();
                switch (statusCodeRecordResult) {
                    case (#Err(_)) { return statusCodeRecordResult };
                    case (_) {
                        // If it's not an error, do nothing and continue the loop
                    };
                };
            } catch (_) {
                // Handle errors, such as llm canister not responding
                return #Err(#Other("Failed to retrieve whitelist info for llm canister = " # Principal.toText(Principal.fromActor(llmCanister))));
            };
        };
        return #Ok({ status_code = 200 });
    };

    // Helper function to check if a principal is whitelisted
    private func isWhitelisted(principal : Principal) : Bool {
        return Principal.isController(principal) or Buffer.contains<Principal>(whitelistedPrincipals, principal, Principal.equal);
    };

    // Admin function to set roundRobinLLMs
    public shared (msg) func setRoundRobinLLMs(_roundRobinLLMs : Nat) : async Types.StatusCodeRecordResult {
        if (not Principal.isController(msg.caller)) {
            return #Err(#StatusCode(401));
        };
        roundRobinUseAll := false;
        roundRobinLLMs := _roundRobinLLMs;
        roundRobinIndex := 0;

        return #Ok({ status_code = 200 });
    };

    // Endpoint to be called by bioniq's NFT collection canister to update a story
    // https://docs.google.com/presentation/d/1HCDdmEik3-NH6peSxlbiE0VKjTBIo3KzNlXqqs3coZM/edit#slide=id.p
    public shared (msg) func StoryUpdate(storyInputRecord: Types.StoryInputRecord) : async Types.StoryOutputRecordResult {
        if (not isWhitelisted(msg.caller)) {
            return #Err(#StatusCode(401));
        };

        let storyID : Types.StoryID = storyInputRecord.storyID; 
        let storyPrompt : Text = storyInputRecord.storyPrompt;

        let rng_seed = getNextRngSeed();
        let startPrompt : Types.Prompt = {
            prompt = storyPrompt;
            steps = 60;
            temperature = 0.1;
            topp = 0.9;
            rng_seed = rng_seed;
        };

        let llmCanister = _getRoundRobinCanister();
        llmUsedByStoryID.put(storyID, llmCanister);

        // Reset the latestStoryOutputRecordResult for this storyID
        var storyOutputRecordResult : Types.StoryOutputRecordResult = #Ok({
            storyID = storyID;
            storyPrompt = storyPrompt;
            story = "";
            status = "generating";
            llmCanisterID = Principal.toText(Principal.fromActor(llmCanister));
        });
        latestStoryOutputRecordResult.put(storyID, storyOutputRecordResult);

        storyOutputRecordResult := await StoryUpdateDoIt_(llmCanister, storyID, startPrompt);

        latestStoryOutputRecordResult.put(storyID, storyOutputRecordResult);

        return storyOutputRecordResult;
    };

    public shared query (msg) func StoryGet(storyInputRecord: Types.StoryInputRecord) : async Types.StoryOutputRecordResult {
        if (not isWhitelisted(msg.caller)) {
            return #Err(#StatusCode(401));
        };

        let storyID : Types.StoryID = storyInputRecord.storyID; 
        let storyPrompt : Text = storyInputRecord.storyPrompt;

        var storyOutputRecordResult : Types.StoryOutputRecordResult = #Ok({
            storyID = storyID;
            storyPrompt = storyPrompt;
            story = "";
            status = "unknown";
            llmCanisterID = "";
        });

        let maybeLatestStoryOutputRecordResult = latestStoryOutputRecordResult.get(storyID);
        switch (maybeLatestStoryOutputRecordResult) {
            case (null) {
                return #Err(
                    #Other(
                        "storyID " # storyID # " does not yet exist."
                    )
                );
            };
            case (?v) {
                storyOutputRecordResult := v;
                return storyOutputRecordResult;
            };
        };
    };

    public shared query func getRoundRobinCanister() : async Types.CanisterIDRecordResult {
        let canisterIDRecord : Types.CanisterIDRecord = {
            canister_id = Principal.toText(Principal.fromActor(_getRoundRobinCanister()));
        };
        return #Ok(canisterIDRecord);
    };

    private func _getRoundRobinCanister() : Types.LLMCanister {
        D.print("_getRoundRobinCanister: using roundRobinIndex " # Nat.toText(roundRobinIndex));
        let canister = llmCanisters.get(roundRobinIndex);
        roundRobinIndex += 1;

        var roundRobinIndexTurn = llmCanisters.size();
        if (roundRobinUseAll == false) {
            roundRobinIndexTurn := Utils.minNat(roundRobinIndexTurn, roundRobinLLMs);
        };

        if (roundRobinIndex >= roundRobinIndexTurn) {
            roundRobinIndex := 0;
        };

        return canister;
    };

    private func StoryUpdateDoIt_(llmCanister: Types.LLMCanister , storyID : Types.StoryID, startPrompt : Types.Prompt) : async Types.StoryOutputRecordResult {
        D.print("Inside function StoryUpdateDoIt_. llmCanister = " # Principal.toText(Principal.fromActor(llmCanister)));

        // The llama2_c canisters refers to each story as an NFT with a token_id
        let myNFT: Types.NFT_llama2_c = {
            token_id = storyID;
        };

        // Start a new story for this nft
        var story : Text = "";
        var story_num_tokens : Nat64 = 0;
        var num_update_calls : Nat64 = 0;
        try {
            D.print("---ctrlb_canister---");
            D.print("calling nft_story_start_mo with : ");
            D.print("myNFT       : " # debug_show (myNFT));
            D.print("startPrompt : " # debug_show (startPrompt));
            num_update_calls += 1;
            let inferenceRecordResult : Types.InferenceRecordResult = await llmCanister.nft_story_start_mo(myNFT, startPrompt);
            D.print("---ctrlb_canister---");
            D.print("returned from nft_story_start_mo with : ");
            D.print("inferenceRecordResult: " # debug_show (inferenceRecordResult));

            switch (inferenceRecordResult) {
                case (#Err(error)) {
                    return #Err(error);
                };
                case (#Ok(inferenceRecord)) {
                    // the generated tokens
                    let inference : Text = inferenceRecord.inference;
                    let inference_num_tokens : Nat64 = inferenceRecord.num_tokens;
                    story := inference;
                    story_num_tokens += inference_num_tokens;
                    D.print("story" # debug_show (story));
                    D.print("story_num_tokens" # debug_show (story_num_tokens));
                };
            };
        } catch (error : Error) {
            // Handle errors, such as llm canister not responding
            D.print("---ctrlb_canister---");
            D.print("catch error when nft_story_start : ");
            D.print("error: " # Error.message(error));
            return #Err(
                #Other(
                    "Failed call to nft_story_start_mo of " # Principal.toText(Principal.fromActor(llmCanister)) #
                    " with error: " # Error.message(error)
                )
            );
        };

        // Continue the story for this nft, until it returns an empty string
        // Avoid endless loop by limiting the number of iterations
        let continuePrompt : Types.Prompt = {
            prompt : Text = "";
            steps : Nat64 = startPrompt.steps;
            temperature : Float = startPrompt.temperature;
            topp : Float = startPrompt.topp;
            rng_seed : Nat64 = startPrompt.rng_seed;
        };
        var continueLoopCount : Nat = 0;
        label continueLoop while (continueLoopCount < 30) {
            try {
                D.print("---ctrlb_canister---");
                D.print("calling nft_story_continue_mo with : ");
                D.print("myNFT         : " # debug_show (myNFT));
                D.print("continuePrompt : " # debug_show (continuePrompt));
                num_update_calls += 1;
                let inferenceRecordResult : Types.InferenceRecordResult = await llmCanister.nft_story_continue_mo(myNFT, continuePrompt);
                D.print("---ctrlb_canister---");
                D.print("returned nft_story_continue_mo with : ");
                D.print("inferenceRecordResult: " # debug_show (inferenceRecordResult));

                switch (inferenceRecordResult) {
                    case (#Err(error)) {
                        return #Err(error);
                    };
                    case (#Ok(inferenceRecord)) {
                        // the generated tokens
                        let inference : Text = inferenceRecord.inference;
                        let inference_num_tokens : Nat64 = inferenceRecord.num_tokens;
                        // D.print("inference :" # debug_show (inference));
                        // D.print("inference_num_tokens :" # Nat64.toText(inference_num_tokens));

                        story := story # inference;
                        story_num_tokens += inference_num_tokens;
                        // D.print("story" # debug_show (story));
                        // D.print("story_num_tokens" # debug_show (story_num_tokens));

                        if (inference_num_tokens < continuePrompt.steps) {
                            break continueLoop; // Exit the loop because the LLM is done. It will only predict "" from now on.
                        };
                    };
                };
            } catch (error : Error) {
                // Handle errors, such as llm_0 not responding
                D.print("---ctrlb_canister---");
                D.print("catch error when nft_story_start : ");
                D.print("error: " # Error.message(error));
                return #Err(
                    #Other(
                        "Failed call to nft_story_start of " # Principal.toText(Principal.fromActor(llmCanister)) #
                        " with error: " # Error.message(error)
                    )
                );
            };
            continueLoopCount += 1;
        };

        // Delete the story in the LLM for this nft
        try {
            D.print("---ctrlb_canister---");
            D.print("calling nft_story_delete with : ");
            D.print("myNFT       : " # debug_show (myNFT));
            let statusCodeRecordResult : Types.StatusCodeRecordResult = await llmCanister.nft_story_delete(myNFT);
            D.print("---ctrlb_canister---");
            D.print("returned from nft_story_delete with : ");
            D.print("statusCodeRecordResult: " # debug_show (statusCodeRecordResult));

        } catch (error : Error) {
            // Handle errors, such as llm canister not responding
            D.print("---ctrlb_canister---");
            D.print("catch error when nft_story_start : ");
            D.print("error: " # Error.message(error));
            return #Err(
                #Other(
                    "Failed call to nft_story_start_mo of " # Principal.toText(Principal.fromActor(llmCanister)) #
                    " with error: " # Error.message(error)
                )
            );
        };


        // Return the story as a StoryOutputRecordResult
        let storyOutputRecord : Types.StoryOutputRecord = {
            storyID = storyID;
            storyPrompt = startPrompt.prompt;
            story = story;
            status = "done";
            llmCanisterID = Principal.toText(Principal.fromActor(llmCanister));
        };
        return #Ok(storyOutputRecord);
    };
};
