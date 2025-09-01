package discord;

/*
import cpp.Pointer;

@:include("cdiscord.h")
@:native("cdiscord")
enum abstract Discord_ActivityTypes(Int) {
    var Playing = 0;
    var Streaming = 1;
    var Listening = 2;
    var Watching = 3;
    var CustomStatus = 4;
    var Competing = 5;
    var HangStatus = 6;
    var forceint = 0x7FFFFFFF;
}

@:native("cdiscord")
enum abstract Discord_Client_Error(Int) {
    var Discord_Client_Error_None = 0;
    var Discord_Client_Error_ConnectionFailed = 1;
    var Discord_Client_Error_UnexpectedClose = 2;
    var Discord_Client_Error_ConnectionCanceled = 3;
    var Discord_Client_Error_forceint = 0x7FFFFFFF;
}

@:native("cdiscord::Discord_Client")
@:struct
extern class Discord_Client {
    public var opaque:cpp.Pointer<cpp.Void>;

    @:native("cdiscord::Discord_Client_Init")
    public function new():Void;

    @:native("cdiscord::Discord_Client_InitWithBases")
    public function initWithBases(apiBase:String, webBase:String):Void;

    @:native("cdiscord::Discord_Client_InitWithOptions")
    public function initWithOptions(options:Discord_ClientCreateOptions):Void;

    @:native("cdiscord::Discord_Client_Drop")
    public function drop():Void;

    @:native("cdiscord::Discord_Client_ErrorToString")
    public function errorToString(type:Discord_Client_Error, returnValue:String):Void;

    @:native("cdiscord::Discord_Client_GetApplicationId")
    public function getAppID(self:Discord_Client):cpp.UInt64;
}

@:native("cdiscord::Discord_ActivityInvite")
@:struct
extern class Discord_ActivityInvite {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ActivityAssets")
@:struct
extern class Discord_ActivityAssets {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ActivityTimestamps")
@:struct
extern class Discord_ActivityTimestamps {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ActivityParty")
@:struct
extern class Discord_ActivityParty {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ActivitySecrets")
@:struct
extern class Discord_ActivitySecrets {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ActivityButton")
@:struct
extern class Discord_ActivityButton {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_Activity")
@:struct
extern class Discord_Activity {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ClientResult")
@:struct
extern class Discord_ClientResult {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_AuthorizationCodeChallenge")
@:struct
extern class Discord_AuthorizationCodeChallenge {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_AuthorizationCodeVerifier")
@:struct
extern class Discord_AuthorizationCodeVerifier {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_AuthorizationArgs")
@:struct
extern class Discord_AuthorizationArgs {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_DeviceAuthorizationArgs")
@:struct
extern class Discord_DeviceAuthorizationArgs {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_VoiceStateHandle")
@:struct
extern class Discord_VoiceStateHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_VADThresholdSettings")
@:struct
extern class Discord_VADThresholdSettings {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_Call")
@:struct
extern class Discord_Call {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_CallInfoHandle")
@:struct
extern class Discord_CallInfoHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ChannelHandle")
@:struct
extern class Discord_ChannelHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_GuildMinimal")
@:struct
extern class Discord_GuildMinimal {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_GuildChannel")
@:struct
extern class Discord_GuildChannel {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_LinkedLobby")
@:struct
extern class Discord_LinkedLobby {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_LinkedChannel")
@:struct
extern class Discord_LinkedChannel {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_RelationshipHandle")
@:struct
extern class Discord_RelationshipHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_UserHandle")
@:struct
extern class Discord_UserHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_LobbyMemberHandle")
@:struct
extern class Discord_LobbyMemberHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_LobbyHandle")
@:struct
extern class Discord_LobbyHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_AdditionalContent")
@:struct
extern class Discord_AdditionalContent {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_MessageHandle")
@:struct
extern class Discord_MessageHandle {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_AudioDevice")
@:struct
extern class Discord_AudioDevice {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_ClientCreateOptions")
@:struct
extern class Discord_ClientCreateOptions {
    public var opaque:cpp.Pointer<cpp.Void>;
}

@:native("cdiscord::Discord_UserMessageSummary")
@:struct
extern class Discord_UserMessageSummary {
    public var opaque:cpp.Pointer<cpp.Void>;
}
*/