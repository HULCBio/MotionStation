% IMSLICE   �C���f�b�N�X�̃C���[�W�f�b�L�ւ̏o��
%   ELEM = IMSLICE([M N P],K) �́A�C���[�W�X���C�X K �̗v�f���� 
%   M x N x P �C���[�W�f�b�L�ɏo�͂��܂��BIMSLICE �́A�C���[�W�f�b�L��
%   ��C���[�W�𒊏o������A�C���[�W�f�b�L�ɑ}�������肵�܂��B���Ƃ�
%   �΁A
%       D(imslice([m n p],2)) = A;
%   �́A�C���[�W A ���f�b�L D �̃C���[�W�X���C�X2�ɑ}�����܂��B���l
%   �ɁA
%       A = D(imslice([m n p],3));
%   �́A�f�b�L D ����C���[�W�X���C�X3�𒊏o���܂��BK ���x�N�g���̏ꍇ
%   �ɂ́A��x�ɕ����̃C���[�W�𒊏o���邱�Ƃ��ł��܂��B���Ƃ��΁A
%       DNEW = D(imslice([m n p],3:5));
%   �́A�f�b�L D ����3�̃C���[�W�𒊏o���A�f�b�L DNEW ���쐬���܂��B
%
%   [A1,A2,A2] ���g���ƁA3�̃C���[�W�iA1,A2,A3�j���܂ރC���[�W�f�b�L
%   ���쐬���邱�Ƃ��ł��܂��B
%   
%   ����: �C���[�W�f�b�L�͍폜����܂��B����� MATLAB ��3�����z��@
%         �\���g�����Ƃ����[�U�ɐ������܂�
%
%   ���
%   ----
%   ���̃R�}���h���g���āA�T�C�Y�x�N�g�� SIZ �����C���[�W�f�b�L D 
%   ��3�����z��֕ϊ����܂��B
%
%        D2 = reshape(D,SIZ);



%   Copyright 1993-2002 The MathWorks, Inc.  
