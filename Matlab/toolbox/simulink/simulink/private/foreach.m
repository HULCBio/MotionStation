function varargout = foreach(iCellArray, iHook)
% FOREACH(CELLARRAY,HOOK) calls feval(HOOK{:},CELLARRAY{i}) for i =
% 1:length(CELLARRAY).  It is similar to CELLFUN but more general. For example,
%
%    foreach({'a','b','c'}, {@disp})
%
% calls
%
%    feval(@disp, 'a')
%    feval(@disp, 'b')
%    feval(@disp, 'c')
%
% and gives
%
%    a
%    b
%    c
%
% as output.  Another example is 
%
%    y = foreach({'a' 'b' 'c'}, {@sprintf, '<%s>'}),
%
% which calls
%
%    y{1} = feval(@sprintf, '<%s>', 'a')
%    y{2} = feval(@sprintf, '<%s>', 'b')
%    y{3} = feval(@sprintf, '<%s>', 'c')
%
% and gives
%
%    y = 
%
%        '<a>'    '<b>'    '<c>'
%
% as output.
%
% The input shape will be preserved in the output, e.g.
%
%    y = foreach({'a'; 'b'; 'c'}, {@sprintf, '<%s>'}),
%
% gives
%
%    y = 
%
%        '<a>'
%        '<b>'
%        '<c>'
%
% as output.
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  if nargout == 0
    findif(iCellArray, {@NeverStopNoOutput, iHook});
  else
    [dummyFinal varargout{1:nargout}] = ...
        findif(iCellArray, {@NeverStopWithOutput, iHook, nargout});
  end


function oFinal = NeverStopNoOutput(iHook, iCell)
  
  oFinal = {};
  
  feval(iHook{:}, iCell);
  
  
function [oFinal, varargout] = NeverStopWithOutput(iHook, iNargout, iCell)
  
  oFinal = {};
  
  [varargout{1:iNargout}] = feval(iHook{:}, iCell);
  