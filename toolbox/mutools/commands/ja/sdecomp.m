% function [sysst,sysun] = sdecomp(sys,bord,fl)
%
% �V�X�e����2�̃V�X�e���̘a�ɕ������܂��B
%    SYS = MADD(SYSST,SYSUN)
% SYSST�́A�ɂ̎�������BORD�������������̂��܂݁ASYSUN�́A�ɂ̎��������A
% BORD�ȏ�̂��̂��܂݂܂��BBORD�́A�f�t�H���g��0�ł��B
%
% SYSUN�ɑ΂���D�s��́AFL = 'd'�łȂ�����[���ŁA���̂Ƃ��́ASYSST���[
% ���ɂȂ�܂��B
%
% �Q�l: HANKMR, SFRWTBAL, SFRWTBLD, SNCFBAL, SREALBAL, SYSBAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
