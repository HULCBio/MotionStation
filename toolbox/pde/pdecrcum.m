function c=circum(p,t)
%PDECRCRM Circumscribe triangles.

%       L. Langemyr 11-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:14 $

x1=p(1,t(1,:)); x2=p(1,t(2,:)); x3=p(1,t(3,:));
y1=p(2,t(1,:)); y2=p(2,t(2,:)); y3=p(2,t(3,:));

a11=x2-x1; a12=y2-y1; b1=x2.^2+y2.^2-x1.^2-y1.^2;
a21=x3-x1; a22=y3-y1; b2=x3.^2+y3.^2-x1.^2-y1.^2;
d=2*(a11.*a22-a21.*a12);

cx=(b1.*a22-b2.*a12)./d;
cy=(a11.*b2-a21.*b1)./d;
c=[cx;cy;sqrt((x1-cx).^2+(y1-cy).^2)];

