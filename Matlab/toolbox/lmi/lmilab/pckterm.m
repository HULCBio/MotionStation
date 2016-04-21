% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function A=pckterm(A,dmap)



if nargin==1,  % used to form A' for cte terms

  % add parentheses when A and B involve operands
  mA=strcmp(A(1),'-'); lA=length(A); depth=0; dmap=zeros(lA,1);
  if mA, j=1; dmap(1)=1; else j=0; end
  for char=A(1+mA:lA)',
    depth=depth+any(char=='[(');
    j=j+1; dmap(j)=depth;
    depth=depth-any(char=='])');
  end
  minA=min(dmap);  % 1 if surrounding () or []
  if lA-mA>2 & ~minA,
    if length(find(~dmap & (A=='+' | A=='-' | A=='*' | A=='\' | A=='/'))),
     A=['(' ; A ; ')']; mA=0;
    end
  end

  lA=length(A);
  if any(A(1+mA)=='0123456789.'),
  elseif minA,  % surrounding () or []
     A = [A ; ''''];
  elseif strcmp(A(lA),''''),
     A(lA)=[]; term=[term;'*';A];
  else
     A = [A;''''];
  end

  return
end


% front processing of coefs in lmiterm
% removes leading and trailing blanks
% removes zeros and eye
if strcmp(A(1),'+'), A(1)=[]; dmap(1)=[]; end
ix=find(A==' ' & dmap==1);
A(ix)=[]; dmap(ix)=[]; lA=length(A);
if lA<2,
elseif strcmp(A(1),'[') & any(A(lA-1:lA)==']'),
  A=strrep(A,'zeros','0');
  A=strrep(A,'eye','1');
end

%  A=strrep(A,'zeros','0');
%  if length(A) < lA, ix=findstr(A,'0('); else ix=[]; end
%  for i=fliplr(ix),
%    delx=find(A(i+2:length(A))==')');
%    A(i+1:i+1+delx(1))=[];
%  end
%  lA=length(A);
%  A=strrep(A,'eye','1');
%  if length(A) < lA, ix=findstr(A,'1('); else ix=[]; end
%  for i=fliplr(ix),
%    delx=find(A(i+2:length(A))==')');
%    A(i+1:i+1+delx(1))=[]; A(i)='I';
%  end
