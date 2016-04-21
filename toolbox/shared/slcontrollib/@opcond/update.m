%UPDATE Update operating point object with structural changes in model.
%
%   UPDATE(OP) updates an operating point object, OP, to reflect any
%   changes in the associated  Simulink model, such as states being
%   added or removed.
%
%   Example:
%   Open the magball model
%     magball
%   Create an operating point object for the model.
%     op=operpoint('magball')
%   Add an Integrator block to the model.
%   Update the operating point to include this new state.
%     update(op)
%
%   See also OPERPOINT, OPERSPEC

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:23 $

