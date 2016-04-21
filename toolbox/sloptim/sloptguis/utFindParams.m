function WS = utFindParams(Model,ParamNames)
% Finds in what workspace (model vs. base) parameters should be resolved.

%   $Revision: 1.1.6.2 $ $Date: 2004/03/24 21:13:11 $
%   Copyright 1986-2004 The MathWorks, Inc.
WS = cell(size(ParamNames));
WS(:) = {'base'};  % default
% Find parameters that live in the model workspace
s = whos(get_param(Model,'ModelWorkspace'));
InMWS = ismember(strtok(ParamNames,'.({'),{s.name});
WS(InMWS) = {'model'};