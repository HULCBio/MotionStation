% SS2SS   ��ԋ�ԃ��f���̏�ԍ��W�ϊ�
%
%
% SYS = SS2SS(SYS,T) �́A��ԋ�ԃ��f�� SYS �̏�ԃx�N�g�� x �ɑ΂��āA
% �����ϊ� z = Tx ���s���܂��B���ʂ̏�ԋ�ԃ��f���́A���̂悤�ɕ\��
% ����܂��B
%
%                .       -1        
%                z = [TAT  ] z + [TB] u
%                        -1
%                y = [CT   ] z + D u
%
% �܂��́A�f�B�X�N���v�^�̏ꍇ�́A���̂悤�ɂȂ�܂��B
%
%            -1  .       -1        
%        [TET  ] z = [TAT  ] z + [TB] u
%                        -1
%                y = [CT   ] z + D u 
%
% SS2SS �́A�A�����ԂƗ��U���Ԃ̗����̃��f���ɓK���ł��܂��B
% LTI �z��SYS �ɑ΂��āA�ϊ� T �͔z����̌X�̃��f���ɑ΂��Ď��s��
% ��܂��B
%
% �Q�l : CANON, SSBAL, BALREAL.


% Copyright 1986-2002 The MathWorks, Inc.
