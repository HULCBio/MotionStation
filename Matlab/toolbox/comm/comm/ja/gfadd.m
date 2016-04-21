% GFADD �K���A�̏�ł̑������̉��Z
%
% C = GFADD(A, B) �́A2�� GF(2) ������ A �� B �̘a���v�Z���܂��BA �� B
% �����������̃x�N�g���ŁA�������قȂ�ꍇ�A�Z�����̃x�N�g���̓[���p�f�B���O
% ����܂��BA �� B ���s��̏ꍇ�́A2�̍s��͓����T�C�Y�łȂ���΂Ȃ�
% �܂���B
% 
% C = GFADD(A, B, P) �́AP ���X�J���f���ł���Ƃ��A2�� GF(P) ������  
% A �� B �̘a���v�Z���܂��BA �� B �̊e�v�f�� GF(P) �̌���\�����܂��B
% A �� B �̗v�f�� 0 ���� P-1 �܂ł̐����ł��B
% 
% C = GFADD(A, B, P, LEN) �́A2�� GF(P) ������ A �� B �̘a���v�Z���A
% ���̑ł��؂�\���A�܂��͓W�J�\����Ԃ��܂��B���ɑΉ�����s�x�N�g����
% LEN �̗v�f��菭�Ȃ��ꍇ�A�Ō�Ƀ[�����ǉ�����܂��B����ALEN �̗v�f
% ���傫���ꍇ�́A�v�f�͍Ōォ��O����܂��BLEN �����̏ꍇ�́A�S�Ă�
% ���������̃[���͊O����܂��B
%
% C = GFADD(A, B, FIELD) �́AGF(P^M) ��ł� A �� B �̌������Z���܂��B
% �����ŁAP �͑f���ŁA M �����̐����ł��BA �� B �̊e�v�f�́A�w���`����
% GF(P^M) �̌���\�����܂��BA �� B �̊e�v�f�́A-Inf �� P^M-2 �̊Ԃ̐���
% �ł��BFIELD �� GF(P^M) �̑S�Ă̌������X�g����s��ŁA�������n���Ɗ֘A
% ���ĕ��ׂ��Ă��܂��BFIELD �́AFIELD = GFTUPLE([-1:P^M-2]', M, P); 
% ���g���Đ������邱�Ƃ��ł��܂��B
% 
% �Q�l�F GFSUB, GFCONV, GFMUL, GFDECONV, GFDIV, GFTUPLE, GFPLUS.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:31 $
