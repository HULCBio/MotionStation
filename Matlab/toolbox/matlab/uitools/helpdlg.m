function varargout = helpdlg(HelpString,DlgName)
%HELPDLG Help dialog box.
%  HANDLE = HELPDLG(HELPSTRING,DLGNAME) displays the 
%  message HelpString in a dialog box with title DLGNAME.  
%  If a Help dialog with that name is already on the screen, 
%  it is brought to the front.  Otherwise a new one is created.
%
%  HelpString will accept any valid string input but a cell
%  array is preferred.
%
%  See also MSGBOX, QUESTDLG, ERRORDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 5.16 $  $Date: 2002/04/15 03:25:45 $

if nargin==0,
   HelpString ={'This is the default help string.'};
end
if nargin<2,
   DlgName = 'Help Dialog';
end

if ischar(HelpString) & ~iscellstr(HelpString)
    HelpString = cellstr(HelpString);
end
if ~iscellstr(HelpString)
    error('HelpString should be a string or cell array of strings');
end

HelpStringCell = cell(0);
for i = 1:length(HelpString)
    HelpStringCell{end+1} = xlate(HelpString{i});
end

handle = msgbox(HelpStringCell,DlgName,'help','replace');

if nargout==1,varargout(1)={handle};end
