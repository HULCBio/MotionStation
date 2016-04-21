% KALMAN   �A���܂��͗��U�� Kalman �������v�Z
%
%  ���U���� Kalman �����
%  ----------------------
%
% [KEST,L,P,M,Z] = KALMAN(SYS,QN,RN,NN) �́ALTI �v�����g SYS �����U��
% �ꍇ�A���U Kalman ����� KEST ���쐬���܂��B���̃v�����g���l���܂��B
%
%   x[n+1] = Ax[n] + Bu[n] + Gw[n]           {��ԕ�����}
%   y[n]   = Cx[n] + Du[n] + Hw[n] + v[n]    {�ϑ�������}
%
% �����ŁAu �͊��m���́Aw �̓v���Z�X�m�C�Y�Av �͑���m�C�Y�ŁA�m�C�Y��
% �����U
%
%   E{ww'} = QN,     E{vv'} = RN,     E{wv'} = NN
% 
% ���g���āA���̌��ʂ� Kalman �����
%
%   x[n+1|n] = Ax[n|n-1] + Bu[n] + L(y[n] - Cx[n|n-1] - Du[n])
%
%    y[n|n]  = Cx[n|n] + Du[n]
%    x[n|n]  = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%
% ���A���͂Ƃ��āAu[n] �� y[u]���g��(���̏��Őݒ�)�A�œK�o�� y[n|n] ��
% �œK��� x[n|n] ���쐬���܂��B������� x[n|n-1] �́A�ߋ��̑���l 
% y[n-1], y[n-2],...��^���āAx[n] �̍œK������s���܂��B
%
% �܂��A�����̃Q�C�� L �ƃC�m�x�[�V�����Q�C�� M �Ƃ��̒����
% �덷�̋����U���o�͂��܂��B
%
%    P = E{(x - x[n|n-1])(x - x[n|n-1])'}   (Riccati �������̉�)
%    Z = E{(x - x[n|n])(x - x[n|n])'}       (�X�V���ꂽ����l)


%   Author(s): P. Gahinet  8-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:02 $
