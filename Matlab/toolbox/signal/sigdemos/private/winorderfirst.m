function winDat = winOrderFirst(winobj,convType)

%WINORDERFIRST conversion of zero-order window to first-order
%  W = WINORDERFIRST(WINF,PARAM,NP,TYPE) - returns the a 
%  first-order window that is numerically derived from a zero-order
%  window handle (WINF).  The resulting vector W is a first-order window
%  with NP points.  If the root zero-order window requires a parameter,
%  it should be defined in PARAM, otherwise it should be an empty
%  array: [].  This routine defines several methods of creating
%  a first-order window which are selected by the TYPE input.  The 
%  following list defines the TYPES that are supported.
%
% TYPE - conversion method
%    'fderive' - first deriviative of zero-order window
%    'sin'     - mulitples zero-order window by one period of
%                sin wave
%    'mirror'  - appends two half-period version of the zero-order 
%                window and  reverses the sign of second one
%
%  See also WINDTRANDEMO, WINORDERFIRST, SCALEWINFO 

%   Author(s): A. Dowd
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 01:19:48 $

error(nargchk(2,2,nargin));
Npts = winobj.length;

if strcmpi(convType,'fderive')
    winobj.length = Npts-1;
    winDat0 = generate(winobj);
    
    winDat = diff( [0; winDat0; 0] );
elseif strcmpi(convType,'sin')
    winDat0 = generate(winobj);
    
    winDat = winDat0.*sin(linspace(0,2*pi,Npts)');
elseif strcmpi(convType,'mirror')
    isodd = (mod(Npts,2) == 1);
    if  isodd,   % if odd insert 0 in middle
        winobj.length = round(Npts/2-1);
        winDat0 = generate(winobj);
        
        winDat = [winDat0; 0; -1*winDat0];
    else
        winobj.length = round(Npts/2);
        winDat0 = generate(winobj);
        
        winDat = [winDat0; -1*winDat0];
    end
else
    error(['Technique '' type '' for computing first-order window not recognized']);
end
return

% [EOF] winorderfirst.m
