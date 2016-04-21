% AIRY   Airy�֐�
% 
% W = AIRY(Z) �́AZ �̗v�f��Airy�֐� Ai(z) �ł��B
% W = AIRY(0,Z) �́AAIRY(Z) �Ɠ����ł��B
% W = AIRY(1,Z) �́A���W�� Ai'(z) �ł��B
% W = AIRY(2,Z) �́A��2��Airy�֐� Bi(z) �ł��B
% W = AIRY(3,Z) �́A���W�� Bi'(z) �ł��B
% ���� Z ���z��̏ꍇ�́A���ʂ͓����T�C�Y�ɂȂ�܂��B
%
% [W,IERR] = AIRY(K,Z) �́A�G���[�t���O�̔z����o�͂��܂��B
%     ierr = 1   �������Ԉ���Ă��܂��B
%     ierr = 2   �I�[�o�t���[��Inf���o�͂��܂��B
%     ierr = 3   ���������炷���Ƃɂ��A���x���ቺ���܂��B
%     ierr = 4   z���傫�߂��邱�Ƃɂ��A���x���ቺ���܂��B
%     ierr = 5   �������܂���BNaN���o�͂��܂��B
%
% Airy�֐��ƏC��Bessel�֐��̊֌W�́A���̂悤�ɂȂ�܂��B
%
%     Ai(z) = 1/pi*sqrt(z/3)*K_1/3(zeta)
%     Bi(z) = sqrt(z/3)*(I_-1/3(zeta)+I_1/3(zeta))
%     �����ŁAzeta = 2/3*z^(3/2) �ł��B
%
% ����M-�t�@�C���́AD. E. Amos�ɂ��Fortran���C�u�����ւ�MEX�C���^
% �t�F�[�X���g�p���܂��B
%
% �Q�l�FBESSELJ, BESSELY, BESSELI, BESSELK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:49 $
