% DYADDOWN �@2�i�_�E���T���v�����O
% Y = DYADDOWN(X,EVENODD)�AX �̓x�N�g���ŁAX ��1��тɃ_�E���T���v���������̂�
% �o�͂��܂��BY �́A���̐��� EVENODD �̒l�ɂ���āAX �̋����C���f�b�N�X����C
% ���f�b�N�X�ɂȂ�܂��B
% 
% EVENODD �������̏ꍇ�AY(k) = X(2k)
% EVENODD ����̏ꍇ�AY(k) = X(2k-1)
%
% Y = DYADDOWN(X) �́AY = DYADDOWN(X,0) �Ɠ����ł��B
%
% Y = DYADDOWN(X,EVENODD,'type')�A�܂��́AY = DYADDOWN(X,'type',EVENODD)(X ���s
% ��̏ꍇ)�́A�ϐ� 'type' ���A'c' �܂��� 'r' �܂��� 'm' �ł��邩�ɂ���āA�s(��
% ���͗�A�s�Ɨ�̑o��)����q�̃p�����[�^ EVENODD �̎w��ɂ������`�ō폜���A����
% �ɂ���ē����� X �̃o�[�W�������o�͂��܂��B
%
% Y = DYADDOWN(X) �́AY = DYADDOWN(X,0,'c') �Ɠ����ł��B
% Y = DYADDOWN(X,'type') �́AY = DYADDOWN(X,0,'type') �Ɠ����ł��B
% Y = DYADDOWN(X,EVENODD) �́AY = DYADDOWN(X,EVENODD,'c') �Ɠ����ł��B
%
%                |1 2 3 4|                       |2 4|
% ��� :     X = |2 4 6 8|  ,  DYADDOWN(X,'c') = |4 8|
%                |3 6 9 0|                       |6 0|
%
%                     |1 2 3 4|                        |1 3|
% DYADDOWN(X,'r',1) = |3 6 9 0|  , DYADDOWN(X,'m',1) = |3 9|
%
% �Q�l�F DYADUP.



%   Copyright 1995-2002 The MathWorks, Inc.
