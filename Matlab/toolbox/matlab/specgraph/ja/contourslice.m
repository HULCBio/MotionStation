% CONTOURSLICE   �X���C�X���ʂł̃R���^�[���C��
% 
% CONTOURSLICE(X,Y,Z,V,Sx,Sy,Sz) �́A�x�N�g�� Sx,Sy,Sz ���̓_�ŁAx,y,z
% ���ʂ̎��ɃR���^�[���C����`�悵�܂��B�z�� X,Y,Z �́AV �ɑ΂�����W��
% ��`���A(MESHGRID �ŏo�͂����悤��)�P����3�����i�q�`�łȂ���΂Ȃ�
% �܂���B�e�X�̓������ł̃J���[�́AV �ɂ�茈�肳��܂��BV �́AM*N*P 
% ��3�����z��łȂ���΂Ȃ�܂���B
% 
% CONTOURSLICE(X,Y,Z,V,XI,YI,ZI) �́A�z�� XI,YI,ZI �Œ�`���ꂽ�T�[�t�F�X
% �ɉ����āA�̐� V ��ʂ�R���^�[���C����`�悵�܂��B
%
% CONTOURSLICE(V,Sx,Sy,Sz) �܂��� CONTOURSLICE(V,XI,YI,ZI) �́A
% [M,N,P] = SIZE(V) �̂Ƃ��A[X Y Z] = meshgrid(1:N�A1:M�A1:P) �Ɖ��肵�܂��B
% 
% CONTOURSLICE(...�AN) �́A(�����̒l�𖳎�����)���ʖ��� N �{�̃R���^�[
% ���C����`�悵�܂��B
% 
% CONTOURSLICE(...�ACVALS) �́A�x�N�g�� CVALS �Ŏw�肵���l�ŁA���ʖ���
% LENGTH(CVALS) �̃R���^�[���C����`�悵�܂��B
% 
% CONTOURSLICE(...�A[cv cv]) �́A���x�� cv �ŁA���ʖ���1�̃R���^�[���C��
% ���v�Z���܂��B
% 
% CONTOURSLICE(...,'method') �́A�g�p�����Ԗ@��ݒ肵�܂��B'method' �́A
% 'linear'�A'cubic'�A'nearest' �̂����ꂩ�ł��B'nearest '�́A'linear' ��
% �f�t�H���g�̂Ƃ��ɁA�R���^�[���C���� XI,YI,ZI �Œ�`���ꂽ�T�[�t�F�X��
% �����ĕ`�悳���Ƃ��ȊO�̓f�t�H���g�ł�(INTERP3 ���Q��)�B
% 
% CONTOURSLICE(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = CONTOURSLICE(...) �́APATCH�I�u�W�F�N�g�̃n���h���̃x�N�g����H�ɏo��
% ���܂��B
%
% ���:
%     [x y z v] = flow;
%     h=contourslice(x,y,z,v,[1:9],[],[0], linspace(-8,2,10));
%     axis([0 10 -3 3 -3 3]); daspect([1 1 1])
%     camva(24); camproj perspective;
%     campos([-3 -15 5])
%     set(gcf, 'Color', [.3 .3 .3], 'renderer', 'zbuffer')
%     set(gca, 'Color', 'black' , 'XColor', 'white', ...
%              'YColor', 'white' , 'ZColor', 'white')
%     box on
%
% �Q�l�FISOSURFACE, SMOOTH3, SUBVOLUME, REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
