% PSI    Psi (polygamma)�֐�
% Y = PSI(X) �́AX �̊e�v�f�ɑ΂���psi�֐����v�Z���܂��BX �́A�����Ŕ�
% �łȂ���΂Ȃ�܂���Bpsi�֐��́Adigamma�֐��Ƃ��Ă��m���Agamma�֐�
% �̑ΐ����W���ł��B
%
%    psi(x) = digamma(x) = d(log(gamma(x)))/dx = (d(gamma(x))/dx)/gamma(x).
%
% Y = PSI(K,X) �́AX �̗v�f��psi��K�����W�����v�Z���܂��B
% PSI(0,X) ��digamma�֐��ŁAPSI(1,X) ��trigamma�֐��ŁAPSI(2,X) ��
% tetragamma�֐��A���ɂȂ�܂��B
%
% Y = PSI(K0:K1,X) �́AX �ɂ����āA���W���̎��� K0 ���� K1���v�Z���܂��B
% Y(K,J) �́AX(J) �Ōv�Z���ꂽpsi�� (K-1+K0) �Ԗڂ̔��W���ł��B
%
% ���:
%
%    -psi(1) = -psi(0,1) �́AEuler�̒萔�A0.5772156649015323�ł��B
%
%    psi(1,2) = pi^2/6 - 1.
%
%    x = (1:.005:1.250)';  [x gamma(x) gammaln(x) psi(0:1,x)' x-1]
%    �́AAbramowitz and Stegun��table 5.1��1�y�[�W�𐶐����܂��B.
%
%    psi(2:3,1:.01:2)' �́Atable 6.2 �̈ꕔ�ł��B
%
% �Q�l����: Abramowitz & Stegun, Handbook of Mathematical Functions,
%   sections 6.3 and 6.4.
%
% �Q�l �F GAMMA, GAMMALN, GAMMAINC.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:04:27 $


