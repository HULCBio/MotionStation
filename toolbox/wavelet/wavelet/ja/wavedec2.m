% WAVEDEC2 �@���d���x����2�����E�F�[�u���b�g����
%
% [C,L] = WAVEDEC2(X,N,'wname') �́A������ 'wname'(WFILTERS ���Q��)��
% �ݒ肳�ꂽ�E�F�[�u���b�g���g���āA���x�� N �ōs�� X �̃E�F�[�u���b�g
% �������o�͂��܂��B�o�͂́A�E�F�[�u���b�g�����x�N�g�� C �Ƃ��̒�����
% �v�f�Ƃ���s�� S �ł��BN �͌����ȈӖ��ł̐��̐����łȂ��Ă͂Ȃ�܂���
% (WMAXLEV ���Q��)�B
%
% �E�F�[�u���b�g���̑���ɁA�t�B���^��ݒ肷�邱�Ƃ��ł��܂��B
% [C,S] = WAVEDEC2(X,N,Lo_D,Hi_D) �ɑ΂��āA
%   Lo_D �́A�������[�p�X�t�B���^�ŁA
%   Hi_D �́A�����n�C�p�X�t�B���^�ł��B
%
% 2�����E�F�[�u���b�g�����\�� [C,S] �́A�E�F�[�u���b�g�����x�N�g�� C 
% �Ƃ��̑傫����v�f�Ƃ���s�� S ����\������܂��B�x�N�g�� C �́A
% ���̂悤�ɑg�ݍ��킳��܂��B
%
% C = [ A(N)   | H(N)   | V(N)   | D(N) | ... 
% H(N-1) | V(N-1) | D(N-1) | ...  | H(1) | V(1) | D(1) ].
% 
% �����ŁAA�AH�AV�AD �́A���̂悤�ȍs�x�N�g���ł��B 
%   A = Approximation �W��
%   H = ����Detail �W��
%   V = ����Detail �W��
%   D = �ΊpDetail �W��
% 
% ���ꂼ��̃x�N�g���́A�s��ŗ�P�ʃX�g���[�W�x�N�g���ł��B�s�� S �́A
% ���̓��e���܂�ł��܂��B
%     S(1,:) = Approximation �W��(N)�̑傫��
%     S(i,:) = Detail �W��(N-i+2)�̑傫���A�����ŁAi = 2,...,N+1 �� 
%     S(N+2,:) = size(X) �ł��B
% 
% �Q�l�F DWT2, WAVEINFO, WAVEREC2, WFILTERS, WMAXLEV.



%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
