function sqclose(hFig,optstr)
%CLOSE Closes the SQDTool GUI with handle hFig.
%   If the session has not been saved the user will be prompted 
%   to save the session.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:11 $

error(nargchk(1,2,nargin));

% Check the optional input and make sure that it is valid.
if nargin < 2 | ~ischar(optstr), optstr = ''; end

ud = get(hFig,'UserData');

% If called with "force" close the figure without prompting.
% Skip closing if Cancel button is pressed on save dialog.
if strcmpi(optstr,'force') | sqsave_if_dirty(hFig,'closing'),
    set(hFig, 'Visible', 'Off');
	delete(hFig);
	clear hFig;
end


%---------------------------------------------------------------------
function sqSaveFigfile(hFig)
% SAVEFIGFILE Check if we need to save a new FIG-file based on the 
%    title of the fig (dirty or not).  If so, update the title, update figure's 
%    userdata, and save the GUI's FIG-file.

ud = get(hFig,'Userdata');
FigName = get(hFig,'Name');
dirtyFig = strcmp(FigName(end) =='*');
if dirtyFig
    FigName(end)='';
    set(hFig,'Name',FigName);
    set(hFig,'Userdata',ud);

    try
        % Try saving it in the Preference directory.
        pathNfile = fullfile(prefdir,ud.filename.defaultfigfile);
        hgsave(hFig,pathNfile);
    catch
        % Try saving it in the toolbox directory.
        pathNfile = fullfile(matlabroot,'toolbox','signal',...
            'fdatoolgui',ud.filename.defaultfigfile);
        try, hgsave(hFig,pathNfile); catch, end
    end
    
end

% [EOF]
