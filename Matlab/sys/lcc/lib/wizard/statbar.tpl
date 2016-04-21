
// Global Variables for the status bar control.

HWND  hWndStatusbar;

/*------------------------------------------------------------------------
 Procedure:     UpdateStatusBar ID:1
 Purpose:       Updates the statusbar control with the appropiate
                text
 Input:         lpszStatusString: Charactar string that will be shown
                partNumber: index of the status bar part number.
                displayFlags: Decoration flags
 Output:        none
 Errors:        none

------------------------------------------------------------------------*/
void UpdateStatusBar(LPSTR lpszStatusString, WORD partNumber, WORD displayFlags)
{
    SendMessage(hWndStatusbar,
                SB_SETTEXT,
                partNumber | displayFlags,
                (LPARAM)lpszStatusString);
}


/*------------------------------------------------------------------------
 Procedure:     MsgMenuSelect ID:1
 Purpose:       Shows in the status bar a descriptive explaation of
                the purpose of each menu item.The message
                WM_MENUSELECT is sent when the user starts browsing
                the menu for each menu item where the mouse passes.
 Input:         Standard windows.
 Output:        The string from the resources string table is shown
 Errors:        If the string is not found nothing will be shown.
------------------------------------------------------------------------*/
LRESULT MsgMenuSelect(HWND hwnd, UINT uMessage, WPARAM wparam, LPARAM lparam)
{
    static char szBuffer[256];
    UINT   nStringID = 0;
    UINT   fuFlags = GET_WM_MENUSELECT_FLAGS(wparam, lparam) & 0xffff;
    UINT   uCmd    = GET_WM_MENUSELECT_CMD(wparam, lparam);
    HMENU  hMenu   = GET_WM_MENUSELECT_HMENU(wparam, lparam);

    szBuffer[0] = 0;                            // First reset the buffer
    if (fuFlags == 0xffff && hMenu == NULL)     // Menu has been closed
        nStringID = 0;

    else if (fuFlags & MFT_SEPARATOR)           // Ignore separators
        nStringID = 0;

    else if (fuFlags & MF_POPUP)                // Popup menu
    {
        if (fuFlags & MF_SYSMENU)               // System menu
            nStringID = IDS_SYSMENU;
        else
            // Get string ID for popup menu from idPopup array.
            nStringID = 0;
    }  // for MF_POPUP
    else                                        // Must be a command item
        nStringID = uCmd;                       // String ID == Command ID

    // Load the string if we have an ID
    if (0 != nStringID)
        LoadString(hInst, nStringID, szBuffer, sizeof(szBuffer));
    // Finally... send the string to the status bar
    UpdateStatusBar(szBuffer, 0, 0);
    return 0;
}


/*------------------------------------------------------------------------
 Procedure:     InitializeStatusBar ID:1
 Purpose:       Initialize the status bar
 Input:         hwndParent: the parent window
                nrOfParts: The status bar can contain more than one
                part. What is difficult, is to figure out how this
                should be drawn. So, for the time being only one is
                being used...
 Output:        The status bar is created
 Errors:
------------------------------------------------------------------------*/
void InitializeStatusBar(HWND hwndParent,int nrOfParts)
{
    const cSpaceInBetween = 8;
    int   ptArray[40];   // Array defining the number of parts/sections
    RECT  rect;
    HDC   hDC;

   /* * Fill in the ptArray...  */

    hDC = GetDC(hwndParent);
    GetClientRect(hwndParent, &rect);

    ptArray[nrOfParts-1] = rect.right;
    //---TODO--- Add code to calculate the size of each part of the status
    // bar here.

    ReleaseDC(hwndParent, hDC);
    SendMessage(hWndStatusbar,
                SB_SETPARTS,
                nrOfParts,
                (LPARAM)(LPINT)ptArray);

    UpdateStatusBar("Ready", 0, 0);
    //---TODO--- Add code to update all fields of the status bar here.
    // As an example, look at the calls commented out below.

//    UpdateStatusBar("Cursor Pos:", 1, SBT_POPOUT);
//    UpdateStatusBar("Time:", 3, SBT_POPOUT);
}


/*------------------------------------------------------------------------
 Procedure:     CreateSBar ID:1
 Purpose:       Calls CreateStatusWindow to create the status bar
 Input:         hwndParent: the parent window
                initial text: the initial contents of the status bar
 Output:
 Errors:
------------------------------------------------------------------------*/
static BOOL CreateSBar(HWND hwndParent,char *initialText,int nrOfParts)
{
    hWndStatusbar = CreateStatusWindow(WS_CHILD | WS_VISIBLE | WS_BORDER|SBARS_SIZEGRIP,
                                       initialText,
                                       hwndParent,
                                       IDM_STATUSBAR);
    if(hWndStatusbar)
    {
        InitializeStatusBar(hwndParent,nrOfParts);
        return TRUE;
    }

    return FALSE;
}
