function synchronizeJavaViewer(h,varargin)
%  SYNCHRONIZEJAVAVIEWER
%  This function will synchronize the java window
%  with the udd representation 
%  of the Diagnsotic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
   
%  $Revision: 1.1.6.2 $ 

  
% Make sure java is engaged
   if (h.javaEngaged == 1)
     if (h.javaAllocated == 1)
       switch nargin,
	case 1, selectRow = 1;
	case 2, selectRow = varargin{1};
	otherwise,
	 selectRow = 1;
       end;
       % Here get the handle to the actual java object  
       win = h.jDiagnosticViewerWindow;
       % Here walk through all the messages of UDD object
       % and add them to the java window
       % Do a clean up in case something is already there
       win.removeAllMsgs;
       win.addDiagnosticMsgs;
       win.synchronizeColumnVisib;
       win.selectDiagnosticMsg(selectRow);
     else
       error('Java not engaged');
     end;
   end;
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:53 $
