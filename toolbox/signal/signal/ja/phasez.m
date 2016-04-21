% PHASEZ �f�W�^���t�B���^�ʑ�����
% [PHI,W] = PHASEZ(B,A,N) �́AN-�_unwrapped�ʑ������̃x�N�g��PHI�ƁA
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
% [PHI,W] = PHASEZ(B,A,N,'whole') �́A�P�ʉ~�̑S����N�_���g�p���܂��B
%
% PHI = PHASEZ(B,A,W) �́A�x�N�g��W�Ŏ������radians/sample 
% (�ʏ�A0 �ƃ΂̊�)�́A���g���ł̈ʑ��������o�͂��܂��B
%
% [PHI,F] = PHASEZ(B,A,N,Fs) �� [PHI,F] = PHASEZ(B,A,N,'whole',Fs) �́A 
% (Hz�ŕ\��)�ʑ��x�N�g��F ���o�͂��܂��B�����ŁAFs �́A(Hz�ŕ\��)
% �T���v�����O���g���ł��B
%   
% PHI = PHASEZ(B,A,F,Fs) �́A(Hz�ŕ\��)�x�N�g��F�ŁA�w�肷����g��
% �ł̈ʑ��������o�͂��܂��B �����ŁAFs �́A(Hz�ŕ\��)�T���v�����O���g���ł��B
%
% [PHI,W,S] = PHASEZ(...) ���邢�� [PHI,F,S] = PHASEZ(...) �́A�v���b�g
% �̏����o�͂��܂��B S �́A�\���̂ł���A���̃t�B�[���h�́A�قȂ���g��
% �����̃v���b�g�𓾂�悤�ɕύX���邱�Ƃ��ł��܂��B 
%
% PHASEZ(B,A,...)���A�o�͈����������Ȃ��ꍇ�A�t�B���^��unwrapped phase
% ���v���b�g���܂��B
%
% ��� #1:
%     b=fircls1(54,.3,.02,.008);
%     phasez(b)
%
% ��� #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasez(b,a,512,'whole');
%
% �Q�l FREQZ, PHASEDELAY, GRPDELAY, FVTOOL.

%   Copyright 1988-2002 The MathWorks, Inc.
