function setDirty(this, flag)
% SETDIRTY Sets the Dirty flag of the project node (@projectnode) that
% contains THIS to FLAG.  If FLAG is not specified, Dirty is set to true.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:53 $

% If no root is found returns itself.
h = this;

% Search for the container project node
while ~isa(h, 'explorer.projectnode') && ~isempty(h.up)
  h = h.up;
end

% Set the flag
if nargin < 2
  flag = true;
end

if isa(h, 'explorer.projectnode')
  h.Dirty = flag;
end
