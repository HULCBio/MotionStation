% BALMR �������ɂ�镽�t���ł��؂� (�s����v�����g)
%
% [SS_M,TOTBND,HSV] = BALMR(SS_,MRTYPE,NO) �܂��́A
% [AM,BM,CM,DM,TOTBND,HSV] = BALMR(A,B,C,D,MRTYPE,NO) �́A���̊֌W��
% ������O���~�A���̐�PQ�̕������Ɋ�Â��āAG(s):=(a,b,c,d)�̕��t���ł�
% �؂�ɂ�郂�f���̒᎟�������������܂��B
%
% �덷(Ghed(s) - G(s))�̖�����m���� <= 
%                      2(n-k)�ŏ��n���P�����ْl(SVH)�̘a
%
% �s�����G(s)�ɑ΂��āA�A���S���Y���́A�܂����蕔�ƕs���蕔��G(s)�𕪊�
% ���܂��B
%
% "MRTYPE"�̑I���ɂ��A���̃I�v�V����������܂��B
%
% 1). MRTYPE = 1  --- "NO"�Œ�`���������̒᎟�����f�����Z�o�B
% 2). MRTYPE = 2  --- �g�[�^���̌덷��"NO"��菬�����Ȃ�k���̃��f�����Z
%                     �o�B
% 3). MRTYPE = 3  --- �S�Ẵn���P�����ْl��\�����A����"k"�̓��͂𑣂�
%                     �܂��B
%
% TOTBND = �덷�͈� , HSV = �n���P�����ْl



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
