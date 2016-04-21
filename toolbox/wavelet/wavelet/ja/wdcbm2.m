% WDCBM2�@�@ Birge-Massart�@���g���āA�E�F�[�u���b�g2�����G�������܂��͈��k�ɑ�
%            ����X���b�V���z�[���h���s���܂��B
%
% [THR,NKEEP] = WDCBM2(C,S,ALPHA,M) �́ABirge-Massart �@��p�����E�F�[�u���b�g�W
% ���̑I�𑥂ɂ���ē�����G�������A�܂��͈��k�Ɋւ��āA���x���Ɉˑ��ɂ���X��
% �b�V���z�[���h�l THR �ƕێ������W���̐� NKEEP ���o�͂��܂��B
%
% [C,S] �́A���x�� J0 = size(S,1)-2 �ɂ����ĎG�������܂��͈��k���ꂽ�C���[�W�̃E
% �F�[�u���b�g�����\���ł��BALPHA ��1���傫�������łȂ���΂Ȃ�܂���B�T�^�I
% �ɂ́A���k�̏ꍇ ALPHA = 1.5�ŁA�G�������̏ꍇ�� ALPHA = 3�ƂȂ�܂��BM �͐���
% �����ŁA�T�^�I�ɂ́A���x�� J0+1 �� Detail �W���̒��� M = 3*prod(S(1,:))/4 �ɂ�
% ��܂��B
%
% THR �� 3 �s J0 ��̍s��ł��BTHR(:,I) �́A���x�� I �ɑ΂���3�̕����A�����A��
% �p�A���������œ����郌�x���ˑ��̃X���b�V���z�[���h�l�ł��BNKEEP �́A���� J0 
% �̃x�N�g���ł��BNKEEP(:,I) �́A���x�� I �ŕێ������W���̐��ł��B
%
% Birge-Massart �̘_�����Q�Ƃ���ƁAJ0 �� J0+1 �ƂȂ��Ă��܂��BJ0�AM�AALPHA�@���A
% ���̎�@���`�t���邱�ƂɂȂ�܂��B:
%   - ���x�� J0+1(�y�т��e�����x��)�ł́A���ׂĂ̂��̂��ێ�����܂��B
%   - 1���� J0 �܂ł͈̔͂ɂ��郌�x�� J �ɂ����āA���傫���W���ł��� nj �́Anj
%     = M/(J0+1-j)^ALPHA �ɕۂ���܂��BM �͒����p�����[�^(�f�t�H���g�l���Q��)��
%     ���B
%
% WDCBM2(C,L,ALPHA) �́AWDCBM2(C,L,ALPHA,3*PROD(S(1,:))/4) �Ɠ����ł��B
%
% �Q�l�����F L. Birge, P. Massart, "From model selection to
%            adaptive estimation", in Festschrift for Lucien Le Cam,
%            D. Pollard, E. Torgersen, G.L. Yang editors, Springer, 
%           1997, p. 55-87
% 
% �Q�l�F WDENCMP, WPDENCMP.



%   Copyright 1995-2002 The MathWorks, Inc.
