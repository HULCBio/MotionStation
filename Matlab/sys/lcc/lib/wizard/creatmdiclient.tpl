//
//  FUNCTION: CreateMdiClient(HWND)
//
//  PURPOSE: To create an MDI client window.
//
//  PARAMETERS:
//    hwnd - The window handing the message.
//  RETURN VALUE:
//    The handle of the mdiclient window.
static HWND CreateMdiClient(HWND hwndparent)
{
    CLIENTCREATESTRUCT ccs = {0};
    HWND hwndMDIClient;
    int icount = GetMenuItemCount(GetMenu(hwndparent));

    // Find window menu where children will be listed
    ccs.hWindowMenu  = GetSubMenu(GetMenu(hwndparent), icount-2);
    ccs.idFirstChild = IDM_WINDOWCHILD;

    // Create the MDI client filling the client area
    hwndMDIClient = CreateWindow("mdiclient",
                                 NULL,
                                 WS_CHILD | WS_CLIPCHILDREN | WS_VSCROLL |
                                 WS_HSCROLL,
                                 0, 0, 0, 0,
                                 hwndparent,
                                 (HMENU)0xCAC,
                                 hInst,
                                 (LPVOID)&ccs);

    ShowWindow(hwndMDIClient, SW_SHOW);

    return hwndMDIClient;
}

