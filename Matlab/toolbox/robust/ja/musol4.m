% MUSOL4 ����/���f�������\�������ْl
%
% �T�v�F musol4(M), musol4(M,K), musol4(M,K,T), musol4(M,K,T,x).
%
% MUSOL4 �́A�ȉ��̃��|�[�g�̍\�������ْl�̏�E���v�Z���܂��B
%
% "Robustness in the Presence of Mixed Parametric Uncertainty and
% Unmodeled Dynamics," by M.K.H. Fan, A.L. Tits and J.C. Doyle, IEEE
% Transactions on Automatic Control, January 1991.
%
% MUSOL4 �́A�ȉ��m���|�[�g�̒���(���ǂ��ꂽ)���_�@���g�p���܂��B
%
%     "An Interior Point Method for Solving Linear Matrix Inequality
%     Problems," by M.K.H. Fan and B. Nekooie, SIAM Journal on Control
%     and Optimization, to appear.
%
% ���́F
%  M  -  SSV �̏�E���v�Z����� n �s n ��̍s��
%
% �I�v�V�������́F
%  K  -  m �s 1 ��̃u���b�N�\������Ȃ�܂��BK(i), i = 1:m �́A���ꂼ���
%        �u���b�N�T�C�Y�ł���Asum(K) �́An �ɂȂ�܂��B�f�t�H���g�́AK = 
%        ones(n,1)�ł��B
%  T  -  m �s 1 ��̃x�N�g���ŁA���ꂼ��̃u���b�N�̃^�C�v�������܂��B
%        i = 1:m �ɑ΂��āA
%           T(i)=1 �́A�Ή�����u���b�N�������u���b�N�ł��邱�Ƃ������A
%           �����āA
%           T(i)=2 �́A�Ή�����u���b�N�����f���ł��邱�Ƃ������܂��B
% K(i) �́AT(i) = 1 �̏ꍇ�A1�ł��B�f�t�H���g�́A2*ones(length(K),1)�ł��B
%  x  -  �ȑO�ɓǂ� muso14 ����̏���[�߂��x�N�g��
%
% �o�́F
%     r   -  �v�Z���ꂽ��E��[�߂������X�J��
%     D,G -  n �s n ��̈ȉ��̂悤�ȁA������̍s��
%            M'*D^2*M + sqrt(-1)*(G*M-M'*G) - r^2*D^2
%            
%     x   -  �s��� M �Ɏ��������邽�߂ɁA���� muso14 ���ĂԂ̂ݎg�p�ł�
%            �����[�߂��x�N�g��

% Copyright 1988-2002 The MathWorks, Inc. 
