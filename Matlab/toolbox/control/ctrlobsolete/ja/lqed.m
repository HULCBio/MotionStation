% LQED   �A�����ԕ]���֐����痣�U���� Kalman �����
%
% [M,P,Z,E] = LQED(A,G,C,Q,R,Ts) �́A���̂悤�ȃv���Z�X�m�C�Y�Ƒ���
% �m�C�Y
% 
%   E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R,  E{wv'} = 0
% 
% �����A�����ԃV�X�e��
% 
%         .
%         x = Ax + Bu + Gw    {��ԕ�����}
%         y = Cx + Du +  v    {���������}
%
% �ɑ΂��āA����덷�Ɠ����ȗ��U����덷���ŏ��ɂ��闣�U Kalman �Q�C��
% �s�� M ���v�Z���܂��B�܂��A���U�� Riccati �������̉� P�A����덷��
% �����U Z�A���U�̐����̋� E = EIG(Ad-Ad*M+C) ���o�͂��܂��B���ʂ�
% ���U�� Kalman �����́ADESTIM ���g���č쐬���܂��B
%
% �A���v�����g (A,B,C,D) �ƘA�������U�s�� (Q,R) �́A�T���v������ Ts ��
% �[�����z�[���h�ߎ����g���āA���U������܂��B�Q�C���s�� M �́ADLQE ��
% �g���Čv�Z����܂��B
%
% �Q�l : DLQE, LQE, LQRD, DESTIM.


%   Clay M. Thompson 7-18-90
%   Revised: P. Gahinet  7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:08:08 $
