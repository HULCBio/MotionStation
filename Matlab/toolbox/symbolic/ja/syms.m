% SYMS   �V���{���b�N�I�u�W�F�N�g�쐬�̃V���[�g�J�b�g
% 
%      SYMS arg1 arg2 ...
% 
% �́A���̃X�e�[�g�����g�̒Z�k�`�ł��B
% 
%      arg1 = sym('arg1');
%      arg2 = sym('arg2'); ...
%
%      SYMS arg1 arg2 ... real
%  
% �́A���̃X�e�[�g�����g�̒Z�k�`�ł��B
% 
%      arg1 = sym('arg1','real');
%      arg2 = sym('arg2','real'); ...
%
%      SYMS arg1 arg2 ... positive
%   
% �́A���̃X�e�[�g�����g�̒Z�k�`�ł��B
% 
%      arg1 = sym('arg1','positive');
%      arg2 = sym('arg2','positive'); ...
%
%     SYMS arg1 arg2 ... unreal
%   
% �́A���̃X�e�[�g�����g�̒Z�k�`�ł��B
% 
%      arg1 = sym('arg1','unreal');
%      arg2 = sym('arg2','unreal'); ...
%
% �e���͈����́A�����Ŏn�܂�A�p�����݂̂��܂܂Ȃ���΂Ȃ�܂���B
%
% SYMS �����ł́A���[�N�X�y�[�X���̃V���{���b�N�I�u�W�F�N�g�����X�g����
% ���B
%
% ���:
% 
%      syms x beta real
% 
% �́A���̃X�e�[�g�����g�Ɠ����ł��B
% 
%      x = sym('x','real');
%      beta = sym('beta','real');
%
% 'real' ��Ԃ̃V���{���b�N�I�u�W�F�N�g x �� beta ���������邽�߂ɂ́A��
% ���̂悤�Ƀ^�C�v���Ă��������B
% 
%      syms x beta unreal
%
% �Q�l   SYM.



%   Copyright 1993-2002 The MathWorks, Inc.
