% PRIMPOLY   �K���A�̂ɑ΂��錴�n�������̌��o
%
% PR = PRIMPOLY(M) �́AGF(2^M) �ɑ΂��鎟�� M �̌��n���������v�Z���܂��B
%
% PR = PRIMPOLY(M, OPT) �́AGF(2^M) �ɑ΂��錴�n���������v�Z���܂��B
% OPT = 'min'  �ŏ��̏d�݂̌��n�����������o
% OPT = 'max'  �ő�̏d�݂̌��n�����������o
% OPT = 'all'  ���ׂĂ̌��n�����������o
% OPT = L      �d�� L �̂��ׂĂ̌��n�����������o
%   
% PR = PRIMPOLY(M, OPT, 'nodisplay') �܂��́A
% PR = PRIMPOLY(M, 'nodisplay') �́A�f�t�H���g�̕\���X�^�C���𖳌���
% ���܂��B
%
% PR �̊e�v�f�́A������10�i���ɂ�鑽������\���܂��B
% OPT = 'all' �܂��� L �ŁA1�ȏ�̌��n������������𖞂����ꍇ�APR ��
% �e�v�f�́A������������\���܂��B
% ����𖞂������n���������Ȃ��ꍇ�APR �͋�ɂȂ�܂��B
% ���:
%     PR = primpoly(3)
% 
%     Primitive polynomial(s) = 
%
%     D^3+D^1+1
%
%     PR =
%
%     11
%
%     PR = primpoly(4,'nodisplay')
%
%     PR =
%
%     19
%
% �Q�l : ISPRIMITIVE.


%   Copyright 1996-2002 The MathWorks, Inc.
