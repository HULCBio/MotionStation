% QUIVER3   3����quiver�v���b�g
% 
% QUIVER3(X,Y,Z,U,V,W) �́A�_(x,y,z)�Ő���(u,v,w)�������Ƃ��āA���x
% �x�N�g�����v���b�g���܂��B�s�� X,Y,Z,U,V,W �́A���ׂē����T�C�Y�ŁA
% �Ή�����ʒu�Ƒ��x�������܂܂Ȃ���΂Ȃ�܂���BQUIVER3 �́A�����I��
% �����X�P�[�����O���܂��B
%
% QUIVER3(Z,U,V,W) �́A�s��Z�Ŏw�肳�ꂽ���Ԋu�̃T�[�t�F�X��̓_�ɁA
% ���x�x�N�g�����v���b�g���܂��B
%
% QUIVER3(Z,U,V,W,S) �܂��� QUIVER3(X,Y,Z,U,V,W,S) �́A���������I��
% �X�P�[�����O���A���̌セ���� S �{�Ɋg�債�܂��B�����X�P�[�����O��
% �s�킸�ɖ����v���b�g���邽�߂ɂ́AS = 0���g���Ă��������B
%
% QUIVER3(...,LINESPEC) �́A���x�x�N�g���ɑ΂��Ďw�肳�ꂽ���C���X�^�C��
% ���g�p���܂��B���̐�[�̑���ɁALINESPEC �̃}�[�J���`�悳��܂��B
% �}�[�J��ݒ肵�Ȃ��悤�ɂ���ɂ́A'.' ���g�p���Ă��������B�g�p�\��
% ���̒l�ɂ��ẮAPLOT ���Q�Ƃ��Ă��������B
%
% QUIVER3(...,'filled') �́A�w�肵���}�[�J��h��Ԃ��܂��B
%
% QUIVER3(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = QUIVER3(...) �́Aline�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g����
% �o�͂��܂��B
%
% ���:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
% �Q�l�FQUIVER, PLOT, PLOT3, SCATTER.


%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
