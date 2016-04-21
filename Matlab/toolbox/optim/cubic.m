function [maximum,err]=cubic(pts,checkpt,location)
%CUBIC Cubicly interpolates four points to find the maximum value.
%   The second argument is for estimation of the error in the 
%   interpolated maximum. 

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/02/07 19:12:55 $

d=pts(1);
abc=[0.5 -0.5 1/6 ; -2.5 2 -0.5; 3 -1.5 1/3]*[pts(2:4)-d*ones(3,1)];
root=real(sqrt(4*(abc(2)^2)-12*abc(1)*abc(3)));
x1=(-2*abc(2)+root)/(6*abc(1));
if 6*abc(1)*x1+2*abc(2)<0
    stepmin=x1; 
   else
    stepmin=(-2*abc(2)-root)/(6*abc(1));
end
maximum=abc(1)*stepmin^3+abc(2)*stepmin^2+abc(3)*stepmin+d;
if nargin>1
    if location==0
        checkpt2=-abc(1)+abc(2)-abc(3)+d;
    else
        checkpt2=64*abc(1)+16*abc(2)+4*abc(3)+d;
    end
    err=abs(checkpt-checkpt2);
end
