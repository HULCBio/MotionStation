% PRIMPOLY   �K���A�̂ɑ΂��錴�n�������̌��o
%
% PR = PRIMPOLY(M) �́AGF(2^M) �ɑ΂��鎟�� M �̌��n���������v�Z���܂��B
%
% PR = PRIMPOLY(M, OPT) �́AGF(2^M) �ɑ΂��錴�n���������v�Z���܂��B
% OPT = 'min'  �ŏ��d�ݕt���̌��n�����������o
% OPT = 'max'  �ő�d�ݕt���̌��n�����������o
% OPT = 'all'  ���ׂĂ̌��n�����������o
% OPT = L      �d�� L �̂��ׂĂ̌��n�����������o
%   
% PR = PRIMPOLY(M, OPT, 'nodisplay') �܂��́A
% PR = PRIMPOLY(M, 'nodisplay') �́A���n�������̃f�t�H���g�\���X�^�C��
% �𖳌��ɂ��܂��B������ 'nodisplay' �́A2�Ԗڂ�3�Ԗڂ̈����̂ǂ��炩��
% �^���邱�Ƃ��ł��܂��B
%
% �o�̗͂�x�N�g�� PR �́A������10�i���ɂ���ă��X�g����鑽������\��
% �܂��BOPT = 'all' �܂��́AL �ŁA1�ȏ�̌��n������������𖞂����ꍇ�A
% PR �̊e�v�f�́A������������\���܂��B����𖞂������n���������Ȃ��ꍇ�A
% PR �͋�ɂȂ�܂��B
%
% �Q�l: ISPRIMITIVE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $   $Date: 2003/06/23 04:35:03 $


