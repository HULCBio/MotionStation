% FILL3   3�����̑��p�`�̓h��Ԃ�
% 
% FILL3(X,Y,Z,C) �́A�x�N�g�� X�AY�AZ �Œ�`���ꂽ3�������p�`���AC ��
% �w�肵���F�œh��Ԃ��܂��B���p�`�̒��_�́AX�AY�AZ ������3�v�f�Ŏw��
% ����܂��B�K�v�ȏꍇ�A���p�`�͍Ō�̒��_���ŏ��̒��_�ɐڑ����āA���p�`
% ����܂��B
%
% C ���A���X�g 'r'�A'g'�A'b'�A'c'�A'm'�A'y'�A'w'�A'k' ����I�����ꂽ
% �P��̃L�����N�^������A���邢��RGB�s�x�N�g����3�v�f [r g b] �̏ꍇ�́A
% ���p�`�͈��̎w�肳�ꂽ�F�œh��Ԃ���܂��B
%
% C ���AX�AY�AZ �Ɠ��������̃x�N�g���̏ꍇ�A���̗v�f�� CAXIS �ŃX�P�[
% �����O����A���_�̃J���[���w�肷�邽�߂ɁA�J�����g�� COLORMAP �̃C��
% �f�b�N�X�Ƃ��Ďg�p����܂��B���p�`���̃J���[�́A���_�̃J���[����`
% ��Ԃ��ē����܂��B
%
% X�AY�AZ �������T�C�Y�̍s��̏ꍇ�A1�񖈂�1�̑��p�`���`�悳��܂��B
% ���̏ꍇ�AC �� "flat" ���p�`�̃J���[�ɑ΂���s�x�N�g���ŁAC ��
% "interpolated" ���p�`�̃J���[�ɑ΂���s��ł��B
%
% X�AY�AZ �̂����ꂩ���s��ŁA����ȊO�������s���̗�x�N�g���ł���ꍇ�́A
% ��x�N�g���̈����́A�v�������T�C�Y�̍s����o�͂��邽�߂ɕ�������܂��B
%
% FILL3(X1,Y1,Z1,C1,X2,Y2,Z2,C2,...) �́A�����̗̈�̓h��Ԃ����w��
% �������1�̕��@�ł��B
%
% FILL3 �́AC �s��̒l�ɂ��APATCH�I�u�W�F�N�g�� FaceColor �v���p�e�B���A
% 'flat'�A'interp' �܂��� colorspec �ɐݒ肵�܂��B
%
% FILL3 �́APATCH�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ��x�N�g�����o�͂��܂��B
% PATCH����1�̃n���h���ԍ��������܂��BX�AY�AZ�AC ��4�v�f�̂��ɂ́A
% patch�̃v���p�e�B���w�肷��p�����[�^�ƒl�̑g���w�肵�܂��B
% 
% �Q�l�FPATCH, FILL, COLORMAP, SHADING.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:53 $
%   Built-in function.
