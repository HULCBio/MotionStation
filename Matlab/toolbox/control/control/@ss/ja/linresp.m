% LINRESP   LTI���f���̎��ԉ����V�~�����[�V����
%
% [Y,T,X] = LINRESP(SYS,TS,U,T,X0) �́A������� X0 �ŁA���� U �� T �� 
% LTI���f�� SYS �̎��ԉ������V�~�����[�V�������܂��BTS �� SYS �̃T���v��
% ���ԂŁAT �͏o�͎��Ԃ̃x�N�g���ł��B
%
% [Y,T,X] = LINRESP(SYS,TS,U,T,X0,INTERPRULE)�́A�A�����ԐM���ɑ΂��āA
% �T���v���Ԃ̓��}���[��(ZOH �܂��� FOH)�𖾎��I�ɐݒ肵�܂��B�f�t�H���g
% �́A�M����2�̘A������T���v���ԂŁA�U���̑S�̂ł̃����W��75 %����
% �傫���Ȃ�ꍇ�������āAFOH �ł��B
%
% �֐� LSIM �ŃR�[������ᐅ�����[�e�B���e�B


%   Author: P. Gahinet, 4-98
%   Copyright 1986-2002 The MathWorks, Inc. 
