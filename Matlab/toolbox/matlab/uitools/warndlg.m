function varargout = warndlg(WarnString,DlgName,Replace)
%WARNDLG Warning dialog box.
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME) creates an warning dialog box
%  which displays WARNSTRING in a window named DLGNAME.  A pushbutton
%  labeled OK must be pressed to make the warning box disappear.
%  
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME,CREATEMODE) allows CREATEMODE options
%  that are the same as those offered by MSGBOX.  The default value
%  for CREATEMODE is 'non-modal'.
%
%  WARNSTRING may be any valid string format.  Cell arrays are
%  preferred.
%
%  See also MSGBOX, HELPDLG, QUESTDLG, ERRORDLG, WARNING.

%  Author: L. Dean
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 5.24 $  $Date: 2002/04/15 03:27:37 $

if nargin==0,
   WarnString = 'This is the default warning string.';
end
if nargin<2,
   DlgName = 'Warning Dialog';
end
if nargin<3,
   Replace = 'non-modal';
end

if ischar(WarnString) & ~iscellstr(WarnString)
    WarnString = cellstr(WarnString);
end
if ~iscellstr(WarnString)
    error('WarnString should be a string or cell array of strings');
end

WarnStringCell = cell(0);
for i = 1:length(WarnString)
    WarnStringCell{end+1} = xlate(WarnString{i});
end

handle = msgbox(WarnStringCell,DlgName,'warn',Replace);

if nargout==1,varargout(1)={handle};end
