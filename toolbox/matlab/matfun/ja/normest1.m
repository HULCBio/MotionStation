% NORMEST1  �u���b�N������1�m�����p���[�@���g���čs���1�m�����𐄒�
%
% C = NORMEST1(A) �́Anorm(A,1) �̐���l C ���o�͂��܂��B�����ŁAA ��N 
% �sN ��̍s��ł��BA �́A�����I�ȍs��܂��� FEVAL(@AFUN,FLAG,X) ��
% �悤�Ȋ֐� AFUN �̂����ꂩ�ł��B�����ŁAFLAG �ɂ͂��̂��̂����p
% �ł��܂��B
%     FLAG       returns
%     'dim'      N
%     'real'     A �������̏ꍇ��1�A���̑��̏ꍇ��0
%     'notransp' A*X
%     'transp'   A'*X
%
% C = NORMEST1(A,T) �́A�f�t�H���g��2����J��Ԃ��v�Z���s���s�����
% �񐔂�ω������܂��BT <= N/4 ��I�����邱�Ƃ������߂��܂��B
% ���̑��̏ꍇ�́AA �̗v�f���琳�m�ȃm���������ȒP�ɍ쐬����悤��
% ����K�v������܂��B���Ƃ��΁AN <= 4 �܂��� T == N �ł���ꍇ�ł��B
% T < 0 �̏ꍇ�́AABS(T) �̗񂪎g���A�g���[�X��񂪈������܂��B
% T ����s��ŗ^������ꍇ�́A�f�t�H���gT ���g���܂��B
%
% C = NORMEST1(A,T,X0) �́A�P��1�m�����̗�����A�J�n�s�� X0 ���w��
% ���܂��B�f�t�H���g�́AT>1 �ɑ΂��ă����_���ł��BX0 ����s��([])�Ƃ���
% �^������ꍇ�́A�f�t�H���g�� X0 ���g���܂��B
%
% C = NORMEST1(AFUN,T,X0,P1,P2,...) �́A�ǉ����� P1, P2,...�� 
% FEVAL(@AFUN,FLAG,X,P1,P2,...) �ɓn���܂��B
%
% [C,V] = NORMEST1(A,...) �� [C,V,W] = NORMEST1(A,...) �́AW = A*V ��
% NORM(W,1) = C*NORM(V,1) �ɂȂ�悤�Ƀx�N�g�� V �� W ���o�͂��܂��B
%
% [C,V,W,IT] = NORMEST1(A,...) �́A���̂悤�ȃx�N�g�� IT ���o�͂��܂��B
%   IT(1) �́A�J��Ԃ��񐔂ł��B
%   IT(2) �́AN x N x N x T �̍s��̐ς̐��ł��B
%   ���ς����悻�AIT(2) = 4 �ł��B
%
% ���ӁFNORMEST1 �́ARAND ���Ăяo���܂��B�J��Ԃ��\�Ȍ��ʂ��K�v��
% �ꍇ�́A���̊֐����R�[������O�ɁAJ �ɑ΂���RAND('STATE',J) ���Ăяo��
% �݂܂��B
%
% �Q�l�FCONDEST.

%   Nicholas J. Higham, 9-8-99
%   Copyright 1984-2004 The MathWorks, Inc.
