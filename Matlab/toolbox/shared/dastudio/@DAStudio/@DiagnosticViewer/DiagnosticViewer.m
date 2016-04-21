function h = DiagnosticViewer(name)
%  DIAGNOSTICVIEWER
%  This is the constructor for the 
%  DiagnosticViewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
 rt = DAStudio.Root;
 h = DAStudio.DiagnosticViewer;
 % Here load the appropriate listeners for these properites
 h.visibleListener;
 h.openListener;
 h.selectListener;
 
 %Load Visibility of column listeners
 h.showSummaryListener;
 h.showMessageListener;
 h.showReportedListener;
 h.showSourceListener;
 %Here initialize appropriate fields
 h.rowSelected= -1;
 h.rowOpen = -1;
 h.name = name;
 h.summaryVisible = 1;
 h.messageVisible = 1;
 h.sourceVisible = 1;
 h.reportVisible = 1;
 blockH = [-1.0 -1.0 -1.0 -1.0 -1.0];
 h.reverseSort = [h.reverseSort; blockH];
 connect(rt,h,'down');
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:23 $
