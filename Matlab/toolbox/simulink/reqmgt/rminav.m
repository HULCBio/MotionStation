function rminav
%RMINAV Requirements Management Interface Navigator.
%   RMINAV Starts the Requirements Interface Navigator.
%

%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:36:52 $

reqwindow = com.mathworks.toolbox.reqmgt.ReqMgtWindow;
reqviewer = com.mathworks.toolbox.reqmgt.RequirementBrowser.createBrowser(reqmgropts);
reqwindow.setProjectViewer(reqviewer);
reqwindow.setVisible(1);

%e nd function rminav
