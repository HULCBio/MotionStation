% MARGIN   �Q�C���]�T�A�ʑ��]�T�ƃQ�C���������g���A�ʑ��������g��
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) �́ASISO �J���[�vLTI���f�� SYS (�A���n
% �܂��͗��U�n)�̃Q�C���]�T Gm �ƈʑ��]�T Pm�A�����āA�֘A����ʑ�����
% ���g�� Wcg �ƃQ�C���������g�� Wcp ���v�Z���܂��B�Q�C���]�T Gm �� 1/G 
% �Ƃ��Ē�`����A�����ŁAG �͈ʑ���-180�x�ƌ�������Ƃ��̃Q�C���ł��B
% �ʑ��]�T Pm �́A�x�P�ʂŕ\��܂�
%
% dB�P�ʂŕ\�����Q�C���]�T�́A���̊֌W���瓱����܂��B
% 
%      Gm_dB = 20*log10(Gm)
% 
% Wcg �ł̃��[�v�̃Q�C���́A���萫���������O�ł̑����܂��͌�������
% �Q�C���ŁAGm_dB < 0 (Gm < 1)�́A���萫�����[�v�Q�C���̌����ɔ���
% �q���ł��邱�Ƃ��Ӗ����܂��B�����̌����_�����݂���ꍇ�AMARGIN �́A
% �ň��̗]�T(�Q�C���]�T��0 dB �ɋ߂��A�ŏ��ʑ��]�T)���o�͂��܂��B
%
% LTI���f���� S1*...*Sp �z�� SYS �ɑ΂��āAMARGIN �́A�T�C�Y [S1 ... Sp]
% �̂��̂悤�Ȕz����o�͂��܂��B
%      [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp))
%
% [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) BODE �ɂ���Đ������ꂽ Bode
% �Q�C���A�ʑ��A���g���x�N�g���ł��� MAG, PHASE, W ����Q�C���ƈʑ��]�T��
% ���o���܂��B��Ԃ́A�l�𐄒肷�邽�߂Ɏ��g���_�Ԃōs���܂��B
%
% MARGIN(SYS) �́A���ꎩ�g�ł͐������C���Ń}�[�N�t�����ꂽ�Q�C���ƈʑ��]�T
% ���g���ĊJ���[�vBode���v���b�g���܂��B
%
% �Q�l : ALLMARGIN, BODE, LTIVIEW, LTIMODELS.


%   Andrew Grace 12-5-91
%   Revised ACWG 6-21-92
%   Revised P.Gahinet 96-98
%   Revised A.DiVergilio 7-00
%   Revised J.Glass 1-02
%   Copyright 1986-2002 The MathWorks, Inc. 
