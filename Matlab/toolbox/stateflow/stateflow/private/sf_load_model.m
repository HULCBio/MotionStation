function sf_load_model(modelName)
%
% Silently loads a Simulink model given its name.
%

%   Jay Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:59:40 $

	eval([modelName,'([],[],[],''load'');'], '');

