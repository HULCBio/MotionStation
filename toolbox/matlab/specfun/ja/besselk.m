% BESSELK   ��2��C��Bessel�֐�
% 
% K = BESSELK(NU,Z) �́A��2��̏C��Bessel�֐� K_nu(Z) �ł��B���� NU
% �́A�����ł���K�v�͂���܂��񂪁A�����łȂ���΂Ȃ�܂���B���� Z �́A
% ���f���ł��\���܂���BZ �����̂Ƃ��A���ʂ͎����ɂȂ�܂��B
%
% Nu �� Z �������傫���̔z��̏ꍇ�́A���ʂ̔z��������傫���ɂȂ�܂��B
% �����ꂩ�̓��͂��X�J���̏ꍇ�́A��������̓��͂̃T�C�Y�Ɠ����傫����
% �g������܂��B1�̓��͂��s�x�N�g���ŁA���̓��͂���x�N�g���̏ꍇ�A
% ���ʂ͊֐��l����Ȃ�2�����̃e�[�u���ɂȂ�܂��B
%
% K = BESSELK(NU,Z,1) �́Aexp(-abs(real(z))) �� K_nu(z) ���X�P�[�����O
% ���܂��B
%
% [K,IERR] = BESSELK(NU,Z) �́A�G���[�t���O�̔z����o�͂��܂��B
%     ierr = 1   �������Ԉ���Ă��܂��B
%     ierr = 2   �I�[�o�t���[��Inf���o�͂��܂��B
%     ierr = 3   ���������炷���Ƃɂ��A���x���ቺ���܂��B
%     ierr = 4   z�܂���NU���傫�߂��邱�Ƃɂ��A���x���ቺ���܂��B
%     ierr = 5   �������܂���BNaN���o�͂��܂��B
%
% ���:
%
% besselk(3:9,(0:.2:10)',1)�́AAbramowitz �� Stegun�̒�"Handbook of 
% Mathematical Functions"��424�y�[�W�ɋL����Ă���\���쐬���܂��B
%
% ����M-�t�@�C���́AD. E. Amos�ɂ��Fortran���C�u������MEX�C���^�t�F�[�X
% ���g�p���܂��B
%
% �Q�l�FBESSELJ, BESSELY, BESSELI, BESSELH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:55 $
