% BRUSSODE   ���w�����̃��f�����O�̃X�e�B�b�t�Ȗ��(the Brusselator).
% 
% �p�����[�^N > =  2���g���āA�O���b�h�_�̐����w�肵�܂��B���ʂ̃V�X�e��
% �̌��ʂ́A2N�̕������ō\������܂��B�f�t�H���g�ł́AN��20 �ł��BN��
% ��������ƁA���̓X�e�B�b�t�A���X�p�[�X�x�͍����Ȃ�܂��B���̖���
% ���R�r�A���́A�X�p�[�X�萔�s��ł�(�ш��5�ł�)�B
%   
% �v���p�e�B 'JPattern' �́AJacobian df/dy �̒��̔�[���̈ʒu�������A0��
% 1����\�������X�p�[�X�s����g�����\���o��^���邽�߂Ɏg�����̂ł��B
% �f�t�H���g�ł́AODE Suite �̃X�e�B�t�ȃ\���o�́A�t���s��Ɠ����悤��
% ���l�I�� Jacobian ���쐬���܂��B�������A�X�p�[�X���������p�^�[�����^��
% ��ꂽ�ꍇ�A�\���o�͂�����g���āA�X�p�[�X�s��Ƃ��Đ��l�I�� 
% Jacobian ���쐬���܂��B�X�p�[�X�p�^�[����^���邱�Ƃ́AJacobian ���쐬
% ���邽�߂ɕK�v�Ȋ֐��l�̎Z�o�񐔂���Ɍ��炵�A�ϕ��𑬂����邱�Ƃɂ�
% ��܂��BBRUSSODE ���ɑ΂��āA2N �s 2N ���Jacobian �s����v�Z����
% ���邽�߂ɁA4��̊֐��̎��s���K�v�ł��B
%   
% 'Vectorized' �v���p�e�B��ݒ肷�邱�Ƃ́A�֐� f ���x�N�g��������Ă���
% ���Ƃ������Ă��܂��B
%   
% E. Hairer and G. Wanner, Solving Ordinary Differential Equations II,
% Stiff and Differential-Algebraic Problems, Springer-Verlag, Berlin,
% 1991, pp. 5-8.
%   
% �Q�l�FODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.

