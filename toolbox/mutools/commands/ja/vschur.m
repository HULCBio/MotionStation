% function [u,t] = vschur(mat)
%
% VARYING/CONSTANT�s���Schur�������v�Z���܂��BMATLAB��SCHUR�R�}���h�Ɠ�
% ���ł����AVSCHUR��VARYING�s��ɑ΂��Ă��@�\���܂��B
%   ����:
%	     MAT - VARYING/CONSTANT�s��
%   �o��:
%	     U   - ���j�^����VARYING/CONSTANT�s��B
%                  MAT = MMULT(U,T,TRANSP(U))��MMULT(TRANSP(U),U)�́A��
%                  ������^�C�v�̒P�ʍs��ł��B
%            T   - ���͂�VARYING/CONSTANT�s��ɂ���āA���fSchur�^�܂���
%                  ��Schur�^�B
%
% �Q�l: CSORD, EIG, RSF2CSF, SCHUR, SVD, VEIG, VSVD.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
