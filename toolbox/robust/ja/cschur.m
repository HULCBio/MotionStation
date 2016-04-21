% CSCHUR   �����t����ꂽ���fSchur����
%
% [V,T,M,SWAP] = CSCHUR(A,ODTYPE)�́A���fSchur�������v�Z���܂��B
%
%              V' * A * V  = T = |T1  T12|
%                                | 0   T2|,
%
%              m    = ����ȋɂ̐�(s�܂���z����)
%              swap = �X���b�v��]��
%
% "schur"�ŏo�͂��ꂽ�����t������Ă��Ȃ�Schur�^�́A�אڂ���Ίp�����X��
% �b�v���邽�߂ɁA���fGivens��]���g���ď����t�����܂��B
%
% 6��ނ̏��Ԃ��I���ł��܂��B
%
%         odtype = 1 --- Re(eig(T1)) < 0, Re(eig(T2)) > 0
%         odtype = 2 --- Re(eig(T1)) > 0, Re(eig(T2)) < 0
%         odtype = 3 --- �ŗL�l�̎���������������
%         odtype = 4 --- �ŗL�l�̎��������傫����
%         odtype = 5 --- �ŗL�l�̐�Βl����������
%         odtype = 6 --- �ŗL�l�̐�Βl���傫����
%



% Copyright 1988-2002 The MathWorks, Inc. 
