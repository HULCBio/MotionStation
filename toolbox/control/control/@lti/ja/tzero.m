% TZERO   LTI�V�X�e���̓`�B��_
% 
% Z = TZERO(SYS) �́ALTI�V�X�e�� SYS �̓`�B��_���o�͂��܂��B
%
% [Z,GAIN] = TZERO(SYS) �́A�V�X�e����SISO�̏ꍇ�A�`�B�֐��̃Q�C����
% �o�͂��܂��B
% 
% Z = TZERO(A,B,C,D) �́A��ԋ�ԍs��ɒ��ړI�ɓ����A��ԋ�ԃV�X�e����
% �`�B��_���o�͂��܂��B   
%        .
%        x = Ax + Bu     �܂���   x[n+1] = Ax[n] + Bu[n]
%        y = Cx + Du              y[n]  = Cx[n] + Du[n]
%
% �Q�l : ZERO, PZMAP, POLE.


%   Clay M. Thompson  7-23-90, 
%       Revised: P.Gahinet 5-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
