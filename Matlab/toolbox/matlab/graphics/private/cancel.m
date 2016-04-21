function pj = cancel( pj )
%Cancel Method to interupt a print job and finish it right now.
%   Stop the spooling of output. System dependent on how soon the current
%   print job can be stopped. Output will be terminated or incomplete depending
%   on driver and operating system.
%
%   See also FINISH

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:29 $

pj.Active = 0;

%Tell internal driver
if feature('NewPrintAPI')
    err = hardcopy( pj, 'cancel' )
end
