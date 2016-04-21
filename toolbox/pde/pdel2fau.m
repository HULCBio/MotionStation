function cc=pdel2fau(p,t,a,f,u,ar)
%PDEL2FAU Triangle L2 norm of f-a*u

%       A. Nordmark 94-12-05
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:21 $

np=size(p,2);
nt=size(t,2);
% Number of variables
N=size(u,1)/np;

cc=zeros(N,nt);

if size(f,1)==1
  f=ones(N,1)*f;
end

it1=t(1,:);
it2=t(2,:);
it3=t(3,:);

if size(a,1)==1 % Scalar a
  for k=1:N
    fmau1=f(k,:)-a.*u(it1+(k-1)*np).';
    fmau2=f(k,:)-a.*u(it2+(k-1)*np).';
    fmau3=f(k,:)-a.*u(it3+(k-1)*np).';
    cc(k,:)=abs(fmau1).^2+abs(fmau2).^2+abs(fmau3).^2;
  end
elseif size(a,1)==N % Diagonal a
  for k=1:N
    fmau1=f(k,:)-a(k,:).*u(it1+(k-1)*np).';
    fmau2=f(k,:)-a(k,:).*u(it2+(k-1)*np).';
    fmau3=f(k,:)-a(k,:).*u(it3+(k-1)*np).';
    cc(k,:)=abs(fmau1).^2+abs(fmau2).^2+abs(fmau3).^2;
  end
elseif size(a,1)==N*(N+1)/2 % Symmetric a
  for k=1:N
    fmau1=f(k,:)+zeros(1,nt);
    fmau2=f(k,:)+zeros(1,nt);
    fmau3=f(k,:)+zeros(1,nt);
    for l=1:N
      m=min(k,l);
      M=max(k,l);
      ia=M*(M-1)/2+m;
      fmau1=fmau1-a(ia,:).*u(it1+(l-1)*np).';
      fmau2=fmau2-a(ia,:).*u(it2+(l-1)*np).';
      fmau3=fmau3-a(ia,:).*u(it3+(l-1)*np).';
    end
    cc(k,:)=abs(fmau1).^2+abs(fmau2).^2+abs(fmau3).^2;
  end
elseif size(a,1)==N*N % General (unsymmetric) a
  for k=1:N
    fmau1=f(k,:)+zeros(1,nt);
    fmau2=f(k,:)+zeros(1,nt);
    fmau3=f(k,:)+zeros(1,nt);
    for l=1:N
      ia=k+(l-1)*N;
      fmau1=fmau1-a(ia,:).*u(it1+(l-1)*np).';
      fmau2=fmau2-a(ia,:).*u(it2+(l-1)*np).';
      fmau3=fmau3-a(ia,:).*u(it3+(l-1)*np).';
    end
    cc(k,:)=abs(fmau1).^2+abs(fmau2).^2+abs(fmau3).^2;
  end
else
  error('PDE:pdel2fau:NumRowsA', 'Wrong number of rows of a.');
end % size(a,1)

cc=sqrt(cc.*(ones(N,1)*ar/3));

