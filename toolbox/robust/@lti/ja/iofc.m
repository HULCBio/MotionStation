% IOFC ��ԋ�ԕ\���̃C���i�[/�A�E�^�[����
%
% [SS_IN,SS_INP,SS_OUT] = IOFC(SS_)�A�܂��́A
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = ....
% IOFC(A,B,C,D)�́Am�sn��̓`�B�֐� G: SS_ = MKSYS(A,B,C,D) (m<n)���A��
% ���̂悤�ɁA�C���i�[/�A�E�^�[�������܂��B
% 
%                      G = |M  0| |Th |
%                                 |Thp|
% 
% �����ŁA
%                     |Th |: �����ŃC���i�[
%                     |Thp|
%
%                      M : �A�E�^�[���q
%
% ���ʂƂ��ē�����4��1�g�ŕ\��������ԋ�Ԃ́A(ain,bin,...)�A�܂��́A
% ���̂悤�ɏo�͂���܂��B
%
%            ss_in  = mksys(ain,bin,cin,din);
%            ss_inp = mksys(ainp,binp,cinp,dinp);
%            ss_out = mksys(aout,bout,cout,dout);
%
% �W���I�ȏ�ԋ�ԕ\���́A"branch"�ɂ�蒊�o���邱�Ƃ��ł��܂��B



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
