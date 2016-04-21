function this = GradientModel(model, hVars)
% GRADIENTMODEL Constructor

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:39 $

% Create object
this = slcontrol.GradientModel;

% Set properties
this.OrigModel  = model;
tmpstr = strrep( tempname, tempdir, '' );
this.GradModel  = tmpstr;
this.WSVariable = tmpstr;

% Create and initialize gradient model
initialize(this, hVars)

% Listeners
L = [ handle.listener( this, 'ObjectBeingDestroyed', @LocalDelete ) ];
set( L, 'CallbackTarget', this );
this.Listeners = L;

% ----------------------------------------------------------------------------%
function LocalDelete(this, hdata)
% Delete temporary variables in the workspace
evalin( 'base', [ 'clear ' this.WSVariable ] )   % parameters
evalin( 'base', [ 'clear x' this.WSVariable ] )  % initial state

% Close the model
if exist( this.GradModel, 'file') == 4
  close_system( this.GradModel, 0 );
end
