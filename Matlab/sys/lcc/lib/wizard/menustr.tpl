// This tables contains the explanation strings to be shown in the status
// bar when the uses moves the mouse in an open menu.
// Organization: 
// For each popup menu, there is the identifier of the popup itself, followed
// by the strings for all items in that menu. The ID of each string is its
// command #define.
//
STRINGTABLE DISCARDABLE
BEGIN
    IDS_FILEMENU        "Create, open, save, or print documents"
    IDM_NEW             "Creates a new document"
    IDM_OPEN            "Opens an existing document"
    IDM_SAVE            "Saves the active document"
    IDM_SAVEAS          "Saves the active document under a different name"
    IDM_CLOSE           "Closes the active document"
END

STRINGTABLE DISCARDABLE
BEGIN
    IDM_EXIT                "Quits this application"
END

STRINGTABLE DISCARDABLE
BEGIN
    IDS_HELPMENU            "Get help"
    IDM_ABOUT               "Displays information about this application"
END
