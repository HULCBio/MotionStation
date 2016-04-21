% PHASEDELAY �f�W�^���t�B���^�̈ʑ��x��
% [PHI,W] = PHASEDELAY(B,A,N)�́AN-�_�ʑ��x�������̃x�N�g��PHI�ƁA
% �t�B���^��radians/sample�ł�N-�_���g���x�N�g��W ���o�͂��܂��B
% �t�B���^�́A�x�N�g��B��A �ŗ^����ꂽ���q�ƕ���̌W���ŗ^�����܂��B 
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
% �ʑ������́A�P�ʉ~�̏㔼���ɓ��Ԋu�ɕ��� N �_�ŕ]������܂��B 
% N ���w�肵�Ȃ��ꍇ�A�f�t�H���g�́A512�ł��B
%
% [PHI,W] = PHASEDELAY(B,A,N,'whole') �́A�P�ʉ~�S�̂̎���N �_
% ���g�p���܂��B
%
% PHI = PHASEDELAY(B,A,W) �́A�x�N�g��W�Ŏ������radians/sample 
% (�ʏ�A0 �� �΂̊�)�́A���g���ł̈ʑ��x���̉������o�͂��܂��B
%
% [PHI,F] = PHASEDELAY(B,A,N,Fs) �� [PHI,F] = PHASEDELAY(B,A,N,'whole',Fs)�́A
% (Hz�ŕ\��)�ʑ��x���̃x�N�g��F ���o�͂��܂��B�����ŁAFs�́A(Hz�ŕ\��)
% �T���v�����O���g���ł��B
%   
% PHI = PHASEDELAY(B,A,F,Fs) �́A(Hz�ŕ\��)�x�N�g��F�Ŏw�肳���
% ���g���ł̈ʑ��x���̉������o�͂��܂��B �����ŁAFs �́A(Hz�ŕ\��)
% �T���v�����O���g���ł��B
%
% [PHI,W,S] = PHASEDELAY(...)�A���邢�́A[PHI,F,S] = PHASEDELAY(...) �́A
% �v���b�g�̏����o�͂��܂��B
% S �́A�\���̂ł���A���̃t�B�[���h�́A�قȂ���g�������̃v���b�g
% �𓾂�悤�ɕύX���邱�Ƃ��ł��܂��B 
%
% PHASEDELAY(B,A,...)���A�o�͈����������Ȃ��ꍇ�A�J�����g�t�B�M���A
% �E�B���h�E�Ƀt�B���^�̈ʑ��x���̉������v���b�g���܂��B
%
% ��� #1:
%     b=fircls1(54,.3,.02,.008);
%     phasedelay(b)
%
% ��� #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasedelay(b,a,512,'whole')
%

%   Copyright 1988-2002 The MathWorks, Inc.
