% 2�̃K�E�X�Ȑ������킹�������o�V�b�v�֐�
%
% �\��
%    y = gauss2mf(x,params)
%    y = gauss2mf(x,[sig1 c1 sig2 c2])
%
% �ڍ�
% �K�E�X�֐��́A2�̃p�����[�^ sig �� c ��ϐ��Ƃ��āA���̂悤�ɕ\��
% ����܂��B
% 
%    EXP(-(X - C).^2/(2*SIGMA^2));
% 
% �֐� gauss2mf �́A2�̃K�E�X�֐���g�ݍ��킹�Ă��܂��B�ŏ��̊֐��́A
% sig1 �� c1 �Őݒ肳��A�����̋Ȑ����`���܂��B2�Ԗڂ̊֐��́A�E���̋�
% ����ݒ肵�܂��Bc1 < c2 �̂Ƃ��́A���ł��A�֐� gauss2mf �͍ő�l1��
% �B���܂��B���̏ꍇ�A�ő�l��1�����ł��B�p�����[�^�́A���̏��ԂŐݒ�
% ����܂��B
% 
%    [sig1,c1,sig2,c2]
%
% ���
%    x = (0:0.1:10)';
%    y1 = gauss2mf(x,[2 4 1 8]);
%    y2 = gauss2mf(x,[2 5 1 7]);
%    y3 = gauss2mf(x,[2 6 1 6]);
%    y4 = gauss2mf(x,[2 7 1 5]);
%    y5 = gauss2mf(x,[2 8 1 4]);
%    plot(x,[y1 y2 y3 y4 y5]);
%    set(gcf,'name','gauss2mf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
