% TF2ZPK  ���U���ԓ`�B�֐��̗�_�]�ɕϊ�
% [Z,P,K] = TF2ZPK(NUM,DEN)  �́A
%
% �������̌`�́A�V���O���̓��́A�V���O���̏o�͂̓`�B�֐�
%
%               NUM(z)
%       H(z) = -------- 
%               DEN(z)
%
% ����A���̂悤�ɁA��_�A�ɁA�Q�C���������܂��B
%
%                 (z-Z(1))(z-Z(2))...(z-Z(n))
%       H(z) =  K ---------------------------
%                 (z-P(1))(z-P(2))...(z-P(n))
%
% ���:
%     [b,a] = butter(3,.4);
%     [z,p,k] = tf2zpk(b,a)

%   Copyright 1988-2002 The MathWorks, Inc.
