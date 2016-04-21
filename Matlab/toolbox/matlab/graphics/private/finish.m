function pj = finish( pj )
%Finish Method to end a PrintJob at its current page.
%   Finish current page and close connection to device or file output is 
%   beeing spooled to. Proper way to end a print job.
%   
%   See also CANCEL

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:37 $

pj.Active = 0;

%Tell internal driver
if feature('NewPrintAPI')
    err = hardcopy( pj, 'finish' )
end
