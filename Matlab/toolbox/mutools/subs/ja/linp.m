% function [basic,sol,cost,lambda,tnpiv,flopcnt] = ....
%                                    linp(a,b,c,startbasic)
%
% ���`�v��@�ɑ΂���V���v���b�N�X�A���S���Y���ł��B�f�[�^�́A3�̍s��A
% A (m�sn��Am<=n)�AB(m�s1��)�AC(1�sn��)�ƁASTARTBASIC�Ƃ�����{�I�ŁA��
% ���ł�����ɑΉ����鐮���v�f�̃I�v�V�����x�N�g���ł��B���̕ϐ����ȗ���
% ���ƁA��{�I�ȉ����⏕�I�Ȗ����g���ē����܂��B�o�͂́A���̂���
% ���܂݂܂��B
%   BASIC   -  �œK��{���̃C���f�b�N�X
%   SOL -  ��{���̃x�N�g��(size = m)
%   COST-  �œK�R�X�g
%   LAMBDA  -  2�̖��̉�
%   TNPIV   -  �s�{�b�g���Z�̑���
%   FLOPCNT -  flop�J�E���g
% 
% �Q�l: MU.

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:09 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
