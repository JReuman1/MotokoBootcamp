import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import IC "Ic";
import HTTP "Http";
import Type "Types";
import Calculator "Calculator";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  

  stable var students : [(Principal, StudentProfile)] = [];
  var studentsProfileStore = HashMap.fromIter<Principal, StudentProfile>(students.vals(), 0, Principal.equal, Principal.hash);

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {

    switch (Principal.isAnonymous(caller)) {
      case (false) {
        return #err("Your user is anonymous. You aren't allowed to create a profile here.");
      };
      case (true) {
        studentsProfileStore.put(caller, profile);
        return #ok;
      };
    };

  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    switch (studentsProfileStore.get(p)) {
      case (null) {
        return #err("Invalid principal key. Check your spelling.");
      };
      case (?ok) {
        return #ok(ok);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    switch (studentsProfileStore.get(caller)) {
      case (null) {
        return #err("Didn't find such profile.");
      };
      case (?ok) {
        let updatedProfile : StudentProfile = {
          name = ok.name;
          team = ok.team;
          graduate = ok.graduate;
        };
        studentsProfileStore.put(caller, profile);
        return #ok;
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    switch (studentsProfileStore.remove(caller)) {
      case (null) {
        return #err("Didn't find such profile.");
      };
      case (?ok) {
        return #ok;
      };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  public type CalculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let calculatorActor = await Calculator.Calculator();
    //let day5Actor = await Verifier();
    try {
      let result1 = await calculatorActor.add(1);
      if (result1 != 1) {
        return #err(#UnexpectedValue("Expected 1, got " # Int.toText(result1)));
      };
      let result2 = await calculatorActor.add(2);
      if (result2 != 3) {
        return #err(#UnexpectedValue("Expected 3, got " # Int.toText(result2)));
      };
      return #ok ();
    } catch (error : Error) {
    // Si ocurre algún error, devolver el mensaje de error como UnexpectedError
      return #err(#UnexpectedError(Error.message(error)));
    };
    };

  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  public func verifyOwnership(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    return #err("not implemented");
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  public type HttpRequest = HTTP.HttpRequest;
  public type HttpResponse = HTTP.HttpResponse;

  // NOTE: Not possible to develop locally,
  // as Timer is not running on a local replica
  public func activateGraduation() : async () {
    return ();
  };

  public func deactivateGraduation() : async () {
    return ();
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    return ({
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("");
      streaming_strategy = null;
    });
  };
  // STEP 5 - END

  system func preupgrade() {
    students := Iter.toArray(studentsProfileStore.entries());
  };

  system func postupgrade() {
    students := [];
  };
};
