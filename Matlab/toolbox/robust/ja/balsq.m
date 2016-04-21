% BALSQ �������ɂ�镽�t���ł��؂� (����v�����g)
%
% [SS_Q,AUG,SVH,SLBIG,SRBIG] = BALSQ(SS_,MRTYPE,NO)�A�܂��́A
% [AQ,BQ,CQ,DQ,AUG,SVH,SLBIG,SRBIG] = BALSQ(A,B,C,D,MRTYPE,NO) �́A
% ���̊֌W�𖞑�����O���~�A���̐�PQ�̕������Ɋ�Â��āA
% G(s):=(a,b,c,d)�̕��t���ł��؂�ɂ�郂�f���̒᎟�������������܂��B
%
% �덷(Ghed(s) - G(s))�̖�����m���� <= 2(n-k)�ŏ��n���P�����ْl(SVH)��
% �a
%
%           (aq,bq,cq,dq) = (slbig'*a*srbig,slbig'*b,c*srbig,d)
%
% "MRTYPE"�̑I���ɂ��A���̃I�v�V����������܂��B
%
% 1). MRTYPE = 1  --- "NO"�Œ�`���������̒᎟�����f�����Z�o�B
% 2). MRTYPE = 2  --- �g�[�^���̌덷��"NO"��菬�����Ȃ�k���̃��f�����Z
%                     �o�B
% 3). MRTYPE = 3  --- �n���P�����ْl��\�����A����"k"�̓��͂𑣂��܂��B
%
% AUG = [�폜���ꂽ��Ԃ̐� , �덷�͈�] , SVH = �n���P�����ْl

% Copyright 1988-2002 The MathWorks, Inc. 
