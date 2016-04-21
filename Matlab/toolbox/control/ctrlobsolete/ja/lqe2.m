% LQE2   ���`�񎟐�����݌v
%
% �A�����ԃV�X�e���ɑ΂��āA
%    .
%    x = Ax + Bu + Gw            {��ԕ�����}
%    z = Cx + Du + v             {���������}
% 
% ���̃v���Z�X�m�C�Y�Ƒ���m�C�Y�����U�����Ƃ��܂��B
% 
%    E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R, E{wv'} = 0
%
% L = LQE2(A,G,C,Q,R) �́A�Q�C���s�� L ���o�͂��A��������ƂɁA��� 
% Kalman �t�B���^
% 
%    x = Ax + Bu + L(z - Cx - Du)
% 
% ���Ax �� LQG �̍œK������s���܂��B�����́AESTIM ���g���č쐬���܂��B
%
% [L,P] = LQE2(A,G,C,Q,R) �́A�Q�C���s�� L �� ����덷�����U�ɂȂ� Riccati 
% �������̉� P ���o�͂��܂��B
%
% [L,P] = LQE2(A,G,C,Q,R,N) �́A�v���Z�X�m�C�Y�ƃZ���T�m�C�Y�����ւ����� 
% E{wv'} = N �ꍇ�A�������ɂȂ�܂��B
%
% LQE2 �́ASCHUR �A���S���Y�����g���A�ŗL�l�������g���� LQE ���A���l�I��
% �M���x���������̂ł��B
%
% �Q�l : LQEW, LQE, ESTIM.


%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:07 $
