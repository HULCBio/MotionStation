% function [sysout,pts] = drawmag(in,init_pts)
%
% �}�E�X���g���đΘb�I�ɗ��ΐ��O���t��`���A�ߎ����s���c�[���ł��B
%
% ����:  in       = ����v���b�g�����VARYING�f�[�^���A�f�[�^�̃E�B���h
%                   �E[xmin xmax ymin ymax]���w�肷��CONSTANT�s��̂���
%                   �ꂩ�B
%        init_pts = �����̓_��ݒ肷��VARYING�s��(�I�v�V����)
%
% �o��:  sysout   = �ߎ����ꂽSYSTEM�s��
%        pts      = �ŏI�_��VARYING�s��
%
% �v���b�g�E�B���h�E�Ń}�E�X���g���ƁA���̃L�[���F������܂��B
%	- �}�E�X�{�^�����N���b�N����ƁA�_��ǉ����܂�(�J�����g�E�B���h
%         �E�̊O�ɒǉ������ꍇ������܂�)�B
%	- 'a'����͂���ƁA�_��ǉ����܂�(�}�E�X�{�^���̃N���b�N�Ɠ�����
%          ��)�B
%	- 'r'����͂���ƁA�ł��߂����g���������_���폜���܂��B
%	- ����(0-9)����͂���ƁA����ȍŏ��ʑ��ߎ����s���܂��B
%	- 'w'����͂���ƁA�E�B���h�E���쐬���A�ēx�N���b�N�����2�Ԗڂ�
%         �E�B���h�E�̍��W��ݒ肵�܂��B
%	- 'p'����͂���ƁA�ăv���b�g���܂��B
%	- 'g'����͂���ƁA�O���b�h�̕\����؂�ւ��܂��B
%
% �Q�l: FITMAG, GINPUT, MAGFIT, PLOT, VPLOT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
