% IMPIXEL   �s�N�Z���̃J���[�l�̌���
%
% IMPIXEL �́A�w�肵���C���[�W�s�N�Z���̐ԁA�΁A�̃J���[�l���o�͂���
% ���B���̍\���ɏ]���āAIMPIXEL �́A���̓C���[�W��\�����A���[�U��
% �}�E�X���g���ăs�N�Z�����w�肷��̂�҂�ԂɂȂ�܂��B
%
%        P = IMPIXEL(I)
%        P = IMPIXEL(X,MAP)
%        P = IMPIXEL(RGB)
%
% ���͈������ȗ�����ƁAIMPIXEL �́A�J�����g���ɕ\������Ă���C���[�W
% �ɍ�p���܂��B
%
% �s�N�Z���̑I���ɂ́A�ʏ�̃{�^���N���b�N���g���܂��B���ɑI�����Ă���
% �s�N�Z����I����Ԃ����������ɂ́A<BACKSPACE>�A�܂��́A<DELETE> ��
% �����Ă��������BShift ���������܂܃N���b�N���邩�A�E�{�^���ŃN���b�N
% ���邩�A�܂��́A�_�u���N���b�N�ɂ��A�Ō�̃s�N�Z����I�����܂��B
% <RETURN> ���������Ƃɂ��A�s�N�Z�����������ɑI�����I�����邱�Ƃ��ł�
% �܂��B
%
% �s�N�Z���̑I�����I������ƁAIMPIXEL �́A�ݒ肵���o�͈����� RGB �l����
% �\�������M�s3��̍s����o�͂��܂��B�o�͈�����ݒ肵�Ȃ��ꍇ�AIMPIXEL 
% �́AANS �ɍs����o�͂��܂��B
%
% �s�N�Z���̑I�����Θb�I�ɍs���ɂ́A���̍\���ɏ]���Ă��������B
%
%        P = IMPIXEL(I,C,R)
%        P = IMPIXEL(X,MAP,C,R)
%        P = IMPIXEL(RGB,C,R)
%
% R �� C �́ARGB �l�� P �ɏo�͂���s�N�Z���̍��W���w�肷��x�N�g����
% ���݂����������ɂȂ�܂��BP �� k �Ԗڂ̍s�́A�s�N�Z��(R(k),C(k))��
% RGB �l���܂�ł��܂��B
%
% �o�͈�����3�ݒ肷��ƁAIMPIXEL �́A�I�������s�N�Z���̍��W���o��
% ���܂��B
%
%        [C,R,P] = IMPIXEL(...)
%
% ���̓C���[�W�ɑ΂��āA�f�t�H���g�łȂ���ԍ��W�n���w�肷��ɂ́A��
% �̍\�����g���܂��B
%
%        P = IMPIXEL(x,y,I,xi,yi)
%        P = IMPIXEL(x,y,X,MAP,xi,yi)
%        P = IMPIXEL(x,y,RGB,xi,yi)
%
% x �� y �́A�C���[�W XData �� YData ���w�肷��2�v�f����Ȃ�x�N�g����
% ���Bxi �� yi �́AP �� RGB �l���o�͂���s�N�Z���̋�ԍ��W���w�肷��
% ���������̃x�N�g���ł��B3�̏o�͈�����I������ƁAIMPIXEL �́A�I��
% �����s�N�Z���̍��W���o�͂��܂��B
%
%        [xi,yi,P] = IMPIXEL(x,y,...)
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Auint8�Auint16�Adouble�A�܂��́Alogical �̂������
% �N���X���T�|�[�g���Ă��܂��B���̂��ׂĂ̓��͂Əo�͂́A�N���X double
% �ł��B
%
% ���
% ----
%       RGB = imread('flowers.tif');
%       c = [12 146 410];
%       r = [104 156 129];
%       pixels = impixel(RGB,c,r)
%
% �Q�l�FIMPROFILE



%   Copyright 1993-2002 The MathWorks, Inc.  
