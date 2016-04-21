echo off
%DIFEQITE Used in difeqdem.

%   Copyright 1987-2002 C. de Boor and The MathWorks, Inc. 
%   latest change: December 24, 1989
%   cb : 9 may '95 (use .' instead of ')
%   $Revision: 1.13 $

echo on
%  Here is the iteration:

xlabel('... and iterates')
while 1
   vtau=fnval(y,colpnts);
   weights=[0 1 0;
            [2*vtau.' zeros(n-2,1) epsilon*ones(n-2,1)];
            1 0 0];
   colloc=zeros(n,n);
   for j=1:n
    colloc(j,:)=weights(j,:)*colmat(3*(j-1)+[1:3],:);
   end
   coefs=colloc\[0 vtau.*vtau+1 0].';
   z=spmak(knots,coefs.');
   fnplt(z,'k'),pause
   maxdif=max(max(abs(z.coefs-y.coefs)))
   if (maxdif<tolerance), break, end
   % now reiterate
   y=z;
end
