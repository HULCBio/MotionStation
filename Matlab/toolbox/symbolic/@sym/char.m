function M = char(A,d)
%CHAR   Convert scalar or array sym to string.
%   CHAR(A,d) converts A to its string representation.
%   CHAR(A) for scalar A is simply A.s.
%   CHAR(A,1) has the form 'vector([...])'.
%   CHAR(A,2) has the form 'matrix([[...],[...]])'.
%   CHAR(A,d) for d >= 3 has the form
%      'array([1..m,1..n,1..p],[(1,1,1)=xxx,...,(m,n,p)=xxx])'
%   CHAR(A) uses d = ndims(A).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/16 22:22:10 $


if all(size(A) == 1)
   % Scalar
   s = A.s;
   % s(s=='`') = [];
   M = s;

elseif any(size(A) == 0)
   M = 'array([])';

else
   % Array
   if nargin < 2, d = ndims(A); end
   z = size(A);
   n = prod(z);
   switch d

      case 1
         M = 'vector([';
         for k = 0:n-1
            switch d
               case 1
                  q = k;
               case 2
                  q = floor(k/z(2))+mod(k,z(2))*z(1);
               case 3
                  t = mod(floor(k./u),z);
                  q = t*v';
            end
            s = A(k+1).s;
            % s(s=='`') = [];
            M(end+1:end+length(s)) = s;
            M(end+1) = ',';
         end
         M(end:end+1) = '])';

      case 2
         M = 'matrix([[';
         zz = [z(2) n n];
         for k = 0:n-1
            q = floor(k/z(2))+mod(k,z(2))*z(1);
            s = A(q+1).s;
            % s(s=='`') = [];
            M(end+1:end+length(s)) = s;
            if mod(k+1,z(2))==0
               M(end+1:end+3) = '],[';
            else
               M(end+1) = ',';
            end
         end
         M(end-1:end) = '])';

      otherwise
         if length(z) < 3, z(3) = 1; end
         M = ['array(' sprintf('1..%d,',z) '['];
         v = cumprod([1 z(1:end-1)]);
         for k = 0:n-1
            is = mod(floor(k./v),z)+1;
            s = ['(' sprintf('%d,',is)];
            s(end) = ')';
            s = [s '=' A(k+1).s ','];
            % s(s=='`') = [];
            M(end+1:end+length(s)) = s;
         end
         M(end:end+1) = '])';
   end
end
