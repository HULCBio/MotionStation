% TZERO   LTI�V�X�e���̓`�B��_
% 
% Z = TZERO(SYS) �́ALTI�V�X�e�� SYS �̓`�B��_���o�͂��܂��B
% 
% �V�X�e����SISO�̏ꍇ�́A[Z,GAIN] = TZERO(SYS) �́A�`�B�֐��������o��
% ���܂��B
% 
% Z = TZERO(A,B,C,D) �́A��ԋ�ԍs��𒼐ڏ������A��ԋ�ԃV�X�e����
% �`�B��_���o�͂��܂��B
%             .
%             x = Ax + Bu     �܂���   x[n+1] = Ax[n] + Bu[n]
%             y = Cx + Du              y[n]  = Cx[n] + Du[n]
%
% �Q�l�F PZMAP, POLE, EIG.


%   Clay M. Thompson  7-23-90
%       Revised: A.Potvin 6-1-94, P.Gahinet 5-15-96
%   Copyright 1984-2004 The MathWorks, Inc. 