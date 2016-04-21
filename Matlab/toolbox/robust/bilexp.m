%BILEXP Example of bilinear pole-shifting transform.

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

k = 1; m1 = 1; m2 = 1;
agg = [0      0     1     0
      0      0     0     1
   -k/m1   k/m1    0     0
    k/m2  -k/m2    0     0];
bgg = [0 0 1/m1 0]'; cgg = [0 1 0 0]; dgg = 0;
lamg = eig(agg);
[ta1,ta2,ta3,ta4] = bilin(agg,bgg,cgg,dgg,1,'Sft_jw',[-12 -2]);
lamtg = eig(ta1);
xaxis = 2:0.2:12;
[tmp1,tmp2]=size(xaxis);
y = sqrt(25-(xaxis-7*ones(tmp1,tmp2)).^2);
y = [y;-y];
subplot(111);
plot(real(lamg),imag(lamg),'bs',...
   real(lamtg),imag(lamtg),'r+',-real(lamtg),imag(lamtg),'r*',...
   -2*real(lamtg),imag(lamtg),'bx',xaxis,y,'k--',-xaxis,y,'k--');
v=axis;
v(4)=v(4)+5;
axis(v);
grid on;
hl=legend(...
   'original plant poles (s-plane)',...
   'shifted plant poles (s^~-plane)',...
   'shifted H-Inf closed-loop poles',...
   'final H-Inf closed-loop poles',1);
%set(hl,'Visible','off')

text(-3,0,'p1')
text(3,0,'-p1')
text(-13,0,'p2')
text(13,0,'-p2')
xlabel('(p1 = -2, p2 = -12)')
title('Example of Bilinear Mapping: s~ = (-s + p1) / (s/p2 -1)')
hold off
pause
%
% ------ End of BILEXP.M % RYC/MGS %
