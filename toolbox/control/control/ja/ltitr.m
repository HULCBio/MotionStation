% LTITR �́A���`���s�ώ��ԉ����̌v�Z�J�[�l���ł��B
%
% X = LTITR(A,B,U) �́A�V�X�e�� x[n+1] = Ax[n] + Bu[n] �̓��͗� U �̎���
% �������v�Z���܂��B�s�� U �́A���݂��Ă�����͌Q u �Ɠ����񐔂�������
% ���܂��BU �̊e�s�́A�V�������ԓ_�ɑΉ����Ă��܂��BLTITR �́A��� x ��
% ���Ɠ����񐔂ŁALENGTH(U) �̍s�������s�� X ���o�͂��܂��B
%
%	for i = 1:n
%       x(:,i) = x0;
%       x0 = a * x0 + b * u(i,:).';
%	end
%	x = x.';


%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:26 $
