function y = nncallbk(demo,command)
%NNCALLBK Neural Network Design utility function.

% NNCALLBK(DEMO,COMMAND)
%   DEMO - Name of demo.
%   COMMAND - Command.
% Returns string of form: DEMO('COMMAND').

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.10 $

y = sprintf('%s(''%s'')',demo,command);
