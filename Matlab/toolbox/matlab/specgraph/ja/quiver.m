% QUIVER   Quiver�v���b�g
% 
% QUIVER(X,Y,U,V) �́A�_(x,y)�Ő���(u,v)�������Ƃ��āA���x�x�N�g����
% �v���b�g���܂��B�s�� X,Y,U,V �́A���ׂē����T�C�Y�ŁA�Ή�����ʒu�Ƒ��x
% �������܂܂Ȃ���΂Ȃ�܂���(X ��Y �́A���̃O���b�h���w�肷��x�N�g��
% �ł��\���܂���)�BQUIVER �́A�O���b�h�ɓK������悤�ɁA�����I�ɖ���
% �X�P�[�����O���܂��B
%
% QUIVER(U,V) �́Axy���ʏ�̓��Ԋu�̓_�ŁA���x�x�N�g�����v���b�g���܂��B
%
% QUIVER(U,V,S) �܂��� QUIVER(X,Y,U,V,S) �́A�O���b�h���ɓK������悤�ɁA
% �����I�ɖ����X�P�[�����O���A���̌セ����S�{�Ɋg�債�܂��B����
% �X�P�[�����O���s�킸�ɖ����v���b�g���邽�߂ɂ́AS = 0 ���g���Ă��������B
%
% QUIVER(...,LINESPEC) �́A���x�x�N�g���ɑ΂��āA�w�肳�ꂽ���C���X�^�C��
% ���g�p���܂��B���̐�[�̑���ɁALINESPEC�̃}�[�J���`�悳��܂��B
% �}�[�J��ݒ肵�Ȃ��悤�ɂ���ɂ́A'.' ���g�p���Ă��������A�g�p�\��
% ���̒l�ɂ��ẮAPLOT ���Q�Ƃ��Ă��������B
%
% QUIVER(...,'filled') �́A�w�肵���}�[�J��h��Ԃ��܂��B
%
% QUIVER(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = QUIVER(...) �́Aquiver�O���[�v�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�
% �x�N�g�����o�͂��܂��B
%
% ���ʌ݊���
% QUIVER('v6',...) �́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊���
% �̂��߁Aquiver�O���[�v�I�u�W�F�N�g�̑����line�I�u�W�F�N�g���쐬��
% �܂��B
%  
% ���:
% 
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
% �Q�l�FFEATHER, QUIVER3, PLOT.


%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
