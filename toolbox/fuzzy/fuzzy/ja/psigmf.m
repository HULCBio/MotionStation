% PSIGMF 2�̃V�O���C�h�����o�V�b�v�֐��̐�
% PSIGMF(X,PARAMs) �́AX �Ōv�Z�����2�̃V�O���C�h�֐��̐ςł���s�� 
% Y ���o�͂��܂��BPARAMS �́A���̃����o�V�b�v�֐��̌^�ƈʒu�����肷��4�v
% �f�x�N�g���ł��B���ɁA���̂悤�� X �� PARAMS �� SIGMF �֓n���܂��B
%
%    PSIGMF(X,PARAMS) = SIGMF(X,PARAMS(1:2)).*SIGMF(X,PARAMS(3:4));
%
% ���
%    x = (0:0.2:10)';
%    params1 = [2 3];
%    y1 = sigmf(x,params1);
%    params2 = [-5 8];
%    y2 = sigmf(x,params2);
%    y3 = psigmf(x,[params1 params2]);
%    subplot(211);
%    plot(x,y1,x,y2); title('sigmf');
%    subplot(212);
%    plot(x,y3,'g-',x,y3,'o'); title('psigmf');
%    set(gcf,'name','psigmf','numbertitle','off');
% 
% �Q�l   DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%        SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
