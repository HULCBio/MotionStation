% function [sysout,sig,sysfact] = srelbal(sys,tol)
%
% SYSTEM�s��̏�ԋ�ԃ��f��SYS�̑Ő؂�ꂽ�m���I���t�����������߂܂��B
% SYS�̂��ׂĂ̌ŗL�l�̎������́A���łȂ���΂Ȃ�܂���B���ʂ́ATOL���
% ���傫��Hankel���ْl���c���A����Ő؂�܂��B�o�͈���SYSFACT�́ASYS~*
% SYS = SYSFACT*SYSFACT~�𖞑��������ȍŏ��ʑ��V�X�e���ł��BTOL���ȗ�
% �����ƁAmax(SIG(1)*1.0E-12,1.0E-16)�ɐݒ肳��܂��BSIG�́ASTRUNC(SYS
% OUT,K)���g���ĒB���\�ȑ��Ό덷�ł��B
%
% �Q�l: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
