% IMEXTENDEDMIN �@�g��-minima �ϊ�
% BW = IMEXTENDEDMIN(I,H) �́A�g��-minima �ϊ����s���܂��B����́AH-
% minima �ϊ��̒n��I�ȍŏ��l�̏W�܂�ł��BH �́A�񕉂̃X�J���ł��B
%
% �n��I�ȍŏ��l�̏W�܂�́A����̃s�N�Z���l�� t ���傫���l�̋��x�l t 
% �����s�N�Z���̘A���v�f�Q�ł��B
%
% �f�t�H���g�ŁAIMEXTENDEDMIN �̎g�p����A���x�́A2�����̏ꍇ8�A3������
% �ꍇ26�ŁA�������̏ꍇ�ACONNDEF(NDIMS(I),'minimal') �ł��B
%
% BW = IMEXTENDEDMIN(I,H,CONN) �́ACONN ���A����ݒ肷�镔���ŁA�g��-
% minima �ϊ����v�Z���܂��BCONN �́A���̃X�J���l�̂����ꂩ���g���܂��B
%
%       4     2����4�A���ߖT
%       8     2����8�A���ߖT
%       6     3����6�A���ߖT
%       18    3����18�A���ߖT
%       26    3����26�A���ߖT
%
% �A���x�́ACONN �ɑ΂��āA0��1��v�f�Ƃ���3 x 3 x 3 x ... x 3 �̍s���
% �g���āA�C�ӂ̎����ɑ΂��āA����ʓI�ɒ�`�ł��܂��B�l1�́ACONN �̒�
% �S�v�f�Ɋ֘A���ċߖT�̈ʒu��ݒ肵�܂��BCONN �́A���S�v�f�ɑ΂��āA��
% �̂ł���K�v������܂��B
%
% �N���X�T�|�[�g
% -------------
% I �́A�C�ӂ̔�X�p�[�X���l�N���X�ŁA�C�ӂ̎����������܂��BBW �́AI ��
% �����T�C�Y�ŁA��� logical �ł��B
%
% ���
% -------
%       I = imread('bonemarr.tif');
%       BW = imextendedmin(I,10);
%       imshow(I), figure, imshow(BW)
%   
% �Q�l�FCONNDEF, IMEXTENDEDMAX, IMRECONSTRUCT.



%   Copyright 1993-2002 The MathWorks, Inc.
