% DAMP   LTI���f���̋ɂɊւ���ŗL�U�����ƌ�����
%
% [Wn,Z] = DAMP(SYS) �́ALTI���f�� SYS �̌ŗL�U�����ƌ�����̃x�N�g�� 
% Wn �� Z ���o�͂��܂��B���U���ԃ��f���ɑ΂��āA�ŗL�l lambda �Ɋւ���
% ������ s -���ʂ̌ŗL�U�����ƌ�����́A
%            
%    Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda))) 
%
% �T���v������ Ts ����`����Ȃ��ƁAWn �� Z �́A��s��ł��B
%
% [Wn,Z,P] = DAMP(SYS) �́ASYS �̋� P ���o�͂��܂��B
%
% ���ӂ̏o�͈������ȗ������ꍇ�ADAMP �͋ɂƂ���Ɋւ���ŗL�U�����ƌ�����
% ���e�[�u���ɂ��ă��j�^�ɏo�͂��܂��B�ɂ͎��g���̏��Ƀ\�[�g����܂��B
% 
% �Q�l : POLE, ESORT, DSORT, PZMAP, ZERO.


%   J.N. Little 10-11-85
%   Revised 3-12-87 JNL
%   Revised 7-23-90 Clay M. Thompson
%   Revised 6-25-96 Pascal Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
