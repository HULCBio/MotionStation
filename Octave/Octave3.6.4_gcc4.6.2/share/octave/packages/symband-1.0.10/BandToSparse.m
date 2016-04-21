function Asparse=BandToSparse(Aband)
% function Asparse=BandToSparse(Aband)
% convert a banded symmetric matrix to a sparse matrix

if (nargin !=1)
   usage ("Asparse=BandToSparse(Aband)");   
endif

nonzero=length(find(Ab));
[n,b]=size(Ab);
iInd=jInd=val=zeros(nonzero,1);

ind=1;
for i=1:n
  if Ab(i,1)!=0 
    iInd(ind)=jInd(ind)=i;
    val(ind)=Ab(i,1)/2;
    ind++;
  endif
endfor
for i=1:n-1
  for j=2:min(b,n-i)
    if Ab(i,j)!=0 
      iInd(ind)=i; jInd(ind)=i+j-1;
      val(ind)=Ab(i,j);
      ind++;
    endif
  endfor
endfor

ind--;

iInd=iInd(1:ind);
jInd=jInd(1:ind);
val =val(1:ind);

Asparse=sparse(iInd,jInd,val,n,n);
Asparse=Asparse+Asparse';
endfunction

