function [name] = cfgetuniquewsname(nameprefix)
% CFGETUNIQUEWSNAME Creates unique variable names  

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $

% get all names that start with prefix in workspace
workvars = evalin('base', ['char(who(''',nameprefix,'*''))']);
% trim off prefix name
workvars = workvars(:,length(nameprefix)+1:end); 

if ~isempty(workvars)
    % remove all names with suffixes that are "non-numeric"
    lessthanzero = workvars < '0';
    morethannine = workvars > '9';
    notblank = (workvars ~= ' ');
    notnumrows = any((notblank & (lessthanzero | morethannine)),2);
    workvars(notnumrows,:) = [];
end

% find the "next one"
if isempty(workvars)
    name = [nameprefix, '1'];
else
    nextone = max(str2num(workvars)) + 1;
    name = [nameprefix, num2str(nextone)];
end

