% DRAWTREE�@ �E�F�[�u���b�g�p�P�b�g�����c���[�̕\��
% DRAWTREE(T,D) �́A�E�F�[�u���b�g�p�P�b�g�c���[ T ��\�����܂��BD �́AT �Ɋ֘A
% ����f�[�^�\���ł��BF = DRAWTREE(T,D) �́Afigure �̃n���h���ԍ����o�͂��܂��B
%
% �K���� Figure �I�u�W�F�N�g�̃n���h���ԍ� F �ɑ΂��āADRAWTREE(T,D,F) �����s��
% ��ƁAFigure �n���h���ԍ� F �̃c���[ T ��`�悵�܂��B
%
% ���
%   x = sin(8*pi*[0:0.005:1]);
%   [t,d] = wpdec(x,3,'db2');
%   fig   = drawtree(t,d);
%   %-------------------------------------------------
%   % �R�}���h���C���֐����g���āAt �܂��́Ad ��ύX
%   %-------------------------------------------------
%   [t,d] = wpjoin(t,d,2);
%   drawtree(t,d,fig);
%
% �Q�l�F READTREE.



%   Copyright 1995-2002 The MathWorks, Inc.
