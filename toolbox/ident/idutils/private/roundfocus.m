function [x,idx] = roundfocus(Domain,focus,x,a,b)
% ROUNDFOCUS  Rounds time or freq. focus to entire values.
% 
%   LOW-LEVEL FUNCTION.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2004/04/10 23:20:20 $

% RE: Used by time and freq. response functions when called with output
%     arguments

switch Domain
 case 'freq'
  % Round to entire decades  
  if isempty(focus)
    focus = [1 10];
  end
  xmin = floor(log10(focus(1))+1e3*eps)-1e3*eps;
  xmax = ceil(log10(focus(2))-1e3*eps)+1e3*eps;
  idx = find(x>10^xmin & x<10^xmax);
  x = x(idx);
  if ~isempty(a)
  a = a(:,:,idx);
  b = b(:,:,idx);
end
 case 'time'
  if isempty(focus)
    focus = [0 1];
  end

  xmin = focus(1) - 1e3*eps;
  xmax = focus(2) + 1e3*eps;
  idx = find(x >= xmin & x <= xmax);
  x = x(idx);
  if ~isempty(a)
  a = a(idx,:,:);
end
  if ~isempty(b)
    b = b(idx,:,:);
  end
end
