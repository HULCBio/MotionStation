% SCHMR Schur�@�ɂ�镽�t���ł��؂� (�s����v�����g)
%
% [SS_M,TOTBND,HSV] = SCHMR(SS_,MRTYPE,NO)�A�܂��́A
% [AM,BM,CM,DM,TOTBND,HSV]=SCHMR(A,B,C,D,MRTYPE,NO) �́A���̏����𖞑�
% ����G(s):=(a,b,c,d)�Ɋւ���Schur�@�ɂ�郂�f���᎟���������s���܂��B
% 
% �덷(Ghed(s) - G(s))�̖�����m���� <= 2(n-k)�܂ł̃n���P�����ْl�̘a
% 
% �s�����G(s)�ɑ΂��āA�A���S���Y���͂܂����蕔�ƕs���蕔��G(s)�𕪊���
% �܂��B
%
% "MRTYPE"�̑I���ɂ���āA���̃I�v�V����������܂�:
%
%    1). mrtype = 1  --- no: �᎟�������f���̃T�C�Y"k"
%    2). mrtype = 2  --- �g�[�^���̌덷��"no"��菬�����Ȃ�k���̃��f����
%                        �Z�o�B
%    3). mrtype = 3  --- �S�Ẵn���P�����ْl��\�����A"k"�̓��͂𑣂���
%                        ��(���̏ꍇ�A"no"���w�肷��K�v�͂���܂���)�B
%
% TOTBND = �덷�͈�, HSV = �n���P�����ْl



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
