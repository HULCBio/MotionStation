% GRPDELAY �t�B���^�̌Q�x��
%
% [Gd,W] = GRPDELAY(B,A,N)�́AN�̌v�Z�����_�ł̎��g��W(���W�A���P��)��
% �Q�x��Gd���܂ޒ���N�̃x�N�g�����o�͂��܂��B�Q�x���́A-d{angle(w)}/dw��
% �\���܂��B�܂��AGRPDELAY�́A�P�ʉ~�̏㔼���̎��g���~����̓��Ԋu��N�_
% �ł̌Q�x�����v�Z���܂��BN�̒l��������2�̃x�L��ɂ���ƁAFFT�A���S���Y
% �����g���������v�Z���\�ɂȂ�܂��BN���w�肵�Ȃ��ƁA�f�t�H���g�� N = 
% 512 ���g���܂��B
%
% GRPDELAY(B,A,N,'whole')�́A�P�ʉ~�S�̂̉~�����N�_���g�p���܂��B
%
% [Gd,F] = GRPDELAY(B,A,N,Fs)�A�܂��� [Gd,F] = GRPDELAY(B,A,N,'whole',Fs)
% �́A�T���v�����O���g��Fs��Hz�P�ʂŐݒ肷��ƁA�x�N�g��F�̎��g�����o��
% ���܂��B
%
% Gd = GRPDELAY(B,A,W)�A�܂��́AGd = GRPDELAY(B,A,F,Fs)�́AW(���W�A���P
% ��)�A�܂���F(Hz�P��)�̓_�Ōv�Z�����Q�x�������ꂼ��o�͂��܂��B�����ŁA
% Fs��Hz�P�ʂ̃T���v�����O���g���ł��B
%
% GRPDELAY(B,A,...)�́A�o�͈�����ݒ肹���Ɏg�p����ƁA���K�����ꂽ���g
% ��(�i�C�L�X�g���g����1)�ɑ΂���Q�x�����J�����g��figure�E�B���h�E�Ƀv
% ���b�g�\�����܂��B
%
% �Q�l�F   FREQZ



%   Copyright 1988-2002 The MathWorks, Inc.
