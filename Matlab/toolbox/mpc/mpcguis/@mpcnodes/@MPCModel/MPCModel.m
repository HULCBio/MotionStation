function this = MPCModel(Name,LTIobj)
%  Constructor for @MPCModel class

%  Author(s): Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:34 $

% Create class instance
this = mpcnodes.MPCModel;
% If nargin == 0 we are initializing from a saved state
if nargin > 0
    this.Name = Name;
    this.Label = Name; %jgo
    this.Model = LTIobj;
    this.Notes = char(LTIobj.Notes);
end
