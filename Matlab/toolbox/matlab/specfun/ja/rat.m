% RAT   �L�����ߎ�
% 
% [N,D] = RAT(X,tol) �́Aabs(N./D - X) < =  tol*abs(X) �͈̔͂ŁAN./D �� 
% X �ɋߎ�����悤��2�̐����s����o�͂��܂��B�L�����ߎ��́A�A������
% �W�J�ɂ���č���܂��Btol �̃f�t�H���g�l�́A1.e-6*norm(X(:),1) �ł��B
%
% S = RAT(X) �܂��� RAT(X,tol) �́A�A�����W�J�𕶎���Ƃ��ďo�͂��܂��B
%
% MATLAB��FORMAT RAT�̓����ŁA�f�t�H���g�� tol ���g���������A���S���Y��
% ���g�p����܂��B
%
% �Q�l�FFORMAT, RATS.


%   Cleve Moler, 10-28-90, 12-27-91, 9-4-92, 4-27-95.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:04:28 $
