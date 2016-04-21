% TRIPLEQUAD    ���l�I�ȎO�d�ϕ��̌v�Z
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX) �́A3���������`
% �̈� XMIN <= X <= XMAX, YMIN <= Y <= YMAX, ZMIN <= Z <= ZMAX ��
% �ŁAFUN(X,Y,Z)�̎O�d�ϕ����v�Z���܂��B
% FUN(X,Y,Z) �́A�x�N�g�� X �ƃX�J�� ����� Z ���󂯓���A��ϕ��֐���
% �l�̃x�N�g�����o�͂��܂��B
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL) �́A�f�t�H���g
% �� 1e-6 �̑���ɋ��e�덷 TOL �𗘗p���܂��B
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL) �́A
% �f�t�H���g�� QUAD �̑���ɋ��ϊ֐� QUADL �𗘗p���܂��B  
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,ZMIN,ZMAX,@MYQUADF)
% �́AQUAD �̑���Ƀ��[�U��`�̋��ϊ֐� MYQUADF �𗘗p���܂��B
% MYQUADF �́AQUAD ����� QUADL �Ɠ����Ăяo���V�[�P���X�������܂��B
%
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,TOL,@QUADL,P1,P2,...) 
% �́A�t���I�ȃp�����[�^��  FUN(X,Y,P1,P2,...) �ɓn���܂��B
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,[],[],P1,P2,...) �́A
% TRIPLEQUAD(FUN,XMIN,XMAX,YMIN,YMAX,ZMIN,ZMAX,1.e-6,@QUAD,P1,P2,...) 
% �Ɠ����ł��B
%
% ���:
%       FUN �́A�C�����C���I�u�W�F�N�g�܂��͊֐��n���h���ɂ��邱�Ƃ��\�ł��B
%
%         Q = triplequad(inline('y*sin(x)+z*cos(x)'), 0, pi, 0, 1, -1, 1) 
%
%       �܂���
%
%         Q = triplequad(@integrnd, 0, pi, 0, 1, -1, 1) 
%
%       �����ŁAintegrnd.m ��M-�t�@�C���ł�:       
%           function f = integrnd(x, y, z)
%           f = y*sin(x)+z*cos(x);  
%
%       ����́A�̈� 0 <= x <= pi, 0 <= y <= 1, -1 <= z <= 1 ��
%       y*sin(x)+z*cos(x) ��ϕ����܂��B��ϕ��֐��́A�x�N�g�� x �����
%       �X�J�� y, z ���g���Čv�Z����邱�Ƃɒ��ӂ��Ă��������B
%
% �Q�l �F QUAD, QUADL, DBLQUAD, INLINE, @.


%   Copyright 1984-2003 The MathWorks, Inc.
