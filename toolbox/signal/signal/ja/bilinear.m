% BILINEAR �o�ꎟ�ϊ����g�����ϐ��̃}�b�s���O(�ݒ���g���ɂ��āA�}�b�s
% ���O�O��ŉ��������킹��I�v�V�����t��)
%
% [Zd,Pd,Kd] = BILINEAR(Z,P,K,Fs)�́A��_(Z),��(P),����� �Q�C��(K)�Ő�
% �肳���s�̈�̓`�B�֐����A�o�ꎟ�ϊ����瓾���铙����z�̈�̊֐��ɕ�
% �����܂��B
%
%    H(z) = H(s) |
%                | s = 2*Fs*(z-1)/(z+1)
%
% �����ŁA��_(Z),��(P)�͗�x�N�g���ŁA�Q�C��(K)�̓X�J���ł��B�܂��AFs 
% �́AHz �P�ʂ̃T���v�����O���g����\���Ă��܂��B
%
% [NUMd,DENd] = BILINEAR(NUM,DEN,Fs)�́As�̈�ō~�ׂ��̏��ɐݒ肳�ꂽ�`
% �B�֐� NUM(s)/DEN(s)�̌W������͈����Ƃ��āAz�̈�ɕϊ����A�~�ׂ��̏�
% �ɕ��ׂ��`�B�֐�NUM(z)/DEN(z)�̌W�����o�͂��܂��B
%
% [Ad,Bd,Cd,Dd] = BILINEAR(A,B,C,D,Fs)�́A�s��A�AB�AC�AD�̘A���n��ԋ��
% �V�X�e���𗣎U�n�V�X�e���ɕϊ����܂��B
%
% �֐� BILINEAR �̏�L��3�̌`���́A�I�v�V�����Œǉ�������͈�����^����
% ���ƂŁA�v�����[�s���O�Ɋւ���ݒ�����邱�Ƃ��ł��܂��B
% 
% ���Ƃ��΁A[Zd,Pd,Kd] = BILINEAR(Z,P,K,Fs,Fp)�́A�o�ꎟ�ϊ��̑O�ɁA
% �v�����[�s���O��K�p����̂ŁA�}�b�s���O�����̑O��Ŏ��g�������́A
% ���g��(Fp)�Ő��m�Ɉ�v���܂��B(��v������g��Fp��Hz�P�ʂŎ����܂��B)
%
% �Q�l  IMPINVAR.



%   Copyright 1988-2002 The MathWorks, Inc.
