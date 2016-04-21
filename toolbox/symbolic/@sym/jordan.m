function [V,J] = jordan(A)
%JORDAN   Jordan Canonical Form.
%   JORDAN(A) computes the Jordan Canonical/Normal Form of the matrix A.
%   The matrix must be known exactly, so its elements must be integers,
%   or ratios of small integers.  Any errors in the input matrix may
%   completely change its JCF.
%
%   [V,J] = JORDAN(A) also computes the similarity transformation, V, so
%   that V\A*V = J.  The columns of V are the generalized eigenvectors.
%
%   Example:
%      A = sym(gallery(5));
%      [V,J] = jordan(A)
%
%   See also EIG, POLY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:45 $

if all(size(A) == 1)
   if nargout <= 1
      V = A;
   else
      J = A;
      V = sym(1);
   end
else
   if nargout <= 1
      [V,stat] = maple('jordan',A);
      if stat, error('symbolic:sym:jordan:errmsg1',V); end
   else
      [J,stat] = maple('jordan',A,'''_jcfv''');
      if stat, error('symbolic:sym:jordan:errmsg2',J); end
      V = sym(maple('print','_jcfv'));
      maple('_jcfv := ''_jcfv'';');
   end
end
