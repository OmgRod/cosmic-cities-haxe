package discord;

/*
import cpp.Pointer;
import discord.CDiscord;

typedef ParticipantChangedCallback = (cpp.UInt64, Bool) -> Void;

@:include("discordpp.h")
@:native("discordpp")
extern class Discord {
    public static function RunCallbacks():Void;
    public static function ActivityActionTypes(value:ActivityActionTypes):String;
    public static function ActivityPartyPrivacy(value:ActivityPartyPrivacy):String;
    public static function ActivityTypes(value:ActivityTypes):String;
    public static function StatusDisplayTypes(value:StatusDisplayTypes):String;
    public static function ActivityGamePlatforms(value:ActivityGamePlatforms):String;
    public static function ErrorType(value:ErrorType):String;
    public static function HttpStatusCode(value:HttpStatusCode):String;
    public static function AuthenticationCodeChallengeMethod(value:AuthenticationCodeChallengeMethod):String;
    public static function IntegrationType(value:IntegrationType):String;
    public static function AdditionalContentType(value:AdditionalContentType):String;
    public static function AudioSystem(value:AudioSystem):String;
    public static function CallError(value:CallError):String;
    public static function AudioModeType(value:AudioModeType):String;
    public static function CallStatus(value:CallStatus):String;
    public static function ChannelType(value:ChannelType):String;
    public static function RelationshipType(value:RelationshipType):String;
    public static function UserAvatarType(value:AvatarType):String;
    public static function StatusType(value:StatusType):String;
    public static function DisclosureTypes(value:DisclosureTypes):String;
    public static function ClientError(value:Error):String;
    public static function ClientStatus(value:Status):String;
    public static function ClientThread(value:Thread):String;
    public static function AuthorizationTokenType(value:AuthorizationTokenType):String;
    public static function AuthenticationExternalAuthType(value:AuthenticationExternalAuthType):String;
    public static function LoggingSeverity(value:LoggingSeverity):String;
    public static function RelationshipGroupType(value:RelationshipGroupType):String;
}

// ------------------ ENUMS ------------------

@:native("discordpp::DiscordObjectState")
extern enum abstract DiscordObjectState(Int) {
    var Invalid;
    var Owned;
}

@:native("discordpp::ActivityActionTypes")
extern enum abstract ActivityActionTypes(Int) {
    var Join = 1;
    var JoinRequest = 5;
}

@:native("discordpp::ActivityPartyPrivacy")
extern enum abstract ActivityPartyPrivacy(Int) {
    var Private = 0;
    var Public = 1;
}

@:native("discordpp::ActivityTypes")
extern enum abstract ActivityTypes(Int) {
    var Playing = 0;
    var Streaming = 1;
    var Listening = 2;
    var Watching = 3;
    var CustomStatus = 4;
    var Competing = 5;
    var HangStatus = 6;
}

@:native("discordpp::StatusDisplayTypes")
extern enum abstract StatusDisplayTypes(Int) {
    var Name = 0;
    var State = 1;
    var Details = 2;
}

@:native("discordpp::ActivityGamePlatforms")
extern enum abstract ActivityGamePlatforms(Int) {
    var Desktop = 1;
    var Xbox = 2;
    var Samsung = 4;
    var IOS = 8;
    var Android = 16;
    var Embedded = 32;
    var PS4 = 64;
    var PS5 = 128;
}

@:native("discordpp::ErrorType")
extern enum abstract ErrorType(Int) {
    var None = 0;
    var NetworkError = 1;
    var HTTPError = 2;
    var ClientNotReady = 3;
    var Disabled = 4;
    var ClientDestroyed = 5;
    var ValidationError = 6;
    var Aborted = 7;
    var AuthorizationFailed = 8;
    var RPCError = 9;
}

@:native("discordpp::HttpStatusCode")
extern enum abstract HttpStatusCode(Int) {
    var None = 0;
    var Continue = 100;
    var SwitchingProtocols = 101;
    var Processing = 102;
    var EarlyHints = 103;
    var Ok = 200;
    var Created = 201;
    var Accepted = 202;
    var NonAuthoritativeInfo = 203;
    var NoContent = 204;
    var ResetContent = 205;
    var PartialContent = 206;
    var MultiStatus = 207;
    var AlreadyReported = 208;
    var ImUsed = 209;
    var MultipleChoices = 300;
    var MovedPermanently = 301;
    var Found = 302;
    var SeeOther = 303;
    var NotModified = 304;
    var TemporaryRedirect = 307;
    var PermanentRedirect = 308;
    var BadRequest = 400;
    var Unauthorized = 401;
    var PaymentRequired = 402;
    var Forbidden = 403;
    var NotFound = 404;
    var MethodNotAllowed = 405;
    var NotAcceptable = 406;
    var ProxyAuthRequired = 407;
    var RequestTimeout = 408;
    var Conflict = 409;
    var Gone = 410;
    var LengthRequired = 411;
    var PreconditionFailed = 412;
    var PayloadTooLarge = 413;
    var UriTooLong = 414;
    var UnsupportedMediaType = 415;
    var RangeNotSatisfiable = 416;
    var ExpectationFailed = 417;
    var MisdirectedRequest = 421;
    var UnprocessableEntity = 422;
    var Locked = 423;
    var FailedDependency = 424;
    var TooEarly = 425;
    var UpgradeRequired = 426;
    var PreconditionRequired = 428;
    var TooManyRequests = 429;
    var RequestHeaderFieldsTooLarge = 431;
    var InternalServerError = 500;
    var NotImplemented = 501;
    var BadGateway = 502;
    var ServiceUnavailable = 503;
    var GatewayTimeout = 504;
    var HttpVersionNotSupported = 505;
    var VariantAlsoNegotiates = 506;
    var InsufficientStorage = 507;
    var LoopDetected = 508;
    var NotExtended = 510;
    var NetworkAuthorizationRequired = 511;
}

@:native("discordpp::AuthenticationCodeChallengeMethod")
extern enum abstract AuthenticationCodeChallengeMethod(Int) {
    var S256 = 0;
}

@:native("discordpp::IntegrationType")
extern enum abstract IntegrationType(Int) {
    var GuildInstall = 0;
    var UserInstall = 1;
}

@:native("discordpp::AdditionalContentType")
extern enum abstract AdditionalContentType(Int) {
    var Other = 0;
    var Attachment = 1;
    var Poll = 2;
    var VoiceMessage = 3;
    var Thread = 4;
    var Embed = 5;
    var Sticker = 6;
}

@:native("discordpp::AudioSystem")
extern enum abstract AudioSystem(Int) {
    var Standard = 0;
    var Game = 1;
}

@:native("discordpp::AudioModeType")
extern enum abstract AudioModeType(Int) {
    var MODE_UNINIT = 0;
    var MODE_VAD = 1;
    var MODE_PTT = 2;
}

@:native("discordpp::ChannelType")
extern enum abstract ChannelType(Int) {
    var GuildText = 0;
    var Dm = 1;
    var GuildVoice = 2;
    var GroupDm = 3;
    var GuildCategory = 4;
    var GuildNews = 5;
    var GuildStore = 6;
    var GuildNewsThread = 10;
    var GuildPublicThread = 11;
    var GuildPrivateThread = 12;
    var GuildStageVoice = 13;
    var GuildDirectory = 14;
    var GuildForum = 15;
    var GuildMedia = 16;
    var Lobby = 17;
    var EphemeralDm = 18;
}

@:native("discordpp::RelationshipType")
extern enum abstract RelationshipType(Int) {
    var None = 0;
    var Friend = 1;
    var Blocked = 2;
    var PendingIncoming = 3;
    var PendingOutgoing = 4;
    var Implicit = 5;
    var Suggestion = 6;
}

@:native("discordpp::StatusType")
extern enum abstract StatusType(Int) {
    var Online = 0;
    var Offline = 1;
    var Blocked = 2;
    var Idle = 3;
    var Dnd = 4;
    var Invisible = 5;
    var Streaming = 6;
    var Unknown = 7;
}

@:native("discordpp::DisclosureTypes")
extern enum abstract DisclosureTypes(Int) {
    var MessageDataVisibleOnDiscord = 3;
}

@:native("discordpp::AuthorizationTokenType")
extern enum abstract AuthorizationTokenType(Int) {
    var User = 0;
    var Bearer = 1;
}

@:native("discordpp::AuthenticationExternalAuthType")
extern enum abstract AuthenticationExternalAuthType(Int) {
    var OIDC = 0;
    var EpicOnlineServicesAccessToken = 1;
    var EpicOnlineServicesIdToken = 2;
    var SteamSessionTicket = 3;
    var UnityServicesIdToken = 4;
}

@:native("discordpp::LoggingSeverity")
extern enum abstract LoggingSeverity(Int) {
    var Verbose = 1;
    var Info = 2;
    var Warning = 3;
    var Error = 4;
    var None = 5;
}

@:native("discordpp::RelationshipGroupType")
extern enum abstract RelationshipGroupType(Int) {
    var OnlinePlayingGame = 0;
    var OnlineElsewhere = 1;
    var Offline = 2;
}

// ------------------ CLASSES ------------------

@:native("discordpp::ActivityInvite")
extern class ActivityInvite {
    private var instance_:Discord_ActivityInvite;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ActivityInvite, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivityInvite>;
    public static var nullobj:ActivityInvite;
    public function explicit():Void;
    @:native("~ActivityInvite")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivityInvite):ActivityInvite;
    @:native("operator=")
    public function assignCopy(other:ActivityInvite):ActivityInvite;
    public function isValid():Bool;
    public function SenderId():cpp.UInt64;
    public function SetSenderId(SenderId:cpp.UInt64):Void;
    public function ChannelId():cpp.UInt64;
    public function SetChannelId(ChannelId:cpp.UInt64):Void;
    public function MessageId():cpp.UInt64;
    public function SetMessageId(MessageId:cpp.UInt64):Void;
    public function Type():ActivityActionTypes;
    public function SetType(Type:ActivityActionTypes):Void;
    public function ApplicationId():cpp.UInt64;
    public function SetApplicationId(ApplicationId:cpp.UInt64):Void;
    public function ParentApplicationId():cpp.UInt64;
    public function SetParentApplicationId(ParentApplicationId:cpp.UInt64):Void;
    public function PartyId():String;
    public function SetPartyId(PartyId:String):Void;
    public function SessionId():String;
    public function SetSessionId(SessionId:String):Void;
    public function IsValid():Bool;
    public function SetIsValid(IsValid:Bool):Void;
}

@:native("discordpp::ActivityAssets")
extern class ActivityAssets {
    private var instance_:Discord_ActivityAssets;
    private var state_:DiscordObjectState;

    public function new(instance:Discord_ActivityAssets, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivityAssets>;
    public static var nullobj:ActivityAssets;
    public function explicit():Void;
    @:native("~ActivityAssets")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivityAssets):ActivityAssets;
    @:native("operator=")
    public function assignCopy(other:ActivityAssets):ActivityAssets;
    public function isValid():Bool;
    public function LargeImage():String;
    public function SetLargeImage(value:String):Void;
    public function LargeText():String;
    public function SetLargeText(value:String):Void;
    public function LargeUrl():String;
    public function SetLargeUrl(value:String):Void;
    public function SmallImage():String;
    public function SetSmallImage(value:String):Void;
    public function SmallText():String;
    public function SetSmallText(value:String):Void;
    public function SmallUrl():String;
    public function SetSmallUrl(value:String):Void;
}

@:native("discordpp::ActivityTimestamps")
extern class ActivityTimestamps {
    private var instance_:Discord_ActivityTimestamps;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ActivityTimestamps, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivityTimestamps>;
    public static var nullobj:ActivityTimestamps;
    public function explicit():Void;
    @:native("~ActivityTimestamps")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivityTimestamps):ActivityTimestamps;
    @:native("operator=")
    public function assignCopy(other:ActivityTimestamps):ActivityTimestamps;
    public function isValid():Bool;
    public function Start():cpp.UInt64;
    public function SetStart(value:cpp.UInt64):Void;
    public function End():cpp.UInt64;
    public function SetEnd(value:cpp.UInt64):Void;
}

@:native("discordpp::ActivityParty")
extern class ActivityParty {
    private var instance_:Discord_ActivityParty;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ActivityParty, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivityParty>;
    public static var nullobj:ActivityParty;
    public function explicit():Void;
    @:native("~ActivityParty")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivityParty):ActivityParty;
    @:native("operator=")
    public function assignCopy(other:ActivityParty):ActivityParty;
    public function isValid():Bool;
    public function Id():String;
    public function SetId(Id:String):Void;
    public function CurrentSize():Int;
    public function SetCurrentSize(CurrentSize:Int):Void;
    public function MaxSize():Int;
    public function SetMaxSize(MaxSize:Int):Void;
    public function Privacy():ActivityPartyPrivacy;
    public function SetPrivacy(Privacy:ActivityPartyPrivacy):Void;
}

@:native("discordpp::ActivitySecrets")
extern class ActivitySecrets {
    private var instance_:Discord_ActivitySecrets;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ActivitySecrets, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivitySecrets>;
    public static var nullobj:ActivitySecrets;
    public function explicit():Void;
    @:native("~ActivitySecrets")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivitySecrets):ActivitySecrets;
    @:native("operator=")
    public function assignCopy(other:ActivitySecrets):ActivitySecrets;
    public function isValid():Bool;
    public function Join():String;
    public function SetJoin(Join:String):Void;
}

@:native("discordpp::ActivityButton")
extern class ActivityButton {
    private var instance_:Discord_ActivityButton;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ActivityButton, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ActivityButton>;
    public static var nullobj:ActivityButton;
    public function explicit():Void;
    @:native("~ActivityButton")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ActivityButton):ActivityButton;
    @:native("operator=")
    public function assignCopy(other:ActivityButton):ActivityButton;
    public function isValid():Bool;
    public function Label():String;
    public function SetLabel(Label:String):Void;
    public function Url():String;
    public function SetUrl(Url:String):Void;
}

@:native("discordpp::Activity")
extern class Activity {
    private var instance_:Discord_Activity;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_Activity, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_Activity>;
    public static var nullobj:Activity;
    public function explicit():Void;
    @:native("~Activity")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:Activity):Activity;
    @:native("operator=")
    public function assignCopy(other:Activity):Activity;
    public function isValid():Bool;
    public function AddButton(button:ActivityButton):Void;
    public function Equals(other:Activity):Bool;
    public function GetButtons():Array<ActivityButton>;
    public function Name():String;
    public function SetName(Name:String):Void;
    public function Type():ActivityTypes;
    public function SetType(Type:ActivityTypes):Void;
    public function StatusDisplayType():Null<StatusDisplayTypes>;
    public function SetStatusDisplayType(StatusDisplayType:Null<StatusDisplayTypes>):Void;
    public function State():Null<String>;
    public function SetState(State:Null<String>):Void;
    public function StateUrl():Null<String>;
    public function SetStateUrl(StateUrl:Null<String>):Void;
    public function Details():Null<String>;
    public function SetDetails(Details:Null<String>):Void;
    public function DetailsUrl():Null<String>;
    public function SetDetailsUrl(DetailsUrl:Null<String>):Void;
    public function ApplicationId():Null<cpp.UInt64>;
    public function SetApplicationId(ApplicationId:Null<cpp.UInt64>):Void;
    public function ParentApplicationId():Null<cpp.UInt64>;
    public function SetParentApplicationId(ParentApplicationId:Null<cpp.UInt64>):Void;
    public function Assets():Null<ActivityAssets>;
    public function SetAssets(Assets:Null<ActivityAssets>):Void;
    public function Timestamps():Null<ActivityTimestamps>;
    public function SetTimestamps(Timestamps:Null<ActivityTimestamps>):Void;
    public function Party():Null<ActivityParty>;
    public function SetParty(Party:Null<ActivityParty>):Void;
    public function Secrets():Null<ActivitySecrets>;
    public function SetSecrets(Secrets:Null<ActivitySecrets>):Void;
    public function SupportedPlatforms():ActivityGamePlatforms;
    public function SetSupportedPlatforms(SupportedPlatforms:ActivityGamePlatforms):Void;
}

@:native("discordpp::ClientResult")
extern class ClientResult {
    private var instance_:Discord_ClientResult;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ClientResult, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ClientResult>;
    public static var nullobj:ClientResult;
    public function explicit():Void;
    @:native("~ClientResult")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ClientResult):ClientResult;
    @:native("operator=")
    public function assignCopy(other:ClientResult):ClientResult;
    public function isValid():Bool;
    public function ToString():String;
    public function Type():ErrorType;
    public function SetType(Type:ErrorType):Void;
    public function Error():String;
    public function SetError(Error:String):Void;
    public function ErrorCode():Int;
    public function SetErrorCode(ErrorCode:Int):Void;
    public function Status():HttpStatusCode;
    public function SetStatus(Status:HttpStatusCode):Void;
    public function ResponseBody():String;
    public function SetResponseBody(ResponseBody:String):Void;
    public function Successful():Bool;
    public function SetSuccessful(Successful:Bool):Void;
    public function Retryable():Bool;
    public function SetRetryable(Retryable:Bool):Void;
    public function RetryAfter():Float;
    public function SetRetryAfter(RetryAfter:Float):Void;
}

@:native("discordpp::AuthorizationCodeChallenge")
extern class AuthorizationCodeChallenge {
    private var instance_:Discord_AuthorizationCodeChallenge;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_AuthorizationCodeChallenge, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_AuthorizationCodeChallenge>;
    public static var nullobj:AuthorizationCodeChallenge;
    public function explicit():Void;
    @:native("~AuthorizationCodeChallenge")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:AuthorizationCodeChallenge):AuthorizationCodeChallenge;
    @:native("operator=")
    public function assignCopy(other:AuthorizationCodeChallenge):AuthorizationCodeChallenge;
    public function isValid():Bool;
    public function Method():AuthenticationCodeChallengeMethod;
    public function SetMethod(Method:AuthenticationCodeChallengeMethod):Void;
    public function Challenge():String;
    public function SetChallenge(Challenge:String):Void;
}

@:native("discordpp::AuthorizationCodeVerifier")
extern class AuthorizationCodeVerifier {
    private var instance_:Discord_AuthorizationCodeVerifier;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_AuthorizationCodeVerifier, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_AuthorizationCodeVerifier>;
    public static var nullobj:AuthorizationCodeVerifier;
    public function explicit():Void;
    @:native("~AuthorizationCodeVerifier")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:AuthorizationCodeVerifier):AuthorizationCodeVerifier;
    @:native("operator=")
    public function assignCopy(other:AuthorizationCodeVerifier):AuthorizationCodeVerifier;
    public function isValid():Bool;
    public function Challenge():AuthorizationCodeChallenge;
    public function SetChallenge(Challenge:AuthorizationCodeChallenge):Void;
    public function Verifier():String;
    public function SetVerifier(Verifier:String):Void;
}

@:native("discordpp::AuthorizationArgs")
extern class AuthorizationArgs {
    private var instance_:Discord_AuthorizationArgs;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_AuthorizationArgs, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_AuthorizationArgs>;
    public static var nullobj:AuthorizationArgs;
    public function explicit():Void;
    @:native("~AuthorizationArgs")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:AuthorizationArgs):AuthorizationArgs;
    @:native("operator=")
    public function assignCopy(other:AuthorizationArgs):AuthorizationArgs;
    public function isValid():Bool;
    public function ClientId():cpp.UInt64;
    public function SetClientId(ClientId:cpp.UInt64):Void;
    public function Scopes():String;
    public function SetScopes(Scopes:String):Void;
    public function State():Null<String>;
    public function SetState(State:Null<String>):Void;
    public function Nonce():Null<String>;
    public function SetNonce(Nonce:Null<String>):Void;
    public function CodeChallenge():Null<AuthorizationCodeChallenge>;
    public function SetCodeChallenge(CodeChallenge:Null<AuthorizationCodeChallenge>):Void;
    public function IntegrationType():Null<IntegrationType>;
    public function SetIntegrationType(IntegrationType:Null<IntegrationType>):Void;
    public function CustomSchemeParam():Null<String>;
    public function SetCustomSchemeParam(CustomSchemeParam:Null<String>):Void;
}

@:native("discordpp::DeviceAuthorizationArgs")
extern class DeviceAuthorizationArgs {
    private var instance_:Discord_DeviceAuthorizationArgs;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_DeviceAuthorizationArgs, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_DeviceAuthorizationArgs>;
    public static var nullobj:DeviceAuthorizationArgs;
    public function explicit():Void;
    @:native("~DeviceAuthorizationArgs")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:DeviceAuthorizationArgs):DeviceAuthorizationArgs;
    @:native("operator=")
    public function assignCopy(other:DeviceAuthorizationArgs):DeviceAuthorizationArgs;
    public function isValid():Bool;
    public function ClientId():cpp.UInt64;
    public function SetClientId(ClientId:cpp.UInt64):Void;
    public function Scopes():String;
    public function SetScopes(Scopes:String):Void;
}

@:native("discordpp::VoiceStateHandle")
extern class VoiceStateHandle {
    private var instance_:Discord_VoiceStateHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_VoiceStateHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_VoiceStateHandle>;
    public static var nullobj:VoiceStateHandle;
    public function explicit():Void;
    @:native("~VoiceStateHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:VoiceStateHandle):VoiceStateHandle;
    @:native("operator=")
    public function assignCopy(other:VoiceStateHandle):VoiceStateHandle;
    public function isValid():Bool;
    public function SelfDeaf():Bool;
    public function SelfMute():Bool;
}

@:native("discordpp::VADThresholdSettings")
extern class VADThresholdSettings {
    private var instance_:Discord_VADThresholdSettings;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_VADThresholdSettings, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_VADThresholdSettings>;
    public static var nullobj:VADThresholdSettings;
    public function explicit():Void;
    @:native("~VADThresholdSettings")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:VADThresholdSettings):VADThresholdSettings;
    public function isValid():Bool;
    public function VadThreshold():Float;
    public function SetVadThreshold(VadThreshold:Float):Void;
    public function Automatic():Bool;
    public function SetAutomatic(Automatic:Bool):Void;
}

@:native("discordpp::Call")
extern class Call {
    private var instance_:Discord_Call;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_Call, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_Call>;
    public static var nullobj:Call;
    public function explicit():Void;
    @:native("~Call")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:Call):Call;
    public function isValid():Bool;
    public function OnVoiceStateChanged(userId:cpp.UInt64):Void;
    public function OnParticipantChanged(userId:cpp.UInt64, added:Bool):Void;
    public function OnSpeakingStatusChanged(userId:cpp.UInt64, isPlayingSound:Bool):Void;
    public function OnStatusChanged(status:Status, error:Error, errorDetail:Int):Void;
    public static function ErrorToString(type:Error):String;
    public static function StatusToString(type:Status):String;
    public function GetAudioMode():AudioModeType;
    public function GetChannelId():cpp.UInt64;
    public function GetGuildId():cpp.UInt64;
    public function GetLocalMute(userId:cpp.UInt64):Bool;
    public function GetParticipants():Array<cpp.UInt64>;
    public function GetParticipantVolume(userId:cpp.UInt64):Float;
    public function GetPTTActive():Bool;
    public function GetPTTReleaseDelay():UInt;
    public function GetSelfDeaf():Bool;
    public function GetSelfMute():Bool;
    public function GetStatus():Status;
    public function GetVADThreshold():VADThresholdSettings;
    public function GetVoiceStateHandle(userId:cpp.UInt64):Null<VoiceStateHandle>;
    public function SetAudioMode(audioMode:AudioModeType):Void;
    public function SetLocalMute(userId:cpp.UInt64, mute:Bool):Void;
    public function SetOnVoiceStateChangedCallback(cb:cpp.Function<Void, cpp.abi.Abi>):Void;
    public function SetParticipantChangedCallback(cb:ParticipantChangedCallback):Void;
    public function SetParticipantVolume(userId:cpp.UInt64, volume:Float):Void;
    public function SetPTTActive(active:Bool):Void;
    public function SetPTTReleaseDelay(releaseDelayMs:UInt):Void;
    public function SetSelfDeaf(deaf:Bool):Void;
    public function SetSelfMute(mute:Bool):Void;
    public function SetSpeakingStatusChangedCallback(cb:(cpp.UInt64, Bool) -> Void):Void;
    public function SetStatusChangedCallback(cb:(Status, Error, Int) -> Void):Void;
    public function SetVADThreshold(automatic:Bool, threshold:Float):Void;
}

@:native("discordpp::Call::Error")
extern enum abstract CallError(Int) {
    var None = 0;
    var SignalingConnectionFailed = 1;
    var SignalingUnexpectedClose = 2;
    var VoiceConnectionFailed = 3;
    var JoinTimeout = 4;
    var Forbidden = 5;
}

@:native("discordpp::Call::Status")
extern enum abstract CallStatus(Int) {
    var Disconnected = 0;
    var Joining = 1;
    var Connecting = 2;
    var SignalingConnected = 3;
    var Connected = 4;
    var Reconnecting = 5;
    var Disconnecting = 6;
}

@:native("discordpp::ChannelHandle")
extern class ChannelHandle {
    private var instance_:Discord_ChannelHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ChannelHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ChannelHandle>;
    public static var nullobj:ChannelHandle;
    public function explicit():Void;
    @:native("~ChannelHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ChannelHandle):ChannelHandle;
    public function isValid():Bool;
    public function copy(other:ChannelHandle):ChannelHandle;
    public function Id():cpp.UInt64;
    public function Name():String;
    public function Recipients():Array<cpp.UInt64>;
    public function Type():ChannelType;
}

@:native("discordpp::GuildMinimal")
extern class GuildMinimal {
    private var instance_:Discord_GuildMinimal;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_GuildMinimal, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_GuildMinimal>;
    public static var nullobj:GuildMinimal;
    public function explicit():Void;
    @:native("~GuildMinimal")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:GuildMinimal):GuildMinimal;
    public function isValid():Bool;
    public function copy(other:GuildMinimal):GuildMinimal;
    public function Id():cpp.UInt64;
    public function SetId(Id:cpp.UInt64):Void;
    public function Name():String;
    public function SetName(Name:String):Void;
}

@:native("discordpp::GuildChannel")
extern class GuildChannel {
    private var instance_:Discord_GuildChannel;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_GuildChannel, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_GuildChannel>;
    public static var nullobj:GuildChannel;
    public function explicit():Void;
    @:native("~GuildChannel")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:GuildChannel):GuildChannel;
    public function isValid():Bool;
    public function copy(other:GuildChannel):GuildChannel;
    public function Id():cpp.UInt64;
    public function SetId(Id:cpp.UInt64):Void;
    public function Name():String;
    public function SetName(Name:String):Void;
    public function IsLinkable():Bool;
    public function SetIsLinkable(value:Bool):Void;
    public function IsViewableAndWriteableByAllMembers():Bool;
    public function SetIsViewableAndWriteableByAllMembers(value:Bool):Void;
    public function LinkedLobby():Null<discord.LinkedLobby>;
    public function SetLinkedLobby(value:Null<discord.LinkedLobby>):Void;
}

@:native("discordpp::LinkedLobby")
extern class LinkedLobby {
    private var instance_:Discord_LinkedLobby;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_LinkedLobby, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_LinkedLobby>;
    public static var nullobj:LinkedLobby;
    public function explicit():Void;
    @:native("~LinkedLobby")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:LinkedLobby):LinkedLobby;
    public function isValid():Bool;
    public function copy(other:LinkedLobby):LinkedLobby;
    public function ApplicationId():cpp.UInt64;
    public function SetApplicationId(ApplicationId:cpp.UInt64):Void;
    public function LobbyId():cpp.UInt64;
    public function SetLobbyId(LobbyId:cpp.UInt64):Void;
}

@:native("discordpp::LinkedChannel")
extern class LinkedChannel {
    private var instance_:Discord_LinkedChannel;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_LinkedChannel, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_LinkedChannel>;
    public static var nullobj:LinkedChannel;
    public function explicit():Void;
    @:native("~LinkedChannel")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:LinkedChannel):LinkedChannel;
    public function isValid():Bool;
    public function copy(other:LinkedChannel):LinkedChannel;
    public function Id():cpp.UInt64;
    public function SetId(Id:cpp.UInt64):Void;
    public function Name():String;
    public function SetName(Name:String):Void;
    public function GuildId():cpp.UInt64;
    public function SetGuildId(GuildId:cpp.UInt64):Void;
}

@:native("discordpp::RelationshipHandle")
extern class RelationshipHandle {
    private var instance_:Discord_RelationshipHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_RelationshipHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_RelationshipHandle>;
    public static var nullobj:RelationshipHandle;
    public function explicit():Void;
    @:native("~RelationshipHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:RelationshipHandle):RelationshipHandle;
    public function isValid():Bool;
    public function copy(other:RelationshipHandle):RelationshipHandle;
    public function DiscordRelationshipType():discord.RelationshipType;
    public function GameRelationshipType():discord.RelationshipType;
    public function Id():cpp.UInt64;
    public function IsSpamRequest():Bool;
    public function User():Null<discord.UserHandle>;
}

@:native("discordpp::UserHandle")
extern class UserHandle {
    private var instance_:Discord_UserHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_UserHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_UserHandle>;
    public static var nullobj:UserHandle;
    public function explicit():Void;
    @:native("~UserHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:UserHandle):UserHandle;
    public function isValid():Bool;
    public function copy(other:UserHandle):UserHandle;
    public function Avatar():Null<String>;
    public static function AvatarTypeToString(type:AvatarType):String;
    public function AvatarUrl(animatedType:AvatarType, staticType:AvatarType):String;
    public function DisplayName():String;
    public function GameActivity():Null<Activity>;
    public function GlobalName():Null<String>;
    public function Id():cpp.UInt64;
    public function IsProvisional():Bool;
    public function Relationship():RelationshipHandle;
    public function Status():StatusType;
    public function Username():String;
}

@:native("discordpp::UserHandle::AvatarType")
extern enum abstract AvatarType(Int) {
    var Gif = 0;
    var Webp = 1;
    var Png = 2;
    var Jpeg = 3;
}

@:native("discordpp::LobbyMemberHandle")
extern class LobbyMemberHandle {
    private var instance_:Discord_LobbyMemberHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_LobbyMemberHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_LobbyMemberHandle>;
    public static var nullobj:LobbyMemberHandle;
    public function explicit():Void;
    @:native("~LobbyMemberHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:LobbyMemberHandle):LobbyMemberHandle;
    public function isValid():Bool;
    public function copy(other:LobbyMemberHandle):LobbyMemberHandle;
    public function CanLinkLobby():Bool;
    public function Connected():Bool;
    public function Id():cpp.UInt64;
    public function Metadata():Map<String,String>;
    public function User():Null<UserHandle>;
}

@:native("discordpp::LobbyHandle")
extern class LobbyHandle {
    private var instance_:Discord_LobbyHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_LobbyHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_LobbyHandle>;
    public static var nullobj:LobbyHandle;
    public function explicit():Void;
    @:native("~LobbyHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:LobbyHandle):LobbyHandle;
    public function isValid():Bool;
    public function copy(other:LobbyHandle):LobbyHandle;
    public function GetCallInfoHandle():Null<CallInfoHandle>;
    public function GetLobbyMemberHandle(memberId:cpp.UInt64):Null<LobbyMemberHandle>;
    public function Id():cpp.UInt64;
    public function LinkedChannel():Null<LinkedChannel>;
    public function LobbyMemberIds():Array<cpp.UInt64>;
    public function LobbyMembers():Array<LobbyMemberHandle>;
    public function Metadata():Map<String,String>;
}

@:native("discordpp::AdditionalContent")
extern class AdditionalContent {
    private var instance_:Discord_AdditionalContent;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_AdditionalContent, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_AdditionalContent>;
    public static var nullobj:AdditionalContent;
    public function explicit():Void;
    @:native("~AdditionalContent")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:AdditionalContent):AdditionalContent;
    public function isValid():Bool;
    public function copy(other:AdditionalContent):AdditionalContent;
    public function Equals(rhs:AdditionalContent):Bool;
    public static function TypeToString(type:AdditionalContentType):String;
    public function Type():AdditionalContentType;
    public function SetType(Type:AdditionalContentType):Void;
    public function Title():Null<String>;
    public function SetTitle(Title:Null<String>):Void;
    public function Count():cpp.UInt8;
    public function SetCount(Count:cpp.UInt8):Void;
}

@:native("discordpp::MessageHandle")
extern class MessageHandle {
    private var instance_:Discord_MessageHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_MessageHandle, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_MessageHandle>;
    public static var nullobj:MessageHandle;
    public function explicit():Void;
    @:native("~MessageHandle")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:MessageHandle):MessageHandle;
    public function isValid():Bool;
    public function copy(other:MessageHandle):MessageHandle;
    public function AdditionalContent():Null<AdditionalContent>;
    public function ApplicationId():Null<cpp.UInt64>;
    public function Author():Null<UserHandle>;
    public function AuthorId():cpp.UInt64;
    public function Channel():Null<ChannelHandle>;
    public function ChannelId():cpp.UInt64;
    public function Content():String;
    public function DisclosureType():Null<DisclosureTypes>;
    public function EditedTimestamp():cpp.UInt64;
    public function Id():cpp.UInt64;
    public function Lobby():Null<LobbyHandle>;
    public function Metadata():Map<String, String>;
    public function RawContent():String;
    public function Recipient():Null<UserHandle>;
    public function RecipientId():cpp.UInt64;
    public function SentFromGame():Bool;
    public function SentTimestamp():cpp.UInt64;
}

@:native("discordpp::AudioDevice")
extern class AudioDevice {
    private var instance_:Discord_AudioDevice;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_AudioDevice, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_AudioDevice>;
    public static var nullobj:AudioDevice;
    public function explicit():Void;
    @:native("~AudioDevice")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:AudioDevice):AudioDevice;
    public function isValid():Bool;
    public function copy(other:AudioDevice):AudioDevice;
    public function Equals(rhs:AudioDevice):Bool;
    public function Id():String;
    public function SetId(Id:String):Void;
    public function Name():String;
    public function SetName(Name:String):Void;
    public function IsDefault():Bool;
    public function SetIsDefault(value:Bool):Void;
}

@:native("discordpp::UserMessageSummary")
extern class UserMessageSummary {
    private var instance_:Discord_UserMessageSummary;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_UserMessageSummary, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_UserMessageSummary>;
    public static var nullobj:UserMessageSummary;
    public function explicit():Void;
    @:native("~UserMessageSummary")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:UserMessageSummary):UserMessageSummary;
    public function isValid():Bool;
    public function copy(other:UserMessageSummary):UserMessageSummary;
    public function LastMessageId():cpp.UInt64;
    public function UserId():cpp.UInt64;
}

@:native("discordpp::ClientCreateOptions")
extern class ClientCreateOptions {
    private var instance_:Discord_ClientCreateOptions;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_ClientCreateOptions, state:DiscordObjectState);
    public function instance():cpp.Pointer<Discord_ClientCreateOptions>;
    public static var nullobj:ClientCreateOptions;
    public function explicit():Void;
    @:native("~ClientCreateOptions")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:ClientCreateOptions):ClientCreateOptions;
    public function isValid():Bool;
    public function copy(other:ClientCreateOptions):ClientCreateOptions;
    public function WebBase():String;
    public function SetWebBase(value:String):Void;
    public function ApiBase():String;
    public function SetApiBase(value:String):Void;
    public function ExperimentalAudioSystem():AudioSystem;
    public function SetExperimentalAudioSystem(value:AudioSystem):Void;
    public function ExperimentalAndroidPreventCommsForBluetooth():Bool;
    public function SetExperimentalAndroidPreventCommsForBluetooth(value:Bool):Void;
}

@:native("discordpp::Client")
extern class Client {
    private var instance_:Discord_Client;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_Client, state:DiscordObjectState);
    public function instance():Pointer<Discord_Client>;
    public static var nullobj:Client;
    public function explicit():Void;
    @:native("~Client")
    public function Drop():Void;
    @:native("operator=")
    public function assignMove(other:Client):Client;
    public function isValid():Bool;
    @:overload(function():Void {})
    @:overload(function(apiBase:String, webBase:String):Void {})
    @:overload(function(options:ClientCreateOptions):Void {})
    @:overload(function(instance:Discord_Client, state:DiscordObjectState):Void {})
    public function operatorBool():Bool;
    public static function ErrorToString(e:Error):String;
    public static function StatusToString(s:Status):String;
    public static function ThreadToString(t:Thread):String;
    public static function GetDefaultAudioDeviceId():String;
    public static function GetDefaultCommunicationScopes():String;
    public static function GetDefaultPresenceScopes():String;
    public static function GetVersionHash():String;
    public static function GetVersionMajor():Int;
    public static function GetVersionMinor():Int;
    public static function GetVersionPatch():Int;
    public function GetApplicationId():UInt;
    public function SetHttpRequestTimeout(ms:Int):Void;
    public function EndCall(channelId:UInt, cb:EndCallCallback):Void;
    public function EndCalls(cb:EndCallsCallback):Void;
    public function GetCall(channelId:UInt):Call;
    public function GetCalls():Array<Call>;
    public function GetCurrentInputDevice(cb:GetCurrentInputDeviceCallback):Void;
    public function GetCurrentOutputDevice(cb:GetCurrentOutputDeviceCallback):Void;
    public function GetInputDevices(cb:GetInputDevicesCallback):Void;
    public function GetOutputDevices(cb:GetOutputDevicesCallback):Void;
    public function GetInputVolume():Float;
    public function GetOutputVolume():Float;
    public function GetSelfDeafAll():Bool;
    public function GetSelfMuteAll():Bool;
    public function SetAecDump(on:Bool):Void;
    public function SetAutomaticGainControl(on:Bool):Void;
    public function SetDeviceChangeCallback(cb:DeviceChangeCallback):Void;
    public function SetEchoCancellation(on:Bool):Void;
    public function SetEngineManagedAudioSession(isEngineManaged:Bool):Void;
    public function SetInputDevice(deviceId:String, cb:SetInputDeviceCallback):Void;
    public function SetInputVolume(volume:Float):Void;
    public function SetNoAudioInputCallback(cb:NoAudioInputCallback):Void;
    public function SetNoAudioInputThreshold(dBFSThreshold:Float):Void;
    public function SetNoiseSuppression(on:Bool):Void;
    public function SetOpusHardwareCoding(encode:Bool, decode:Bool):Void;
    public function SetOutputDevice(deviceId:String, cb:SetOutputDeviceCallback):Void;
    public function SetOutputVolume(volume:Float):Void;
    public function SetSelfDeafAll(deaf:Bool):Void;
    public function SetSelfMuteAll(mute:Bool):Void;
    public function SetSpeakerMode(speakerMode:Bool):Bool;
    public function SetThreadPriority(thread:Thread, priority:Int):Void;
    public function SetVoiceParticipantChangedCallback(cb:VoiceParticipantChangedCallback):Void;
    public function ShowAudioRoutePicker():Bool;
    public function StartCall(channelId:UInt):Call;
    public function StartCallWithAudioCallbacks(
        lobbyId:UInt,
        receivedCb:UserAudioReceivedCallback,
        capturedCb:UserAudioCapturedCallback
    ):Call;
    public function AbortAuthorize():Void;
    public function AbortGetTokenFromDevice():Void;
    public function Authorize(args:AuthorizationArgs, cb:AuthorizationCallback):Void;
    public function CloseAuthorizeDeviceScreen():Void;
    public function CreateAuthorizationCodeVerifier():AuthorizationCodeVerifier;
    public function ExchangeChildToken(token:String, appId:UInt, cb:ExchangeChildTokenCallback):Void;
    public function FetchCurrentUser(tokenType:AuthorizationTokenType, token:String, cb:FetchCurrentUserCallback):Void;
    public function GetProvisionalToken(appId:UInt, authType:AuthenticationExternalAuthType, token:String, cb:TokenExchangeCallback):Void;
    public function GetToken(appId:UInt, code:String, codeVerifier:String, redirectUri:String, cb:TokenExchangeCallback):Void;
    public function GetTokenFromDevice(args:DeviceAuthorizationArgs, cb:TokenExchangeCallback):Void;
    public function GetTokenFromDeviceProvisionalMerge(args:DeviceAuthorizationArgs, authType:AuthenticationExternalAuthType, token:String, cb:TokenExchangeCallback):Void;
    public function GetTokenFromProvisionalMerge(appId:UInt, code:String, codeVerifier:String, redirectUri:String, authType:AuthenticationExternalAuthType, token:String, cb:TokenExchangeCallback):Void;
    public function IsAuthenticated():Bool;
    public function OpenAuthorizeDeviceScreen(clientId:UInt, userCode:String):Void;
    public function ProvisionalUserMergeCompleted(success:Bool):Void;
    public function RefreshToken(appId:UInt, token:String, cb:TokenExchangeCallback):Void;
    public function RevokeToken(appId:UInt, token:String, cb:RevokeTokenCallback):Void;
    public function SetAuthorizeDeviceScreenClosedCallback(cb:AuthorizeDeviceScreenClosedCallback):Void;
    public function SetGameWindowPid(pid:Int):Void;
    public function SetTokenExpirationCallback(cb:TokenExpirationCallback):Void;
    public function UnmergeIntoProvisionalAccount(appId:UInt, authType:AuthenticationExternalAuthType, token:String, cb:UnmergeIntoProvisionalAccountCallback):Void;
    public function UpdateProvisionalAccountDisplayName(name:String, cb:UpdateProvisionalAccountDisplayNameCallback):Void;
    public function UpdateToken(tokenType:AuthorizationTokenType, token:String, cb:UpdateTokenCallback):Void;
    public function CanOpenMessageInDiscord(messageId:UInt):Bool;
    public function DeleteUserMessage(recipientId:UInt, messageId:UInt, cb:DeleteUserMessageCallback):Void;
    public function EditUserMessage(recipientId:UInt, messageId:UInt, content:String, cb:EditUserMessageCallback):Void;
    public function GetChannelHandle(channelId:UInt):Null<ChannelHandle>;
    public function GetLobbyMessagesWithLimit(lobbyId:UInt, limit:Int, cb:GetLobbyMessagesCallback):Void;
    public function GetMessageHandle(messageId:UInt):Null<MessageHandle>;
    public function GetUserMessageSummaries(cb:UserMessageSummariesCallback):Void;
    public function GetUserMessagesWithLimit(recipientId:UInt, limit:Int, cb:UserMessagesWithLimitCallback):Void;
    public function OpenMessageInDiscord(messageId:UInt, provisionalCb:ProvisionalUserMergeRequiredCallback, cb:OpenMessageInDiscordCallback):Void;
    public function SendLobbyMessage(lobbyId:UInt, content:String, cb:SendUserMessageCallback):Void;
    public function SendLobbyMessageWithMetadata(lobbyId:UInt, content:String, metadata:Map<String,String>, cb:SendUserMessageCallback):Void;
    public function SendUserMessage(recipientId:UInt, content:String, cb:SendUserMessageCallback):Void;
    public function SendUserMessageWithMetadata(recipientId:UInt, content:String, metadata:Map<String,String>, cb:SendUserMessageCallback):Void;
    public function SetMessageCreatedCallback(cb:MessageCreatedCallback):Void;
    public function SetMessageDeletedCallback(cb:MessageDeletedCallback):Void;
    public function SetMessageUpdatedCallback(cb:MessageUpdatedCallback):Void;
    public function SetShowingChat(showing:Bool):Void;
    public function AddLogCallback(cb:LogCallback, minSeverity:LoggingSeverity):Void;
    public function AddVoiceLogCallback(cb:LogCallback, minSeverity:LoggingSeverity):Void;
    public function Connect():Void;
    public function Disconnect():Void;
    public function GetStatus():Status;
    public function OpenConnectedGamesSettingsInDiscord(cb:OpenConnectedGamesSettingsInDiscordCallback):Void;
    public function SetApplicationId(appId:UInt):Void;
    public function SetLogDir(path:String, minSeverity:LoggingSeverity):Bool;
    public function SetStatusChangedCallback(cb:OnStatusChanged):Void;
    public function SetVoiceLogDir(path:String, minSeverity:LoggingSeverity):Void;
    public function CreateOrJoinLobby(secret:String, cb:CreateOrJoinLobbyCallback):Void;
    public function CreateOrJoinLobbyWithMetadata(secret:String, lobbyMetadata:Map<String,String>, memberMetadata:Map<String,String>, cb:CreateOrJoinLobbyCallback):Void;
    public function GetGuildChannels(guildId:UInt, cb:GetGuildChannelsCallback):Void;
    public function GetLobbyHandle(lobbyId:UInt):Null<LobbyHandle>;
    public function GetLobbyIds():Array<UInt>;
    public function GetUserGuilds(cb:GetUserGuildsCallback):Void;
    public function JoinLinkedLobbyGuild(lobbyId:UInt, provisionalCb:ProvisionalUserMergeRequiredCallback, cb:JoinLinkedLobbyGuildCallback):Void;
    public function LeaveLobby(lobbyId:UInt, cb:LeaveLobbyCallback):Void;
    public function LinkChannelToLobby(lobbyId:UInt, channelId:UInt, cb:LinkOrUnlinkChannelCallback):Void;
    public function SetLobbyCreatedCallback(cb:LobbyCreatedCallback):Void;
    public function SetLobbyDeletedCallback(cb:LobbyDeletedCallback):Void;
    public function SetLobbyMemberAddedCallback(cb:LobbyMemberAddedCallback):Void;
    public function SetLobbyMemberRemovedCallback(cb:LobbyMemberRemovedCallback):Void;
    public function SetLobbyMemberUpdatedCallback(cb:LobbyMemberUpdatedCallback):Void;
    public function SetLobbyUpdatedCallback(cb:LobbyUpdatedCallback):Void;
    public function UnlinkChannelFromLobby(lobbyId:UInt, cb:LinkOrUnlinkChannelCallback):Void;
    public function AcceptActivityInvite(invite:ActivityInvite, cb:AcceptActivityInviteCallback):Void;
    public function ClearRichPresence():Void;
    public function RegisterLaunchCommand(appId:UInt, command:String):Bool;
    public function RegisterLaunchSteamApplication(appId:UInt, steamAppId:UInt):Bool;
    public function SendActivityInvite(userId:UInt, content:String, cb:SendActivityInviteCallback):Void;
    public function SendActivityJoinRequest(userId:UInt, cb:SendActivityInviteCallback):Void;
    public function SendActivityJoinRequestReply(invite:ActivityInvite, cb:SendActivityInviteCallback):Void;
    public function SetActivityInviteCreatedCallback(cb:ActivityInviteCallback):Void;
    public function SetActivityInviteUpdatedCallback(cb:ActivityInviteCallback):Void;
    public function SetActivityJoinCallback(cb:ActivityJoinCallback):Void;
    public function SetActivityJoinWithApplicationCallback(cb:ActivityJoinWithApplicationCallback):Void;
    public function SetOnlineStatus(status:StatusType, cb:UpdateStatusCallback):Void;
    public function UpdateRichPresence(activity:Activity, cb:UpdateRichPresenceCallback):Void;
    public function AcceptDiscordFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function AcceptGameFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function BlockUser(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function CancelDiscordFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function CancelGameFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function GetRelationshipHandle(userId:UInt):RelationshipHandle;
    public function GetRelationships():Array<RelationshipHandle>;
    public function GetRelationshipsByGroup(group:RelationshipGroupType):Array<RelationshipHandle>;
    public function RejectDiscordFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function RejectGameFriendRequest(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function RemoveDiscordAndGameFriend(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function RemoveGameFriend(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function SearchFriendsByUsername(search:String):Array<UserHandle>;
    public function SendDiscordFriendRequest(username:String, cb:SendFriendRequestCallback):Void;
    public function SendDiscordFriendRequestById(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function SendGameFriendRequest(username:String, cb:SendFriendRequestCallback):Void;
    public function SendGameFriendRequestById(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function SetRelationshipCreatedCallback(cb:RelationshipCreatedCallback):Void;
    public function SetRelationshipDeletedCallback(cb:RelationshipDeletedCallback):Void;
    public function UnblockUser(userId:UInt, cb:UpdateRelationshipCallback):Void;
    public function GetCurrentUser():UserHandle;
    public function GetCurrentUserV2():Null<UserHandle>;
    public function GetDiscordClientConnectedUser(appId:UInt, cb:GetDiscordClientConnectedUserCallback):Void;
    public function GetUser(userId:UInt):Null<UserHandle>;
    public function SetRelationshipGroupsUpdatedCallback(cb:RelationshipGroupsUpdatedCallback):Void;
    public function SetUserUpdatedCallback(cb:UserUpdatedCallback):Void;
}

typedef EndCallCallback = Void->Void;
typedef EndCallsCallback = Void->Void;
typedef GetCurrentInputDeviceCallback = AudioDevice->Void;
typedef GetCurrentOutputDeviceCallback = AudioDevice->Void;
typedef GetInputDevicesCallback = Array<AudioDevice>->Void;
typedef GetOutputDevicesCallback = Array<AudioDevice>->Void;
typedef DeviceChangeCallback = (Array<AudioDevice>, Array<AudioDevice>)->Void;
typedef SetInputDeviceCallback = ClientResult->Void;
typedef NoAudioInputCallback = Bool->Void;
typedef SetOutputDeviceCallback = ClientResult->Void;
typedef VoiceParticipantChangedCallback = (UInt, UInt, Bool)->Void;
typedef UserAudioReceivedCallback = (UInt, Pointer<Int>, UInt, Int, UInt, Bool)->Void;
typedef UserAudioCapturedCallback = (Pointer<Int>, UInt, Int, UInt)->Void;
typedef AuthorizationCallback = (ClientResult, String, String)->Void;
typedef ExchangeChildTokenCallback = (ClientResult, String, AuthorizationTokenType, Int, String)->Void;
typedef FetchCurrentUserCallback = (ClientResult, UInt, String)->Void;
typedef TokenExchangeCallback = (ClientResult, String, String, AuthorizationTokenType, Int, String)->Void;
typedef RevokeTokenCallback = ClientResult->Void;
typedef AuthorizeDeviceScreenClosedCallback = Void->Void;
typedef TokenExpirationCallback = Void->Void;
typedef UnmergeIntoProvisionalAccountCallback = ClientResult->Void;
typedef UpdateProvisionalAccountDisplayNameCallback = ClientResult->Void;
typedef UpdateTokenCallback = ClientResult->Void;
typedef DeleteUserMessageCallback = ClientResult->Void;
typedef EditUserMessageCallback = ClientResult->Void;
typedef GetLobbyMessagesCallback = (ClientResult, Array<MessageHandle>)->Void;
typedef UserMessageSummariesCallback = (ClientResult, Array<UserMessageSummary>)->Void;
typedef UserMessagesWithLimitCallback = (ClientResult, Array<MessageHandle>)->Void;
typedef ProvisionalUserMergeRequiredCallback = Void->Void;
typedef OpenMessageInDiscordCallback = ClientResult->Void;
typedef SendUserMessageCallback = (ClientResult, UInt)->Void;
typedef MessageCreatedCallback = UInt->Void;
typedef MessageDeletedCallback = (UInt, UInt)->Void;
typedef MessageUpdatedCallback = UInt->Void;
typedef LogCallback = (String, LoggingSeverity)->Void;
typedef OpenConnectedGamesSettingsInDiscordCallback = ClientResult->Void;
typedef OnStatusChanged = (Status, Error, Int)->Void;
typedef CreateOrJoinLobbyCallback = (ClientResult, UInt)->Void;
typedef GetGuildChannelsCallback = (ClientResult, Array<GuildChannel>)->Void;
typedef GetUserGuildsCallback = (ClientResult, Array<GuildMinimal>)->Void;
typedef JoinLinkedLobbyGuildCallback = (ClientResult, String)->Void;
typedef LeaveLobbyCallback = ClientResult->Void;
typedef LinkOrUnlinkChannelCallback = ClientResult->Void;
typedef LobbyCreatedCallback = UInt->Void;
typedef LobbyDeletedCallback = UInt->Void;
typedef LobbyMemberAddedCallback = (UInt, UInt)->Void;
typedef LobbyMemberRemovedCallback = (UInt, UInt)->Void;
typedef LobbyMemberUpdatedCallback = (UInt, UInt)->Void;
typedef LobbyUpdatedCallback = UInt->Void;
typedef AcceptActivityInviteCallback = (ClientResult, String)->Void;
typedef SendActivityInviteCallback = ClientResult->Void;
typedef ActivityInviteCallback = ActivityInvite->Void;
typedef ActivityJoinCallback = String->Void;
typedef ActivityJoinWithApplicationCallback = (UInt, String)->Void;
typedef UpdateStatusCallback = ClientResult->Void;
typedef UpdateRichPresenceCallback = ClientResult->Void;
typedef UpdateRelationshipCallback = ClientResult->Void;
typedef SendFriendRequestCallback = ClientResult->Void;
typedef RelationshipCreatedCallback = (UInt, Bool)->Void;
typedef RelationshipDeletedCallback = (UInt, Bool)->Void;
typedef GetDiscordClientConnectedUserCallback = (ClientResult, Null<UserHandle>)->Void;
typedef RelationshipGroupsUpdatedCallback = UInt->Void;
typedef UserUpdatedCallback = UInt->Void;

@:native("discordpp::Client::Error")
enum abstract Error(Int) {
    var None = 0;
    var ConnectionFailed = 1;
    var UnexpectedClose = 2;
    var ConnectionCanceled = 3;
}

@:native("discordpp::Client::Status")
enum abstract Status(Int) {
    var Disconnected = 0;
    var Connecting = 1;
    var Connected = 2;
    var Ready = 3;
    var Reconnecting = 4;
    var Disconnecting = 5;
    var HttpWait = 6;
}

@:native("discordpp::Client::Thread")
enum abstract Thread(Int) {
    var Client = 0;
    var Voice = 1;
    var Network = 2;
}

@:native("discordpp::CallInfoHandle")
extern class CallInfoHandle {
    private var instance_:Discord_CallInfoHandle;
    private var state_:DiscordObjectState;
    public function new(instance:Discord_CallInfoHandle, state:DiscordObjectState);
    public function instance():Pointer<Discord_CallInfoHandle>;
    public static var nullobj:CallInfoHandle;
    public function operatorBool():Bool;
    public function assignMove(other:CallInfoHandle):CallInfoHandle;
    public function assignCopy(other:CallInfoHandle):CallInfoHandle;
    @:native("~CallInfoHandle")
    public function Drop():Void;
    public function ChannelId():UInt;
    public function GetParticipants():Array<UInt>;
    public function GetVoiceStateHandle(userId:UInt):Null<VoiceStateHandle>;
    public function GuildId():UInt;
}
*/