% TRIMF �O�p�`�����o�V�b�v�֐�
% 
% TRIMF(X,PARAMS) �́AX �Ōv�Z�����O�p�`�����o�V�b�v�֐��ł���s����o
% �͂��܂��BPARAMS = [A B C] �́A���̃����o�V�b�v�֐��̃u���[�N�|�C���g
% �����肷��3�v�f�x�N�g���ł��B�ʏ�AA < =  B < =  C ��K�v�Ƃ��܂��B
%
% MF �́A��ɒP�ʍ����������Ƃɒ��ӂ��Ă��������B�P�ʍ������Ⴂ����
% �̎O�p�֐������ɂ́A����� TRAPMF ���g�p���Ă��������B
%
% ���
%    x = (0:0.2:10)';
%    y1 = trimf(x,[3 4 5]);
%    y2 = trimf(x,[2 4 7]);
%    y3 = trimf(x,[1 4 9]);
%    subplot(211),plot(x,[y1 y2 y3]);
%    y1 = trimf(x,[2 3 5]);
%    y2 = trimf(x,[3 4 7]);
%    y3 = trimf(x,[4 5 9]);
%    subplot(212),plot(x,[y1 y2 y3]);
%    set(gcf,'name','trimf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, 
%         PSIGMF, SIGMF, SMF, TRAPMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
