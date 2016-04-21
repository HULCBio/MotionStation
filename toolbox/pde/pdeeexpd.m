function f=pdeeexpd(x,y,s,nx,ny,u,t,f)
%PDEEEXPD Evaluate an expression on edges.

%       A. Nordmark 12-21-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/01 04:28:12 $

if ischar(f)
  fold=f;
try 
    f=eval(fold);
catch
    errstr = sprintf('Invalid expression ''%s'' when evaluating boundary conditions. \n',...
        fold);
    error('PDE:pdeeexpd:InvalidExprForBC', errstr);   
end
  if any(size(f)-[1 1]) && any(size(f)-size(x))
    errstr=sprintf( ...
      '%s\n\nIn expression:\n%s\nwhen evaluating boundary conditions.\n', ...
      'Expression evaluates to wrong size',fold);
    error('PDE:pdeeexpd:InvalidExprSizeForBC', errstr);
  end
end

if length(f)==1
  f=f.*ones(1,length(x));
end

