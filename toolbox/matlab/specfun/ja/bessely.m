% BESSELY   ��2��Bessel�֐�
% 
% Y = BESSELY(NU,Z) �́A��2��Bessel�֐� Y_nu(Z) �ł��B���� NU �́A����
% �ł���K�v�͂���܂��񂪁A�����łȂ���΂Ȃ�܂���B���� Z �́A���f��
% �ł��\���܂���BZ �����̂Ƃ��A���ʂ͎����ɂȂ�܂��B
%
% NU �� Z �������傫���̔z��̏ꍇ�́A���ʂ̔z��������傫���ɂȂ�܂��B
% �����ꂩ�̓��͂��X�J���̏ꍇ�́A��������̓��͂̃T�C�Y�Ɠ����傫����
% �g������܂��B1�̓��͂��s�x�N�g���ŁA���̓��͂���x�N�g���̏ꍇ�A
% ���ʂ́A�֐��l����Ȃ�2�����̃e�[�u���ɂȂ�܂��B
%
% Y = BESSELY(NU,Z,1) �́Aexp(-abs(imag(z))) �� Y_nu(z) ���X�P�[�����O
% ���܂��B
%
% [Y,IERR] = BESSELY(NU,Z) �́A�G���[�t���O�̔z����o�͂��܂��B
%     ierr = 1   �������Ԉ���Ă��܂��B
%     ierr = 2   �I�[�o�t���[��Inf���o�͂��܂��B
%     ierr = 3   ���������炷���Ƃɂ��A���x���ቺ���܂��B
%     ierr = 4   z�܂���NU���傫�߂��邱�Ƃɂ��A���x���ቺ���܂��B
%     ierr = 5   �������܂���BNaN���o�͂��܂��B
%
% ���:
%
% bessely(3:9,(0:.2:10)')�́AAbramowitz �� Stegun�̒�"Handbook of 
% Mathematical Functions"��399�y�[�W�ɋL����Ă���\���쐬���܂��B
%
% ����M-�t�@�C���́AD. E. Amos�ɂ��Fortran���C�u������MEX�C���^�t�F�[�X
% ���g�p���܂��B
%
% �Q�l�FBESSELJ, BESSELI, BESSELK, BESSELH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:56 $
