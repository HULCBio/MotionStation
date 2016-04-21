function WS = findParametersWS(this, model, names)
% Finds in what workspace (model vs. base) parameters should be resolved.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:05 $

WS = cell( size(names) );
WS(:) = {'base'};  % Default workspace

% Find parameters that live in the model workspace
s = whos( get_param( model, 'ModelWorkspace' ) );
InMWS = ismember( strtok(names, '.({'), {s.name} );
WS(InMWS) = {'model'};
