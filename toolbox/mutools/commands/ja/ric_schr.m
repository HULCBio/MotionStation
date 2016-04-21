% function [x1,x2,fail,reig_min,epkgdif] = ric_schr(ham,epp,balflg)
%
% Riccati�������̈��艻��(A+R*X������)�Ɋ֘A����ŗL�l���������܂��B
%
%        A'*X + X*A + X*R*X - Q = 0
%
% ��Schur�����́AHamilton�s��HAM�̈���ȕs�ϕ�����Ԃ𓾂邽�߂Ɏg����
% ���B���̍s��́A���̌`���̕ϐ��������܂��B
%
%        HAM = [A  R; Q  -A']
%
% HAM��jw����ɌŗL�l�������Ă��Ȃ��ꍇ�An�sn��̍s��x1��x2�����݂��܂��B
% �����̍s��[ x1 ; x2 ]�́AHAM��n�����̈���ȕs�ϕ�����Ԃł��Bx1����
% ���ȏꍇ�AX := x2/x1��Riccati�������𖞑����A���̌��ʂ�A+RX�͈���ɂ�
% ��܂��B�o�̓t���OFAIL�͒ʏ�0�ł��Bjw����ɌŗL�l�����ꍇ�AFAIL��1��
% �o�͂���܂��B���ƕ��̌ŗL�l�̐��������łȂ���΁AFAIL�ɂ�2���o�͂���A
% �����̏��������ɐ�����Ƃ��ɂ́AFAIL �ɂ�3���o�͂���܂��B
%
% RIC_SCHR�́A�����t����ꂽ���fSchur�^���쐬���邽�߁ACSORD���Ăяo����
% ���B���̌^����Schur�^�ɕϊ����A��]����Hamiltonian�̈���ȕs�ϕ������
% ��^���܂��B�ŗL�l�̍ŏ��������̐�Βl�́AREIG_MIN�ɏo�͂���܂��B
%
% BALFLG�́ARiccati�������������O��HAM�𕽍t�����邩�ǂ������w�肷��t��
% �O�ł��BBALFLG��0�ɐݒ肷���HAM�𕽍t�����A1�ɐݒ肷��ƕ��t�����܂�
% ��B�f�t�H���g�ł́ABALFLG��0�ɐݒ肳��܂��BEPKGDIF�́A2�̈قȂ�jw
% ���̃e�X�g�̔�r�ł��B
%
% �Q�l: CSORD, HAMCHK, RIC_EIG, SCHUR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
