% MINREAL   �ŏ������Ƌɗ�̏���
%
% MSYS = MINREAL(SYS) �́ALTI���f�� SYS �ɑ΂��āA���ׂẴL�����Z������
% ��/��_�̑g�A�܂��́A��ŏ���ԃ_�C�i�~�N�X�̂ǂ��炩��������������
% �Ɠ����ȃ��f�� MSYS ���쐬���܂��B��ԋ�ԃ��f���ɑ΂��āAMINREAL �́A
% ���ׂĂ̕s���䃂�[�h�܂��͕s�ϑ����[�h���폜���邱�Ƃɂ��ASYS ��
% �ŏ����� MSYS �����߂܂��B 
%
% MSYS = MINREAL(SYS,TOL) �́A��/��_������������A��ԃ_�C�i�~�N�X��
% �폜����Ƃ��ɗ��p���鋖�e�l TOL ���ݒ肵�܂��B�f�t�H���g�l�́A
% TOL = SQRT(EPS) �ŁA���̋��e�l��傫�����邱�Ƃɂ��A����ɑ�����
% ���������s���܂��B
%
% ��ԋ�ԃ��f�� SYS = SS(A,B,C,D) �ɑ΂��āA
% 
%   [MSYS,U] = MINREAL(SYS)
% 
% �́A(U*A*U',U*B,C*U') �� (A,B,C) ��Kalman�����ƂȂ钼���s�� U ���o��
% ���܂��B
% 
% �Q�l : SMINREAL, BALREAL, MODRED.


%   J.N. Little 7-17-86
%   Revised A.C.W.Grace 12-1-89, P. Gahinet 8-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 
