% ELLIPSOID  �ȉ~�ʂ̍쐬
%
% [X,Y,Z]=ELLIPSOID(XC,YC,ZC,XR,YR,ZR,N) �́A3�� (N+1)�s(N+1)��̍s���
% �쐬���܂��B�����āASUFRF(X,Y,Z) �ɂ��A���S(XC,YC,ZC) �ŁA���a XR,  
% YR, ZR �����ȉ~�ʂ��쐬���܂��B
% 
% [X,Y,Z] = ELLIPSOID(XC,YC,ZC,XR,YR,ZR) �́AN = 20 ���g�p���܂��B
%
% ELLIPSOID(...) �� ELLIPSOID(...,N) �ŁA�o�͈�����ݒ肵�Ȃ����̂́A
% SURFACE �Ɠ��l�ȑȉ~�ʂ�\�����A�o�͂��s���܂���B
%
% ELLIPSOID(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% �ȉ~�ʃf�[�^�́A���̕��������g���č쐬����܂��B
%
%  (X-XC)^2     (Y-YC)^2     (Z-ZC)^2
%  --------  +  --------  +  --------  =  1
%    XR^2         YR^2         ZR^2
%
% �Q�l�F SPHERE, CYLINDER.


% Laurens Schalekamp and Damian T. Packer
% Copyright 1984-2002 The MathWorks, Inc. 
