% WAVEDEC �@���d���x����1�����E�F�[�u���b�g����
%
% WAVEDEC �́A�w�肳�ꂽ����̃E�F�[�u���b�g(WFILTERS�Q��)�܂��͓����
% �E�F�[�u���b�g�����t�B���^�̂����ꂩ���g���āA���d���x����1�����E�F�[
% �u���b�g��͂��s���܂��B
%
% [C,L] = WAVEDEC(X,N,'wname') �́A'wname'���g���āA���x�� N �ŐM�� X ��
% �E�F�[�u���b�g�������o�͂��܂��B
%
% N �́A�����ȈӖ��ł̐��̐����łȂ��Ă͂Ȃ�܂���(WMAXLEV ���Q��)�B�o��
% �����\���́A�E�F�[�u���b�g�����x�N�g�� C �Ƃ��̑傫����v�f�Ƃ���x�N
% �g�� L �ł��B
%
% [C,L] = WAVEDEC(X,N,Lo_D,Hi_D) �ɑ΂��āA
%   Lo_D �́A�������[�p�X�t�B���^�ŁA
%   Hi_D �́A�����n�C�p�X�t�B���^�ł��B
%
% ���̍\���́A���̂悤�ɑg�D������܂��B
%   C      = [Approximation �W��(N)| Detail �W��(N)|... |Detail �W��(1)]
%   L(1)   = Approximation �W���̒��� (N)
%   L(i)   = Detail �W���̒��� (N-i+2) �����ŁAi = 2,...,N+1 �ł��B
%   L(N+2) = length(X).
%
% �Q�l�F DWT, WAVEINFO, WAVEREC, WFILTERS, WMAXLEV.



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
