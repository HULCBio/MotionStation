% SQRTM   �s��̕�����
% 
% X = SQRTM(A )�́AA �̍s��̕��������v�Z���܂��B�܂� X*X = A �ł��B
%
% X �́A���ׂĂ̌ŗL�l���񕉂̎��������A���j�[�N�Ȑ����s��ł��B
% A �����̎����l�̌ŗL�l�����ꍇ�́A���ʂ͕��f���ɂȂ�܂��B
% A �����ٍs��̏ꍇ�AA �͕������������܂���B
% ���ِ������o���ꂽ�ꍇ�̓��[�j���O��\�����܂��B
%
% 2�̏o�͈������w�肵���ꍇ�A[X, RESNORM] = SQRTM(A) �́A�x�����b�Z�[�W
% �͕\�����܂��񂪁A�c�� norm(A-X^2,'fro')/norm(A,'fro') ���o�͂��܂��B
%
% 3�̏o�͈������w�肵���ꍇ�A[S�AALPHA�ACONDEST] = SQRTM(A) �́A�����
% �q ALPHA �� X �̍s��̕������̏������̐���l CONDEST ���o�͂��܂��B�c�� 
% norm(A-X^2,'fro')/norm(A,'fro') �́A(n+1)*ALPHA*EPS �����E�Ƃ��AX ��
% Frobenius �m�����Ɋ֘A�����G���[�́AN*ALPHA*CONDEST*EPS �����E�Ƃ��܂��B
% �����ŁAN = MAX(SIZE(A)) �ł��B
%
% �Q�l�FEXPM, LOGM, FUNM.

%   �Q�l����:
%   N. J. Higham, Computing real square roots of a real
%       matrix, Linear Algebra and Appl., 88/89 (1987), pp. 405-430.
%   A. Bjorck and S. Hammarling, A Schur method for the square root of a
%       matrix, Linear Algebra and Appl., 52/53 (1983), pp. 127-140.
%
%   Nicholas J. Higham
%   Copyright 1984-2002 The MathWorks, Inc.
