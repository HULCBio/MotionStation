void /*@@CLS@@*/_OnCommand(HWND hwnd, int id, HWND hwndCtl, UINT codeNotify)
{
	switch(id) {
		// ---TODO--- Add new menu commands here
		/*@@NEWCOMMANDS@@*/
		case IDM_NEW:
		MDICmdFileNew(NULL); // Use a character string if you do not
					// want the default "untitled%d" title
		break;
		case IDM_WINDOWTILE:
		SendMessage(hwndMDIClient,WM_MDITILE,0,0);
		break;
		case IDM_WINDOWCASCADE:
		SendMessage(hwndMDIClient,WM_MDICASCADE,0,0);
		break;
		case IDM_WINDOWICONS:
		SendMessage(hwndMDIClient,WM_MDIICONARRANGE,0,0);
		break;
		case IDM_EXIT:
		PostMessage(hwnd,WM_CLOSE,0,0);
		break;
	}
}
