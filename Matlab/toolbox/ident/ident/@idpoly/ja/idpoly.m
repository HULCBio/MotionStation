% IDPOLY �́AIDPOLY ���f���\���̂��쐬���܂��B
%       
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts)
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts,'Property',Value,..)
%
%  M: ���̃��f�����L�q���郂�f���\���̃I�u�W�F�N�g�Ƃ��ďo��
%
%     A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%
% ���F�m�C�Y���̕��U�́ANoiseVariance �ł��BTs �̓T���v���Ԋu�ŁATs = 0 
% �͘A�����ԃ��f�����Ӗ����܂��B
% 
% A,B,C,D, F �́A�������Ƃ��ē��͂���܂��B
%
% ���U���ԃ��f���ł́AA, C, D, F ��1����n�܂�A����AB �ɂ́A�x�������
% �[�����t������܂��B�����̓V�X�e���̏ꍇ�AB �� F �́A���͐��Ɠ������s
% �������s��ł��B���n��̏ꍇ�AB �� F �́A[] �Ƃ��Đݒ肵�܂��B
%
% ���F
% A = [1 -1.5 0.7], B = [0 0.5 0 0.3; 0 0 1 0], Ts = 1 �́A���̃��f��
% ���`���܂��B
% 
%   y(t) - 1.5y(t-1) + 0.7y(t-2) = 0.5u1(t-1) + 0.3u1(t-3) + u2(t-2)
%
% �A�����ԃ��f���ɑ΂��āA���������As �̍~�x�L�̏��ɓ��͂���Ă��܂��B
% 
% ���F 
% A = 1; B = [1 2;0 3]; C = 1; D = 1; F = [1 0;0 1]; Ts = 0 �́A���̘A
% �����ԃV�X�e���ɒ�`���܂��B
% 
%    Y = (s+2)/s U1 + 3 U2.
%
% C, D, F, NoiseVariance, Ts �ȍ~���ȗ�����ƁA1�Ƃ݂Ȃ��܂�(B = [] �̏�
% ���AF = []�ł�)�B
%
% M = IDPOLY �́A��̃I�u�W�F�N�g���쐬���܂��B
%
% M = IDPOLY(SYS) �́A�C�ӂ̒P�o�� IMODEL�A�܂��́ALTI �I�u�W�F�N�g SYS 
% �p�� IDPOLY ���f�����쐬���܂��BLTI ���f����InputGroup 'Noise' ���܂�
% �ꍇ�A���F�m�C�Y�Ƃ��Ď�舵�����Ƃ� M �̃m�C�Y���f�����v�Z���܂��B
%
% IDPOLY �v���p�e�B�̏ڍׂȏ��́ASET(IDPOLY) �ƃ^�C�v���Ă��������B
% 
% �Q�l�FPOLYDATA 
%



%   Copyright 1986-2001 The MathWorks, Inc.
