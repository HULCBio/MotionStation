% ZMF Z�^�Ȑ������o�V�b�v�֐�
% 
% ZMF(X,PARAMS) �́AX �Ōv�Z���� Z �^�����o�V�b�v�֐��ł���s����o�͂�
% �܂��BPARAMS = [X1 X0] �́A���̃����o�V�b�v�֐��̃u���[�N�|�C���g����
% �肷��2�v�f�x�N�g���ł��BX1 < X0 �̏ꍇ�AZMF �́A(X1 �̂Ƃ���)1����(X0
% �̂Ƃ���)0�ւ̊��炩�Ȉڍs�ł��BX1 > =  X0 �̏ꍇ�AZMF �́A(X0+X1)/2 
% ��1����0�փW�����v����X�e�b�v�֐��ł��B
%
% ���
%    x = 0:0.1:10;
%    subplot(311); plot(x,zmf(x,[2 8]));
%    subplot(312); plot(x,zmf(x,[4 6]));
%    subplot(313); plot(x,zmf(x,[6 4]));
%    set(gcf,'name','zmf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, SMF, TRAPMF, TRIMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
