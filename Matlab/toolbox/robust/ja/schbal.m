% SCHBAL Schur�@�ɂ�镽�t���ł��؂� (����v�����g)
%
% [SS_H,AUG,HSV,SLBIG,SRBIG] = SCHBAL(SS_,MRTYPE,NO)�A�܂��́A
% [AHED,BHED,CHED,DHED,AUG,HSV,SLBIG,SRBIG]=SCHBAL(A,B,C,D,MRTYPE,NO) �́A
% ���̏����𖞑�����G(s):=(a,b,c,d)�Ɋւ���Schur�@�ɂ�郂�f���᎟����
% �����s���܂��B
% 
%    �덷(Ghed(s) - G(s))�̖�����m���� <= 
%                 2(n-k)�܂ł̃n���P�����ْl�̘a
%
%         (ahed,bhed,ched,dhed) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
% "MRTYPE"�̑I���ɂ��A���̃I�v�V����������܂��B:
%
%  1). mrtype = 1  --- no: �᎟�������f���̃T�C�Y"k"
%  2). mrtype = 2  --- �g�[�^���̌덷��"no"��菬�����Ȃ�k���̃��f�����Z
%                      �o�B
%  3). mrtype = 3  --- �S�Ẵn���P�����ْl��\�����A"k"�̓��͂𑣂��܂��B
%                      (���̏ꍇ�A"no"���w�肷��K�v�͂���܂���B)
%
% AUG = [�폜������Ԃ̐�, �덷�͈�], HSV = �n���P�����ْl

% Copyright 1988-2002 The MathWorks, Inc. 
