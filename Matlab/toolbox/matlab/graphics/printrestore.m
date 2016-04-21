function pj = printrestore( pj, h )
%PRINTRESTORE Reset a Figure or Simulink model after printing.
%   When printing a model or Figure, some properties have to be changed
%   to create the desired output. PRINTRESTORE resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = PRINTRESTORE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PRINTPREPARE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:06:09 $


error( nargchk(2,2,nargin) )

% call private version.
pj = restore(pj, h);

