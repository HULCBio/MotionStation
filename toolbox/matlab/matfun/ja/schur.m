% SCHUR   Schur����
% 
% [U,T] = SCHUR(X) �́AX = U*T*U' ���� U'*U = EYE(SIZE(U)) �ł���悤�ȁA
% Schur�s�� T �ƃ��j�^���s�� U ���o�͂��܂��BX �͐����łȂ���΂Ȃ�܂���B
%
% T = SCHUR(X) �́ASchur�s�� T �݂̂��o�͂��܂��B
%
% X �����f���s��̏ꍇ�́A�s�� T �ɕ��fSchur�^���o�͂��܂��B���fSchur�^�́A
% �Ίp�v�f�� X �̌ŗL�l������O�p�s��ł��B
%
% X �������̏ꍇ�́A2�̈قȂ镪�����\�ł��B
% SCHUR(X,'real') �́A���ŗL�l�͑Ίp�v�f��ɁA���f�ŗL�l��2�s2��̃u���b
% �N�ŁA�Ίp����ɔz�u����܂��B
% SCHUR(X,'complex') �́AX �����f�ŗL�l�̏ꍇ�A�O�p�s��ŕ��f���ɂȂ�܂��B
% SCHUR(X,'real') ���A�f�t�H���g�ł��B
%
% ��Schur�^���畡�fSchur�^�ւ̕ϊ��ɂ��ẮARSF2CSF ���Q�Ƃ��Ă��������B
%
% �Q�l ORDSCHUR, QZ.

%   Copyright 1984-2002 The MathWorks, Inc. 

