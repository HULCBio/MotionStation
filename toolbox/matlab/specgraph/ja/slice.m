% SLICE   �{�����[���X���C�X�v���b�g
% 
% SLICE(X,Y,Z,V,Sx,Sy,Sz) �́A�x�N�g�� Sx,Sy,Sz �̓_�ŁAx,y,z�����ɃX���C�X
% ��`�悵�܂��B�z�� X,Y,Z �́AV �ɑ΂�����W���`���A�P���ŁA(MESHGRID
% �ŏo�͂����悤��)3�����̊i�q�`�łȂ���΂Ȃ�܂���B�e�_�ł̃J���[�́A
% �̐� V ��3������Ԃɂ���Č��肳��܂��BV �́AM*N*P �̔z��ł��B 
%
% SLICE(X,Y,Z,V,XI,YI,ZI) �́A�z�� XI,YI,ZI �Œ�`���ꂽ�T�[�t�F�X�ɑ΂��āA
% �̐� V �̃X���C�X��`�悵�܂��B
%
% SLICE(V,Sx,Sy,Sz) �܂��� SLICE(V,XI,YI,ZI) �́AX = 1:N�AY = 1:M�AZ = 1:P
% �Ɖ��肵�܂��B
%
% SLICE(...,'method') �́A�g�p�����ԕ��@���w�肵�܂��B'method' �́A
% 'linear'�A'cubic'�A'nearest' �̂����ꂩ�ł��B'linear' �̓f�t�H���g�ł�
% (INTERP3 ���Q��)�B
%
% SLICE(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = SLICE(...) �́ASURFACE�I�u�W�F�N�g�̃n���h���ԍ�����Ȃ�x�N�g����
% �o�͂��܂��B
%
% ���: 
% �֐� x*exp(-x^2-y^2-z^2) ��͈� -2 < x < 2�A-2 < y < 2�A-2 < z < 2 ��
% �������܂��B
%
%      [x,y,z] = meshgrid(-2:.2:2, -2:.25:2, -2:.16:2);
%      v = x .* exp(-x.^2 - y.^2 - z.^2);
%      slice(x,y,z,v,[-1.2 .8 2],2,[-2 -.2])
%
% �Q�l�FMESHGRID, INTERP3.


%   J.N. Little 1-23-92
%   Revised 4-27-93, 2-10-94
%   Revised 6-17-94 by Clay M. Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
