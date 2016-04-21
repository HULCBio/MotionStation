function varargout = desktop(option)
%DESKTOP Start and query the MATLAB Desktop.
%   DESKTOP starts the MATLAB Desktop using the configuration
%   stored the last time the Desktop was run, or the default
%   configuration if no configuration file is present.
%
%   DESKTOP -NORESTORE doesn't restore the configuration from the last
%   time the desktop was run.
%
%   USED = DESKTOP('-INUSE') returns whether or not the Desktop is
%   currently in use.  It does not start the Desktop.
%
%   See also JAVACHK, USEJAVA.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.5 $  $Date: 2004/03/17 20:05:08 $

import com.mathworks.mde.desk.MLDesktop;

% Check for required level of Java support
err = javachk('mwt', 'Desktop');
if (~isempty(err))
    error(err.identifier, err.message);
end

%Launch the Desktop
if nargin>0
    if strcmp(option,'-norestore')
        try
            MLDesktop.getInstance.initMainFrame(0, 0);
        catch
            error('MATLAB:desktop:DesktopFailure', 'Failed to open Desktop');
        end
    elseif strcmp(option, '-inuse')
        try
            varargout{1} = MLDesktop.getInstance.hasMainFrame;
        catch
            error('MATLAB:desktop:DesktopQueryFailure', ...
                'Failed to query the Desktop');
        end
    else
        error('MATLAB:desktop:FirstArgInvalid', ...
            ['DESKTOP input argument must be',...
            ' ''-inuse'' or ''-norestore''']);
    end
else
    try
        MLDesktop.getInstance.initMainFrame(0, 1);
    catch
        error('MATLAB:desktop:DesktopFailure', ...
            'Failed to open the Desktop');
    end
end
