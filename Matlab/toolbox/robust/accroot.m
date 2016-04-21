%ACCROOT Script file for plotting the root locus of 1990 ACC benchmark problem.

% R. Y. Chiang & M. G. Safonov 5/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.

clf
plot(real(pole),imag(pole),'x',real(zero),imag(zero),'o',...
     real(RL),imag(RL),'.');
axis([-3 2 -3 3]);
if flag == 3
   title('Enlarged Root Locus (H-Inf + Internal Model)')
else
   title('Enlarged Root Locus');
end
xlabel('Real   (Root Locus Gain: 0:0.1:30)'); ylabel('Imag');
text(0.2,1.4,'Plant');
text(0.2,-1.5,'Plant');
text(0.2,-0.1,'Plant');
if flag == 3
   text(0.2,0.4,'Int. Model');
   text(0.2,-0.6,'Int. Model');
   text(-2,0.5,'Int. Model');
   text(-2,-0.8,'Int. Model');
end
pause
axis
plot(real(pole),imag(pole),'x',real(zero),imag(zero),'o',...
     real(RL),imag(RL),'.');
if flag == 3
   title('Root Locus (H-Inf + Internal Model)');
else
   title('Root Locus');
end
xlabel('Real   (Root Locus Gain: 0:0.1:30)'); ylabel('Imag');
%
% ------ End of ACCROOT.M % RYC/MGS %




