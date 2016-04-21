function [x,y,ep,hp]=pdedistr(g,p,e,t,Hmax,Hgrad,tol,hp,factor)
%PDEDISTR Distribute edge points.

%       L. Langemyr 8-2-95, LL,AN 24-8-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

np=size(p,2);
ne=size(e,2);
nt=size(t,2);

bb=[];
ss=[];
ep=[];

m=size(p,2)+1;

if all(hp>=Hmax)
  for i=1:ne
    n=ceil((e(4,i)-e(3,i))*factor(e(5,i))/Hmax);
    s=linspace(e(3,i),e(4,i),n+1);
    bb=[bb;e(5,i)*ones(n-1,1)];
    ss=[ss;s(2:n)'];
    ep=[ep [[e(1,i) m:m+n-2]
            [m:m+n-2 e(2,i)]
             s(1:n)
             s(2:n+1)
             e(5:7,i)*ones(1,n)]];
    m=m+n-1;
  end
  [x,y]=pdeigeom(g,bb,ss);
  x=x'; y=y';
  hp=Hmax;
  return
end

H=sqrt((p(1,e(1,:))-p(1,e(2,:))).^2+(p(2,e(1,:))-p(2,e(2,:))).^2);
h1=hp(e(1,:));
h2=hp(e(2,:));

for i=1:ne
  X12=H(i)/2+(h2(i)-h1(i))/2/(Hgrad-1);

  X(1)=0;
  X(2)=(Hmax-h1(i))/(Hgrad-1);
  X(3)=H(i)-(Hmax-h2(i))/(Hgrad-1);
  X(4)=H(i);

  HH(1)=h1(i);
  HH(2)=Hmax;
  HH(3)=Hmax;
  HH(4)=h2(i);

  if X(2)<X(3)                  % flat case
    if X(3)<h1(i)+Hmax
      X(2)=0;
      X(3)=0;
      HH(2)=HH(1);
      HH(3)=HH(1);
    elseif H(i)-X(2)<h2(i)+Hmax
      X(2)=H(i);
      X(3)=H(i);
      HH(2)=HH(4);
      HH(3)=HH(4);
    else
      if X(2)<h1(i)
        X(2)=0;
        HH(2)=HH(1);
      end
      if H(i)-X(3)<h2(i)
        X(3)=H(i);
        HH(3)=HH(4);
      end
      if X(3)-X(2)<=Hmax
        X(2)=(X(2)+X(3))/2;
        X(3)=X(2);
        HH(2)=(HH(2)+HH(3))/2;
        HH(3)=HH(2);
      end
    end
  else                          % peak case
    if X12<h1(i)
      X(2)=0;
      X(3)=0;
      HH(2)=HH(1);
      HH(3)=HH(1);
    elseif X12>H(i)-h2(i)
      X(2)=H(i);
      X(3)=H(i);
      HH(2)=HH(4);
      HH(3)=HH(4);
    else
      X(2)=X12;
      X(3)=X12;
      HH(2)=(Hgrad-1)*X(2)+h1(i);
      HH(3)=HH(2);
    end
  end

  for j=1:3
    if X(j)~=X(j+1)
      if abs(HH(j)-HH(j+1))<tol
        n=ceil((X(j+1)-X(j))/HH(j)-tol);
        k=1;
        s=linspace(X(j),X(j+1),n+1);
        hhh=HH(j).*ones(1,n-1);
      else
        if HH(j)<HH(j+1)
          HH1=HH(j); HH2=HH(j+1);
        else
          HH1=HH(j+1); HH2=HH(j);
        end
        HHH=abs(X(j+1)-X(j));
        if HHH>HH2+tol
          k=(HHH-HH1)./(HHH-HH2);
          if k>Hgrad
            k=Hgrad;
          end
          n=max(ceil(log((HHH*(k-1)+HH1)/HH1)/log(k)),2);
          s=HH1*cumprod(k*ones(1,n));
          s=s/sum(s)*(X(j+1)-X(j));
          hhh=s;
          if HH(j)<HH(j+1)
            s=[X(j) X(j)+cumsum(s)];
          else
            s=[X(j+1) X(j+1)-cumsum(s)];
            s=s(n+1:-1:1);
          end
        else
          n=1;
          s=[X(j) X(j+1)];
          hhh=[];
        end
      end
      s=s/H(i)*(e(4,i)-e(3,i))+e(3,i);
      if abs(X(j))<tol & abs(X(j+1)-H(i))<tol
        hp=[hp hhh];
        bb=[bb;e(5,i)*ones(n-1,1)];
        ss=[ss;s(2:n)'];
        ep=[ep [[e(1,i) m:m+n-2]
                [m:m+n-2 e(2,i)]
                s(1:n)
                s(2:n+1)
                e(5:7,i)*ones(1,n)]];
        m=m+n-1;
      elseif abs(X(j))<tol
        hp=[hp hhh HH(j+1)];
        bb=[bb;e(5,i)*ones(n,1)];
        ss=[ss;s(2:n+1)'];
        ep=[ep [[e(1,i) m:m+n-2]
                m:m+n-1
                s(1:n)
                s(2:n+1)
                e(5:7,i)*ones(1,n)]];
        m=m+n;
      elseif abs(X(j+1)-H(i))<tol
        hp=[hp hhh];
        bb=[bb;e(5,i)*ones(n-1,1)];
        ss=[ss;s(2:n)'];
        ep=[ep [m-1:m+n-2
                [m:m+n-2 e(2,i)]
                s(1:n)
                s(2:n+1)
                e(5:7,i)*ones(1,n)]];
        m=m+n-1;
      else
        hp=[hp hhh HH(j+1)];
        bb=[bb;e(5,i)*ones(n,1)];
        ss=[ss;s(2:n+1)'];
        ep=[ep [m-1:m+n-2
                m:m+n-1
                s(1:n)
                s(2:n+1)
                e(5:7,i)*ones(1,n)]];
        m=m+n;
      end
    end
  end
end

[x,y]=pdeigeom(g,bb,ss);

x=x'; y=y';

