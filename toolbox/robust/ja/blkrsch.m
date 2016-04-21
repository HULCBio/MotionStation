% BLKRSCH   �u���b�N�������t����ꂽ��Schur����
%
% [V,T,M] = BLKRSCH(A,ODTYPE,CUT)�́A���������s��A�̎��u���b�N���̕�����
% �s���܂��B
%
%               V'AV = T = |B1  B12|
%                          | 0   B2|
%
%               B1 = T(1:CUT,1:CUT)
%               B2 = T(CUT+1:END,CUT+1:END)
%                M = ����ȌŗL�l�� (s �܂���z����)
%
% 6��ނ̏��Ԃ��I���ł��܂��B
%         odtype = 2 �܂��� 3 --- Re(eig(B1)) > Re(eig(B2))
%         odtype = 1 �܂��� 4 --- Re(eig(B1)) < Re(eig(B2))
%         odtype = 5 --- abs(eig(B1)) > abs(eig(B2))
%         odtype = 6 --- abs(eig(B1)) < abs(eig(B2))
%
%  ODTYPE <3 & NARGIN<3�̏ꍇ�ACUT�̃f�t�H���g�́A���̂悤�ɂȂ�܂��B
%         odtype = 1 --->   CUT = M
%         odtype = 2 --->   CUT = size(A,1)-M



% Copyright 1988-2002 The MathWorks, Inc. 
