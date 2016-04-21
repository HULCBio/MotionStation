function y=sum4vms(x)
%SUM    Sum of the elements.
%   For vectors, SUM(X) is the sum of the elements of X.
%   For matrices, SUM(X) is a row vector with the sum over
%   each column. SUM(DIAG(X)) is the trace of X.
%
%   See also PROD, CUMPROD, CUMSUM.

%   L. Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:55 $

if isempty(find(isnan(x)))
  %regular sum
  y=sum(x);
else
  [t1,t2]=size(x);
  if min(t1,t2) == 1
    y=NaN;
  else
    for i=1:t2
      if isempty(find(isnan(x(:,i))))
        y(i) = sum(x(:,i));
      else
        y(i) = NaN;
      end;
    end;
  end;
end
