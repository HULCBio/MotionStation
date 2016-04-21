function [V,D,p] = eig(A)
%EIG    Symbolic eigenvalues and eigenvectors.
%   With one output argument, LAMBDA = EIG(A) is a symbolic vector 
%   containing the eigenvalues of a square symbolic matrix A.
%
%   With two output arguments, [V,D] = EIG(A) returns a matrix V whose
%   columns are eigenvectors and a diagonal matrix D containing eigenvalues.
%   If the resulting V is the same size as A, then A has a full set of
%   linearly independent eigenvectors which satisfy A*V = V*D.
%
%   With three output arguments, [V,D,P] also returns P, a vector of indices
%   whose length is the total number of linearly independent eigenvectors,
%   so that A*V = V*D(P,P).  If A is n-by-n, then V is n-by-m where n is
%   the sum of the algebraic multiplicities and m is the sum of the geometric
%   multplicities.
%
%   LAMBDA = EIG(VPA(A)) and [V,D] = EIG(VPA(A)) compute numeric eigenvalues
%   and eigenvectors using variable precision arithmetic.  If A does not
%   have a full set of eigenvectors, the columns of V will not be linearly
%   independent.
%
%   Examples:
%      [v,lambda] = eig([a,b,c; b,c,a; c,a,b])
%
%      R = sym(gallery('rosser'));
%      eig(R)
%      [v,lambda] = eig(R)
%      eig(vpa(R))
%      [v,lambda] = eig(vpa(R))
%
%      A = sym(gallery(5)) does not have a full set of eigenvectors.
%      [v,lambda,p] = eig(A) produces only one eigenvector.
%
%   See also POLY, JORDAN, SVD, VPA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.25.4.2 $  $Date: 2004/04/16 22:22:19 $

if all(size(A) == 1)

   % Monoelemental matrix

   if nargout < 2
      V = A;
   else
      V = sym(1);
      D = A;
   end

elseif nargout < 2

   % Eigenvalues only

   [res,stat] = maple(['ml_eigvals := [eigenvalues(' char(A) ')]:']);
   if stat ~= 0
      error('symbolic:sym:eig:errmsg1',res)
   end
   V = [];
   for k = 1:str2num(maple('nops(ml_eigvals)'))
      val = maple(['op(',num2str(k),',ml_eigvals);']);
      if findstr(val,'RootOf')
         try
            val = ['[' maple('evalf',val) ']'];
         catch
            warning('symbolic:sym:eig:warnmsg1','RootOf involves symbolic variables and cannot be expanded.')
         end
      end
      V = [V; sym(val).'];
   end
   maple('ml_eigvals := ''ml_eigvals'':');

else

   % Eigensystem

   [res,stat] = maple(['ml_eigvecs := [eigenvectors(' char(A) ')]:']);
   if stat ~= 0
      error('symbolic:sym:eig:errmsg2',res)
   end
   V = [];
   D = sym(zeros(size(A)));
   V = sym([]);
   p = [];
   m = 0;
   for k = 1:str2num(maple('nops(ml_eigvecs)'))
      maple(['ml_eva := [allvalues(op(',num2str(k),',ml_eigvecs))]:']);
      for j = 1:str2num(maple('nops(ml_eva)'))
         maple(['ml_ev := op(',num2str(j),',ml_eva):']);
         % ml_ev = [eigval, algebraic-mult, {vect_1, ..., vect_geometric-mult}]
         val = maple('op(1,ml_ev)');
         if findstr(val,'RootOf')
            val = maple('evalf',val);
         end
         val = sym(val);
         malg = str2num(maple('op(2,ml_ev)'));
         maple(['ml_v := op(3,ml_ev):']);
         mgeo = str2num(maple('nops(ml_v)'));
         for i = 1:mgeo
            s = maple('op',i,'ml_v');
            if findstr(s,'RootOf')
               s = maple('evalf',s);
            end
            V = [V sym(s).'];
         end
         p = [p m+(1:mgeo)];
         for i = 1:malg
            m = m+1;
            D(m,m) = val;
         end
      end
   end
   maple(['ml_eigvecs := ''ml_eigvecs'': ml_eva := ''ml_eva'': ' ... 
      'ml_ev := ''ml_ev'': ml_v := ''ml_v'':']);
end
