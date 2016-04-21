% QUADL  �K�� Lobatto ���ϖ@���g���āA���l�I�Ȑϕ����s���܂�
% 
% Q = QUADL(FUN,A,B) �́AA ���� B �܂ŁA�����̍ċA�K�����ϖ@���g���āA
% 1.e-6 �̌덷���ŁA�֐� FUN �̐ϕ����ߎ����܂��B�֐� Y = FUN(X) �́A
% �x�N�g������ X ����͂��A���ʂ̃x�N�g�� Y ���o�͂��܂��B�x�N�g�� 
% Y �́AX �̊e�v�f�ł̌v�Z������ϕ��l��v�f�ɂ��Ă��܂��B  
%
% Q = QUADL(FUN,A,B,TOL) �́A�f�t�H���g��1e-6 �̑���� TOL ����
% �덷���e�͈͂Ƃ��Ďg���܂��BTOL �̒l��傫������ƁA�֐��̌v�Z��
% ������A�����ɂȂ�܂����A���x�͒ቺ���܂��B
%
% [Q,FCNT] = QUADL(...) �́A�֐��v�Z�̉񐔂��o�͂��܂��B
%
% ��[���� TRACE ���g���� QUADL(FUN,A,B,TOL,TRACE) �́A���J�[�V�u�v�Z
% �̊ԂɁA[fcnt a b-a Q] �̒l�������܂��B
%
% QUADL(FUN,A,B,TOL,TRACE,P1,P2,...) �́A�t���I�Ȉ��� P1, P2, ... ���֐�
% FUN �ɒ��ړn���AFUN(X,P1,P2,...) �Ƃ��܂��BTOL �� TRACE �ɑ΂��āA��s��
% ��n�����Ƃ́A�f�t�H���g�l���g�����Ƃ��Ӗ����Ă��܂��B
%
% �x�N�g�������Ƌ��Ɍv�Z�ł���悤�ɁAFUN �̒�`�̒��ŁA�z�񉉎Z�q .*, 
% ./, .^ ���g���܂��B
%
% �֐� QUAD �́A�ᐸ�x�A�܂��́A�X���[�Y�łȂ���ϕ��֐��ɁA�������I��
% �����܂��B
%
% ���:
%       FUN �́A�ȉ��̂悤�ɐݒ肷�邱�Ƃ��ł��܂��B
%
%       �C�����C���I�u�W�F�N�g:
%          F = inline('1./(x.^3-2*x-5)');
%          Q = quadl(F,0,2);
%
%       �֐��n���h��:
%          Q = quadl(@myfun,0,2);
%          �����ŁAmyfun.m ��M-�t�@�C���ł��B
%             function y = myfun(x)
%             y = 1./(x.^3-2*x-5);
%
% �Q�l �F QUAD, DBLQUAD, TRIPLEQUAD, INLINE, @.


%   Based on "adaptlob" by Walter Gautschi.
%   Ref: W. Gander and W. Gautschi, "Adaptive Quadrature Revisited", 1998.
%   http://www.inf.ethz.ch/personal/gander
%   Copyright 1984-2004 The MathWorks, Inc. 
