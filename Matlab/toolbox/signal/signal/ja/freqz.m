% FREQZ �́A�f�W�^���t�B���^���g���������v�Z���܂��B
%
% [H,W] = FREQZ(B,A,N) �́AN �_�ł̃t�B���^�̕��f���g�������x�N�g�� H ��
% ������v�Z���� N �_�̎��g���x�N�g��(�P�ʂ̓��W�A��)���o�͂��܂��B
% 
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
% 
% �́A�x�N�g�� B �� A �ɁA���q�ƕ���̌W����ݒ肵�܂��B���g�������́A�P
% �ʉ~�̏㔼���ɓ��Ԋu�ɕ��z���� N �_�Ōv�Z���܂��BN ���ݒ肳��Ă��Ȃ�
% �ꍇ�A�f�t�H���g��512���g���܂��B
%
% [H,W] = FREQZ(B,A,N,'whole') �́A�P�ʉ~�S�̂��g���܂��B
%
% H = FREQZ(B,A,W) �́A�ݒ肷����g�������W�A��/�T���v���P�ʂŁA�x�N�g�� 
% W �ɐݒ�(�ʏ�́A0�����)�������g���ɑ΂��鉞�����o�͂��܂��B
%
% [H,F] = FREQZ(B,A,N,Fs) �� [H,F] = FREQZ(B,A,N,'whole',Fs) �́A���g��
% �x�N�g�� F(Hz �P��)���o�͂��܂��B�����ŁAFs �̓T���v�����O���g��(Hz�P
% ��)�ł��B
%   
% H = FREQZ(B,A,F,Fs) �́A�x�N�g�� F(Hz�P��)�ɐݒ肵�����g���ŁA���f���g
% ���������o�͂��܂��B�����ŁAFs �̓T���v�����O���g��(Hz �P��)�ł��B
%
% FREQZ(B,A,...) ���g�ł́A�J�����g�t�B�M���A�E�C���h�E���ɃQ�C���ƘA��
% �I�Ȉʑ����v���b�g���܂��B
%
% �Q�l�FFILTER, FFT, INVFREQZ, FVTOOL, FREQS.


%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
