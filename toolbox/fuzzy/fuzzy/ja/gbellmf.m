% GBELLMF ��ʓI�ȃx���^�Ȑ������o�V�b�v�֐�
% 
% GBELLMF(X,PARAMS) �́AX �Ōv�Z������ʓI�ȃx���^�����o�V�b�v�֐���
% ����s����o�͂��܂��BPARAMS �́A���̃����o�V�b�v�֐��̌^�ƈʒu��ݒ�
% ����3�v�f�x�N�g���ł��B��茵���Ɍ����΁A���̃����o�V�b�v�֐��̎��́A
% ���̂Ƃ���ł��B
%
%    GBELLMF(X,[A,B,C]) = 1./((1+ABS((X-C)/A))^(2*B));
%
% ���̃����o�V�b�v�֐��́ACauchy �m�����z�֐����g���������̂ł��邱�Ƃ�
% ���ӂ��Ă��������B
%
% ���:
%    x = (0:0.1:10)';
%    y1 = gbellmf(x,[1 2 5]);
%    y2 = gbellmf(x,[2 4 5]);
%    y3 = gbellmf(x,[3 6 5]);
%    y4 = gbellmf(x,[4 8 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = gbellmf(x,[2 1 5]);
%    y2 = gbellmf(x,[2 2 5]);
%    y3 = gbellmf(x.[2 4 5]);
%    y4 = gbellmf(x,[2 8 5]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','gbellmf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
