% OHKLMR �œK�n���P���m�����ߎ� (�s����v�����g)
%
% [SS_M,TOTBND,HSV] = OHKLMR(SS_,MRTYPE,IN)�A�܂��́A
% [AM,BM,CM,DM,TOTBND,HSV] = OHKLMR(A,B,C,D,MRTYPE,IN) �́A���̂悤��
% �����𖞑�������m�̃v�����gG(s)�̃n���P�����f���᎟���������s���܂��B
% 
% �덷(Ghed(s) - G(s))�̖�����m���� <= 
%            G(s)��k+1����n�܂ł̃n���P�����ْl�̘a��2�{
% 
% ���t���͕K�v����܂���B
%
%   mrtype = 1�̏ꍇ�Ain�͒᎟�������f���̎���k�B
%   mrtype = 2�̏ꍇ�A�g�[�^���̌덷��"in"��菬�����Ȃ�᎟�������f����
%                     �Z�o�B
%   mrtype = 3�̏ꍇ�A�n���P�����ْl��\�����A����k�̓��͂𑣂��܂��B
%                    (���̏ꍇ�A"in"���w�肷��K�v�͂���܂���B)
%
% TOTBND = �덷�͈�, HSV = �n���P�����ْl



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
