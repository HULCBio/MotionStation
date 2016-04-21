function vqclose(hFig,optstr)
%CLOSE Closes the VQDTool GUI with handle hFig.
%   If the session has not been saved the user will be prompted 
%   to save the session.

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:50 $

error(nargchk(1,2,nargin));

% Check the optional input and make sure that it is valid.
if nargin < 2 | ~ischar(optstr), optstr = ''; end

ud = get(hFig,'UserData');

% If called with "force" close the figure without prompting.
% Skip closing if Cancel button is pressed on save dialog.
if strcmpi(optstr,'force') | vqsave_if_dirty(hFig,'closing'),
    set(hFig, 'Visible', 'Off');
	delete(hFig);
	clear hFig;
end

% [EOF]
