function x = vrwho
%VRWHO List all virtual worlds in memory.
%   VRWHO lists all virtual worlds currently present in memory.
%   X = VRWHO returns a vector of handles to all currently present
%   virtual worlds.
%
%   See also VRWHOS, VRWORLD, VRCLEAR.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.6.4.3 $ $Date: 2004/04/06 01:11:17 $ $Author: batserve $


% create the world objects
x = vrworld(vrsfunc('VRT3ListScenes'));

% print the info if output argument not required
if nargout==0
fprintf('\n');
disp(x);
clear x;
fprintf('\n');
end
