% NORM   LTI�V�X�e���̃m����
%
%
% NORM(SYS) �́ALTI���f�� SYS �̃C���p���X������2�敽�ρA�܂��́A������SYS ��
% H2 �m���������߂܂��B
%
% NORM(SYS,2) �́ANORM(SYS) �Ɠ����ł��B
%
% NORM(SYS,inf) �́ASYS �̖�����m�����ł��B ���Ȃ킿�A���g�������̃s�[�N�Q�C��
% (MIMO�̏ꍇ�A�ő���ْl�ŕ]������܂�)�ł��B
%
% NORM(SYS,inf,TOL) �́A������m�������v�Z���邽�߂̑��ΐ��x TOL ���w�肵��
% ��(�f�t�H���g�́ATOL = 1e-2)�B
%
% [NINF,FPEAK] = NORM(SYS,inf) �́A�Q�C�������̃s�[�N�l NINF �ƂȂ���g��
% FPEAK ���o�͂��܂��B
%
% LTI���f���� S1*...*Sp �z�� SYS �ɑ΂��āANORM �̓T�C�Y�� [S1 ... Sp]�ł���A
% ���̂悤�Ȕz�� N ���o�͂��܂��B N(j1,...,jp) = NORM(SYS(:,:,j1,...,jp))
%
% �Q�l : SIGMA, FREQRESP, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
