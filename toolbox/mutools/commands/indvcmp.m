% function code = indvcmp(mat1,mat2,errcrit)
%
%   Compares the INDEPENDENT VARIABLE data for two VARYING matrices:
%       CODE = 0; varying data is different
%       CODE = 1; varying data is identical OR both are CONSTANT matrices
%       CODE = 2; different number of points
%       CODE = 3; matrices are not both VARYING, or not both CONSTANT
%
%       ERRCRIT - 1x2 optional matrix containing the relative
%          error and absolute error bounds. The relative error
%          is used to test error in independent variables whose
%          magnitude is greater than 1e-9, while the absolute
%          error bound used for smaller independent variable
%          values. Default values are 1e-6, and 1e-13, respectively.
%
%   See also: GETIV, SORTIV, VUNPCK, XTRACT, and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function ccode = indvcmp(mat1,mat2,errcrit)
 if nargin < 2
   disp('usage: code = indvcmp(mat1,mat2)')
   return
 elseif nargin == 2
   relerr = 1e-6;
   abserr = 1e-13;
 else
   [ecr,ecc] = size(errcrit);
   if ecr == 1 & ecc == 2
     relerr = errcrit(1);
     abserr = errcrit(2);
   else
     error('errcrit (3rd argument) should be a 1x2 matrix')
     return
   end
 end
 code = 1;
 [m1type,m1r,m1c,m1n] = minfo(mat1);
 [m2type,m2r,m2c,m2n] = minfo(mat2);
 if strcmp(m1type,'vary') & strcmp(m2type,'vary')
   if m1n == m2n
     nrlyzero = find(abs(mat1(1:m1n,m1c+1))<1e-9);
%                  ind variables for mat1 that are less than 1e-9
     if length(nrlyzero) == 0
       relerrs = (mat2(1:m1n,m2c+1)-mat1(1:m1n,m1c+1)) ./ mat1(1:m1n,m1c+1);
       if max(abs(relerrs)) > relerr
         code = 0;
       end
     else
       notnz = comple(nrlyzero,m1n);
       nzerr = max(abs(mat1(nrlyzero,m1c+1)-mat2(nrlyzero,m2c+1)));
       relerrs = (mat2(notnz,m2c+1)-mat1(notnz,m1c+1)) ./ mat1(notnz,m1c+1);
       if nzerr > abserr | max(abs(relerrs)) > relerr
         code = 0;
       end
     end
   else
     code = 2;
   end
 elseif strcmp(m1type,'cons') & strcmp(m2type,'cons')
   code = 1;
 else
   code = 3;
 end
 if nargout == 0
   if code == 1
     if strcmp(m1type,'vary')
       disp('varying data is the same')
     else
       disp('both are CONSTANT matrices')
     end
   elseif code == 0
     disp('varying data is DIFFERENT')
   elseif code == 2
     disp('different number of independent variable values')
   else
     disp('matrices are not both VARYING, or not both CONSTANT')
   end
 else
   ccode = code;
 end
%
%