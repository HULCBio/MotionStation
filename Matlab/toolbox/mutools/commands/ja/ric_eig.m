% function [x1,x2,fail,reig_min,epkgdif] = ric_eig(ham,epp,balflg)
%
% Riccati�������̈��艻��(A+R*X������)�Ɋ֘A����ŗL�l���������܂��B
%
%       A'*X + X*A + X*R*X - Q = 0
%
% �ŗL�l�����́AHamiltonian�s��HAM�̈���ȕs�ϕ�����Ԃ𓾂邽�߂Ɏg���
% �܂��B���̍s��́A���̌`���̕ϐ��������܂��B
%
%      HAM = [A  R; Q  -A']
%
% HAM��jw����ɌŗL�l�������Ă��Ȃ��ꍇ�An�sn��̍s��X1��X2�����݂��܂��B
% �����̍s��[ X1 ; X2 ]�́AHAM��n�����̈���ȕs�ϕ�����Ԃł��BX1����
% ���ȏꍇ�AX = X2/X1��Riccati�������𖞑����A���̌��ʂ�A+RX�͈���ɂȂ�
% �܂��BHAM��jw����ɌŗL�l�����ꍇ�AFAIL��1���o�͂���܂��B�ŗL�l�̎�
% �����̑傫����EPP��菬������΁A�ŗL�l�͏������ƍl���܂��B�ŗL�l�̍�
% ���������́AREIG_MIN�ɏo�͂���܂��BEPP�̃f�t�H���g�l��1e-10�ł��B
%
% BALFLG�́ARiccati�������������O��HAM�𕽍t�����邩�ǂ������w�肵�܂��B
% BALFLG��0�ɐݒ肷���HAM�𕽍t�����ABALFLG���[���ɐݒ肷��ƕ��t����
% �܂���B�f�t�H���g�ł́ABALFLG��0�ɐݒ肳��܂��B
%
% ���̃R�}���h�́AHAM���Ίp������Ȃ��ꍇ�A�s���m�Ȍ��ʂɂȂ�܂��B����
% �ꍇ�́ARIC_SCHR���g�����Ƃ����E�߂��܂��BEPKGDIF�́A2�̈قȂ�jw����
% �e�X�g�̔�r�ł��B
%
% �Q�l: EIG, RIC_SCHR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
