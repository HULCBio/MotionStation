% TRAPMF ��`�����o�V�b�v�֐�
% 
% TRAPMF(X,PARAMS) �́AX �Ōv�Z�����`�̃����o�V�b�v�֐��ł���s����o
% �͂��܂��BPARAMS = [A B C D] �́A���̃����o�V�b�v�֐��̃u���[�N�|�C��
% �g�����肷��4�v�f�x�N�g���ł��B�����ł́AA < =  B �� C < =  D ��������
% ���܂��BB > =  C �̏ꍇ�A���̃����o�V�b�v�֐��͒P�ʌ���菬����������
% ���O�p�����o�V�b�v�֐��ł�(�ȉ��̗��Q��)�B
%
% ���
%    x = (0:0.1:10)';
%    y1 = trapmf(x,[2 3 7 9]);
%    y2 = trapmf(x,[3 4 6 8]);
%    y3 = trapmf(x,[4 5 5 7]);
%    y4 = trapmf(x,[5 6 4 6]);
%    plot(x,[y1 y2 y3 y4]);
%    set(gcf,'name','trapmf','numbertitle','off');
%
% �Q�l   DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%        PSIGMF, SIGMF, SMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
