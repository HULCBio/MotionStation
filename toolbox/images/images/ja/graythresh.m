% GRAYTHRESH  Otsu �@���g���āA�O���[�o���C���[�W�X���b�V���z�[���h���v�Z
% LEVEL = GRAYTHRESH(I) �́A���x�C���[�W���o�C�i���C���[�W�� IM2BW ���g
% ���āA�ϊ�����Ƃ��Ɏg�p����O���[�o���X���b�V���z�[���h���v�Z���܂��B
% LEVEL �́A[0, 1]�͈̔͂ɓ��鐳�K�����ꂽ���x�l�ł��BGRAYTHRESH �́A
% Otsu �̕��@���g���܂��B���̕��@�́A�X���b�V���z�[���h��K�p���鍕�s�N
% �Z���Ɣ��s�N�Z���̓����N���X�ł̕��U���ŏ��ɂ���悤�ɃX���b�V���z�[��
% �h��I�����܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W I �́A�N���X uint8, uint16, double �̂����ꂩ�Őݒ�ł��A
% ��X�p�[�X�ł���K�v������܂��B�o�� LEVEL �́Adouble �̃X�J���ł��B
%
% ���
% -------
%       I = imread('blood1.tif');
%       level = graythresh(I);
%       BW = im2bw(I,level);
%       imshow(BW)
%
% �Q�l�F IM2BW



%   Copyright 1993-2002 The MathWorks, Inc.  
