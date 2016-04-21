function uiresume (hFigDlg)
%UIRESUME Resume execution of blocked M-file.
%   UIRESUME(FIG) resumes the m-file execution that was suspended by a
%   UIWAIT(FIG) command.  UIRESUME is a companion function to UIWAIT.
%
%   See also UIWAIT, WAITFOR.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:25:51 $

% -------- Validate argument
if nargin < 1,
    hFigDlg = gcf;
end
if ~strcmp (get(hFigDlg, 'Type'), 'figure') 
    error ('Input argument must be of type dialog')
end

set (hFigDlg, 'waitstatus', 'inactive');
