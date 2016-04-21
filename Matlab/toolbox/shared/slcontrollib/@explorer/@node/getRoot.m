function h = getRoot(this)
% GETROOT Returns the NEAREST node up in the tree hierarchy labeled as root
% (ISROOT = true).

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:47 $

% If no root is found returns itself.
h = this;

% Search for the root
while ~isa(h, 'explorer.tasknode') && ~isempty(h.up)
  h = h.up;
end
