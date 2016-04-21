function oStr = strcat_with_seperator(iCell, iSep)
% Concantenates the strings in iCell with iSep character in the middle.
%
% for example:
%              strcat_with_seperator({'foo', 'goo', 'moo', 'zoo'}, '->')
% returns
%              'foo->goo->moo->zoo'

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

  % make iCell into a row vector
  iCell = iCell(:); iCell = iCell';
  
  n = length(iCell);
  if n == 1,
    oStr = iCell{1};
    return;
  end

  tmpCell = [iCell(1:n-1); repmat({iSep}, 1, n-1)];
  oStr = [[tmpCell{:}], iCell{n}];
  
% endfunction
