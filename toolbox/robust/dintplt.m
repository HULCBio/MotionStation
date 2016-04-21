%DINTPLT Script file for plotting the SV Bode plot of DINTDEMO.
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

clf
subplot(2,2,1)
semilogx(w,svtt(1,:))
grid on
title('Cost Function: Ty1u1 ')
xlabel('Rad/Sec')
ylabel('db')
%
subplot(2,2,2)
semilogx(w,svw1i,w,svs);
grid on
title('1/W1 & S');
xlabel('Rad/Sec');
ylabel('db');
%
subplot(2,2,3)
semilogx(w,svw3i,w,svt);
grid on
title('1/W3 & T');
xlabel('Rad/Sec')
ylabel('db')
%
subplot(2,2,4)
plot(t,y)
grid on
title('Step Response')
xlabel('sec')
drawnow
pause
%
% -------- End of DINTPLT.M --- RYC/MGS %



