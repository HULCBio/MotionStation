% NORM   �s��ƃx�N�g���̃m����
% 
% �s��ɑ΂���
%   NORM(X) �́AX �̍ő���ْl max(svd(X)) �ł��B
%   NORM(X,2) �́ANORM(X) �Ɠ����ł��B
%   NORM(X,1) �́AX ��1-�m�����A�ő��a max(sum(abs((X)))) �ł��B
%   NORM(X,inf) �́AX �̖�����m�����A�ő�s�a max(sum(abs((X')))) �ł��B
%   NORM(X,'fro') �́AFrobenius�m�����Asqrt(sum(diag(X'*X))) �ł��B
%   NORM(X,P) �́AP ��1�A2�Ainf�A'fro' �̏ꍇ�݂̂ɍs�� X �ɑ΂��Ď��s
%   �ł��܂��B
%
% �x�N�g���ɑ΂���
%   NORM(V,P) �́Asum(abs(V).^P)^(1/P) �ł��B
%   NORM(V) �́Anorm(V,2) �ł��B
%   NORM(V,inf) �́Amax(abs(V)) �ł��B
%   NORM(V,-inf) �́Amin(abs(V)) �ł��B
% 
% �Q�l�FCOND, RCOND, CONDEST, NORMEST.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:58 $
%   Built-in function.

