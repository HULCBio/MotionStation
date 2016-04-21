function p = findpar(this,name)
% Finds parameter with a given name.
%
% Example:
%   proj = getsro('srodemo1')
%   p = findpar(proj,'P')

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:12 $
%   Copyright 1986-2004 The MathWorks, Inc.

% RE: Returns a @Parameter object
if isempty(this.Parameters)
   p = [];
else
   p = find(this.Parameters,'Name',name);
end
