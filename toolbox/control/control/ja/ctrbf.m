% CTRBF   ���䐫�X�e�A�P�[�X�^���o��
%
% [ABAR,BBAR,CBAR,T,K] = CTRBF(A,B,C) �́A���䐫/����䐫�̕������
% �ɕ������܂��B
%
% [ABAR,BBAR,CBAR,T,K] = CTRBF(A,B,C,TOL) �́A�g�������X TOL ���g�p���܂��B
%
% Co = CTRB(A,B) ���A�����N r < =  n = SIZE(A,1) �̏ꍇ�A���̂悤��
% �����ϊ� T �����݂��܂��B
%
%   Abar = T * A * T' ,  Bbar = T * B ,  Cbar = C * T'
%
% �����āA�ϊ����ꂽ�V�X�e���́A���̂悤�Ȍ^�����Ă��܂��B
%
%          | Anc    0 |           | 0 |
%   Abar =  ----------  ,  Bbar =  ---  ,  Cbar = [Cnc| Cc].
%          | A21   Ac |           |Bc |
%                                                 -1          -1
% �����ŁA(Ac,Bc) �͉���ŁA���̊֌W�ACc(sI-Ac) Bc = C(sI-A) B ����
% �藧���܂��B
% 
% �ŐV�̏o�� K �́A�A���S���Y���̊e�J��Ԃ��Ŏ��ʂ�������ȏ�Ԃ̐�
% ��v�f�Ƃ������� n �̃x�N�g���ł��B����ȏ�Ԑ��́ASUM(K) �ł��B
%
% �Q�l�FCTRB, OBSVF.


%   Author : R.Y. Chiang  3-21-86
%   Revised 5-27-86 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:03:55 $
