function [U,S,V] = svd(A)
%SVD    Symbolic singular value decomposition.
%   With one output argument, SIGMA = SVD(A) is a symbolic vector 
%   containing the singular values of a symbolic matrix A.
%   SIGMA = SVD(VPA(A)) computes numeric singular values using
%   using variable precision arithmetic.
%
%   With three output arguments, both [U,S,V] = SVD(A) and
%   [U,S,V] = SVD(VPA(A)) return numeric unitary matrices U and V
%   whose columns are the singular vectors and a diagonal matrix S
%   containing the singular values.  Together, they satisfy
%   A = U*S*V'.  The singular vector computation uses variable
%   precision arithmetic and requires the input matrix to be numeric.
%   Symbolic singular vectors are not available.
%
%   Examples:
%      A = sym(magic(4))
%      svd(A)
%      svd(vpa(A))
%      [U,S,V] = svd(A)
%
%      syms t real
%      A = [0 1; -1 0]
%      E = expm(t*A)
%      sigma = svd(E)
%      simplify(sigma)
%
%   See also EIG, VPA.
 
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/16 22:23:11 $

if all(size(A) == 1)

   % Monoelemental matrix

   if nargout < 2
      U = A;
   else
      U = sym(1);
      S = A;
      V = sym(1);
   end

elseif nargout < 2

   % Singular values only

   [res,stat] = maple(['ml_singvals := singularvals(' char(A) '):']);
   if stat ~= 0
      error('symbolic:sym:svd:errmsg1',res)
   end
   U = [];
   for k = 1:str2num(maple('nops(ml_singvals)'))
      val = maple(['op(',num2str(k),',ml_singvals);']);
      if findstr(val,'RootOf')
         try
            val = ['[' maple('evalf',val) ']'];
         catch
            warning('symbolic:sym:svd:warnmsg1','RootOf involves symbolic variables and cannot be expanded.')
         end
      end
      U = [U; sym(val).'];
   end
   maple('ml_singvals := ''ml_singvals'':');

else

   % Numeric singular values and vectors.

   A = vpa(A);
   [res,stat] = maple(['evalf(Svd(' char(A) ',ml_U,ml_V))']);
   if stat ~= 0
      error('symbolic:sym:svd:errmsg2',res)
   end
   S = diag(sym(res));
   U = sym(maple('print(ml_U)'));
   V = sym(maple('print(ml_V)'));
   maple('ml_U := ''ml_U'': ml_V := ''ml_V'':');
end
