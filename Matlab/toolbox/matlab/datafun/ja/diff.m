% DIFF   �����Ƌߎ����֐�
% 
% DIFF(X)�́AX���x�N�g���̏ꍇ�A[X(2)-X(1)  X(3)-X(2) ... X(n)-X(n-1)]��
% ���B
% 
% DIFF(X)�́AX���s��̏ꍇ�A�s���ɍ������v�Z���܂��B
%    [X(2:n,:) - X(1:n-1,:)].
% 
% DIFF(X)�́AX��N�����z��̏ꍇ�AX�̍ŏ���1�łȂ������̍������v�Z���܂��B
% 
% DIFF(X,N)�́A�ŏ���1�łȂ�����(DIM�Őݒ�)��N�K�����ł��BN > =  size(X,
% DIM)�̏ꍇ�A����1�łȂ������̂��̂ɘA���I�Ɉړ����āA�������܂��B
% 
% DIFF(X,N,DIM)�́A����DIM��N�K�����֐��ł��BN > =  size(X,DIM)�̏ꍇ�A
% DIFF�͋�z����o�͂��܂��B
%
% ���:
%    h = .001; x = 0:h:pi;
%    diff(sin(x.^2))/h�́A2*cos(x.^2).*x�̋ߎ��ł��B
%    diff((1:10).^2)�́A3:2:19�ł��B
%
%    X = [3 7 5
%         0 9 2]
% �̏ꍇ�Adiff(X,1,1) �� [-3 2 -3]�Adiff(X,1,2) �� [4 -2  �ł��B
%                                                   9 -7]
%                                         
% diff(X,2,2)�́A2�Ԗڂ̎����ɑ΂���2�K�������o�͂��Adiff(X,3,2)�́A
% ��s����o�͂��܂��B
%
% �Q�l�FGRADIENT, SUM, PROD.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:40 $
%   Built-in function.
