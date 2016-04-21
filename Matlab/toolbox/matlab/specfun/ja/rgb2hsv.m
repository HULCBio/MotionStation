% RGB2HSV   RGB(��-��-��)�J���[�}�b�v��HSV(�F��-�ʓx-�l)�ɕϊ�
% 
% H = RGB2HSV(M) �́ARGB�J���[�}�b�v��HSV�J���[�}�b�v�ɕϊ����܂��B�e
% �}�b�v�ͤ�C�ӂ̍s��������3��̍s��ŁA�v�f��0����1�̋�Ԃ̒l�ł��B
% ���͍s�� M �̗�́A���ꂼ��ԁA�΁A�̋��x��\�킵�܂��B�o�͍s�� H 
% �̗�́A���ꂼ��F���A�ʓx�A�l��\�킵�܂��B
%
% HSV = RGB2HSV(RGB) �́ARGB�C���[�W RGB(3�����z��)���A������HSV�C���[�W
% HSV(3�����z��)�ɕϊ����܂��B
%
% �N���X�T�|�[�g
% --------------
% ���͂�RGB�C���[�W�̏ꍇ�́A����́Auint8, uint16, double�̂�����ł�
% �\���܂���B�����āA�o�̓C���[�W�́A�N���Xdouble�ɂȂ�܂��B���͂�
% �J���[�}�b�v�̏ꍇ�́A���͂Əo�͂̃J���[�}�b�v�͋���double�ł��B
% 
% �Q�l�FHSV2RGB, COLORMAP, RGBPLOT. 


%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 2-2-92.
%      revised by C. Griffin for uint8 inputs 7-26-96
%      revised by P. Gravel for faster execution and less memory
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:30 $
