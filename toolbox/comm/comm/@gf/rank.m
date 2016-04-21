function r = rank(a)
%RANK  Matrix rank.
%   RANK(A) computes the number of linearly
%   independent rows or columns of Galois matrix A.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/03/27 00:14:50 $

if isempty(a.x)
    r=0;
    return;
end

[n, m] = size(a);
k = 1;
i = 1;

S.type ='()';    

r=0;
while k <= m
    %GET THE actual Matrix just for use with the FIND function and WHILE condition
    ax=double(a.x);
    
    ind = find(ax(:,k) ~= 0); 
    if isempty(ind)
        k = k + 1;
    else
        r=r+1;
        %Make the first non-zero element (whose index is indy) 1 by multiplying the whole column by the order of this element
        indy=ind(1);
        S.subs = {indy,k};
        nael=subsref(a,S);  %First non-zero element
        
        %Find order of nael
        ordermat=nael.^(1:(2^a.m-1));
        ordermat=double(ordermat.x);
        ordmat=find(ordermat==1);
        ord=ordmat(1);
        
        %Multiply the first column by nael^(ord-1) to make nael=1
        S.subs={':',k};
        acol=subsref(a,S);
        acol=acol.*(nael^(ord-1));
        a=subsasgn(a,S,acol);
        
        %Now make elements of the same row in all other colums >k ==0
        for ii=k+1:m
            S.subs={indy,ii};
            aik=subsref(a,S);
            S.subs={':',ii};
            oldcol=subsref(a,S);
            newcol= acol*aik +oldcol;
            a=subsasgn(a,S,newcol);
        end
        k=k+1; 
    end
    
end
 