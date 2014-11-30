// Public Domain

import core.sys.windows.windows;

import farplugin;
import wcharutil;

import core.cpuid;
import std.string;

GUID MainGuid = { 0xc2731ba7, 0x5714, 0x4d00, [ 0xad, 0xb8, 0xb4, 0x9c, 0x75, 0x7e, 0x86, 0xe1 ] };
GUID MenuGuid = { 0x2caea29a, 0xf9d9, 0x4be8, [ 0x87, 0x71, 0xbb, 0x43, 0xba, 0x97, 0xa0, 0x59 ] };

enum {
    MTitle,

    MVendor,
    MProcessor,
    MSignature,
    MFeatures,
    MMultithreading,

    MButton,
}

enum PLUGIN_BUILD  = 1;
enum PLUGIN_NAME   = "HelloWorld"w;
enum PLUGIN_DESC   = "Hello World Plugin for Far Manager"w;
enum PLUGIN_AUTHOR = "Public domain"w;
auto PLUGIN_VERSION() { return MakeFarVersion(FARMANAGERVERSION_MAJOR, FARMANAGERVERSION_MINOR, FARMANAGERVERSION_REVISION, PLUGIN_BUILD, FARMANAGERVERSION_STAGE); }

PluginStartupInfo Info;

export extern (Windows)
void GetGlobalInfoW(GlobalInfo* info)
{
    info.StructSize = GlobalInfo.sizeof;
    info.MinFarVersion = FARMANAGERVERSION;
    info.Version = PLUGIN_VERSION;
    info.Guid = MainGuid;
    info.Title = PLUGIN_NAME.dup.ptr;
    info.Description = PLUGIN_DESC.dup.ptr;
    info.Author = PLUGIN_AUTHOR.dup.ptr;
}

const(wchar)* GetMsg(int msgId)
{
    return Info.GetMsg(&MainGuid, msgId);
}

export extern (Windows)
void SetStartupInfoW(PluginStartupInfo* info)
{
    Info = *info;
}

export extern (Windows)
void GetPluginInfoW(PluginInfo* info)
{
    info.StructSize=PluginInfo.sizeof;
    info.Flags=PF_EDITOR;
    static const(wchar)*[1] PluginMenuStrings;
    PluginMenuStrings[0] = GetMsg(MTitle);
    info.PluginMenu.Guids = &MenuGuid;
    info.PluginMenu.Strings = &PluginMenuStrings[0];
    info.PluginMenu.Count = PluginMenuStrings.length;
}

auto GetCPUDetails()
{
    string features;
    if (mmx)            features ~= "MMX ";
    if (hasFxsr)        features ~= "FXSR ";
    if (sse)            features ~= "SSE ";
    if (sse2)           features ~= "SSE2 ";
    if (sse3)           features ~= "SSE3 ";
    if (ssse3)          features ~= "SSSE3 ";
    if (amd3dnow)       features ~= "3DNow! ";
    if (amd3dnowExt)    features ~= "3DNow!+ ";
    if (amdMmx)         features ~= "MMX+ ";
    if (isItanium)      features ~= "IA-64 ";
    if (isX86_64)       features ~= "X86_64 ";
    if (hyperThreading) features ~= "HTT";

	return [
        "%s: %s".format(GetMsg(MVendor).toWString.rightJustify(16), vendor).toWStringz,
        "%s: %s".format(GetMsg(MProcessor).toWString.rightJustify(16), processor).toWStringz,
        "%s: Family=%d Model=%d Stepping=%d".format(GetMsg(MSignature).toWString.rightJustify(16), family, model, stepping).toWStringz,
        "%s: %s".format(GetMsg(MFeatures).toWString.rightJustify(16), features).toWStringz,
        "%s: %d threads / %d cores".format(GetMsg(MMultithreading).toWString.rightJustify(16), threadsPerCPU, coresPerCPU).toWStringz
    ];
}

export extern (Windows)
HANDLE OpenW(OpenInfo *info)
{
	const(wchar)*[] MsgItems;
    MsgItems ~= GetMsg(MTitle);
    MsgItems ~= GetCPUDetails();
    MsgItems ~= "\x01"w.dup.ptr; // separator line
    MsgItems ~= GetMsg(MButton);

	Info.Message(
        &MainGuid,               // GUID
        null,
        FMSG_LEFTALIGN,          // Flags
        "Contents"w.dup.ptr,     // HelpTopic
        MsgItems.ptr,            // Items
        MsgItems.length,         // ItemsNumber
        1);                      // ButtonsNumber

    return null;
}
