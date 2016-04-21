% TF2LATC �`�B�֐������e�B�X�t�B���^�ɕϊ�
% K = TF2LATC(NUM)�́ANUM(1)�Ő��K�����ꂽFIR(MA)���e�B�X�t�B���^
% �ɑ΂��郉�e�B�X�p�����[�^K�����߂܂��BFIR�t�B���^�̃[�����P�ʉ~���
% ����ꍇ�ɂ́A�덷��������ꍇ������܂��B
%
% K = TF2LATC(NUM,'max')�ŁANUM�͍ő�ʑ�FIR�t�B���^�ɑΉ����A
% FIR���e�B�X�ɕϊ�����O��NUM�𔽓]�����A���������܂��B
% ����́Aabs(K) <= 1�ƂȂ�ALATCFILT�̑��o�͂Ƃ��čő�ʑ��t�B���^��
% �������邽�߂ɗp�����܂��B
%
% K = TF2LATC(NUM,'min')�ŁANUM�͍ŏ��ʑ�FIR�t�B���^�ɑΉ����A
% ����́Aabs(K) <= 1�ƂȂ�ALATCFILT�̑��o�͂Ƃ��čŏ��ʑ��t�B���^��
% �������邽�߂ɗp�����܂��B
%
% K = TF2LATC(NUM,DEN,...)�ŁADEN�́AK = TF2LATC(NUM/DEN,...)��
% �����ȃX�J���ł��B
%
% [K,V] = TF2LATC(NUM,DEN)�́ADEN(1)�ɂ���Đ��K�����ꂽIIR (ARMA) 
% lattice-ladder �t�B���^�ɑ΂��郉�e�B�X�p�����[�^K��ladder�p�����[�^V��
% ���߂܂��B�`�B�֐��̋ɂ��P�ʉ~��ɂ���ꍇ�ɂ́A�덷��������ꍇ��
% ����܂��B
%
% K = TF2LATC(1,DEN)�́AIIR all-pole (AR)���e�B�X�t�B���^�ɑ΂��郉�e�B�X
% �p�����[�^K�����߂܂��B[K,V] = TF2LATC(B0,DEN) �ŁAB0�̓X�J���ŁA
% ladder�W��V�̃x�N�g�����o�͂��܂��B���̏ꍇ�́AV�̍ŏ��̗v�f�݂̂�
% ��[���ł��B
%
%   ���:
%      % Convert an all-pole IIR filter to lattice coefficients:
%      DEN = [1 13/24 5/8 1/3];
%      K = tf2latc(1,DEN);  % K will be [1/4 1/2 1/3]'
%
% �Q�l�FLATC2TF, LATCFILT, POLY2RC, RC2POLY.



%   Copyright 1988-2002 The MathWorks, Inc.
