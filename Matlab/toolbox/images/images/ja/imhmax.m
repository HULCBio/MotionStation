% IMHMAX �@H-maxima �ϊ�
% I2 = IMHMAX(I,H) �́AH �����Ⴂ�����ł��� I �̒��̂��ׂĂ̍ō��l�̏W
% �܂��ጸ���܂��BI �́A���x�C���[�W�ŁAH �͔񕉂̃X�J���ł��B
%
% �n��I�ȍő�l�̏W�܂�́A�������x�l t �����s�N�Z���̘A�������ł��B
% ���̎���̃s�N�Z���́At ��菬�����l�ł��B
%
% �f�t�H���g�ŁAIMHMAX �̎g�p����A���x�́A2�����̏ꍇ8�A3�����̏ꍇ26��
% �������̏ꍇ�ACONNDEF(NDIMS(I),'maximal') �ł��B
%
% I2 = IMHMAX(I,H,CONN) �́ACONN ���A����ݒ肷�镔���ŁAH-maxima �ϊ���
% �v�Z���܂��BCONN �́A���̃X�J���l�̂����ꂩ���g���܂��B
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
% I �́A�C�ӂ̔�X�p�[�X���l�N���X�ŁA�C�ӂ̎����������Ă��܂��BI2 �́AI 
% �Ɠ����T�C�Y�ŁA�N���X�ł��B 
%
% ���
% -------
%       a = zeros(10,10);
%       a(2:4,2:4) = 3;  % �����荂���Amaxima 3 
%       a(6:8,6:8) = 8;  % �����荂���Amaxima 8
%       b = imhmax(a,4); % 4���傫���ő�l�̏W�܂肪�c��
%
% �Q�l�F CONNDEF, IMHMIN, IMRECONSTRUCT.



%   Copyright 1993-2002 The MathWorks, Inc.
