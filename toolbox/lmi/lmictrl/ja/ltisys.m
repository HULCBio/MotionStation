% sys = ltisys(a,b,c,d,e)
% sys = ltisys('tf',n,d)
%
% LTI�V�X�e���̏�ԋ�Ԏ���(A,B,C,D,E)��SYSTEM�s��Ƃ��Ċi�[���܂��B
%
%                       | A+j(E-I)   B   na  |
%             SYS  =    |    C       D    0  |
%                       |    0       0  -Inf |
%
% �����ŁAna = size(A,1)�ł��B�s��A����E�͎����ł��B�ȗ�����ƁAD��E�́A
% �f�t�H���g�lD=0��E=I�ɐݒ肳��܂��BE�ɑ΂���l0��1�́AE=0��E=I�Ɖ���
% ����܂��B
%
% SYS = LTISYS(A)��SYS = LTISYS(A,E)�́A���R�n��ݒ肵�܂��B
% 
%               dx/dt = A x     ��   E dx/dt = A x 
%
% SISO�V�X�e���́A�`�B�֐��\��N(s)/D(s)�ɂ���Ă��ݒ�ł��܂��B�V���^�b
% �N�X�́ASYS = LTISYS('tf',N,D)�ŁA�����ŁAN��D�́A������N(s)��D(s)�̃x
% �N�g���\���ł��B
%
% �Q�l�F    LTISS, LTITF, SINFO.



%  Copyright 1995-2002 The MathWorks, Inc. 
