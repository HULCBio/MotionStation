% IMRECONSTRUCT �@�`�Ԋw�I�č\�����s���܂��B
% IM = IMRECONSTRUCT(MARKER,MASK) �́A�C���[�W MASK �̉��ŁA�C���[�W 
% MARKER �̌`�Ԋw�I�ȍč\�����s���܂��BMARKER �� MASK �́A�����傫��
% �����A2�̋��x�C���[�W���A�܂��́A�o�C�i���C���[�W�ł��BIM �́A
% ���͂ɑΉ����āA���x�C���[�W���A�o�C�i���C���[�W�ɂȂ�܂��BMARKER 
% �́AMASK �Ɠ����傫���ŁA���̗v�f�́AMASK �̑Ή�����v�f��菬����
% �l�̗v�f�ɂȂ�܂��B
%
% �f�t�H���g�ł́AIMRECONSTRUCT �́A2�����C���[�W�ŁA8�A���ߖT�A3����
% �C���[�W�ŁA26�A���ߖT���g���܂��B�������̏ꍇ�́ACONNDEF(NDIMS(I),
% 'maximal') ���g���܂��B
%
% IM = IMRECONSTRUCT(MARKER,MASK,CONN) �́A�w�肵���A�������`�Ԋw�I
% �č\�����s���܂��BCONN �́A���̃X�J���l���g���܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s��
% ���g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN 
% �̒��S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂�
% �āA�Ώ̂ł���K�v������܂��B
%
% �`�Ԋw�I�č\���́A�������̑��� Image Processing Toolbox �֐��AIM-
% CLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, IMHMIN, 
% IMIMPOSEMIN �ɑ΂���A���S���Y���̊�ɂȂ��Ă��܂��B
%
% �N���X�T�|�[�g
% -------------
% MARKER �� MASK �́A�����N���X�ŔC�ӂ̎���������X�p�[�X�̐��l�A
% �܂��� logical �łȂ���΂Ȃ�܂���BIM �́AMARKER �� MASK �Ɠ���
% �N���X�ł��B
%
% �Q�l�F IMCLEARBORDER, IMEXTENDEDMAX, IMEXTENDEDMIN, IMFILL, IMHMAX, 
%        IMHMIN, IMIMPOSEMIN.



%   Copyright 1993-2002 The MathWorks, Inc.
