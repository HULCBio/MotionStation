% DLQE   ���U���ԃV�X�e���ɑ΂��� Kalman �����̐݌v
%
% ���̃V�X�e�����l���܂��B
%
%   x[n+1] = Ax[n] + Bu[n] + Gw[n]    {��ԕ�����}
%   y[n]   = Cx[n] + Du[n] +  v[n]    {���������}
%
% ���̃V�X�e���́A�o�C�A�X��K�p���Ă��Ȃ��v���Z�X�m�C�Y w[k] �Ƒ���
% �m�C�Y v[k] �������Ă��܂��B�����ł̋����U�́A���̂悤�ɕ\���܂��B
%
%   E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
% [M,P,Z,E] = DLQE(A,G,C,Q,R) �́Ay[n] �Ɖߋ��̑����^���āA�ϑ�������
% �ƍX�V������
%
%   x[n|n]   = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%   x[n+1|n] = Ax[n|n] + Bu[n] 
% 
% �������U�A��� Kalman �t�B���^�́Ax[n] �̍œK��Ԑ��� x[n|n]���쐬
% ����Q�C���s�� M ���o�͂��܂��B���ʂ� Kalman �����́ADESTIM ���g����
% �쐬�ł��܂��B
%
% �܂��A�o�͂������̂́A����Ԍ덷�����U
%
%   P = E{(x[n|n-1] - x)(x[n|n-1] - x)'}     (Riccati �������̉�)
%   Z = E{(x[n|n] - x)(x[n|n] - x)'}         (�덷�̋����U)
%
% �Ɛ����̋� E = EIG(A-A*M*C) �ł��B
%
% �Q�l : DLQEW, LQED, DESTIM, KALMAN, DARE.


%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet, 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:46 $
