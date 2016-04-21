function cleanup(ff,opt)
% CLEANUP Returns CCS into its state before function call.
%   CLEANUP(FF) Returns CCS into its state before the function was called. 
%   This method restores values of the registers in the ff.savedregs list,
%   cleans up the stack and resets FF properties.
%
%   CLEANUP is an optional step after running a function.
%
%   See also RUN.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:08:15 $

error(nargchk(1,2,nargin));
if nargin==1
    p_cleanup(ff,'all');
else
    p_cleanup(ff,opt);
end

% [EOF] cleanup.m