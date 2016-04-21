HWND MDICmdFileNew(char *title)
{
	HWND  hwndChild;
	char  rgch[150];
	static int cUntitled;
	MDICREATESTRUCT mcs;

	if (title == NULL)
		wsprintf(rgch,"Untitled%d", cUntitled++);
	else {
		strncpy(rgch,title,149);
		rgch[149] = 0;
	}

	// Create the MDI child window

        mcs.szClass = "/*@@MDICHILDCLASS@@*/";      // window class name
        mcs.szTitle = rgch;             // window title
        mcs.hOwner  = hInst;            // owner
        mcs.x       = CW_USEDEFAULT;    // x position
        mcs.y       = CW_USEDEFAULT;    // y position
        mcs.cx      = CW_USEDEFAULT;    // width
        mcs.cy      = CW_USEDEFAULT;    // height
        mcs.style   = 0;                // window style
        mcs.lParam  = 0;                // lparam

        hwndChild = (HWND) SendMessage(hwndMDIClient,
                                       WM_MDICREATE,
                                       0,
                                       (LPARAM)(LPMDICREATESTRUCT) &mcs);

	if (hwndChild != NULL)
		ShowWindow(hwndChild, SW_SHOW);

	return hwndChild;
}

