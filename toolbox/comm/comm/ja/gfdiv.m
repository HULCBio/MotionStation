% GFDIV   �K���A�̂̌��̏��Z
%
% Q = GFDIV(B, A) �́AGF(2) �̊e���ŁAB �� A �ŏ��Z���܂��BA �� B ��
% �X�J���A���邢�͓����T�C�Y�̃x�N�g�����s��ł��BA �� B �̊e�v�f�� 
% GF(2) �̌���\�����܂��BA �� B �̗v�f�́A0�܂���1�ł��B
% 
% Q = GFDIV(B, A, P) �́AGF(P) �̊e���ŁAB �� A �ŏ��Z���܂��B�����ŁA
% P �͑f���ł��BA �� B �̊e�v�f�́AGF(P) �̌���\�����܂��BA �� B ��
% �v�f�́A0 �� P-1 �̊Ԃ̐����ł��B
%
% Q = GFDIV(B, A, FIELD) �́AGF(P^M) �̊e���ŁAB �� A �ŏ��Z���܂��B
% ������ P �͑f���ŁAM �͐��̐����ł��BA �� B �̊e�v�f�́A�w���`���� 
% GF(P^M) �̌���\�����܂��BA �� B �̗v�f�́A-Inf �� P^M-2 �̊Ԃ̐����ł��B
% FIELD �� GF(P^M) �̑S�������X�g�����s��ŁA�������n���Ɗ֘A���ĕ���
% ���Ă��܂��BFIELD �� FIELD = GFTUPLE([-1:P^M-2]', M, P); ���g����
% �������邱�Ƃ��ł��܂��B
%
% GF(P) �܂��� GF(P^M) �̑������̏��Z�ɂ��ẮAGFDECONV ���g�p����
% ���������B
%
% �Q�l�F GFMUL, GFCONV, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:35 $
