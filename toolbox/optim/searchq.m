function [pcnt, matl,matx,stepsize,fnew,how]=searchq(pcnt,fnew,oldx,matl,matx,sd,gdold,stepsize,how)
%SEARCHQ Line search routine for LSQNONLIN, and LSQCURVEFIT functions.
%   Performs line search procedure for least squares optimization. 
%   Uses Quadratic Interpolation. When finished pcnt returns 0.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/01/24 09:23:07 $

if pcnt==1
% Case 1: Next point less than initial point. 
%     Increase step-length based on last gradient evaluation
    if fnew<matl(1)
% Quadratic Extrapolation using gradient of first point and 
% values of two other points.
        matl(2)=fnew;
        matx(2)=stepsize;
        newstep=-0.5*gdold*stepsize*stepsize/(fnew-gdold*stepsize-matl(1)+eps);
        if newstep<stepsize,how=[how,'QEF ']; newstep=1.2*stepsize; end
        stepsize=1.2*newstep;
        pcnt=2;
    else
% Case 2: New point greater than initial point. Decrease step-length.
        matl(3)=fnew;
        matx(3)=stepsize;
%Interpolate to get stepsize
        stepsize=max([1e-8*stepsize,-gdold*0.5*stepsize^2/(fnew-gdold*stepsize-matl(1)+eps)]);
        how=[how,'r'];
        pcnt=3;
    end
% Case 3: Last run was Case 1 (pcnt=2) and new point less than 
%     both of other 2. Replace. 
elseif pcnt==2  && fnew< matl(2)
    newstep=cubici2(gdold,[matl(1);matl(2);fnew],[matx(1);matx(2);stepsize]);
    if newstep<stepsize,how=[how, 'CEF ']; end
        matl(1)=matl(2);
        matx(1)=matx(2);
        matl(2)=fnew;
        matx(2)=stepsize;
        stepsize=min([newstep,1])+1.5*stepsize;
        stepsize=max([1.2*newstep,1.2*stepsize]);
        how=[how,'i'];
% Case 4: Last run was Case 2: (pcnt=3) and new function still 
%     greater than initial value.
elseif pcnt==3 && fnew>=matl(1)
    matl(2)=fnew;
    matx(2)=stepsize;
    if stepsize<1e-6
        newstep=-stepsize/2;
        % Give up if the step-size gets too small 
        % Stops infinite loops if no improvement is possible.
        if abs(newstep) < (eps * eps), pcnt = 0; end
    else
        newstep=cubici2(gdold,[matl(1);matl(3);fnew],[matx(1);matx(3);stepsize]);
    end
    matx(3)=stepsize;
    if isnan(newstep), stepsize=stepsize/2; else stepsize=newstep; end
    matl(3)=fnew;
    how=[how,'R'];
% Otherwise must have Bracketed Minimum so do quadratic interpolation.
%  ... having just increased step.
elseif pcnt==2 && fnew>=matl(2)
    matx(3)=stepsize;
    matl(3)=fnew;
    [stepsize]=cubici2(gdold,matl,matx);
    pcnt=4;
% ...  having just reduced step.
elseif  pcnt==3  && fnew<matl(1)
    matx(2)=stepsize;
    matl(2)=fnew;
    [stepsize]=cubici2(gdold,matl,matx);
    pcnt=4;
% Have just interpolated - Check to see whether function is any better 
% - if not replace.
elseif pcnt==4 
    pcnt=0;
    stepsize=abs(stepsize);
% If interpolation failed use old point.
    if fnew>matl(2),
        fnew=matl(2);
        how='f';
        stepsize=matx(2);       
    end
end %if pcnt==1
 
