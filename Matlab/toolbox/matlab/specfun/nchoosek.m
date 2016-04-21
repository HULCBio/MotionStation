function c = nchoosek(v,k)
%NCHOOSEK Binomial coefficient or all combinations.
%   NCHOOSEK(N,K) where N and K are non-negative integers returns N!/K!(N-K)!.
%   This is the number of combinations of N things taken K at a time.
%   When a coefficient is greater than 10^15, a warning will be produced
%   indicating possible inexact results. In such cases, the result is good 
%   to 15 digits.
%
%   NCHOOSEK(V,K) where V is a vector of length N, produces a matrix 
%   with N!/K!(N-K)! rows and K columns. Each row of the result has K of 
%   the elements in the vector V. This syntax is only practical for 
%   situations where N is less than about 15.
%
%   See also PERMS.

%   B.A. Jones 2-17-95
%   revised by ZP. You 11-17-97
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.21.4.2 $  $Date: 2004/03/02 21:48:38 $

if numel(k) ~= 1 || k < 0 || k ~= round(k)
  error('MATLAB:nchoosek:InvalidArg2',...
        'The second input has to be a non-negative integer');
end

[m, n] = size(v);

if min(m,n) ~= 1
   error('MATLAB:nchoosek:InvalidArg1',...
         'The first argument has to be a scalar or a vector');
end

% the first argument is a scalar
if isscalar(v) && isa(v,'double') && v==round(v) && v >= 0  
   % if the first argument is a scalar, then, we only return the number of 
   % combinations. Not the actual combinations.
   % We use the Pascal triangle method. No overflow involved. c will be 
   % the biggest number computed in the entire routine.
   %
   
   n = v; % rename v to be n. the algorithm is more readable this way.
   if k > n 
     error('MATLAB:nchoosek:KOutOfRange','K must be an integer between 0 and N'); 
   end 
   if k > n/2, k = n-k; end
   if k <= 1
      c = n^k;
   else
      nums = (n-k+1):n;
      dens = 1:k;
      nums = nums./dens;
      c = round(prod(nums));
      if c > 1e+015
         warning('MATLAB:nchoosek:LargeCoefficient',['Result may not be ' ...
                 'exact. Coefficient is greater than 10^15,\n         and ' ...
                 'is only good to 15 digits.']);
      end
   end
   
else
   % the first argument is a vector, generate actual combinations.
   
   if n == 1, n = m; v = v.'; end
   
   if n == k
      c = v(:).';
   elseif n == k + 1
      tmp = v(:).';
      c   = tmp(ones(n,1),:);
      c(1:n+1:n.*n) = [];
      c = reshape(c,n,n-1);
   elseif k == 1
      c = v.';
   elseif k == 0
      c = zeros(1,0);
   elseif n < 17 && (k > 3 || n-k < 4)
      rows = 2.^(n);
      ncycles = rows;
      
      for count = 1:n
         settings = (1:-1:0);
         ncycles = ncycles/2;
         nreps = rows./(2*ncycles);
         settings = settings(ones(1,nreps),:);
         settings = settings(:);
         settings = settings(:,ones(1,ncycles));
         x(:,n-count+1) = settings(:);
      end
      
      idx = x(find(sum(x') == k),:);
      [nrows,junk]= size(idx);
      [rows,cols] = find(idx');
      c = reshape(v(rows),k,nrows)';
   else 
      c = [];
      if k < n && k > 1
         for idx = 1:n-k+1
            Q = combs(v(idx+1:n),k-1);
            c = [c; [v(ones(size(Q,1),1),idx) Q]];
         end
      end
      
   end
end

%----------------------------------------
function P = combs(v,m)
%COMBS  All possible combinations.
%   COMBS(1:N,M) or COMBS(V,M) where V is a row vector of length N,
%   creates a matrix with N!/((N-M)! M!) rows and M columns containing
%   all possible combinations of N elements taken M at a time.
%
%   This function is only practical for situations where M is less
%   than about 15.

if nargin~=2, error('MATLAB:nchoosek:WrongInputNum', 'Requires 2 input arguments.'); end

v = v(:).'; % Make sure v is a row vector.
n = length(v);
if n == m
   P = v;
elseif m == 1
   P = v.';
else
   P = [];
   if m < n && m > 1
      for k = 1:n-m+1
         Q = combs(v(k+1:n),m-1);
         P = [P; [v(ones(size(Q,1),1),k) Q]];
      end
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
