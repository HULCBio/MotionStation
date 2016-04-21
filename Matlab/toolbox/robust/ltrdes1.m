% function [ae,be,ce,de] = ltrdem1(sys,n,Q,R,Xi,Th);
% function for the ltr controller design. It is specially written for the
% ltrdemo1 simulink program.p
% function [ae,be,ce,de] = ltrdem1(sys,n,Q,R,Xi,Th);

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $

pause(-2);
n = length(a);
%place sample-hold to the original system
[az,bz]=c2d(a,b,0.01);
[A,B,C,D]=bilin(az,bz,c,d,-1,'Tustin',0.01);
%Solve Kalman filter gain
disp('Use LQRC to solve kalman filter gain');
Kf = lqrc(A', C', diagmx(Xi,Th))';
disp('find the frequency range of the singular value by using SIGMA')
[sv,w]=sigma(A,B,C,D);
%[m,l] = size(w);  if l>m, w=w'; end;
disp('Choose recovery gain to be 1e+5')
q=[1e+5];
disp('Use LTRY to calculate the feedback controller')
disp('ignore the up coming ''strike a key .... hit <RET>'' message')
[ae,be,ce,de,svl]=ltry(A,B,C,D,Kf,Q,R,q,w);
pause(-2);
clear q sv A B C D az bz
disp('Design finished')

