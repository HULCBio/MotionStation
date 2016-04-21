function pj = newpage( pj )
%NEWPAGE Method to finish the current page of a PrintJob and start next.
%   Depending on current driver being used, may cause current page
%   from being ejected from output device.
%
%   Ex:
%      pj = NEWPAGE( pj ); %modfies PrintJob object state
%
%   See also RENDER, FINISH, CANCEL.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:46 $

if ~pj.Active
   error('PrintJob is not active')
end

pj.PageNumber = pj.PageNumber + 1;

%Tell internal driver
if feature('NewPrintAPI')
    err = hardcopy( pj, 'newpage' );
end
