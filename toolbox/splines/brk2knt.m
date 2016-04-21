function t = brk2knt(breaks,mults)
%BRK2KNT Breaks with multiplicities into knots.
%
%   T = BRK2KNT(BREAKS,MULTS) returns the sequence T in which, for each i,
%   BREAKS(i) is repeated MULTS(i) times. 
%   If BREAKS is strictly increasing, then T is the knot sequence in which
%   each BREAKS(i) occurs exactly MULTS(i) times.
%
%   If MULTS is to be constant, then only that constant value need be given.
%
%   [T,INDEX] = BRK2KNT(BREAKS,MULTS) also returns 
%   INDEX = [1 find(diff(T)>0)-1] . If all multiplicities are positive, 
%   then, for all j, INDEX(j) is the first place in T at which BREAKS(j)
%   appears.
%
%   Example:
%      t = brk2knt(1:2,3)
%   gives  t = [1 1 1 2 2 2], while
%
%      t = [1 1 2 2 2 3 4 5 5];  [xi,m] = knt2brk(t);  tt = brk2knt(xi,m);
%
%   gives  [1 2 3 4 5]  for xi , [2 3 1 1 2] for m , and t for tt.
%
%   See also KNT2BRK, KNT2MLT, AUGKNT.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
%   $Revision: 1.12 $

s = sum(mults);
if s==0
   t = [];
else
   li = length(breaks);
      % make sure there is a multiplicity assigned to each break,
      % and drop any break whose assigned multiplicity is not positive.
   if length(mults)~=li, mults = repmat(mults(1),1,li); s = mults(1)*li;
   else
      fm = find(mults<=0);
      if ~isempty(fm), breaks(fm)=[]; mults(fm)=[]; li = length(breaks); end
   end
   mm = zeros(1,s);
   mm(cumsum([1 reshape(mults(1:li-1),1,li-1)])) = ones(1,li);
   t = breaks(cumsum(mm));
end
