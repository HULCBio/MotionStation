% DREG   ���U��LQG �R���g���[��
%
% [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L) �́A���U�V�X�e��(A, B, C, D)���x�[�X�ɁA
% �t�B�[�h�o�b�N�Q�C���s�� K�AKalman �Q�C���s�� L ���g���āA�V�X�e�����͂�
% ������́A�V�X�e���̂��ׂĂ̏o�͂́A�Z���T�o�͂ł���Ƃ̉���̂��ƂŁA
% LQG �R���g���[�����쐬���܂��B���ʂ̏�ԋ�ԃR���g���[���́A���̂悤��
% �Ȃ�܂��B
%
%   xBar[n+1] = [A-ALC-(B-ALD)E(K-KLC)] xBar[n] + [AL-(B-ALD)EKL] y[n]
%   uHat[n]   = [K-KLC+KLDE(K-KLC)]     xBar[n] + [KL+KLDEKL]     y[n]
%
% �����ŁAE = inv(I+KLD) �ŁA���͂Ƃ��ăZ���T y �A�o�͂Ƃ��Đ���t�B�[�h
% �o�b�N�w�� uhat �ł��B�R���g���[���́A���̃t�B�[�h�o�b�N���g���āA
% �v�����g�Ɍ������܂��B
% 
% [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L,SENSORS,KNOWN,CONTROLS) �́ASENSORS ��
% �ݒ肳���Z���T�AKNOWN �Őݒ肳���t�����m���́ACONTROLS �Őݒ肳���
% ������͂��g���āALQG �R���g���[�����쐬���܂��B���ʂ̃V�X�e���́A����
% �t�B�[�h�o�b�N�w�߂��o�͂Ƃ��A���m���͂ƃZ���T����͂Ƃ��܂��BKNOWN 
% ���͂́A�v�����g�̔�m���I�ȓ��͂ŁA�ʏ�A�t���I�Ȑ�����͂܂��͎w��
% ���͂ł��B
%
% �Q�l : DESTIM, DLQR, DLQE, REG.


%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:54 $
