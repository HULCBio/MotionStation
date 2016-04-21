% GFMUL �K���A�̂̌�����Z
% 
% C = GFMUL(A, B) �́AGF(2) �̌����ƂɁAA �� B �̏�Z���s���܂��BA �� B 
% �̓X�J�����A�܂��͓����T�C�Y�̃x�N�g�����s��ł��BA �� B �̊e�v�f�́A
% GF(2) �̌���\�����܂��BA �� B �̗v�f�́A0 �܂��� 1 �ł��B
%
% C = GFMUL(A, B, P) �́AGF(P) �̌����ƂɁAA �� B �̏�Z���s���܂��B
% ������ P �͑f���̃X�J���ł��BA �� B �̊e�v�f�́AGF(P) �̌���\�����܂��B 
% A �� B �̊e�v�f�́A0 �� P-1 �̊Ԃ̐����ł��B
%
% C = GFMUL(A, B, FIELD) �́A GF(P^M) �̌����ƂɁAA �� B �̏�Z���s���܂��B
% ������ P �͑f���ŁAM �͐��̐����ł��BA �� B �̊e�v�f�́A�w���`����
% GF(P^M) �̌���\�����܂��BA �� B �̊e�v�f�́A-Inf �� P^M-2 �̊Ԃ̐���
% �ł��BFIELD �� GF(P^M) �̑S�������X�g����s��ŁA�������n���Ɗ֘A����
% ���ׂ��Ă��܂��BFIELD �� FIELD = GFTUPLE([-1:P^M-2]', M, P); ���g����
% �������邱�Ƃ��ł��܂��B
%
% GF(P) �܂��� GF(P^M) �̑������̏�Z�ɂ��ẮAGFCONV ���g���Ă��������B
%
% �Q�l:   GFDIV, GFDECONV, GFADD, GFSUB, GFTUPLE.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:40 $
