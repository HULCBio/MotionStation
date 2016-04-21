function cfsaveanalysis(varnames, data)
%CFSAVEANALYSIS saves analysis information to the workspace
%This is a helper function for the Curve Fitting tool

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/02/01 21:40:00 $

results = cfgetset('analysisresults');
if isempty(results) | ~isstruct(results) | ~isfield(results,'xi') ...
                    | isempty(results.xi)
   uiwait(warndlg('No analysis results available.',...
                  'Save to Workspace','modal'));
else
   assignin('base',varnames{1},results);
end


