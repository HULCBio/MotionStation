% MAKETREE �@�c���[�̍쐬
% [T,NB] = MAKETREE(ORD,D) �́A�[�� D �������� ORD �̃c���[�\�����쐬���܂��B
% �o�͈��� NB = ORD^D �́A�s�A���m�[�h�̔ԍ��ł��B�o�̓x�N�g�� T �́A[T(1) ... 
% T(NB+1)]�̂悤�ɍ���܂��B�����ŁAT(i)�Ai �� 1 ���� NB �ŁANB �͕s�A���m�[�h
% �̃C���f�b�N�X�ŁAT(NB+1) = -ORD�ł��B
%
% �m�[�h�́A������E�A�ォ�牺�ւƔԍ��t������Ă��܂��B���[�g�ƂȂ�C���f�b�N�X
% ��0�ł��B
%
% 3�̓��͈������g���Ƃ��A[T,NB] = MAKETREE(ORD,D,NBI) �́A��̂悤�� T(1,:) ��
% (1+NBI) �s (NB+1) ��̍s��Ƃ��� T ���v�Z���܂��B�܂��AT(2:NBI+1,:) �ɂ́A���[
% �U�͎��g�̂��̂����R�ɕt���ł��܂��B
%
% �Ȃ��AMAKETREE(ORD) �́AMAKETREE(ORD,0,0) �Ɠ����ł��BMAKETREE(ORD,D) �́AMA-
% KETREE(ORD,D,0) �Ɠ����ł��B
%
% �Q�l�F PLOTTREE, WTREEMGR.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
