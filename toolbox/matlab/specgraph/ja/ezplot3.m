% EZPLOT3   3�����p�����g���b�N�Ȑ��v���b�g�̊ȒP�Ȏg����
% 
% EZPLOT3(x,y,z) �́A�f�t�H���g�̗̈� 0 < t < 2*pi �ɁA��ԓI�ȋȐ� 
% x = x(t)�Ay = y(t)�Az = z(t) ���v���b�g���܂��B
%
% EZPLOT3(x,y,z,[tmin,tmax]) �́Atmin < t < tmax �ɋȐ� x = x(t)�Ay = y(t)�A
% z = z(t) ���v���b�g���܂��B
%
% EZPLOT3(x,y,z,'animate') �܂��� EZPLOT(x,y,z,[tmin,tmax],'animate') �́A
% �Ȑ��̃A�j���[�V�����������O�Ղ��쐬���܂��B
% 
% EZPLOT3(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = EZPLOT3(...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����H�ɏo�͂��܂��B
%
% ���
%  �֐� x, y, z �́A@ �܂��̓C�����C���I�u�W�F�N�g�A�������\�����g���Đݒ�
%  ���邱�Ƃ��ł��܂��BM-�t�@�C���֐��ƃC�����C���֐��́A�x�N�g�����͂���
%  �������悤�ɏ����K�v������܂��B
%        fy = inline('t .* sin(t)')
%        ezplot3(@cos, fy, @sqrt)
%        ezplot3('cos(t)', 't * sin(t)', 'sqrt(t)', [0,6*pi])
%        ezplot3(@cos, fy, @sqrt, 'animate')
%
% �Q�l�F EZPLOT, EZSURF, EZPOLAR, PLOT, PLOT3


%   Copyright 1984-2002 The MathWorks, Inc. 
