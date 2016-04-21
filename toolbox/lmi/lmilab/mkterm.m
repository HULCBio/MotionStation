% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function term = mkterm(A,B,X,vt,flag)

if strcmp(B(1),'$'), B(1)=[]; sym=mkterm(A,B,X,vt,~flag); else sym=[]; end


% add parentheses when A and B involve operands
mA=strcmp(A(1),'-'); lA=length(A); depth=0; dmap=zeros(lA,1);
if mA, j=1; dmap(1)=1; else j=0; end
for char=A(1+mA:lA)',
  depth=depth+any(char=='[(');
  j=j+1; dmap(j)=depth;
  depth=depth-any(char=='])');
end
minA=min(dmap);    % 1 if surrounding () or []
if lA-mA>2 & ~minA,
 if length(find(~dmap & (A=='+' | A=='-' | A=='*' | A=='\' | A=='/'))),
   A=['(' ; A ; ')']; mA=0;
 end
end

mB=strcmp(B(1),'-'); lB=length(B); depth=0; dmap=zeros(lB,1);
if mB, j=1; dmap(1)=1; else j=0; end
for char=B(1+mB:lB)',
  depth=depth+any(char=='[(');
  j=j+1; dmap(j)=depth;
  depth=depth-any(char=='])');
end
minB=min(dmap);    % 1 if surrounding () or []
if lB-mB>2 & ~minB,
 if length(find(~dmap & (B=='+' | B=='-' | B=='*' | B=='\' | B=='/'))),
   B=['(' ; B ; ')']; mB=0;
 end
end


% handle minus sign
if mA, A(1)=[]; end
if mB, B(1)=[]; end
isminus=xor(mA,mB);
lA=length(A); lB=length(B); X=X(:);



if flag, % form (A*X*B)'

   if vt(1) | vt(2), term=X; else term=[X;'''']; end

   if strcmp(A,'1'),
   elseif any(A(1)=='1234567890.'),
      term=[term;'*';A];
   elseif minA,  % surrounding () or []
      term=[term ; '*' ; A ; ''''];
   elseif strcmp(A(lA),''''),
      A(lA)=[]; term=[term;'*';A];
   else
      term=[term;'*';A;''''];
   end

   if strcmp(B,'1'),
   elseif any(B(1)=='1234567890.'),
      term=[B;'*';term];
   elseif minB,
      term=[B;'''';'*';term];
   elseif strcmp(B(lB),''''),
      B(lB)=[]; term=[B;'*';term];
   else
      term=[B;'''' ; '*';term];
   end

else

   if ~vt(1) | vt(2), term=X; else term=[X;'''']; end
   if ~strcmp(A,'1'),
      term=[A; '*' ;term];
   end
   if ~strcmp(B,'1'),
      term=[term ; '*' ; B];
   end
end


if isminus,
  term=['-';term];
end

if length(sym),
  if isminus, term=[term;sym]; else term=[term;'+';sym]; end
end
