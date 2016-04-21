% FEEDBACK   2��LTI���f�����t�B�[�h�o�b�N����
%
% SYS = FEEDBACK(SYS1,SYS2) �́A���[�v�t�B�[�h�o�b�N�V�X�e����LTI���f��
% SYS �����߂܂��B
%
%       u --->O---->[ SYS1 ]----+---> y
%             |                 |           y = SYS * u
%             +-----[ SYS2 ]<---+
%
% ���̃t�B�[�h�o�b�N�����肳��A�v�Z���ʂ̃V�X�e�� SYS �́Au ���� y �ւ�
% �����������܂��B���̃t�B�[�h�o�b�N��K�p���邽�߂ɂ́A���̏�����p��
% �܂��B
% 
%    SYS = FEEDBACK(SYS1,SYS2,+1)
%
% SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) �́A����ʓI�ȃt�B�[�h
% �o�b�N�������쐬���܂��B
%                   +--------+
%       v --------->|        |--------> z
%                   |  SYS1  |
%       u --->O---->|        |----+---> y
%             |     +--------+    |
%             |                   |
%             +-----[  SYS2  ]<---+
%
% �x�N�g�� FEEDIN �́ASYS1 �̓��̓x�N�g���ɑ΂���C���f�b�N�X���܂݁A
% �ǂ̓��� u ���t�B�[�h�o�b�N���[�v�Ɋ܂܂��̂���ݒ肵�܂��B���l�� 
% FEEDOUT �́ASYS1 �̂ǂ̏o�͂��t�B�[�h�o�b�N�Ɏg�p�����̂���ݒ肵
% �܂��BSIGN = 1 �Ƃ���ƁA���̃t�B�[�h�o�b�N���g�p����܂��BSIGN = -1
% �Ƃ��邩�ASIGN ���ȗ�����ƕ��̃t�B�[�h�o�b�N���A�g�p����܂��B���ׂ�
% �̏ꍇ�A�v�Z���ʂ�LTI���f�� SYS �́ASYS1 �Ɠ������͂Əo�͂������܂�
% (�����̎�����ێ����܂�)�B
%
% SYS1 �� SYS2 ���ALTI���f���̔z��Ƃ���ƁAFEEDBACK �́A��������������
% LTI�z�� SYS ���o�͂��܂��B�����ŁA 
% 
%   SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k))
% 
% �ł��B
%
% �Q�l : LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.


%   P. Gahinet  6-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
