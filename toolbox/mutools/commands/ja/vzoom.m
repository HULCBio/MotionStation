%function vzoom('axis')
%
% VZOOM�́A�v���b�g����2�_���N���b�N���邱�Ƃɂ���āA�����Œ肵�܂��B
% STR�́A���̂悤�ȕ�����ϐ��ł��B
%	'ss'  �W���̃v���b�g(�f�t�H���g)
%	'll'  ���ΐ�
%	'ls'  �Бΐ�(x�����ΐ�) 
%	'sl'  �Бΐ�(y�����ΐ�) 
%
% �܂��ASTR��'bode'�ȊO�̔C�ӂ�VPLOT�̓��͂ō\���܂���B
% 
%  ���:
%            tf = frsp(nd2sys([ 1 .1],[.1 1]),logspace(-2,2,100));
%            vplot('nic',tf); vzoom('nic'); vplot('nic',tf);axis;
%
% �Q�l: GINPUT, VPLOT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
