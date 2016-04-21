function [s,len] = poly2str(den,tvar)
%POLY2STR Return polynomial as string.
%   S = POLY2STR(P,'s') or S=POLY2STR(P,'z') returns a string S 
%   consisting of the polynomial coefficients in the vector P 
%   multiplied by powers of the transform variable 's' or 'z'.
%
%       Example: POLY2STR([1 0 2],'s') returns the string  's^2 + 2'. 
%
%   [S,LEN] = POLY2STR(P,'s') also returns the maximum wrapped length
%   of the polynomial.
%
%   See also: PRINTSYS.

%   Clay M. Thompson  7-24-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:38 $

nd = length(den);
len = []; s = [];
% Form denominator
dlen=0;   first_term = 1;  old = 0;
for j=1:nd
  term=den(j);
  if first_term&(term~=0),
    if (term==1)&(j~=nd),
      s=['  '];
    else
      s=['   ',num2str(term)];
    end
    first_term=0;
  else
    if (term==1)&(j~=nd),
      s=[s,' + '];
    elseif (term==0)
      % do nothing
    elseif (term>=0), 
      s=[s,' + ',num2str(term)];
    else
      s=[s,' - ',num2str(abs(term))];
    end
  end
  if term~=0,
    if (nd-j>1),
      s=[s,' ',tvar,'^',num2str(nd-j)];
    elseif (nd-j==1),
      s=[s,' ',tvar];
    end
  end
  if (length(s)-old>63)&(j~=nd), 
    len=max([len,length(s)-old]); s=[s,13,10,'  ',];
    old = length(s)-2;
  end
end
if isempty(s), s=['   0']; end
len = max([len,length(s)-old]);

% end poly2str
