% MTIMES   LTI���f���̏�Z
%
% SYS = MTIMES(SYS1,SYS2)�́ASYS = SYS1 * SYS2 ���v�Z���܂��B2��
% LTI���f���̏�Z�́A���L�Ɏ������񌋍��Ɠ����ł��B
%
%     u ----> SYS2 ----> SYS1 ----> y 
%
% SYS1 �� SYS2 ���A���ꂼ��LTI���f���̔z��̂Ƃ��A�����̏�Z�́A
% ���f���̐��Ɠ�����LTI�z�� SYS �ɂȂ�܂��B�����ŁAk �Ԗڂ̃��f���́A
% 
%   SYS(:,:,k) = SYS1(:,:,k) * SYS2(:,:,k) 
% 
% �ł��B
%
% �Q�l : SERIES, MLDIVIDE, MRDIVIDE, INV, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
