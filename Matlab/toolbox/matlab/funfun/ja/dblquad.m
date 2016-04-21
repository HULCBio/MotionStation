% DBLQUAD   2�d�ϕ��𐔒l�I�Ɍv�Z
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX) �́A�����`��� XMIN <= X <= XMAX, 
% YMIN <= Y <= YMAX �ŁAFUN(X,Y) ��2�d�ϕ����s���܂��BF(X,Y) �́A
% �x�N�g��X �ƃX�J�� Y ���󂯓���āA��ϕ��֐��l���x�N�g���Ŗ߂��܂��B
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL) �́A�f�t�H���g�̋��e�덷 1.e-6
% �̑���ɁATOL ���g���܂��B
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL) �́A�f�t�H���g�� QUAD 
% �̑���ɁA���ϊ֐� QUADL ���g���܂��BMYQUAD �́AQUAD �� QUADL ��
% �����R�[���̕��@���g���܂��B
%
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,TOL,@QUADL,P1,P2,...) �́A
% FUN(X,Y,P1,P2,...) �ɃG�L�X�g���̃p�����[�^��n���܂��B
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,[],[],P1,P2,...) �́A
% DBLQUAD(FUN,XMIN,XMAX,YMIN,YMAX,1.e-6,@QUAD,P1,P2,...)�Ɠ����ł��B
%
% ���F
%     FUN �́A�C�����C���I�u�W�F�N�g�A�܂��́A�֐��n���h���ł��B
%
%         Q = dblquad(inline('y*sin(x)+x*cos(y)'), pi, 2*pi, 0, pi) 
%
%     �܂��́A
%
%         Q = dblquad(@integrnd, pi, 2*pi, 0, pi) 
%
%     �����ŁAintegrnd.m �́AM-�t�@�C���ł��B       
%           function z = integrnd(x, y)
%           z = y*sin(x)+x*cos(y);  
%
%     ����́Api <= x <= 2*pi, 0 <= y <= pi �̐����`�̋�ԂŁA 
%     y*sin(x)+x*cos(y) ��ϕ����܂��B�ϕ��́A�x�N�g�� x �ƃX�J�� y ��
%     �g���Čv�Z���邱�Ƃɒ��ӂ��Ă��������B
%
%     �����`�łȂ��̈�́A�̈�̊O���Ƀ[�������肵�āA�����`�ɂ����^��
%     �ϕ�����舵���܂��B�����̑̐ς́A���̂悤�ɋ��܂�܂��B
%
%       dblquad(inline('sqrt(max(1-(x.^2+y.^2),0))'),-1,1,-1,1)
%
%     �܂��́A
%
%       dblquad(inline('sqrt(1-(x.^2+y.^2)).*(x.^2+y.^2<=1)'),-1,1,-1,1)
% 
% �Q�l�FQUAD, QUADL, TRIPLEQUAD, INLINE, @.


%   Copyright 1984-2003 The MathWorks, Inc.
