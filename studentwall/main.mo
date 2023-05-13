import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Order "mo:base/Order";
import Int "mo:base/Int";

actor class StudentWall() {

    type Message = Type.Message;
    type Content = Type.Content;
    type Survey = Type.Survey;
    type Answer = Type.Answer;

    var messageId : Nat = 0;

    var wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, Hash.hash);

    // Add a new message to the wall
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        //1. Auth

        //2. prepare Data
        let id : Nat = messageId;
        messageId := messageId + 1;
        let newMessage : Message = {
            content = c;
            vote = 0;
            creator = caller;
        };

        //3. Create Message.
        wall.put(id, newMessage);

        //4. Return confirmation
        return id;
    };

    // Get a specific message by ID
    public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        //1. Auth

        //2. Query Data
        let messageIdResult = wall.get(messageId);

        //3. Return Messages or Null
        switch (messageIdResult) {
            case (null) {
                return #err("Message not found");
            };
            case (?ok) {
                return #ok(ok);
            };
        };
    };

    // Update the content for a specific message by ID
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {

        //1. auth

        //2. query data.
        let messageIdResult = wall.get(messageId);

        //3. validate if exists
        switch (messageIdResult) {
            case (null) {
                return #err("Message not found");
            };
            case (?ok) {
                //4. update new message data
                let updatedMessage : Message = {
                    content = c;
                    vote = ok.vote;
                    creator = caller;
                };
                //5. update message
                wall.put(messageId, updatedMessage);
                //6. return success
                return #ok(());
            };
        };

    };

    // Delete a specific message by ID
    public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        //1. auth
        //2. query data
        let messageIdResult = wall.get(messageId);
        //3. validate if exists
        switch (messageIdResult) {
            case (null) {
                return #err("Message not found");
            };
            case (?ok) {
                let deletedMessage = wall.remove(messageId);
                return #ok(());
            };
        };
    };

    // Voting
    public func upVote(messageId : Nat) : async Result.Result<(), Text> {
        //1. auth
        //2. query data
        let messageIdResult = wall.get(messageId);
        //3. validate if exists
        switch (messageIdResult) {
            case (null) {
                return #err("Message not found");
            };
            case (?ok) {
                let voteUp : Message = {
                    content = ok.content;
                    vote = ok.vote + 1;
                    creator = ok.creator;
                };
                wall.put(messageId, voteUp);
                return #ok(());
            };
        };
    };

    public func downVote(messageId : Nat) : async Result.Result<(), Text> {
        //1. auth
        //2. query data
        let messageIdResult = wall.get(messageId);
        //3. validate if exists
        switch (messageIdResult) {
            case (null) {
                return #err("Message not found");
            };
            case (?ok) {
                let voteDown : Message = {
                    content = ok.content;
                    vote = ok.vote - 1;
                    creator = ok.creator;
                };
                wall.put(messageId, voteDown);
                return #ok(());
            };
        };
    };

    // Get all messages
    public func getAllMessages() : async [Message] {
        var messages = Buffer.Buffer<Message>(0);

        for (message in wall.vals()) {
            messages.add(message);
        };

        return Buffer.toArray(messages);
    };

    // Get all messages ordered by votes
    public func getAllMessagesRanked() : async [Message] {
        var messages = Buffer.Buffer<Message>(0);

        func compare(messageA : Message , messageB : Message) : Order.Order{
            switch(Int.compare(messageA.vote , messageB.vote)){
                case (#greater){
                    return #less;
                };
                case(#less){
                    return #greater;
                };
                case(_){
                    return #equal
                }
            }
        };
        for (message in wall.vals()) {
            messages.add(message);

        };

        messages.sort(compare);

        return Buffer.toArray(messages);
    };
};
