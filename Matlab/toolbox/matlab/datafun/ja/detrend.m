% DETREND �́AFFT�����ň�ʂɎg�����@�ŁA�x�N�g������g�����h����������
% ���̂ł��B
% 
% Y = DETREND(X)�́A�x�N�g��X�̒��̃f�[�^�𒼐��ߎ����s���A���̗ʂ����
% �����A���̌��ʂ��x�N�g��Y�ɏo�͂��܂��BX���s��̏ꍇ�ADETREND�́A�e��
% �ɂ��ăg�����h�̏������s���܂��B
% 
% Y = DETREND(X,'constant')�ͤ�x�N�g��X���畽�ϒl���������A�܂��́AX���s
% ��̏ꍇ�A�e�񂩂畽�ϒl����菜���܂��B
% 
% Y = DETREND(X,'linear',BP)�́A�A���I�ȁA�敪�I���`�g�����h����菜����
% ���B���`�g�����h�ɑ΂���u���[�N�|�C���g�̃C���f�b�N�X�́A�x�N�g��BP��
% �ݒ肵�܂��B�f�t�H���g�ł́A�u���[�N�|�C���g�͑��݂��܂���B����ŁA
% �P�Ƃ̒�����X�̊e�񂩂��菜����܂��B
%
% �Q�l�FMEAN


%   Author(s): J.N. Little, 6-08-86
%   	   J.N. Little, 2-29-88, revised
%   	   G. Wolodkin, 2-02-98, added piecewise linear fit of L. Ljung
%   Copyright 1984-2004 The MathWorks, Inc. 
