function c = sym2poly(p)
%SYM2POLY Symbolic polynomial to polynomial coefficient vector.
%   SYM2POLY(P) returns a row vector containing the coefficients 
%   of the symbolic polynomial P.
%
%   Example:
%      sym2poly(x^3 - 2*x - 5) returns [1 0 -2 -5].
%
%   See also POLY2SYM, COEFFS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $  $Date: 2004/04/16 22:23:13 $

p = expand(p);
x = findsym(p);

if isempty(x)
   % constant case
   c = double(p);

elseif ~isempty(find(x==','))
   error('symbolic:sym:sym2poly:errmsg1','Input has more than one symbolic variable.')

else
   maple(['_ans := ' p.s]);
   [c,stat] = maple(['[seq(coeff(_ans,' x ',k),k=0..degree(_ans))]']);
   [cl,statl] = maple(['[seq(coeff(_ans,' x ',k),k=ldegree(_ans)..-1)]']);
   if stat | statl | ~isequal(cl,'[]')
      error('symbolic:sym:sym2poly:errmsg2','Not a polynomial.')
   else
       c = fliplr(eval(c));
   end
   maple('_ans := ''_ans'';');
end;
