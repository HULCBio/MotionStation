% DCOVAR   ���F�m�C�Y�ɑ΂��闣�U�V�X�e���̋����U����
%
% [P,Q] = DCOVAR(A,B,C,D,W) �́A���U��ԋ�ԃV�X�e�� (A, B, C, D)�� ���x 
% W ��Gauss���F�m�C�Y����͂����ꍇ�̋����U�������v�Z���܂��B
%
%    E[w(k)w(n)'] = W delta(k,n)
%
% �����ŁAdelta(k, n) �́AKronecker �f���^�ł��BP �͏o�́AQ �́A���
% �����U�����ł��B
%
%    P = E[yy'];  Q = E[xx'];
%
% P = DCOVAR(NUM,DEN,W) �́A�������`�B�֐��V�X�e���̏o�͋����U������
% �v�Z���܂��BW �́A���̓m�C�Y�̋��x�ł��B
%
% �Q�l : COVAR, LYAP, DLYAP.


%   Clay M. Thompson  7-5-90
%       Revised by Wes Wang 8-5-92
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:36 $
