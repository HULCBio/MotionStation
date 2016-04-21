% HSV2RGB   HSV(�F��-�ʓx-�l)�J���[�}�b�v��RGB(��-��-��)�ɕϊ�
% 
% M = HSV2RGB(H) �́AHSV�J���[�}�b�v��RGB�J���[�}�b�v�ɕϊ����܂��B
% �e�}�b�v�́A�C�ӂ̍s��������3��̍s��ŁA�v�f��0����1�̋�Ԃ̒l�ł��B
% ���͍s�� H �̗�́A���ꂼ��F���A�ʓx�A�l��\�킵�܂��B�o�͍s�� M ��
% ��́A���ꂼ��ԁA�΁A�̋��x��\�킵�܂��B
%
% RGB = HSV2RGB(HSV) �́AHSV�C���[�W HSV(3�����z��)���A������RGB�C���[�W
% RGB(3�����z��)�ɕϊ����܂��B
%
% �F����0����1�ɕω�����ɘA��āA���ʂ̃J���[�͐Ԃ��物�A�΁A�V�A���A�A
% �}�W�F���^���o�ĐԂɖ߂�܂��B�ʓx��0�̂Ƃ��A�F�͖O�a���Ă��܂���
% (�܂�O���C�������Ă��܂�)�B�ʓx��1�̂Ƃ��A�J���[�͏\���ɖO�a����
% ���܂�(�܂蔒�F�������܂܂�Ă��܂���)�B�l��0����1�ɕω�����ɂ�āA
% �P�x���������܂��B
%
% �J���[�}�b�vHSV�́Ah ��0����1�܂ł̐��`�����v�ŁAs �� v �̂��ׂĂ�
% �v�f��1�̂Ƃ��Ahsv2rgb([h s v]) �ł��B
% 
% �Q�l�FRGB2HSV, COLORMAP, RGBPLOT.


%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 2-2-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:19 $
