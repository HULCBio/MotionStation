% DSIGMF 2�̃V�O���C�h�����o�V�b�v�֐��Ԃ̍����g���������o�V�b�v�֐�
% 
% �\��
%    y = dsigmf(x,[a1 c1 a2 c2])
% 
% �ڍ�
% �����ň����V�O���C�h�����o�V�b�v�֐��́A2�̃p�����[�^ a �� c �Ɉˑ�
% ���Af(X,a,c) = 1/(1+exp(-a(x-c))) �ŗ^�����܂��B
% 
% �����o�V�b�v�֐� dsigmf �́A4�̃p�����[�^ a1�Ac1�Aa2 ����� c2 �Ɉ�
% �����A���̂悤��2�̃V�O���C�h�֐��̍��ł��B
% 
%    f1(x; a1,c1) - f2(x; a2,c2)
% 
% �p�����[�^�̐ݒ菇�́A[a1 c1 a2 c2] �ł��B
% 
% ���
%    x = 0:0.1:10;
%    y = dsigmf(x,[5 2 5 7]);
%    plot(x,y)
%    xlabel('dsigmf�AP = [5 2 5 7]')
% 
% �Q�l    EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
