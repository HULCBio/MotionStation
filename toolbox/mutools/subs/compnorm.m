% function normtest = compnorm(T,invT,S,s,h);
%
% Called by SDHFSYN and SDHFNORM in order to check whether
%  the sampled data compressed norm is greater than 1.
%
%  NORMTEST =1 if  compressed norm <1
%  NORMTEST =0 if  compressed norm >=1.
%
% The input data is the output from HAM2SCHR

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function normtest = compnorm(T,invT,S,s,h);

s1=s(1); s2=s(2); s3=s(3);
inx1=1:s1;inx2=s1+1:s1+s2;inx12=1:s1+s2;inx3=s1+s2+1:s1+s2+s3;
normtest = 1;
n=max(size(T))/2;
if s3==0,
     expmhS=expm(h*S);
     Gamma11=T(1:n,:)*expmhS*invT(:,1:n);
     if rank(Gamma11) < n,
       	normtest =0;
	return
      end
     N=50; % number of points checked
     first=1;
     last=det(real(Gamma11));
     sgn=sign(last);
     if sign(first)~=sgn,
     	normtest =0;
%	return;
      end
     X=T(1:n,:);  Y=expmhS*invT(:,1:n);
     exphN=expm(-S*h/N);
  points=zeros(N,1); points(1)=first; points(N)=last;
     for j=1:N-1,
         X=X*exphN;
         now=det(real(X*Y));
points(N-j)=now;
         if sign(now)~=sgn,
		normtest =0;
%		return
            end
       end; %for j=1:N-1
end; %if s3==0

if s3>0,  % use alternate formulae to avoid exp(h*S3)
     [q,r]=qr(invT(s1+s2+1:2*n,1:n)');
     invTaug=[invT(s1+s2+1:2*n,1:n); q(:,s3+1:n)'];
     detinvTaug=det(invTaug);
     invT1121a=invT(inx12,1:n)/invTaug;
     T13z=[T(1:n,inx3) zeros(n,n-s3)];
     exphS12=[expm(h*S(inx1,inx1)), zeros(s1,s2);...
               zeros(s2,s1) expm(h*S(inx2,inx2))];
     Gamma11eq=T(1:n,inx12)*exphS12*invT1121a...
           *[expm(-h*S(inx3,inx3)) zeros(s3,n-s3);zeros(n-s3,s3) eye(n-s3)]...
             + T13z;

     if rank(Gamma11eq) < n,
	normtest =0;
	return
	end

     N=50; % number of points checked

     first=real(detinvTaug*det(T(1:n,inx12)*invT1121a+T13z));
     last=real(detinvTaug*det(Gamma11eq));
     sgn=sign(last);
     if sign(first)~=sgn,
     	normtest =0;
%	return;
      end

  points=zeros(N,1); points(1)=first; points(N)=last;
     expm12=[expm((h/N)*S(inx1,inx1)) zeros(s1,s2);...
               zeros(s2,s1) expm((h/N)*S(inx2,inx2))];
     expm3=expm(-(h/N)*S(inx3,inx3));
     X=T(1:n,inx12); Y=invT1121a;

     for j=1:N-1,
       X=X*expm12; Y(:,1:s3)=Y(:,1:s3)*expm3;
       now=real(detinvTaug*det(X*Y+T13z));
points(j)=now;
       if sign(now)~=sgn,
		normtest =0;
%		return
		end
	end; %for j=1:N-1
 end; %if s3>0

%plot(points);
%pause(2)