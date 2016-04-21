function [list, prob_files, prob_symbols, prob_strings] = depdir(varargin)
%DEPDIR  Locate dependent directories of an M-file or P-file.
%    LIST = DEPDIR('FUN') returns a cell array of directory names
%    that FUN is dependent on.
%
%    [LIST,PROB_FILES,PROB_SYMBOLS,PROB_STRINGS] = DEPDIR('FUN')
%    also returns a list of M-files or P-files that couldn't be parsed in 
%    PROB_FILES, a list of symbols that couldn't be found in PROB_SYMBOLS, and
%    list of strings that couldn't be parsed in PROB_STRINGS.
%
%    [...] = DEPDIR('FILE1','FILE2',...) processes each file in turn.
%
%    See also DEPFUN.

%    Copyright 1984-2004 The MathWorks, Inc. 
%    $Revision: 1.8.4.1 $ $Date: 2004/01/28 23:10:54 $

% Use depfun to get a list of the dependent functions
%
[list,builtins,classes,prob_files,prob_symbols,prob_strings] = ...
					depfun(varargin{:},'-quiet');

% Strip off function names in list
%
for i=1:length(list)
  list{i} = fileparts(list{i});
end

% Find the unique set
%
list = unique(list);
