/////////////////////////////////////////////////////////////////////////////
//
// Menu
//
IDMAINMENU MENU DISCARDABLE 
BEGIN
    POPUP "&File"
    BEGIN
        MENUITEM "&New",                        IDM_NEW
        MENUITEM "&Open...",                    IDM_OPEN, GRAYED
        MENUITEM "&Save",                       IDM_SAVE, GRAYED
        MENUITEM "Save &As...",                 IDM_SAVEAS, GRAYED
        MENUITEM "&Close",                      IDM_CLOSE, GRAYED
        MENUITEM SEPARATOR
        MENUITEM "&Print",                      IDM_PRINT, GRAYED
        MENUITEM "P&rint Setup...",             IDM_PRINTSU, GRAYED
        MENUITEM SEPARATOR
        MENUITEM "E&xit",                       IDM_EXIT
    END
    POPUP "&Edit"
    BEGIN
        MENUITEM "&Undo\tAlt+BkSp",             IDM_EDITUNDO, GRAYED
        MENUITEM SEPARATOR
        MENUITEM "Cu&t\tShift+Del",             IDM_EDITCUT, GRAYED
        MENUITEM "&Copy\tCtrl+Ins",             IDM_EDITCOPY, GRAYED
        MENUITEM "&Paste\tShift+Ins",           IDM_EDITPASTE, GRAYED
        MENUITEM "&Delete\tDel",                IDM_EDITCLEAR, GRAYED
    END
    POPUP "&Window"
    BEGIN
        MENUITEM "&Tile",                       IDM_WINDOWTILE
        MENUITEM "&Cascade",                    IDM_WINDOWCASCADE
        MENUITEM "Arrange &Icons",              IDM_WINDOWICONS
        MENUITEM "Close &All",                  IDM_WINDOWCLOSEALL
    END
    POPUP "&Help"
    BEGIN
        MENUITEM "&About...",                   IDM_ABOUT
    END
END


/////////////////////////////////////////////////////////////////////////////
//
// Accelerator
//

BARMDI ACCELERATORS MOVEABLE PURE 
BEGIN
    "Q",            IDM_EXIT,               VIRTKEY, CONTROL
END


/////////////////////////////////////////////////////////////////////////////
//
// String Table
//


STRINGTABLE DISCARDABLE 
BEGIN
    IDM_NEW             "Creates a new document"
    IDM_OPEN            "Opens an existing document"
    IDM_SAVE            "Saves the active document"
    IDM_SAVEAS          "Saves the active document under a different name"
    IDM_CLOSE           "Closes the active document"
    IDM_PRINT           "Prints the active document"
    IDM_PRINTSU         "Changes the printer selection or configuration"
    IDM_EXIT                "Quits this application"
    IDM_EDITUNDO            "Reverses the last action"
    IDM_EDITCUT             "Cuts the selection and puts it on the clipboard"
    IDM_EDITCOPY            "Copies the selection and puts it on the clipboard"
    IDM_EDITPASTE           "Inserts the clipboard contents at the insertion point"
    IDM_EDITCLEAR           "Removes the selection without putting it on the clipboard"
    IDM_WINDOWTILE          "Arranges windows as non-overlapping tiles"
    IDM_WINDOWCASCADE       "Arranges windows as overlapping tiles"
    IDM_WINDOWCLOSEALL      "Closes all open windows"
    IDM_WINDOWICONS         "Arranges minimized window icons"
    IDM_WINDOWCHILD         "Switches to "
END

STRINGTABLE DISCARDABLE 
BEGIN
    IDS_HELPMENU            "Get help"
    IDM_ABOUT               "Displays information about this application"
END
