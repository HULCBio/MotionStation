% OBSVF   �ϑ��X�e�A�P�[�X�^���쐬
%
% [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C) �́A�ϑ�/��ϑ����̕�����Ԃ�
% �������܂��B
%
% [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C,TOL) �́A�g�������X TOL ���g���܂��B
%
% Ob = OBSV(A,C) ���Arank r < =  n = SIZE(A,1) �̏ꍇ�A���̂悤�ȑ���
% �ϊ� T �����݂��܂��B
%
%   Abar = T * A * T' ,  Bbar = T * B  ,  Cbar = C * T'
%
% �����āA�ϊ����ꂽ�V�X�e���́A���̂悤�Ȍ^�����Ă��܂��B
%
%       | Ano   A12|           |Bno|
% Abar =  ----------  ,  Bbar =  ---  ,  Cbar = [ 0 | Co].
%       |  0    Ao |           |Bo |
%                                                        
% �����ŁA(Ao,Bo) �͉���ŁA���̊֌W�����藧���܂��B
%          -1          -1
% Co(sI-Ao) Bo = C(sI-A) B
% 
% �ŐV�̏o�� K �́A�A���S���Y���̊e�J��Ԃ��Ŏ��ʂ����ϑ��ȏ�Ԃ̐�
% ��v�f�Ƃ������� n �̃x�N�g���ł��B�ϑ��ȏ�Ԑ��́ASUM(K) �ł��B
%
% �Q�l�F    OBSV, CTRBF.


%   Author : R.Y. Chiang  3-21-86
%   Revised 5-27-86 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:37 $
