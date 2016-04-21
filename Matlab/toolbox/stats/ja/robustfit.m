% ROBUSTFIT   ���o�X�g���`��A
%
% B = ROBUSTFIT(X,Y)�́A���`���f�� Y=Xb �̐���̂��߂Ƀ��o�X�g��A�����s
% ���邱�Ƃœ���ꂽ��A�W���̃x�N�g�� B ��Ԃ��܂�(X ��nxp�̍s��AY ��
% nx1�̊ϑ��x�N�g���ł�)�B���̃A���S���Y���́Abisquare�d�݊֐��Ƃ��ČJ��
% �Ԃ��d�݂�K�p���ꂽ�ŏ�����p���܂��B
%
% B = ROBUSTFIT(X,Y,'WFUN',TUNE,'CONST')�́A�d�݊֐� 'WFUN' ��tuning�萔
% TUNE ���g���܂��B'WFUN' �́A�ȉ��̂����ꂩ�ɂȂ�܂��B
%     'andrews'�A'bisquare'�A'cauchy'�A'fair'�A'huber'�A
%     'logistic'�A'talwar'�A'welsch'
% ����ɁA'WFUN' �́A���͂Ƃ��� �c���̃x�N�g�����Ƃ�A�o�͂Ƃ��ďd��
% �̃x�N�g���𐶐�����֐����������Ƃ��ł��܂��B�c���́A�d�݊֐����R�[��
% ����O�ɁAtuning�萔�ƌ덷���̕W���΍��ɂ���ăX�P�[������܂��B
% 'WFUN' �́A@(�Ⴆ�΁A@myfun)���g�p������A���邢�́A�C�����C���֐���
% ���Ďw�肷�邱�Ƃ��ł��܂��BTUNE �́A�d�݂��v�Z����O�Ɏc���̃x�N�g��
% �ŕ��������tuning�萔�ŁA'WFUN' ���֐��Ƃ��Ďw�肳�ꂽ�Ƃ��ɕK�v��
% �Ȃ�܂��B'CONST' �́A�萔���������邽�߂� 'on' (�f�t�H���g)�Ƃ��邩�A
% ���邢�́A�萔�����ȗ����邽�߂� 'off' �Ƃ��邱�Ƃ��ł��܂��B 
% �萔���̌W���́AB �̍ŏ��̗v�f�ł�(X �̍s����ɒ���1�̗����͂��Ȃ���
% ��������)�B
%
% [B,STATS] = ROBUSTFIT(...)�͂܂��A���̃t�B�[���h������STATS�\���̂�
% �Ԃ��܂��B
%       stats.ols_s     �ŏ����t�B�b�g�����sigma�]��(rmse) 
%       stats.robust_s  sigma�̃��o�X�g�]�� 
%       stats.mad_s     sigma��MAD�]���B�����t�B�b�e�B���O�̊ԁA�c����
%                       �X�P�[�����O���邽�߂Ɏg�p����܂��B 
%       stats.s         sigma�̍ŏI�]���Brobust_s��ols_s��robust_s�̏d��
%                       ���ς̑傫�����̒l
%       stats.se        ����W���̕W���덷 
%       stats.t         stats.se��b�̔� 
%       stats.p         stats.t�ɑ΂���p�l 
%       stats.coeffcorr ����W���̑��ւ̕]�� 
%       stats.w         ���o�X�g�t�B�b�e�C���O�̏d�݃x�N�g�� 
%       stats.h         �ŏ����t�B�b�e�B���O�ɑ΂��郊�׃��b�W�x�N�g��
%       stats.dfe       �덷�ɑ΂��鎩�R�x 
%       stats.R         �s��X��QR������R���q 
% ROBUSTFIT �́A�W���]���̕��U�����U�s��� V=inv(X'*X)*STATS.S^2 �ƕ]����
% �܂��B�W���덷�Ƒ��ւ́AV ���瓱����܂��B


%   Tom Lane 2-11-2000
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:07:03 $
