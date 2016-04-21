function dir(cc)
%DIR List files in the Code Composer Studio(R) working directory.
%   DIR(CC) prints a list of files in Code Composer's current
%   working directory. 
%
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%   See also OPEN, CD

% Copyright 2000-2003 The MathWorks, Inc.
% $Revision: 1.5.4.4 $ $Date: 2004/04/08 20:45:44 $

error(nargchk(1,1,nargin));
error(nargchk(0,1,nargout));

ccdirectory = cd(cc(1));
dir(ccdirectory);

% [EOF] dir.m