% DILATE    �o�C�i���C���[�W�ɖc��������K�p
%
% ���ӁF���̊֐��́A�폜�����֐��ŁA�����̃o�[�W�����ł́A�폜����܂��B
% IMDILATE ���g���Ă��������B
%
% BW2 = DILATE(BW1,SE) �́A�o�C�i���\���������v�f SE ���g���āA�o�C�i��
% �C���[�W BW1 �ɖc���������s���܂��BSE �́A0��1��v�f�Ƃ���s��ł��B
% 
% BW2 = DILATE(BW1,SE,ALG) �́A�ݒ肵���A���S���Y�����g���āA�c��������
% �s���܂��BALG �́A���̒�����ݒ肷�镶����ł��B
% 
% 'spatial'    - ��ԗ̈�ŃC���[�W���������܂��B���̃A���S���Y���́A��
%                �r�I�����ȃC���[�W�ƁA�\�����v�f�����������̂ɑ΂��āA
%                �L���ɋ@�\���܂��B�������A�傫�ȃC���[�W��A�\�����v�f
%                ���傫�����̂ɑ΂��Ă͑��x��������\��������܂��B��
%                �ꂪ�A�f�t�H���g�̃A���S���Y���ł��B
% 'frequency'  - ���g���̈�ŃC���[�W���������܂��B���̃A���S���Y���́A
%                �傫���C���[�W�ɑ΂��āA'spatial'��荂���ɂȂ�܂��B
%                �������A���ɑ����̃��������g���܂��B
% 
% spatial �A���S���Y���� frequency �A���S���Y���̏o�͂��錋�ʂ͓����ł��B
% �������A�������x�ƃ������g�p�̊Ԃ̃g���[�h�I�t���قȂ�܂��B��葬���c
% ���������s���ɂ�'frequency' �A���S���Y����ݒ肵�Ă��������B�c��������
% �� "out of memory"���b�Z�[�W���\�������ꍇ�A'spatial' �A���S���Y����
% �ݒ肵�Ă��������B
% 
% BW2 = DILATE(BW1,SE,...,N) �́A�c�������� N ��J��Ԃ��܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W BW1 �́Adouble�A�܂��́Auint8 �̃N���X���ɃT�|�[�g���܂��B
% �o�̓C���[�W BW2 �́A�N���X uint8 �ł��B
% 
% ���
%       BW1 = imread('text.tif');
%       SE = ones(6,2);
%       BW2 = dilate(BW1,SE);
%       imshow(BW1)
%       figure, imshow(BW2)
%
% �Q�l�FBWMORPH, IMDILATE, IMERODE.



%   Copyright 1993-2002 The MathWorks, Inc.  
