% UNFIXPAR  
% ��ԋ�Ԃ� ARX ���f���\���̌Œ�p�����[�^�����R�p�����[�^�ɕύX
%   
%       TH = UNFIXPAR(TH_OLD, MATRIX, ELEMENTS)
%
%   TH       : �X�V���ꂽ THETA �s��
%   TH_OLD   : �I���W�i���� THETA �s��
%   MATRIX   : �ǂ̍s��𑀍삷�邩('A','B','C','D','K','X0'�̂ǂꂩ1��)
%   ELEMENTS : �ǂ̗v�f�𑀍삷�邩�An �s2��̍s��ŁA�e�s�����삷��v�f
%              �̍s�ԍ��Ɨ�ԍ��A���̈������ȗ������ƁA���ׂĂ̗v�f��
%              ���삳��܂��B
%
% ���F 
%    th1 = unfixpar(th, 'A', [3,1;2,2;1,3]);
%
% �s�� 'A1', 'A2', ...,'B0', 'B1', ...�Ɨ^������ƁAARX �\���̑Ή���
% ��s�񂪑��삳��A���̂悤�ɒ�`���ꂽ TH_OLD ����`����܂��B
%
% ����: 
% UNFIXPAR �́A�W���̃��f���\���ɑ΂��Ă̂݋@�\���܂��BMS2TH, ARX2TH, 
% ARX �Œ�`����܂��BTH_OLD �����[�U��`�̍\��(MF2TH)�Ɋ�Â��ꍇ�A
% ���[�U���g�Ŏ��R�p�����[�^��ݒ肷��K�v������܂��B
%
% �Q�l:    ARX, ARX2TH, MS2TH, FIXPAR, PEM, THSS

%   Copyright 1986-2001 The MathWorks, Inc.
