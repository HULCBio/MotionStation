% FEM1ODE   ���ώ��ʍs�� M(t)*y' = f(t,y) �����X�e�B�b�t�Ȗ��
% 
% �p�����[�^N�͗��U���𐧌䂵�A���ʂ̃V�X�e���́AN�̕������ō\�������
% ���B�f�t�H���g�ł́AN��19�ł��B  
%
% ���̗��ŁA�T�u�֐� f(Y,Y,N) �́A�Δ����������̗L���v�f�̗��U���p�̔�
% �W���x�N�g�����o�͂��܂��B�T�u�֐� mass(T,N) �́A���� T �ŕ]�����鎞��
% �̎��ʍs�� M ���o�͂��܂��B�f�t�H���g�ł́AODE Suite �̃\���o�́Ay' = 
% f(t,y) �̌^�̃V�X�e���������܂��B�V�X�e�� M(t)y' = f(t,y) ���������߂ɁA
% ODESET ���g���āA�v���p�e�B 'Mass' ���֐��ɐݒ肵�AM(t) ���v�Z���邽��
% �ɁA'MStateDepencence'��'none'��ݒ肵�܂��B
%   
% ���̖��ŁAJacobian df/dy �͒萔�ŁA�O�d�Ίp�s��ɂȂ�܂��B'Jacobian' 
% �v���p�e�B�́Adf/dy ���\���o�ɗ^���܂��B
%
% �Q�l�FODE15S, ODE23T, ODE23TB, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 11-11-94.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:48:32 $
