% WDCBM �@Birge-Massart�@���g���āA�E�F�[�u���b�g1�����G�������܂��͈��k�ɑΉ���
%         ��X���b�V���z�[���h���s���܂��B
% [THR,NKEEP] = WDCBM(C,L,ALPHA,M) �́ABirge-Massart �@��p�����E�F�[�u���b�g�W
% ���̑I���K���ɂ���ē�����G�������A�܂��͈��k�Ɋւ��āA���x���Ɉˑ��ɂ���X
% ���b�V���z�[���h�l THR�ƌW���̐���ێ����� NKEEP ���o�͂��܂��B
%
% [C,L] �́A���x�� J0 = length(L)-2 �ɂ����ĎG�������A�܂��͈��k���ꂽ�M���̃E�F
% �[�u���b�g�����\���ł��BALPHA �́A1���傫�������łȂ���΂Ȃ�܂���B�T�^�I
% �ɂ́A���k�̏ꍇ�AALPHA = 1.5�ŁA�G�������̏ꍇ�́AALPHA = 3�ƂȂ�܂��BM �͐�
% �̐����ŁA�T�^�I�ɂ́A�����Ƃ��e�� Approximation �W���̒�����2�Ŋ������l M = L
% (1)/2 �ƂȂ�܂��B
%
% THR �́A���� J0 �̃x�N�g���ŁATHR(:,I) �́A���x�� I �ɑ΂��ē�����X���b�V��
% �z�[���h�l�ł��BNKEEP �́A���� J0 �̃x�N�g���ŁANKEEP(:,I) �́A���x�� I �ŕێ�
% �����W���̐��ł��B
%
% Birge-Massart �̘_�����Q�Ƃ���ƁAJ0 �� J0+1 �ƂȂ��Ă��܂��BJ0�AM�AALPHA�@���A
% ���̎�@���`�t���邱�ƂɂȂ�܂��B
%   - ���x�� J0+1(�y�т��e�����x��)�ł́A���ׂĂ̂��̂��ێ�����܂��B
%   - 1���� J0 �܂ł͈̔͂ɂ��郌�x�� J �ɂ����āA���傫���W���ł��� nj �́Anj
%     = M/(J0+1-j)^ALPHA �ɕۂ���܂��BM �͒����p�����[�^(�f�t�H���g�l���Q��)��
%     ���B
%
% WDCBM(C,L,ALPHA) �́AWDCBM(C,L,ALPHA,L(1)/2) �Ɠ����ł��B
%
% �Q�l�����F L. Birge, P. Massart, "From model selection to
%            adaptive estimation", in Festschrift for Lucien Le Cam,
%            D. Pollard, E. Torgersen, G.L. Yang editors, Springer, 
%            1997, p. 55-87
% 
% �Q�l�F WDEN, WDENCMP, WPDENCMP.



%   Copyright 1995-2002 The MathWorks, Inc.
