function [final, varargout] = findif(iCellArray, iHook)
% FINDIF(CELLARRAY,HOOK) calls feval(HOOK{:},CELLARRAY{i}) while 0 < i <=
% length(CELLARRAY) and the first output of the feval is empty.  For example,
%
%    findif({' ' '' 'a b' 'c'}, {@strtok})
%
% calls
%
%    feval(@strtok, ' ')
%    feval(@strtok, '')
%    feval(@strtok, 'a b')
%
% and gives
%
%    ans =
%
%    a
%
% as output.  Another example is
%
%     [t r] = findif({' ' '' 'a b' 'c'}, {@strtok}),
%
% which calls
%
%    [t r{1}] = feval(@strtok, ' ')
%    [t r{2}] = feval(@strtok, '')
%    [t r{3}] = feval(@strtok, 'a b')
%
% and gives
%
%    t =
%
%    a
%
%    r = 
%
%        ''     ''    ' b'
%
% as output.  Note how this differs from
%
%   [t r] = foreach({' ' '' 'a b' 'c'}, {@strtok}),
%
% which calls
%
%    [t{1} r{1}] = feval(@strtok, ' ')
%    [t{2} r{2}] = feval(@strtok, '')
%    [t{3} r{3}] = feval(@strtok, 'a b')
%    [t{4} r{4}] = feval(@strtok, 'c')
%
% and gives
%
%     t = 
%
%         ''     ''    'a'    'c'
%
%     r = 
%
%         ''     ''    ' b'     ''
%
% as output.
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  CheckCA(iCellArray,'1st');
  CheckCA(iHook,'2nd');
  CheckFunc(iHook{1});
  
  out = {};
  final = {};
  i = 1;
  
  while isempty(final) && i <= length(iCellArray)
    
    if nargout > 1
      [final out{i,1:nargout-1}] = feval(iHook{:}, iCellArray{i});
    else
      final = feval(iHook{:}, iCellArray{i});
    end
    
    i= i+1;
    
  end
  
  % Here we reshape the output so that it has the same shape as the input.  Note
  % that unlike foreach, whose output will have the same dimensions as the
  % input, findif will only have the same shape because it may not iterate over
  % the entire input. E.g. output might be 3x1 even though input is 4x1.
  
  dim = size(iCellArray);
  dim(dim > 1) = i-1; % turn nx1 into (i-1)x1 or 1xn into 1x(i-1)
  for j=1:nargout-1
    varargout{j} = reshape({out{:,j}}, dim(1), dim(2));
  end

    

function CheckFunc(f)
  
  if ~isa(f, 'function_handle') && ~ischar(f)
    error(['Function handle or char expected as 1st cell '...
           'of 2nd argument, got a ' class(f)]);
  end


function CheckCA(iCA, iNth)
  
  if ~iscell(iCA)
    error(['Cell array expected as ' iNth ' argument, got a ' class(iCA)]);
  end
