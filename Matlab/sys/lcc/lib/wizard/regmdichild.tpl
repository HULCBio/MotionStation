	wc.style         = 0;
	wc.lpfnWndProc   = (WNDPROC)/*@@MDICHILDWNDPROC@@*/;
	wc.cbClsExtra    = 0;
	wc.cbWndExtra    = 20;
	wc.hInstance     = hInst;                      // Owner of this class
	wc.hIcon         = LoadIcon(hInst, MAKEINTRESOURCE(IDI_CHILDICON));
	wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1); // Default color
	wc.lpszMenuName  = NULL;
	wc.lpszClassName = "/*@@MDICHILDCLASS@@*/";
	if (!RegisterClass((LPWNDCLASS)&wc))
		return FALSE;
