function [Tstart, Tstop, Fail] = getSimInterval(this, model)
% GETSIMTIME Get simulation interval from the MODEL

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:11 $

ModelWS = get_param( model, 'ModelWorkspace' );
s = whos(ModelWS);
ModelWSVars = {s.name};

[Tstart, FailStart] = evalExpression( this, ...
                                      get_param( model, 'StartTime' ), ...
                                      ModelWS, ModelWSVars );

[Tstop, FailStop]   = evalExpression( this, ...
                                      get_param( model, 'StopTime' ), ...
                                      ModelWS, ModelWSVars );

FailRange = (Tstart > Tstop) | isinf(Tstart);
Fail = FailStop || FailStart || FailRange;
