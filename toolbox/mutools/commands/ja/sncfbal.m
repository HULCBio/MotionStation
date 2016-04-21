% function [sysnlcf,sig,sysnrcf] = sncfbal(sys,tol)
%
% SYSTEM�s��̏�ԋ�ԃ��f��SYS�̐��K�����ꂽ�����񕪉��ƉE���񕪉���(��
% �؂�ꂽ)���t�����������߂܂��BSYSNLCF�����SYSNRCF���̏�ԋ�ԃ��f��
% �́A������SIG�ɂ���ė^����ꂽHankel���ْl���g���āA���t�����������
% ���B  
% 
%  SYSNLCF = [Nl Ml] and Nl Nl~ + Ml Ml~ = I, SYS = Ml^(-1) Nl
%  SYSNRCF = [Nr;Mr] and Nr~ Nr + Mr~ Mr = I, SYS = Nr Mr^(-1)
%
% ���ʂ́A���ׂĂ�Hankel���ْl��TOL���傫���Ȃ�悤�ɑŐ؂��܂��BTOL
% ���ȗ������ƁAMAX(SIG(1)*1.0E-12,1.0E-16)�ɐݒ肳��܂��BSYS���s��
% �o�ł���Ƃ��ɂ́A���[�j���O���b�Z�[�W���\������܂��B���̏ꍇ�A�o�͂�
% �M���ł��Ȃ��ꍇ������܂��B
%
% �Q�l: HANKMR, SFRWTBAL, SFRWTBLD, SRELBAL, SYSBAL, SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
