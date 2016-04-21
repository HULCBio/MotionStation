function datatipinfo(val)
%DATATIPINFO Produce a short description of a variable.
%   DATATIPINFO(X) produces a short description of a variable, as for use in
%   debugger DataTips.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/02/25 07:52:00 $
if nargin ~= 1
   return
end

if isempty(val)
   disp(sizeType(inputname(1), val, 1));
    
% The short description amounts to a summary, so we don't want
% to produce a huge amount of information.  As a rough rule of
% thumb, print the full text of the value only if the total
% number of elements is less than an arbitrary cutoff (500).
elseif numel(val) <= 500 && ndims(val) <= 2
   disp([sizeType(inputname(1), val, 0) ' =']);
   disp(val);

% Otherwise, unless this is a 1xN or Nx1 matrix (in which case we
% print the first 500 characters), just print a description of
% the value (along the lines of '40x40 double')
else
   s = size(val);
   if numel(val) > 500 && ndims(val) == 2 && ...
      (s(1) == 1 || s(2) == 1) 
      disp([sizeType(inputname(1), val, 0) ' =']);
      disp(val(1:500));
   else
      disp(sizeType(inputname(1), val, 0));
   end
end

function prefix= sizeType(name, val, isempty)
s = size(val);
D = numel(s); 
theSize = '';
if D == 2
   theSize = [num2str(s(1)), 'x', num2str(s(2))];
elseif D == 3
   theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
      num2str(s(3))];
else
   theSize = [num2str(D) '-D'];
end
if isempty == 0
    prefix = [name ': ' theSize ' ' class(val)];
else
    prefix = [name ': empty ' theSize ' ' class(val)];             
end