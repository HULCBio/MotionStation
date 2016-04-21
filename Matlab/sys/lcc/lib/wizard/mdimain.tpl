		if (!TranslateMDISysAccel(hwndMDIClient, &msg))
			if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg)) {
				TranslateMessage(&msg);  // Translates virtual key codes
				DispatchMessage(&msg);   // Dispatches message to window
			}
