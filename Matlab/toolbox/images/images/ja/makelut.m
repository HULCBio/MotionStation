% MAKELUT   �֐� APPLYLUT �Ŏg�p���郋�b�N�A�b�v�e�[�u�����쐬
%   LUT = MAKELUT(FUN,N) �́A�֐� APPLYLUT �Ŏg�p���郋�b�N�A�b�v�e�[
%   �u�����o�͂��܂��BFUN �́A���͂Ƃ���1��0����\�������2�s2��A�܂�
%   �́A3�s3��̍s����󂯓���A�X�J�����o�͂���֐��ł��BN �́A2�A��
%   ���́A3�̂ǂ��炩�ł��BMAKELUT �́A2�s2��A�܂��́A3�s3��̋ߖT�� 
%   FUN �ɓn���āALUT ���쐬���A��x��16�v�f�i2�s2��̋ߖT�j�܂��́A
%   512�v�f�i3�s3��̋ߖT�j�x�N�g�����쐬���܂��B�x�N�g���́A�e�\��
%   �ߖT�ɑ΂��AFUN ����̏o�͂��g���܂��B
%
%   LUT = MAKELUT(FUN,N,P1,P2,...) �́A�t���I�ȃp�����[�^ P1,P2,... ��
%   FUN �ɓ]�����܂��B
%
%   FUN �́A@ ���g���č쐬����� FUNCTION_HANDLE ���A�܂��́AINLINE �I
%   �u�W�F�N�g�ł��B
%
%   �N���X�T�|�[�g
% -------------
%   LUT �́A�N���X double �̃x�N�g���Ƃ��ďo�͂���܂��B
%
%   ���
%   ----
%       f = inline('sum(x(:)) >= 2');
%       lut = makelut(f,2);
%
%   �Q�l�FAPPLYLUT, FUNCTION_HANDLE, INLINE



%   Copyright 1993-2002 The MathWorks, Inc.  
