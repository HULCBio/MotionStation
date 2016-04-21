% DYADUP �@2�i�A�b�v�T���v�����O
% DYADUP �́A�E�F�[�u���b�g�č\���A���S���Y���̒��ŁA���ɗL���ȃ[�����p�b�f�B
% ���O����P���ȕ��@�����s���܂��B
%
% Y = DYADUP(X,EVENODD)�A�����ŁAX �̓x�N�g�����w���Ă���A����ɂ��A�[�����
% �}���邱�Ƃɂ�蓾����x�N�g�� X �̊g�����ꂽ�R�s�[���o�͂���܂��B���̐��� 
% EVENODD �̒l�ɂ��A�[���������̃C���f�b�N�X�ɑ}������̂��A��̃C���f�b�N�X
% �ɑ}������̂������肳��܂��B
% 
% EVENODD �������̏ꍇ�A Y(2k-1) = X(k)�AY(2k) = 0
% EVENODD ����̏ꍇ�A Y(2k-1) = 0   �AY(2k) = X(k)
%
% Y = DYADUP(X) �́AY = DYADUP(X,1) �Ɠ����ł��B
%
% Y = DYADUP(X,EVENODD,'type')�A�܂��́AY = DYADUP(X,'type',EVENODD)(X ���s���
% �ꍇ)�́A�ϐ�'type' ���A'c'(�܂��́A'r'�A�܂��́A'm' �̂����ꂩ)�ł��邩�ɂ��
% �āA�s(�܂��͗�A�s�Ɨ�̑o��)����q�̃p�����[�^ EVENODD �̎w��ɂ������`�ő}
% �����A����ɂ���ē����� X �̃o�[�W�������o�͂��܂��B
%
% Y = DYADUP(X) �́AY = DYADUP(X,1,'c') �Ɠ����ł��B
% Y = DYADUP(X,'type') �́AY = DYADUP(X,1,'type') �Ɠ����ł��B
% Y = DYADUP(X,EVENODD) �́AY = DYADUP(X,EVENODD,'c') �Ɠ����ł��B
%
%                |1 2|                     |0 1 0 2 0|
% ���     : X = |3 4|  ,  DYADUP(X,'c') = |0 3 0 4 0|
%
%                   |1 2|                      |1 0 2|
% DYADUP(X,'r',0) = |0 0|  , DYADUP(X,'m',0) = |0 0 0|
%                   |3 4|                      |3 0 4|
%
% �Q�l�F DYADDOWN.



%   Copyright 1995-2002 The MathWorks, Inc.
