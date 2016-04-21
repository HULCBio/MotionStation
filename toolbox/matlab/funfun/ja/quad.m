% QUAD   ���l�ϕ�, �K��Simpson����
%
% Q = QUAD(FUN,A,B) �́A�K�����J�[�V�u��Simpson�@���g���āA���Ό�
% ����1e-3�ȓ��ɂȂ�悤�ɁAF(X) �̐ϕ��� A ���� B �܂ŋߎ����܂��B
% �֐� Y = FUN(X) �́A�x�N�g������X ���󂯓���AX �̗v�f�ɂ����Čv�Z
% ���ꂽ��ϕ��֐��ł��錋�ʂ̃x�N�g�� Y ���o�͂��܂��B  
%
% Q = QUAD(FUN,A,B,TOL) �́A�f�t�H���g�ł���1.e-6 �̑���ɐ�΋��e
% �덷 TOL �𗘗p���܂��BTOL ��傫���l�ɂ���ƁA�֐��v�Z�̉񐔂�����A
% �v�Z�͑����Ȃ�܂����A���ʂ̐��x�͒Ⴍ�Ȃ�܂��BMATLAB 5.3 �̊֐�
% QUAD �́A�M�����̒Ⴂ�A���S���Y���𗘗p���Ă���A�f�t�H���g�̋��e��
% ���� 1.e-3 �ł����B
%
% [Q,FCNT] = QUAD(...) �́A�֐��̌v�Z�񐔂��o�͂��܂��B
%
% QUAD(FUN,A,B,TOL,TRACE) �́ATRACE ���[���łȂ��ꍇ�́A���J�[�V�u��
% ��Ƃ��s���Ă���ԁA[fcnt a b-a Q] �̒l�������܂��B
%
% QUAD(FUN,A,B,TOL,TRACE,P1,P2,...) �́AFUN(X,P1,P2,...) �Ɉ��� P1, P2, ...
% �𒼐ړn���܂��BTOL �� TRACE �̃f�t�H���g�l���g�����߂ɂ́A��s��
% ([])��n���Ă��������B
%
% �x�N�g���������g���Čv�Z�ł���悤�ɁAFUN �̒�`�̒��ŁA�z�񉉎Z�q .*, 
% ./, .^ ���g���܂��B
%
% �֐� QUADL �́A�����x�ƃX���[�Y�Ȕ�ϕ��֐��ɂ��A�����I�Ɏ��s�����
% �ꍇ������܂��B
%
% ���:
%       FUN �́A�ȉ��̂悤�Ɏw�肷�邱�Ƃ��ł��܂��B
%
%       �C�����C���I�u�W�F�N�g:
%          F = inline('1./(x.^3-2*x-5)');
%          Q = quad(F,0,2);
%
%       �֐��n���h��:
%          Q = quad(@myfun,0,2);
%          where myfun.m is an M-file:
%             function y = myfun(x)
%             y = 1./(x.^3-2*x-5);
%
% �Q�l QUADV, QUADL, DBLQUAD, TRIPLEQUAD, INLINE, @.

%   Based on "adaptsim" by Walter Gander.  
%   Ref: W. Gander and W. Gautschi, "Adaptive Quadrature Revisited", 1998.
%   http://www.inf.ethz.ch/personal/gander
%   Copyright 1984-2004 The MathWorks, Inc. 
