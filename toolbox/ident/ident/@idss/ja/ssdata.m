% IDSS/SSDATA �́AIDSS ���f���̏�ԋ�ԃ��f�����o�͂��܂��B
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
% M �́AIDSS ���f���I�u�W�F�N�g�ł��B
% �o�͂́A���f���̃T���v�����O���� Ts �Ɉˑ����āA�A�����ԁA�܂��́A���U
% ���ԃ��f���̂����ꂩ�ŁA���̌^��������ԋ�ԍs��ɂȂ�܂��B
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
% �́A���f���̕s�m����(�W���΍�)dA ���X���o�͂��܂��B



%   Copyright 1986-2001 The MathWorks, Inc.
