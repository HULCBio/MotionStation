% function [sh,su,hsvu]=hankmr(sys,sig,k,opt)
%
% ����n�̏�ԋ��SYSTEM�s��SYS�ɂ����āA����K�̍œKHankel�m�����ߎ����s
% ���܂��B����SYSTEM�s��SYS�́AHankel���ْlSIG�������t�������łȂ����
% �Ȃ�܂���(���Ȃ킿�ASYS��SIG�́ASYSBAL�̏o�͂łȂ���΂Ȃ�܂���)�B
% OPT�́A�ȗ�����邩�A�܂��͂��̂悤�ɐݒ肷�邱�Ƃ��ł��܂��B
%
%  - 'a'�ɐݒ肷��ƁA����ʐ��̍��ŏI�����܂��B����ʐ��̍��́ASH�ɑg��
%    ���܂�ASU = 0�ɂȂ�܂��B
%  - 'd'�ɐݒ肷��ƁAH���덷�͈͂Ŗ������ꂽHankel���ْlSIG(i)�̘a��
%    ����D-�����v�Z���܂��B���Ȃ킿�ASH+SU�́A���K�̈���ȋɂ�����SYS
%    �ւ̍œKH���m�����ߎ��ł��B
%
% OPT = 'a'�̏ꍇ�A����ʐ��̍��́ASH�ɑg�ݍ��܂�ASU = 0�ɂȂ�܂��B��
% �̏ꍇ�ASU�͔���ʐ��̍����܂݁ASH��k���̈��ʓI�V�X�e���ɂȂ�܂��B'd'
% �I�v�V�������g���ƁASU��Hankel���ْl��HSVU�ɏo�͂���܂��B
%
% �Q�l: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL,SRESID, TRUNC.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
