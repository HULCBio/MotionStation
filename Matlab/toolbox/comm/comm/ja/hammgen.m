% HAMMGEN   Hamming ���������s��ƃp���e�B�`�F�b�N�s����쐬
%
% H = HAMMGEN(M) �́AM >=3 �ł��鏊��̐��� M �ɂ��Ẵp���e�B�`�F�b�N
% �s����쐬���܂��BHamming �����̒����́AN = 2^M-1�ł��B���b�Z�[�W���́A
% K = 2^M - M - 1�ł��B�p���e�B�`�F�b�N�s��́AM �s N ��̍s��ł��B
% 
% H = HAMMGEN(M, P) �́A����� GF(2) ���n������ P ���g�p���āA�p���e�B
% �`�F�b�N�s����쐬���܂��B
% 
% [H, G] = HAMMGEN(...) �́A�����s�� G �Ɠ��l�Ƀp���e�B�`�F�b�N�s�� H ��
% �쐬���܂��B�����s��� K �s N ��̍s��ł��B
% 
% [H, G, N, K] = HAMMGEN(...) �́A�R�[�h���[�h�� N �ƃ��b�Z�[�W�� K ���o
% �͂��܂��B
% 
% ����:���͐� M �́A3�ȏ�łȂ���΂Ȃ�܂���BHamming�����͒P�������
% �����ł��B
%
% �Q�l�F ENCODE, DECODE, GEN2PAR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
