% GAUSSMF �K�E�X�Ȑ������o�V�b�v�֐�
% 
% GAUSSMF(X,PARAMS) �́AX �Ōv�Z���ꂽ�K�E�X�����o�V�b�v�֐��ł���s��
% ���o�͂��܂��BPARAMS �́A���̃����o�V�b�v�֐��̌`�ƈʒu�����肷��2�v�f
% �x�N�g���ł��B�����Ɩ��m�Ɍ����΁A���̃����o�V�b�v�֐��̎��́A���̂�
% ����ł��B
%
%    GAUSSMF(X,[SIGMA,C]) = EXP(-(X - C).^2/(2*SIGMA^2));
%
% ���:
%    x = (0:0.1:10)';
%    y1 = gaussmf(x,[0.5 5]);
%    y2 = gaussmf(x,[1 5]);
%    y3 = gaussmf(x,[2 5]);
%    y4 = gaussmf(x.[3 5]);
%    subplot(211); plot(x,[y1 y2 y3 y4]);
%    y1 = gaussmf(x,[1 2]);
%    y2 = gaussmf(x,[1 4]);
%    y3 = gaussmf(x,[1 6]);
%    y4 = gaussmf(x,[1 8]);
%    subplot(212); plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','gaussmf','numbertitle','off');
%
% �Q�l    DSIGMF,EVALMF, GAUSS2MF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
