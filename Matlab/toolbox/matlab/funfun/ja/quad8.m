% QUAD8  �����̐��l�ϕ�
%
% QUAD8�́A�p�łƂȂ��Ă��܂��BQUADL �����Ɏg���Ă��������B
%
% Q = QUAD8(FUN,A,B) �́A�K�����J�[�V�u��Newton Cotes 8 panel�@��
% �g���āA���Ό덷��1e-3�ȉ��ɂȂ�悤�ɁAA �� B �̊Ԃ� F(X) �̐ϕ�
% �l���ߎ����܂��BFUN �́A�x�N�g������ X ���󂯓���AX �̊e�v�f�ɂ���
% �Čv�Z�����֐�FUN�ł���x�N�g�� Y ���o�͂��܂��B  
% ���ٓ_�̐ϕ����������J�[�V�������x���ɒB����ƁAQ = Inf ���o�͂���܂��B
%
% Q = QUAD8(FUN,A,B,TOL) �́A���Ό덷�� TOL �ɂȂ�悤�ɐϕ����܂��B
% 2�v�f�̋��e�덷 TOL = [rel_tol abs_tol] ���g���āA���Ό덷�Ɛ�Ό덷
% ���w�肵�܂��B
%
% Q = QUAD8(FUN,A,B,TOL,TRACE) �́A���Ό덷�� TOL �ɂȂ�܂Őϕ�
% ���܂��B�[���łȂ� TRACE �ɑ΂��āA�ϕ��_�̃v���b�g���s���֐��̎��s
% ��\�����܂��B.
%
% Q = QUAD8(FUN,A,B,TOL,TRACE,P1,P2,...) �́A�֐� FUN(X,P1,P2,...) ��
% ���� P1, P2, ... �𒼐ړn���܂��BTOL �� TRACE �̃f�t�H���g�l���g������
% �ɂ́A��s��([])��n���Ă��������B
%
% �Q�l �F QUADL, QUAD, DBLQUAD, INLINE, @.

%   Copyright 1984-2002 The MathWorks, Inc.

