function str = linsetup
%LINSETUP
%   Set up a model for snapshot linearization, i.e. linearization while the
%   model is running.
%
%   Return a name (based on the block name) that can be used as a workspace
%   variable name to store the resulting linear model.
%
%   See also SFUNLIN, LINMOD, DLINMOD

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $

smode = get_param(bdroot,'SimulationMode');
if ~strcmp(smode,'normal')
  error(sprintf('Linearization is not supported in %s mode', smode));
end

set_param(bdroot,'AnalyticLinearization','on');
set_param(bdroot,'BufferReuse','off');
set_param(bdroot,'RTWInlineParameters','on');
set_param(bdroot,'BlockReductionOpt','off');

% Workspace variable name will be based the name of the block
str = [ get_param(gcb,'Parent') '/' get_param(gcb,'Name') ];

% Replace any characters that won't make good variable names
str = regexprep(str,'[^a-zA-Z0-9_]','_');

% Remove any leading underscores
str = regexprep(str,'^_+','');

