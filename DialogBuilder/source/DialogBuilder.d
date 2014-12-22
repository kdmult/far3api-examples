// Public Domain

import core.sys.windows.windows;

import farplugin;
import dlgbuilder;
import pluginsettings;
import wcharutil;

GUID MainGuid = { 0xda3fef17, 0x1d62, 0x4537, [ 0x8f, 0xc6, 0x3a, 0x62, 0xd1, 0x70, 0x46, 0x8 ] };
GUID MenuGuid = { 0xc69ebe9, 0xf06d, 0x474d, [ 0x9f, 0xa6, 0xcc, 0xb8, 0x3f, 0xce, 0x26, 0x73 ] };
GUID DialogGuid = { 0x4d2361ac, 0x2dbe, 0x48b2, [ 0x84, 0x3b, 0x9c, 0x86, 0x76, 0xdf, 0x5d, 0xa4 ] };

enum {
    MOk,
    MCancel,
    MTitle,

    MText,
    MTextBefore,
    MTextAfter,
    MCheckbox,
    MButtonAfter,
    MRadioButton1,
    MRadioButton2,
    MTwoColumns,
    MRow1Col1,
    MRow2Col1,
    MRow1Col2,

    MLeft,
    MTop,
    MRight,
    MBottom,

    MEditField,
    MPasswordField,
    MFixEditField,

    MComboBox1,
    MComboBox2,
    MComboBox3,

    MListBox1,
    MListBox2,
    MListBox3,
    MListBox4
}

enum PLUGIN_BUILD  = 1;
enum PLUGIN_NAME   = "DialogBuilder"w;
enum PLUGIN_DESC   = "Dialog Builder example Plugin for Far Manager"w;
enum PLUGIN_AUTHOR = "Public Domain"w;
auto PLUGIN_VERSION() { return MakeFarVersion(FARMANAGERVERSION_MAJOR, FARMANAGERVERSION_MINOR, FARMANAGERVERSION_REVISION, PLUGIN_BUILD, FARMANAGERVERSION_STAGE); }

PluginStartupInfo Info;
FarStandardFunctions FSF;
PluginSettings settings;

const(wchar)* GetMsg(int msgId)
{
    return Info.GetMsg(&MainGuid, msgId);
}

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

export extern (Windows)
void SetStartupInfoW(PluginStartupInfo* info)
{
    Info = *info;
    FSF = *info.FSF;
    Info.FSF = &FSF;
    settings = new PluginSettings(MainGuid, Info.SettingsControl);
}

export extern (Windows)
void GetPluginInfoW(PluginInfo* info)
{
    info.StructSize=PluginInfo.sizeof;
    info.Flags=PF_EDITOR;
    static const(wchar)*[1] PluginMenuStrings;
    PluginMenuStrings[0] = GetMsg(MTitle);
    info.PluginMenu.Guids = &MenuGuid;
    info.PluginMenu.Strings = PluginMenuStrings.ptr;
    info.PluginMenu.Count = PluginMenuStrings.length;
}

export extern (Windows)
HANDLE OpenW(OpenInfo* info)
{
    auto dlg = new PluginDialogBuilder(&Info, MainGuid, DialogGuid, MTitle, null);

    auto textItem = dlg.AddText(MText);
    dlg.AddTextBefore(textItem, MTextBefore);
    dlg.AddTextAfter(textItem, MTextAfter);

    int checkbox = settings.Get(0, "checkbox", true);
    auto checkboxItem = dlg.AddCheckbox(MCheckbox, &checkbox);
    dlg.AddButtonAfter(checkboxItem, MButtonAfter);

    int radioButton = settings.Get(0, "radioButton", 1);
    dlg.AddRadioButtons(&radioButton, 2, [MRadioButton1, MRadioButton2]);

    dlg.StartSingleBox(MTwoColumns);
    dlg.StartColumns();
    dlg.AddText(MRow1Col1);
    dlg.AddText(MRow2Col1);
    dlg.ColumnBreak();
    dlg.AddText(MRow1Col2);
    dlg.AddEmptyLine();
    dlg.EndColumns();
    dlg.EndSingleBox();

    dlg.AddButtons(4, [MLeft, MTop, MRight, MBottom], -1);

    dlg.AddSeparator();

    dlg.StartColumns();
    int intEdit = settings.Get(0, "intEdit", -2);
    auto intEditItem = dlg.AddIntEditField(&intEdit, 3);
    dlg.AddTextBefore(intEditItem, MTextBefore);
    dlg.ColumnBreak();
    uint uintEdit = settings.Get(0, "uintEdit", 2);
    auto uintEditItem = dlg.AddUIntEditField(&uintEdit, 3);
    dlg.AddTextBefore(uintEditItem, MTextBefore);
    dlg.AddTextAfter(uintEditItem, MTextAfter);
    dlg.EndColumns();
    
    wchar[20] editField;
    settings.Get(0, "editField", editField, GetMsg(MEditField).toWString());
    dlg.AddEditField(editField.ptr, editField.length, editField.length);

    wchar[16] passwordField;
    settings.Get(0, "passwordField", passwordField, GetMsg(MPasswordField).toWString());
    auto passwordFieldItem = dlg.AddPasswordField(passwordField.ptr, passwordField.length, passwordField.length);
    dlg.AddTextBefore(passwordFieldItem, MPasswordField);

    wchar[30] fixEditField;
    settings.Get(0, "fixEditField", fixEditField, GetMsg(MFixEditField).toWString());
    dlg.AddFixEditField(fixEditField.ptr, fixEditField.length, fixEditField.length);

    int comboBox = settings.Get(0, "comboBox", 1);
    wchar[40] comboBoxText = "";
    dlg.AddComboBox(&comboBox, comboBoxText.ptr, 20, [MComboBox1, MComboBox2, MComboBox3], 3, DIF_NONE);

    int listBox = settings.Get(0, "listBox", 2);
    dlg.AddListBox(&listBox, 20, 3, [MListBox1, MListBox2, MListBox3, MListBox4], 4, DIF_NONE);

    dlg.AddOKCancel(MOk, MCancel);

    if (dlg.ShowDialog())
    {
        settings.Set(0, "checkbox", checkbox);
        settings.Set(0, "radioButton", radioButton);
        settings.Set(0, "intEdit", intEdit);
        settings.Set(0, "uintEdit", uintEdit);
        settings.Set(0, "editField", editField);
        settings.Set(0, "passwordField", passwordField);
        settings.Set(0, "fixEditField", fixEditField);
        settings.Set(0, "comboBox", comboBox);
        settings.Set(0, "listBox", listBox);
    }

    return null;
}
