% SHIFT2MASK   �V�t�g���W�X�^�̍\���ɑ΂��ăV�t�g���}�X�N�x�N�g���ɕϊ�
%
% MASK = SHIFT2MASK(PRPOLY, SHIFT) �́A���̐ڑ������n������ PRPOLY ��
% �^��������`�t�B�[�h�o�b�N�V�t�g���W�X�^�Ɏw�肳�ꂽ�V�t�g(�܂���
% �I�t�Z�b�g)�ɑ΂��铙���ȃ}�X�N���o�͂��܂��B
%  
% ���n������ PRPOLY �́A�~�ׂ��̌W���̃o�C�i���x�N�g�����A������10�i��
% �̃X�J���̂ǂ��炩�łȂ���΂Ȃ�܂���B
% SHIFT �p�����[�^�́A�����̃X�J���łȂ���΂Ȃ�܂���B
%  
% ���:
%   ������ x^3 + x + 1 ��2�̃V�t�g�ɑ΂��Ď��s
%   m = shift2mask([1 0 1 1], 2)
%   ����
%
%   m = 
%
%        1  0  0
%
% �Q�l: MASK2SHIFT, GF/DECONV, ISPRIMITIVE, PRIMPOLY, DE2BI.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/06/23 04:35:18 $
