% RLOCUS   Evans���O�Ֆ@
%
% RLOCUS(SYS) �́A1����1�o�͂�LTI���f�� SYS �̍��O�Ղ����߂ăv���b�g��
% �܂��B���O�Ճv���b�g�́A���̂悤�ȕ��̃t�B�[�h�o�b�N���[�v����͂���
% ���߂ɗ��p����܂��B
%
%                  +-----+
%      ---->O----->| SYS |----+---->
%          -|      +-----+    |
%           |                 |
%           |       +---+     |
%           +-------| K |<----+
%                   +---+
%
% ���O�Ղ́A�t�B�[�h�o�b�N�Q�C�� K ���A0���� Inf (������)�֕ω�����ꍇ
% �̕��[�v�ɂ̋O�Ղ������܂��BRLOCUS �́A���炩�ȃv���b�g���쐬����
% �悤�Ɏ����I�ɐ��̃Q�C���̏W�����v�Z���܂��B  
%
% RLOCUS(SYS,K) �́A���[�U���ݒ肵���Q�C���x�N�g�� K �𗘗p���܂��B
%
% RLOCUS(SYS1,SYS2,...) �́A������LTI���f�� SYS1,SYS2,...�̍��O�Ղ�
% ��̃v���b�g�}�ɕ\�����܂��B�e���f���ɑ΂��āA�J���[�A���C���X�^�C���A
% �}�[�J�����̂悤�ɐݒ肷�邱�Ƃ��ł��܂��B
% 
%   rlocus(sys1,'r',sys2,'y:',sys3,'gx')
% 
% [R,K] = RLOCUS(SYS)�A�܂��́AR = RLOCUS(SYS,K) �́A�Q�C�� K �ɑΉ�����
% ���f���̈ʒu���s�� R �ɏo�͂��܂��BR �́ALENGTH(K) �̗�������Aj�Ԗ�
% �̗�́A�Q�C�� K(j) �ɑ΂�����[�v���ɂȂ�܂��B  
%
% �Q�l : RLTOOL, RLOCFIND, POLE, ISSISO, LTIMODELS.


%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised P. Gahinet 7-96
%   Revised A. DiVergilio 6-00
%   Copyright 1986-2002 The MathWorks, Inc. 
