% WINMENU   "Window"���j���[�A�C�e���ɑ΂��ăT�u���j���[���쐬
% 
% WINMENU(H) �́AH �Ŏw�肳��郁�j���[�̉��ɃT�u���j���[�����܂��B
% WINMENU(F)�́A�^�O 'winmenu' ������figure F ��uimenu�̎q��T�����āA
% ���������܂��B
% 
% cb = WINMENU('callback') �́A�T�u���j���[�������j���[�A�C�e���ɑ΂��āA
% �K�؂ȃR�[���o�b�N��������o�͂��܂��i���ʌ݊����̂���)�B�R�[���o�b�N��
% ��� 'winmenu(gcbo)'�ł��B
%
% ���F
%
%  fig_handle = figure;
%  uimenu(fig_handle, 'Label', 'Window', ...
%      'Callback', winmenu('callback'), 'Tag', 'winmenu');
%  winmenu(fig_handle);  % Initialize the submenu

    
%  Steven L. Eddins, 6 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
