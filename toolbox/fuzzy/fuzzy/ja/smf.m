% SMF S�^�Ȑ������o�V�b�v�֐�
% 
% SMF(X,PARAMS) �́AX �Ōv�Z���� S �^�����o�V�b�v�֐��ł���s����o�͂�
% �܂��BPARAMS = [X0 X1] �́A���̃����o�V�b�v�֐��̃u���[�N�|�C���g����
% �肷��2�v�f�x�N�g���ł��B
% 
% X0 < X1 �̏ꍇ�ASMF �́A(X0 �̂Ƃ���)0����(X1 �̂Ƃ���)1�ւ̊��炩�Ȉ�
% �s�ł��B
% 
% X0 > =  X1 �̏ꍇ�ASMF �́A(X0+X1)/2 ��0����1�փW�����v����X�e�b�v��
% ���ł��B
%
% ���
%    x = 0:0.1:10;
%    subplot(311); plot(x,smf(x,[2 8]));
%    subplot(312); plot(x,smf(x,[4 6]));
%    subplot(313); plot(x,smf(x,[6 4]));
%    set(gcf,'name','smf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
