% LQE   �A�����ԃV�X�e���ɑ΂��� Kalman �����
%
% ���̃V�X�e�����l���܂��B
%    .
%    x = Ax + Bu + Gw            {��ԕ�����}
%    y = Cx + Du + v             {���������}
%
% ���̃V�X�e���́A�o�C�A�X��K�p���Ă��Ȃ��v���Z�X�m�C�Y w �Ƒ���m�C�Y 
% v �������Ă��܂��B�����ł̋����U�́A���̂悤�ɕ\���܂��B
%
%    E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
% [L,P,E] = LQE(A,G,C,Q,R,N) �́A�Z���T���� y ���g���āAx �̍œK��Ԑ��� 
% x_e ���A��� Kalman �t�B���^
%    .
%    x_e = Ax_e + Bu + L(y - Cx_e - Du)
%
% ���g���āA�ϑ��Q�C���s�� L ���o�͂��܂��B���ʂ� Kalman �����́AESTIM 
% ���g���č쐬�ł��܂��B
%
% �m�C�Y�̑��ݑ��� N �́A�ȗ������0�ɐݒ肳��܂��B�܂��A�֘A���� Riccati 
% ������
%                         -1
%    AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 
%
% �̉� P �Ɛ����̋� E = EIG(A-L*C) ���o�͂��܂��B
%
% �Q�l : LQEW, DLQE, LQGREG, CARE, ESTIM.


%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:06 $
