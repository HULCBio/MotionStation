% IOFR ��ԋ�ԕ\���̃C���i�[/�A�E�^�[����
%
% [SS_IN,SS_INP,SS_OUT] = IOFR(SS_)�A�܂��́A
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = ...
% IOFR(A,B,C,D)�́Am�sn��`�B�֐� G: SS_ = MKSYS(A,B,C,D) (m>=n)���A��
% �̂悤�ɁA�C���i�[/�A�E�^�[�������܂��B
% 
%                      G = |Th Thp| |M|
%                                   |0|
% �����ŁA
%                      [Th Thp] : �����ŃC���i�[
%                      M        : �A�E�^�[���q
%
% ���ʂƂ��ē�����4��1�g�ŕ\��������ԋ�Ԃ́A(ain,bin,...)�A�܂��́A
% ���̂悤�ɏo�͂���܂��B
%
%            ss_in  = mksys(ain,bin,cin,din);
%            ss_inp = mksys(ainp,binp,cinp,dinp);
%            ss_out = mksys(aout,bout,cout,dout);
%
% �W���I�ȏ�ԋ�ԕ\���́A"branch"�ɂ�蒊�o���邱�Ƃ��ł��܂��B



% Copyright 1988-2002 The MathWorks, Inc. 
