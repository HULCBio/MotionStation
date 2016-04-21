function initialize(this, hVars)
% INITIALIZE Creates and initializes the gradient model

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:41 $

% Short names
gradsys = this.GradModel;

% Create model for simulating the actual and the perturbed models
% simultaneously.
try
  new_system( gradsys );
  set_param( gradsys, 'Location', [100 100 500 400] );
catch
  close_system( gradsys, 0 );
  error( 'Error creating gradient model ''%s''.', gradsys );
end

% Get set of MATLAB variables involved in optimization. 
% RE: The variable for "controller.P(1)" is "controller"
VarNames = unique( strtok(get(hVars,{'Name'}), '.({') );

% Create variables which will be used in gradient model simulations.
this.Variables = struct( 'Name', VarNames, 'LValue', [], 'RValue',[] );

% Create the gradient model content
try
  copymdl(this);
catch
  close_system( gradsys, 0 );
  error( 'Error creating gradient model ''%s''.', gradsys );
end

% Copy model workspace from original model
wsOrig = get_param(this.OrigModel, 'ModelWorkspace');
wsGrad = get_param(gradsys, 'ModelWorkspace');
s = whos(wsOrig);
for ct = 1:length(s)
  pname = s(ct).name;
  wsGrad.assignin( pname, wsOrig.evalin(pname) )
end

% Make sure gradsys is properly loaded in memory.
try
  load_system(gradsys);
catch
  close_system( gradsys, 0 );
  error( 'Error loading gradient model ''%s''.', gradsys );
end
