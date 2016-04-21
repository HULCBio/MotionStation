function result = setup( pj )
%SETUP Open the printer setup dialog.
%   If the device driver in the PrintJob object is setup, opens the window
%   system specific dialog for setting options for printing. Normally this 
%   dialog will affect all future printing using the window system's driver
%   (i.e. Windows drivers), not just the current Figure or model.
%
%   Ex:
%      err_code = SETUP( pj ); %returns 1 if successfuly opened setup
%                               dialog, 0 if not.
%
%   See also PRINT.
%   See also PRINT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:10 $

if strcmp('setup', pj.Driver)
    
    result = 1;
    if feature('NewPrintAPI')
        hardcopy( pj );
    else
        hardcopy(pj.Handles{1}(1), '-dsetup');
    end
else
    result = 0;
end
