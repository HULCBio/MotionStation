% RIC   Riccati �������̉��̎c�����v�Z
%
% [Kerr,Serr] = RIC(A,B,Q,R,K,S) �́ARiccati �������̉��̒��̌덷���v�Z
% ���܂��BKerr �́A�Q�C���s��̒��̌덷�ASerr �́ARiccati �������̒���
% �c���덷�ł��B
%
%              -1                           -1
%    Kerr = K-R  B'S;  Serr = SA + A'S - SBR  B'S + Q
%
% [Kerr,Serr] = RIC(A,B,Q,R,K,S,N) �́A�N���X�d�ݕt���̍����g����Riccati
% �������̉��̒��̌덷���v�Z���܂��B
%
%           -1                                    -1
% Kerr = K-R  (N'+B'S);  Serr = SA + A'S - (SB+N)R  (N'+B'S) + Q
%
% �Q�l : DRIC, ARE, LQE, LQR.


%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:21 $
