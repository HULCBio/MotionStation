% DSS   �f�B�X�N���v�^��ԋ��(DSS)���f�����쐬
%
%           .
%         E x = A x + B u            E x[n+1] = A x[n] + B u[n]
%                            �܂��� 
%           y = C x + D u                y[n] = C x[n] + D u[n]  
%
% SYS = DSS(A,B,C,D,E) �́A�A�����Ԃ� DSS ���f�� SYS ���s�� A, B, C, D, E
% ����쐬���܂��B�o�͂� SYS ��SS�I�u�W�F�N�g�ł��B
% D = 0 �̏ꍇ�A�K�؂Ȏ����̃[���s���ݒ肷�邱�Ƃ��ł��܂��B
%
% SYS = DSS(A,B,C,D,E,Ts) �́A�T���v������ Ts (�T���v�����Ԃ𖢒�`�ɂ�����
% �ꍇ�́ATs = -1 �ɐݒ肵�Ă�������)�������U���� DSS ���f�����쐬���܂��B
%
% �����̏����ŁA���̓��X�g�́A���̂悤�ɑg�ɂ��đ����邱�Ƃ��ł��܂��B 
%   'PropertyName1', PropertyValue1, ... 
% ����ɂ��ASS ���f���̗l�X�ȃv���p�e�B��ݒ肵�܂�(�ڍׂ́ALTIPROPS��
% �Q�Ƃ��Ă�������)�B
% �����̃��f�� REFSYS ����ALTI �v���p�e�B���ׂĂ��p������ SYS ���쐬���邽
% �߂ɂ́A���̏����𗘗p���Ă��������B 
%   SYS = DSS(A,B,C,D,E,REFSYS)
%
% A, B, C, D, E �ɑ΂��� ND �z��𗘗p���邱�ƂŁADSS ���f���̔z����쐬�ł�
% �܂��B�ڍׂ́ASS �Ɋւ���w���v���Q�Ƃ��Ă��������B
%
% �Q�l : SS, DSSDATA.


% Copyright 1986-2002 The MathWorks, Inc.
