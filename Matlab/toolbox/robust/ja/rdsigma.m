% SV = DSIGMA(A, B, C, D, TY, W, T)�A�܂��́A
% SV = DSIGMA(SS_,TY,W,Ts) �́ATY �̒l�Ɉˑ����āA���̃V�X�e���̗��U����
% ���ْl���g���������܂ލs�� SV ���o�͂��܂��B
% 
%      TY = 1   ----   G(exp(jwT))
%      TY = 2   ----   inv(G(exp(jwT))
%      TY = 3   ----   I + G(exp(jwT))
%      TY = 4   ----   I + inv(G(exp(jwT)))
% �����ŁAG(z) �́A���U���ԃV�X�e���̎��g�������ł��B
%            x[n+1] = Ax[n] + Bu[n]
%              y[n] = Cx[n] + Du[n].
%
% SS_ �́A�R�}���h SS_=MKSYS(A,B,C,D) �ō쐬������ԋ�ԃV�X�e���ł��BW 
% �͓��ْl���v�Z����������g����v�f�Ƃ���x�N�g���ŁAT �̓T���v�����O�Ԋu
% �ł��B
%
% �O�̃V���^�b�N�X�́AROBUST CONTROL TOOLBOX ���C���X�g�[������Ă���ꍇ
% �Ɏg�p�\�ɂȂ�܂��B�����āA�֐� DSIGMA �̃h�L�������g�ɐ�������Ă���
% �ʂ̃V���^�b�N�X���g�p�\�ł��B%
% 
% �Q�l�F DSIGMA, RSIGMA, SIGMA

% Copyright 1988-2002 The MathWorks, Inc. 
