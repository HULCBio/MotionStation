% LTIFR   ���`���s�ώ��g�������v�Z�J�[�l��
%
% G = LTIFR(A,b,S) �́A�V�X�e�� G(s) = (sI - A)\b �ɑ΂��āA�x�N�g�� S 
% �Őݒ肵�����f�����g���ł̎��g���������v�Z���܂��B��x�N�g�� b �́A
% �s�� A �̍s���Ɠ����ł��B�s�� G �́ASIZE(A) �s LENGTH(S) ��̑傫���ł��B
% ����́A�������s�R�[�h�ł��B
%
%		function g = ltifr(a,b,s)
%		ns = length(s); na = length(a);
%		e = eye(na); g = sqrt(-1) * ones(na,ns);
%		for i = 1:ns
%		    g(:,i) = (s(i)*e-a)\b;
%		end


%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:22 $
