% INTERP3   3�������(table lookup)
% 
% VI = INTERP3(X,Y,Z,V,XI,YI,ZI) �́A�z�� XI, YI, ZI ���̓_�ŁA3�����֐� 
% V �� VI �l�����߂邽�߂ɕ�Ԃ��s���܂��BXI, YI, ZI �́A�����T�C�Y��
% �z��܂��̓x�N�g���łȂ���΂Ȃ�܂���B�x�N�g�������������T�C�Y�łȂ��A
% ���������݂���(�� �s�x�N�g���Ɨ�x�N�g��)�ꍇ�́AMESHGRID �ɓn����A
% �z��Y1, Y2, Y3 ���쐬���܂��B�z�� X, Y, Z �́A�f�[�^ V ���^������_��
% �w�肵�܂��B
%
% VI = INTERP3(V,XI,YI,ZI) �́A[M,N,P] = SIZE(V) �̂Ƃ��AX = 1:N�AY = 1:M�A
% Z = 1:P�Ɖ��肵�܂��B
% VI = INTERP3(V,NTIMES) �́A�ċA�I�� NTIMES ��A�v�f�Ԃ̕�Ԃ��J���
% �����Ƃ��AV ���g�����܂��B
% INTERP3(V) �́AINTERP3(V,1) �Ɠ����ł��B
%
% VI = INTERP3(...,'method') �́A��Ԏ�@���w�肵�܂��B�f�t�H���g�́A
% ���`��Ԃł��B�g�p�\�Ȏ�@�͈ȉ��̒ʂ�ł��B
%
%   'nearest' - �ŋߖT�I�ɂ����
%   'linear'  - ���`���
%   'cubic'   - �L���[�r�b�N���
%   'spline'  - �X�v���C�����
%
% VI = INTERP3(...,'method',EXTRAPVAL) �́AX, Y, Z�ō쐬���ꂽ�̈�̊O����
% VI �̗v�f�ɑ΂��Ďg�p����O�}�@�ƒl���w�肷��̂Ɏg���܂��B
% �������āAVI �́AX, Y, Z �̂��ꂼ��ɂ��쐬����Ă��Ȃ��AXI,YI 
% �܂��� ZI �̂����ꂩ�̒l�ɂ��� EXTRAPVAL �ɓ������Ȃ�܂��B�g�p����� 
% EXTRAPVAL �ɑ΂��āA���\�b�h���w�肳��Ȃ���΂Ȃ�܂���B�f�t�H���g��
% ���\�b�h�� 'linear' �ł��B 
%
% ���ׂĂ̕�Ԗ@�ŁAX, Y, Z �͒P���֐��ŁA(MESHGRID �ō쐬�������̂�
% ���l��)�i�q�`�łȂ���΂Ȃ�܂���BX, Y, Z �́A���Ԋu�łȂ��ꍇ������
% �܂��B
%
% ���Ƃ��΁AFLOW �̑e���ߎ����쐬���A�ׂ������b�V���ŕ�Ԃ��܂��B   
% 
%       [x,y,z,v] = flow(10); 
%       [xi,yi,zi] = meshgrid(.1:.25:10,-3:.25:3,-3:.25:3);
%       vi = interp3(x,y,z,v,xi,yi,zi); % V is 31-by-41-by-27
%       slice(xi,yi,zi,vi,[6 9.5],2,[-2 .2]), shading flat
%      
% �Q�l�FINTERP1, INTERP2, INTERPN, MESHGRID.


%   Copyright 1984-2004 The MathWorks, Inc.
