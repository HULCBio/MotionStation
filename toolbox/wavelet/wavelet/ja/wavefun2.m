% WAVEFUN2   2�����̃E�F�[�u���b�g�֐��ƃX�P�[�����O�֐�
%
% WAVEFUN2 �́A�E�F�[�u���b�g�֐� 'wname' �Ɗ֘A�����X�P�[�����O�֐���
% �ߎ������݂���ꍇ�ɏo�͂��܂��B
%
% [S,W1,W2,W3,XYVAL] = WAVEFUN2('wname',ITER) �́A�����E�F�[�u���b�g��
% �΂���1�����̃X�P�[�����O�֐��ƃE�F�[�u���b�g�֐��̃e���\���ς���X
% �P�[�����O�֐���3�̃E�F�[�u���b�g�֐��̌��ʂ��o�͂��܂��B
%
% ��萳�m�ɂ́A[PHI,PSI,XVAL] = WAVEFUN('wname',ITER) �̏ꍇ�A�X�P�[
% �����O�֐� S �́APHI �� PHI �̃e���\���ςł��B�E�F�[�u���b�g�֐� W1,
% W2 ����� W3 �́A���ꂼ�� (PSI,PHI) ����� (PSI,PSI) �� (PHI,PSI) ��
% �̃e���\���ςł��B2�����ϐ� XYVAL �́A�e���\���� (XVAL,XVAL) ���瓾
% ���� (2^ITER) x (2^ITER) �_�̃O���b�h�ł��B���̐��� ITER �́A�J��
% �Ԃ����ł��B
%
% ... = WAVEFUN2(...,'plot') �́A�v�Z�ƁA�t���I�Ɋ֐����v���b�g���܂��B
%
% WAVEFUN2('wname',A,B) �� (�����ŁAA,B �͐��̐���)�AWAVEFUN2('wname',
% max(A,B)) �Ɠ����ŁA�v���b�g�\�����s���܂��B
%
% WAVEFUN2('wname',0) �́AWAVEFUN2('wname',4,0) �Ɠ����ł��B
% WAVEFUN2('wname') �́AWAVEFUN2('wname',4) �Ɠ����ł��B
%
% �Q�l : INTWAVE, WAVEFUN, WAVEINFO, WFILTERS.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
