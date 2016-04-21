% BESSELH   ��3���Bessel�֐�(Hankel�֐�)
% 
% K = 1�܂���2�ɑ΂��āAH = BESSELH(NU,K,Z) �́A���f�z�� Z �̊e�v�f��
% �΂��āAHankel �֐� H1_nu(Z) �܂��� H2_nu(Z) ���v�Z���܂��B
%
% H = BESSELH(NU,Z) �́AK = 1 ���g���܂��B
% H = BESSELH(NU,1,Z,1) �́Aexp(-i*z) �� H1_nu(z) ���X�P�[�����O���܂��B
% H = BESSELH(NU,2,Z,1) �́Aexp(+i*z) ��H2_nu(z) ���X�P�[�����O���܂��B
%
% NU �� Z �������傫���̔z��̏ꍇ�́A���ʂ̔z��������傫���ɂȂ�܂��B
% �ǂ��炩�̓��͂��X�J���̏ꍇ�́A��������̓��͂̃T�C�Y�Ɠ����傫����
% �g������܂��B1�̓��͂��s�x�N�g���ŁA���̓��͂���x�N�g���̏ꍇ�A
% ���ʂ́A�֐��l����Ȃ�2�����̃e�[�u���ɂȂ�܂��B
%
% [H,IERR] = BESSELH(NU,K,Z) �́A�G���[�t���O�̔z����o�͂��܂��B
%     ierr = 1   �������Ԉ���Ă��܂��B
%     ierr = 2   �I�[�o�t���[�� Inf���o�͂��܂��B
%     ierr = 3   ���������炷���Ƃɂ��A���x���ቺ���܂��B
%     ierr = 4   z�܂���NU���傫�߂��邱�Ƃɂ��A���x���ቺ���܂��B
%     ierr = 5   �������܂���BNaN���o�͂��܂��B
%
% Hankel�֐���Bessel�֐��̊֌W�́A���̂悤�ɂȂ�܂��B
%
%     besselh(nu,1,z) = besselj(nu,z) + i*bessely(nu,z)
%     besselh(nu,2,z) = besselj(nu,z) - i*bessely(nu,z)
%
% ���:
% ���̗�́AAbramowitz �� Stegun��"Handbook of Mathematical Functions"
% ��359�y�[�W�ɋL����Ă���AHankel�֐�H1_0(z)�̃��W�����X�ƈʑ��̃R��
% �^�[�v���b�g���쐬���܂��B
%
%     [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%     H = besselh(0,1,X+i*Y);
%     contour(X,Y,abs(H),0:0.2:3.2)�Ahold on
%     contour(X,Y,(180/pi)*angle(H),-180:10:180); hold off
%
% ����M-�t�@�C���́AD. E. Amos�ɂ��Fortran���C�u������MEX�C���^�t�F�[�X
% ���g�p���܂��B
%
% �Q�l�FBESSELJ, BESSELY, BESSELI, BESSELK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:52 $
