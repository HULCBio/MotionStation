% function [sysout,sig] = sysbal(sys,tol)
%
% SYSTEM�s��̏�ԋ�ԃ��f���̑Ő؂�ꂽ���t���������v�Z���܂��BA�̌ŗL
% �l�̎������́A���łȂ���΂Ȃ�܂���B���ʂ́ATOL�����傫��Hankel��
% �ْl���c���A����Ő؂�܂��BTOL���ȗ������ƁAmax(sig(1)*1.0E-12,1.
% 0E-16)�ɐݒ肳��܂��B
%
% �Q�l�FHANKMR, REORDSYS, FRWTBAL, SFRWTBLD, SNCFBAL,
%       SRELBAL, SRESID, SVD, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
