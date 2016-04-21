function Ab=FullToBand(A)
% function Aband=FullToBand(Afull)
% convert a banded symmetric matrix to a sparse matrix

if (nargin !=1)
   usage ("Aband=FullToBand(Afull)");   
endif

[n,m]=size(A);

band=0;
for i=1:n
  band=max([band,max(find(A(i,:)))-i]);
endfor
Ab=zeros(n,band+1);
for i=1:n-band
  Ab(i,:)=A(i,i:i+band);
endfor
for i=n-band+1:n
  Ab(i,1:n-i+1)=A(i,i:n);
endfor

endfunction
