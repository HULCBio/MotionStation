% SIMLP   GETXO �ŗ��p�����֐�; ���`�v���������
%
% X = SIMLP(f,A,b)�́A���`�v����������܂��B
%
%            min f'x    �������:   Ax < =  b
%             x
%
% X = SIMLP(f,A,b,VLB,VUB) �́A�݌v�ϐ� X �̉����Ə�����A�������
% VLB < =  X < =  VUB�͈̔͂ł���悤�ɒ�`���܂��B
%
% X = SIMLP(f,A,b,VLB,VUB,X0) �́A�����l�� X0 �ɐݒ肵�܂��B
%
% X = SIMLP(f,A,b,VLB,VUB,X0,N) �́AA �� b �ɂ���Ē�`���ꂽ�ŏ���N��
% ���񂪓�������ł��邱�Ƃ������܂��B
%
% X = SIMLP(f,A,b,VLB,VUB,X0,N,DISPLAY) �́A�\�����郏�[�j���O���b�Z�[�W
% �̃��x���𐧌䂵�܂��B���[�j���O���b�Z�[�W�́ADISPLAY  =  -1 �Ƃ���
% ���Ƃɂ���\���ɂł��܂��B
%
% [x,LAMBDA] = SIMLP(f,A,b) �́A���ɂ����郉�O�����W�F�搔�ALAMBDA ��
% �o�͂��܂��B
%
% [X,LAMBDA,HOW]  =  SIMLP(f,A,b) �́A�J��Ԃ��̍Ō�̌덷�̏�Ԃ�\��
% ��������o�͂��܂��B
%
% SIMLP �́A���ɔ͈͂��^�����Ă��Ȃ����A���s�s�\�ł���Ƃ��ɁA
% ���[�j���O���b�Z�[�W���o�͂��܂��B
%
% SIMLP �́Aprivate/QPSUB ���Ăяo���܂��B
%
% �Q�l : GETX0.


%   Copyright 1990-2002 The MathWorks, Inc.
