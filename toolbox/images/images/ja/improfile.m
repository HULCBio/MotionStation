% IMPROFILE   ���C�������ɉ����ăs�N�Z���l�̒f�ʂ��v�Z
%
% IMPROFILE �́A����C���[�W���ŁA1�A�܂��́A�����̃��C���ɉ�����
% ���x�l���v�Z���܂��BIMPROFILE �́A���[�U���w�肵���p�X�ɉ����ē��Ԋu
% �ɓ_��I�����A�e�_�ɑ΂��鋭�x�l����}�ɂ��v�Z���܂��BIMPROFILE �́A
% �O���[�X�P�[�����x�C���[�W�� RGB �C���[�W�ɓK�p�ł��܂��B
%
% ���̍\���̂ǂ��炩���g���āAIMPROFILE ���Ăяo���ƁA�J�����g������
% �C���[�W�ɑ΂��đΘb�I�ɏ������s���܂��B
%
%        C = IMPROFILE
%        C = IMPROFILE(N)
%
% N �́A���x�l���v�Z����_���ł��B���̈������ȗ�����ƁAIMPROFILE �́A
% �p�X���ɑ��݂���s�N�Z�����ɁA�قڕC�G����l N ��ݒ肵�܂��B
%
% �}�E�X���g���āA�C���[�W�̒��̓_���N���b�N���邱�Ƃɂ��A���C���A
% �܂��́A�p�X��ݒ�ł��܂��B���ɐݒ肵���_��ݒ�����ɂ���ɂ́A
% <BACKSPACE>�A�܂��́A<DELETE>�������Ă��������BShift ���������܂�
% �N���b�N���邩�A�E�{�^�����N���b�N���邩�A�܂��́A�_�u���N���b�N�ɂ�
% ��A�Ō�̓_��I�����邱�Ƃ��ł��܂��B�܂��A<RETURN> ���������Ƃɂ��A
% �_��I�����Ȃ��ŏI�����邱�Ƃ��ł��܂��_�̑I�����I������ƁAIMPROFILE 
% �́AC �ɓ��}�����f�[�^�l���o�͂��܂��BC �́A���͂��O���[�X�P�[�����x
% �C���[�W�̏ꍇ�AN �s1��̃x�N�g���ɁARGB �C���[�W�̏ꍇ�AN x 1 x 3�z��
% �ɂȂ�܂��B
%
% �o�͈������ȗ�����ƁAIMPROFILE �͌v�Z�������x�l�̃v���b�g��\������
% ���B�ݒ肵���p�X��1�̒����̏ꍇ�AIMPROFILE �́A���C�������ɉ�����
% �����ɑ΂��鋭�x�l��2�����v���b�g���s���܂��B�܂��A�����̃��C���̑g��
% ���킹����Ȃ�ꍇ�AIMPROFILE �́A������ x ���W�� y ���W�ɑ΂���
% 3�����̋��x�l�̕\�����s���܂��B
%
% ���̍\�����g���āA�p�X�̐ݒ���Θb�I�ɍs�����Ƃ��ł��܂��B
%
%        C = IMPROFILE(I,xi,yi)
%        C = IMPROFILE(I,xi,yi,N)
%
% xi �� yi �́A���C�������̏I�[�̋�ԍ��W��ݒ肷�铯�������̃x�N�g��
% �ł��B
%
% ���̍\�����g���āA�t���I�ȏ����o�͂��܂��B
%
%        [CX,CY,C] = IMPROFILE(...)
%        [CX,CY,C,xi,yi] = IMPROFILE(...)
%
% CX �� CY �́A���x�l���v�Z����_�̋�ԍ��W���܂񂾒����� N �̃x�N�g��
% �ł��B
%
% ���̓C���[�W�ɑ΂��āA�f�t�H���g�łȂ���ԍ��W�n���w�肷��ɂ́A����
% �\�����g���܂��B
%
%        [...] = IMPROFILE(x,y,I,xi,yi)
%        [...] = IMPROFILE(x,y,I,xi,yi,N)
%
% x �� y �́A�C���[�W XData �� YData ���w�肷��2�v�f�x�N�g���ł��B
%
% [...] = IMPROFILE(...,METHOD) �́A���}�@��ݒ肷�邱�Ƃ��ł��܂��B
% METHOD �́A���̒�����I���ł��镶����ł��B
%
%        'nearest'  (�f�t�H���g) �ŋߖT�@
%
%        'bilinear'              Bilinear �@
%
%        'bicubic'               Bicubic �@
%
% METHOD �������ȗ�����ƁAIMPROFILE �́A�f�t�H���g��'nearest'���g��
% �܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Auint8�Auint16�Adouble�A�܂��́Alogical �̂������
% �N���X���T�|�[�g���Ă��܂��B���̂��ׂĂ̓��͂Əo�͂́Adouble �łȂ�
% ��΂Ȃ�܂���B
%
% ���
% ------
%        I = imread('alumgrns.tif');
%        x = [35 338 346 103];
%        y = [253 250 17 148];
%        improfile(I,x,y), grid on
%
% �Q�l�FIMPIXEL, INTERP2



%   Copyright 1993-2002 The MathWorks, Inc.  
