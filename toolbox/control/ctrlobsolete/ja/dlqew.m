% DLQEW   �v���Z�X�m�C�Y�̒��B���������U���ԃV�X�e���ɑ΂��� Kalman �����
%
% ���̃V�X�e�����l���܂��B
%
%   x[k+1] = Ax[k] + Bu[k] + Gw[k]           {��ԕ�����}
%   y[k]   = Cx[k] + Du[k] + Hw[k] + v[k]    {���������}
%
% ���̃V�X�e���́A�o�C�A�X��K�p���Ă��Ȃ��v���Z�X�m�C�Y w[k] �Ƒ���m�C�Y 
% v[k] �������Ă��܂��B�����ł̋����U�́A���̂悤�ɕ\���܂��B
%
%   E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
% [M,P,Z,E] = DLQEW(A,G,C,H,Q,R) �́Ay[k] �Ɖߋ��̑����^���āA�ϑ�������
% �ƍX�V������
%
%   x[k|k]   = x[k|k-1] + M(y[k] - Cx[k|k-1] - Du[k])
%   x[k+1|k] = Ax[k|k] + Bu[k] 
%
% �������U�A��� Kalman �t�B���^�́Ax[k] �̍œK��Ԑ��� x[k|k]���쐬����
% �Q�C���s�� M ���o�͂��܂��B���ʂ� Kalman �����́ADESTIM ���g���č쐬
% �ł��܂��B
%
% �܂��A�o�͂������̂́A����Ԍ덷�����U
%
%   P = E{(x[k|k-1] - x)(x[k|k-1] - x)'}     (Riccati �������̉�)
%   Z = E{(x[k|k] - x)(x[k|k] - x)'}         (�덷�̋����U)
%
% �Ɛ����̋� E = EIG(A-A*M*C) �ł��B
%
% �Q�l : DLQE, LQED, DESTIM, KALMAN, DARE.


%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet 7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:47 $
