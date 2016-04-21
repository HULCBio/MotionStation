function helpbrowser
%HELPBROWSER Help Browser
%	HELPBROWSER Brings up the Help Browser.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

% Check for required level of Java support
err = javachk('mwt', 'The Help browser');
if (~isempty(err))
	error('MATLAB:helpbrowser:UnsupportedPlatform', 'The Help browser is not supported on this platform.  Try helpdesk or helpwin instead.');
end

try
    % Launch the Help Browser
    com.mathworks.mlservices.MLHelpServices.invoke;
catch
    % Failed. Bail
    error('MATLAB:helpbrowser:HelpBrowserFailed', 'Failed to open the Help browser');
end
