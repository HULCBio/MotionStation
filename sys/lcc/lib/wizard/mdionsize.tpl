		// Position the MDI client window between the tool and status bars
		if (wParam != SIZE_MINIMIZED) {
			RECT rc, rcClient;
		
			GetClientRect(hwnd, &rcClient);
			GetWindowRect(hWndStatusbar, &rc);
			ScreenToClient(hwnd, (LPPOINT)&rc.left);
			rcClient.bottom = rc.top;
			MoveWindow(hwndMDIClient,rcClient.left,rcClient.top,rcClient.right-rcClient.left, rcClient.bottom-rcClient.top, TRUE);
		}
		
