% ERODE    �o�C�i���C���[�W��ŏk�ނ����s
%
% ���ӁF���̊֐��́A�����폜����܂��BIMERODE ���g���Ă��������B
%
% BW2 = ERODE(BW1,SE) �́A�o�C�i���C���[�W BW1 ��ŁA�o�C�i���ɂ��\��
% ���v�f SE ���g���ďk�ނ��s���܂��BSE �́A1��0�݂̂���Ȃ�s��ł��B
% 
% BW2 = ERODE(BW1,SE,ALG) �́A�ݒ肵���A���S���Y�����g���āA�k�ނ��s����
% ���BALG �́A���̒�����ݒ�ł��镶����ł��B
% 
% 'spatial'(�f�t�H���g) - ��ԗ̈�ŃC���[�W���������܂��B���̃A���S���Y
%                         ���́A��r�I�����ȃC���[�W�Ə����ȍ\�����v�f��
%                         �΂��ėL���ɋ@�\���܂��B�������A�傫�ȃC���[�W
%                         �Ƒ傫�ȍ\�����v�f�ɑ΂��ẮA���x��������\
%                         ��������܂��B
% 'frequency'           - ���g���̈�ŃC���[�W���������܂��B���̃A���S��
%                         �Y���́A�傫���C���[�W�ɑ΂��āA'spatial' ���
%                         ���x���オ��܂��B�������A���̑����̃�������
%                         �g���܂��B
% 
% spatial �A���S���Y���� frequency �A���S���Y���̏o�͌��ʂ͓����ł��B��
% �����A�������x�ƃ������g�p�̊Ԃ̃g���[�h�I�t���قȂ�܂��B��葬���k��
% �������s���ɂ́A'frequency' �A���S���Y����ݒ肵�Ă��������B�k�ޏ�����
% �� "out of memory" ���b�Z�[�W��\�����邩�A�f�B�X�N�y�[�W���O�̂��߂�
% �R���s���[�^���X���[�_�E������悤�ł�����A'spatial' �A���S���Y�����
% �肵�Ă��������B
% 
% BW2 = ERODE(BW1,SE,...,N) �́A�k�ޏ����� N ��J��Ԃ��܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W BW1 �́Adouble �܂��� uint8 �̃N���X�ł��B�o�̓C���[�W 
% BW2 �́Alogical �ł��B
% 
% ���
% -------
%       BW1 = imread('text.tif');
%       SE = ones(3,1);
%       BW2 = erode(BW1,SE);
%       imshow(BW1), figure, imshow(BW2)
%
% �Q�l�FBWMORPH, IMDILATE, IMERODE.



%   Copyright 1993-2002 The MathWorks, Inc.  
