function A=BandToFull(Ab)
% function Afull=BandToSparse(Aband)
% convert a banded symmetric matrix to a sparse matrix

if (nargin !=1)
   usage ("Afull=BandToFull(Aband)");   
endif


[n,b]=size(Ab);
b-=1;
A=zeros(n,n);
for i=1:n-b
  A(i,i:i+b)=Ab(i,:);
  A(i:i+b,i)=Ab(i,:)';
endfor
for i=n-b+1:n
  A(i,i:n)=Ab(i,1:n-i+1);
  A(i:n,i)=Ab(i,1:n-i+1)';
endfor

endfunction
