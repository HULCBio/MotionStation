% GFTUPLE �K���A�̂̌��̌`�����A�ȗ����܂��͕ϊ�
%
% ���ׂẴV���^�b�N�X�ɑ΂��āAA �́A�e�s���K���A�̂̌���\���s��ł��B
% A �������̗�̏ꍇ�AMATLAB �́A�e�s����̌��̎w���`���Ƃ��ĉ��߂��܂��B
% ���̐�����-Inf �́A�S�āA�̂̒��̃[������\�����܂��BA �������̗��
% �����Ă���ꍇ�AMATLAB �́A��̌��̑������t�H�[�}�b�g�Ƃ��āA�e�s��
% ���߂��܂��B���̏ꍇ�AA �̊e�v�f�́A0 �� P-1 �̊Ԃ̐����łȂ���΂Ȃ�
% �܂���B
%
% ���ׂẴt�H�[�}�b�g�́A���Ɏ����悤�ɁA2�Ԗڂ̈����Őݒ肳��錴�n
% �������̍��Ɋ֘A���Ă��܂��B
% 
% TP = GFTUPLE(A, M) �́AA ���\�����̍ł��ȒP�ȑ������`�����o�͂��܂��B
% �����ŁATP �� k �s�ڂ́AA �� k �s�ڂɑΉ����Ă��܂��B�`���́AGF(2^M)��
% �̃f�t�H���g�̌��n�������̍��Ɋ֘A���Ă��܂��BM �͐��̐����ł��B
%
% TP = GFTUPLE(A, PRIMPOLY) �́APRIMPOLY ���AGF(2^M)��ł� M ���̌��n
% �������̌W�������x�L���ŕ��ׂ��s�x�N�g���ł��邱�ƈȊO�́A��̃V��
% �^�b�N�X�Ɠ����ł��B
%
% TP = GFTUPLE(A, M, P) �́A2���f�� P �ƒu��������Ă���ȊO�́A
% TP = GFTUPLE(A, M) �Ɠ����ł��B
% 
% TP = GFTUPLE(A, PRIMPOLY, P) �́A2 ��f�� P �Œu�����������ƈȊO�́A
% TP = GFTUPLE(A, PRIMPOLY) �Ɠ����ł��B
%
% TP = GFTUPLE(A, PRIMPOLY, P, PRIM_CK) �́AGFTUPLE ���APRIMPOLY ������
% �Ɍ��n��������\���Ă��邩�ۂ����`�F�b�N���邱�ƈȊO�́A��̃V���^�b�N
% �X�Ɠ����ł��B���ɕ\���Ă��Ȃ��ꍇ�AGFTUPLE �́A�G���[�𔭐����ATP ��
% �o�͂��܂���B���͈��� PRIM_CK �́A�C�ӂ̐��l�܂��͕������g�����Ƃ���
% ���܂��B
%         
% [TP, EXPFORM] = GFTUPLE(...) �́A�s�� EXPFORM ���o�͂��܂��BEXPFORM ��
% k �Ԗڂ̍s�́AA �� k �Ԗڂ̍s���\�����̍ł��ȒP�Ȏw���t�H�[�}�b�g�ł��B
%
% �w���`���ŁA���� k �́A�v�f alpha^k ��\���܂��B�����ŁAalpha �́A
% �I�����ꂽ���n�������̍��ł��B�������`���ŁA�s�x�N�g�� k �͏��x�L����
% ���ׂ�ꂽ�W���̃��X�g��\�����܂��B
% ���: GF(5)�ŁAk = [4 3 0 2] �� 4 + 3x + 2x^3��\�����܂��B
%
% GF(P^M) ��ŁAFIELD �s��𐶐�����ɂ́AGFADD �̂悤�ȑ��� GF �֐���
% ����Ďg����悤�ɁA���̃R�}���h���g����\��������܂��B
% FIELD = GFTUPLE([-1 : P^M-2]', M, P);
%
% �Q�l�F GFADD, GFMUL, GFCONV, GFDIV, GFDECONV, GFPRIMDF.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $   $Date: 2003/06/23 04:34:51 $
