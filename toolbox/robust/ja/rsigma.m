% SV = SIGMA(A, B, C, D, TY, W)�A�܂��́A
% SV = SIGMA(SS_,TY,W) �́ATY �̒l�Ɉˑ����āA���̃V�X�e���̓��ْl���g��
% �������܂ލs�� SV ���o�͂��܂��B
% 
%      TY = 1   ----   G(jw)
%      TY = 2   ----   inv(G(jw))
%      TY = 3   ----   I + G(jw)
%      TY = 4   ----   I + inv(G(jw))
% G(jw) �́A�V�X�e���̎��g�������ł��B
%                 .
%                 x = Ax + Bu
%                 y = Cx + Du.
%
% SS_ �́A�R�}���h SS_ = MKSYS(A,B,C,D) �ō쐬������ԋ�ԃV�X�e���ł��B
% W �͎������g����v�f�Ƃ���x�N�g���ł��B
%
% �O�̃V���^�b�N�X�́AROBUST CONTROL TOOLBOX ���C���X�g�[������Ă���ꍇ
% �Ɏg�p�\�ɂȂ�܂��B�����āA�֐� SIGMA �̃h�L�������g�ɐ�������Ă���
% �ʂ̃V���^�b�N�X���g�p�\�ł��B
%
% �Q�l�F SIGMA, DSIGMA, RDSIGMA

% Copyright 1988-2002 The MathWorks, Inc. 
