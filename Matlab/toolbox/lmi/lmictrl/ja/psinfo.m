% PSINFO�́APSYS�Őݒ肳�ꂽ�|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ�
% �V�X�e��PS�Ɋւ����X�̏���^���܂��B
%
% PSINFO(PS)
% �V�X�e���̓�����\�����܂��B
%
% [TYP,K,NS,NI,NO] = PSINFO(PS)
% �V�X�e���̃^�C�v(�|���g�s�b�N�V�X�e���ɑ΂���'pol'�A�A�t�B���p�����[�^
% �ˑ��V�X�e���ɑ΂���'aff')�A���̒�`�Ɋ֘A����SYSTEM�s��̐�K�A��ԁA
% ���́A�o�͂̐�NS, NI, NO���o�͂��܂��B
%
% PV = PSINFO(PS,'par')
% �p�����[�^�x�N�g���̋L�q���o�͂��܂�(�p�����[�^�ˑ��V�X�e���̂�)�B
%
% SK = PSINFO(PS,'sys',K)
% PS�̒�`�Ɋ֘A����K�Ԗڂ�SYSTEM�s��Sk���o�͂��܂��B
%
% SYS = PSINFO(PS,'eval',P) 
%    �|���g�s�b�N�A�܂��́A�p�����[�^�ˑ��̏�ԋ�ԃ��f���������܂��B��
%    �ʂ́A���̂悤�ɗ^������ SYSTEM �s�� SYS �ł��B
%    PS ���|���g�s�b�N�ŁAP = (p1,...,pk), pj >= 0 ���|���g�s�b�N���W�n
%    �̏ꍇ�A
%
%               p1*S1 + ... + pk*Sk
%      * SYS =  -------------------    
%                 p1 + ... + pk
%
%    PS ���A�t�B���ŁAP ���p�����[�^�x�N�g���̓��ʂȒl�̏ꍇ�A
%
%      * SYS = S0 + p1*S1 + ... + pk*Sk   
%
% �Q�l�F    PSYS, PVEC, LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
