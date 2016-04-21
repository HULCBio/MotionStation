% LQEW   �v���Z�X�m�C�Y�̒��B�������A�����ԃV�X�e���ɑ΂���Kalman�����
%
% ���̃V�X�e�����l���܂��B
% 
%    .
%    x = Ax + Bu + Gw        {��ԕ�����}
%    y = Cx + Du + Hw + v    {���������}
%
% ���̃V�X�e���́A�o�C�A�X��K�p���Ă��Ȃ��v���Z�X�m�C�Y w�Ƒ���m�C�Y v
% �������Ă��܂��B�����ł̋����U�́A���̂悤�ɕ\���܂��B
%
%    E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
% [L,P,E] = LQEW(A,G,C,H,Q,R,N) �́A�Z���T���� y ���g���āAx �̍œK���
% ���� x_e ���A��� Kalman �t�B���^
%    .
%    x_e = Ax_e + Bu + L(y - Cx_e - Du)
%
% ���g���āA�ϑ��Q�C���s�� L ���o�͂��܂��B���ʂ� Kalman �����́AESTIM
% ���g���č쐬�ł��܂��B
% 
% �m�C�Y�̑��ݑ��� N �́A�ȗ������0�ɐݒ肳��܂��B�܂��A�֘A����Riccati
% ������
%                         -1
%    AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 
%
% �̉� P �Ɛ����̋� E = EIG(A-L*C) ���o�͂��܂��B
%
% �Q�l : LQE, DLQEW, LQGREG, CARE, ESTIM.


%   Clay M. Thompson  7-23-90
%   Revised  P. Gahinet,  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:09 $
