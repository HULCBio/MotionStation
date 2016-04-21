function[J, ncol] = sfdnls(xcurr,valx,Jstr,group,alpha,fun,YDATA,varargin)
%SFDNLS    Sparse Jacobian via finite differences
%
%
% J = sfdnls(x,valx,J,group,[],fun) returns the
% sparse finite difference approximation J of a Jacobian matrix
% of function 'fun'  at current point x.
% Vector group indicates how to use sparse finite differencing:
% group(i) = j means that column i belongs to group (or color) j.
% Each group (or color) corresponds to a function difference.
% varargin are extra parameters (possibly) needed by function 'fun'.
%
% J = sfdnls(x,valx,J,group,fdata,fun,alpha) overrides the default
% finite differencing stepsize.
%
%[J, ncol] = sfdnls(...) returns the number of function evaluations used
% in ncol.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:43:38 $

%
if nargin < 6
   error('SFDNLS requires six arguments')
elseif nargin < 7
   YDATA = [];
end

scalealpha = 0;
x = xcurr(:); % make it a vector
[m,n] = size(Jstr); 
ncol = max(group); epsi = sqrt(eps);
if isempty(alpha)
    scalealpha = 1;
   alpha = ones(ncol,1)*sqrt(eps); 
end
J = spones(Jstr); d = zeros(n,1);
if ncol < n
   for k = 1:ncol
      d = (group == k);
      if scalealpha
         xnrm = norm(x(d));
         xnrm = max(xnrm,1);
         alpha(k) = alpha(k)*xnrm;
      end
      y = x + alpha(k)*d;
      
      %v = feval(fun,y,fdata);
      xcurr(:) = y;  % reshape for userfunction
      v = feval(fun,xcurr,varargin{:});
      if ~isempty(YDATA)
         v = v - YDATA;
      end
      v = v(:);
      
      w = (v-valx)/alpha(k);
      cols = find(d); 
      
      lpoint = length(cols);
      A = sparse(m,n);
      A(:,cols) = J(:,cols);
      J(:,cols) = J(:,cols) - A(:,cols);
      [i,j,val] = find(A);
      [p,ind] = sort(i);
      val(ind) = w(p);
      A = sparse(i,j,full(val),m,n);
      J = J + A;
   end
else % ncol ==n
   J = full(J);
   for k = 1:n
      if scalealpha
         xnrm = norm(x(k));
         xnrm = max(xnrm,1);
         alpha(k) = alpha(k)*xnrm;
      end
      y = x;
      y(k) = y(k) + alpha(k);
      %v = feval(fun,y,fdata);
      xcurr(:) = y;  % reshape for userfunction
      v = feval(fun,xcurr,varargin{:});
      if ~isempty(YDATA)
         v = v - YDATA;
      end
      v = v(:);
      J(:,k) = (v-valx)/alpha(k);
   end
end


