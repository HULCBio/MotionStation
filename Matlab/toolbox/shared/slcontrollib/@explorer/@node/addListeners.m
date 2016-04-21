function addListeners(this, listeners)
% ADDLISTENERS Install listeners

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:34 $

% Append new listeners
this.Listeners = [ this.Listeners; listeners(:) ];
