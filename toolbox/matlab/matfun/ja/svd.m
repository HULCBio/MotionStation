% SVD   ���ْl����
% 
% [U,S,V] = SVD(X) �́AX �Ɠ����傫���ŁA���łȂ��Ίp�v�f���~���ɂ��Ίp
% �s�� S �ƁAX = U*S*V' �ł���悤�ȃ��j�^���s�� U �� V ���o�͂��܂��B
%
% S = SVD(X) �́A���ْl����Ȃ�x�N�g�����o�͂��܂��B
%
% [U,S,V] = SVD(X,0) �́A�����������̗ǂ��������s���܂��BX �� m > n �ł���
% m�sn��̍s��̏ꍇ�́AU �̍ŏ���n��݂̂��v�Z����AS ��n�sn��ɂȂ�܂��B
% m <= n �ɑ΂��āASVD(X,0) �́ASVD(X) �Ɠ����ł��B
%
% [U,S,V] = SVD(X,'econ') �́A"economy size" �̕������������܂��B
% X ���Am >= n �Ƃ��� m�~n �̏ꍇ�ASVD(X,0) �ɓ����ł��B
% m < n �ɑ΂��āAV �̂͂��߂� m ��݂̂��v�Z����AS �́Am�~m �ł��B
%
% �Q�l SVDS, GSVD.

%   Copyright 1984-2002 The MathWorks, Inc. 

