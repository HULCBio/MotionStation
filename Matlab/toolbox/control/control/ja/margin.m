% MARGIN   �Q�C���]�T�ƈʑ��]�T�ƃN���X�I�[�o���g��
%
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) �́ASISO �J���[�v LTI ���f�� SYS (�A���n�܂���
% ���U�n)�̃Q�C���]�T Gm �ƈʑ��]�T Pm�A�����āA�֘A����ʑ��������g�� Wcg ��
% �Q�C���������g�� Wcp ���v�Z���܂��B�Q�C���]�T Gm �� 1/G �Ƃ��Ē�`����A
% �����ŁAG �͈ʑ���-180�x�ƌ�������Ƃ��̃Q�C���ł��B�ʑ��]�T Pm �́A�x�P�ʂ�
% �\��܂��B
%
% dB�P�ʂŕ\�����Q�C���]�T�́A
%   Gm_dB = 20*log10(Gm) 
% ���瓱����܂��BWcg �ł̃��[�v�̃Q�C���́A���萫���������O�ł̑����܂���
% ��������Q�C���ŁAGm_dB < 0 (Gm < 1)�@�́A���萫�����[�v�Q�C���̌����ɔ���
% �q���ł��邱�Ƃ��Ӗ����܂��B
% �����̌����_�����݂���ꍇ�AMARGIN �́A�ŏ��̗]�T(�Q�C���]�T��0 dB �ɋ߂��A
% �ʑ��]�T��0 �x�ɋ߂�)���o�͂��܂��B
%
% LTI ���f���� S1�~...�~Sp �z�� SYS �ɑ΂��āAMARGIN �́A�T�C�Y [S1 ... Sp]��
% ���̂悤�Ȕz����o�͂��܂��B 
%   [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp))
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) �́ABODE �ɂ���Đ������ꂽBode�Q�C���A
% �ʑ��A���g���x�N�g���ł��� MAG, PHASE, W ����Q�C���]�T�ƈʑ��]�T�𓱏o
% ���܂��B��Ԃ́A�l�𐄒肷�邽�߂Ɏ��g���_�Ԃōs���܂��B
%
% MARGIN(SYS) �́A���ꎩ�g�ł͐������C���Ń}�[�N�t�����ꂽ�Q�C���ƈʑ��]�T��
% �g���ĊJ���[�vBode���v���b�g���܂��B
%
% �Q�l : ALLMARGIN, BODE, LTIVIEW, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
