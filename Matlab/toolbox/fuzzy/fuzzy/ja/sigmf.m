% SIGMF �V�O���C�h�Ȑ������o�V�b�v�֐�
% 
% SIGMF(X,PARAMS) �́AX �Ōv�Z�����V�O���C�h�����o�V�b�v�֐��ł���s��
% ���o�͂��܂��BPARAMS �́A���̃����o�V�b�v�֐��̌^�ƈʒu�����肷��2�v�f
% �x�N�g���ł��B���ɁA���̃����o�V�b�v�֐��̎��́A���̂Ƃ���ł��B
%
%    SIGMF(X,[A,C]) = 1./(1 + EXP(-A*(X-C)))
%
% ���
%    x = (0:0.2:10)';
%    y1 = sigmf(x,[-1 5]);
%    y2 = sigmf(x,[-3 5]);
%    y3 = sigmf(x,[4 5]);
%    y4 = sigmf(x,[8 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = sigmf(x,[5 2]);
%    y2 = sigmf(x,[5 4]);
%    y3 = sigmf(x,[5 6]);
%    y4 = sigmf(x,[5 8]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','sigmf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
