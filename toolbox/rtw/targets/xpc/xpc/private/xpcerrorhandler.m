function [message] = xpcerrorhandler
% XPCERRORHANDLER xPC private function
%
%   XPCERRORHANDLER parses the last error and prints the most important
%   part, i.e. without all the stack information.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.6.1 $ $Date: 2004/04/08 21:04:41 $

fullMessage = lasterr;                  % store the message away.
tokens = tokenize(fullMessage, sprintf('\n'));
message = sprintf('%s\n', tokens{:});
% End xpcerrorhandler()

% Function: tokenize =====================================================
% Abstract: This function takes a string and a set of delimiters, and
%           returns all the tokens in a cell array. The default delimiter
%           is whitespace. All empty lines and lines starting with
%           'Error using ==>' are removed.
function tokens = tokenize(string, delim)
tokens = strread(string,'%s','delimiter',delim);
tokens(strmatch('Error using ==>', tokens))          = [];
tokens(strmatch('',                tokens, 'exact')) = [];
% End tokenize()

%% EOF xpcerrorhandler.m
