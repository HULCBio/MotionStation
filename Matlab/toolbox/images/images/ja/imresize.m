% IMRESIZE   �C���[�W�̃��T�C�Y
%
% IMRESIZE �́A�ݒ肵�����}�@���g���āA�C�ӂ̃^�C�v�̃C���[�W�����T�C�Y
% ���܂��B�T�|�[�g������}�@�́A���̒ʂ�ł��B
%
%        'nearest'  (�f�t�H���g) �ŋߖT�@
%
%        'bilinear'              Bilinear �@
%
%        'bicubic'               Bicubic �@
%
% B = IMRESIZE(A,M,METHOD) �́AA �̑傫���� M �{�����C���[�W���o�͂�
% �܂��BM ��0��1.0�̊Ԃ̒l�ł���ꍇ�AB �́AA �����������Ȃ�܂��B
% M ���A1.0�����傫���ꍇ�AB �́AA ���傫���Ȃ�܂��BMETHOD ����
% ������ƁAIMRESIZE �́A�ŋߖT�@���g�p���܂��B
%
% B = IMRESIZE(A,[MROWS MCOLS],METHOD) �́A�傫�� MROWS �s MCOLS ��
% �̃C���[�W���o�͂��܂��B�ݒ肵���T�C�Y�����̓C���[�W�̂��c�����
% ���������ɂȂ�Ȃ��ꍇ�A�o�̓C���[�W�͘c�݂܂��B
%
% �ݒ肵���o�͂̑傫�����A���̓C���[�W�̃T�C�Y�����������AMETHOD 
% ���A'bilinear'�A�܂��́A'bicubic' ���g���ꍇ�AIMRESIZE �́A�G���A
% �W���O������邽�ߓ��}����O�Ƀ��[�p�X�t�B���^��K�p���܂��B�f�t�H
% ���g�̃t�B���^�T�C�Y�́A11�s11��ł��B
%
% ���̃X�e�[�g�����g���g���āA�f�t�H���g�̃t�B���^�T�C�Y��ύX����
% ���Ƃ��ł��܂��B
%
%        [...] = IMRESIZE(...,METHOD,N)
%
% N �́A�t�B���^�̃T�C�Y N �s N ���ݒ肷�鐮���̃X�J���l�ł��BN ��
% 0�̏ꍇ�AIMRESIZE �̓t�B���^�����O�̃X�e�b�v���ȗ����܂��B
%
% ���̃X�e�[�g�����g���g���āA���[�U���g�̃t�B���^H��ݒ肷�邱��
% ���ł��܂��B
%
%        [...] = IMRESIZE(...,METHOD,H)
%
% H �́A�C�ӂ�(FTRANS2,FWIND1,FWIND2,FSAMP2 �ŏo�͂����悤��)2����
% FIR �t�B���^�ł��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W A �́A���l�܂��� logical �ŁA��X�p�[�X�łȂ���΂Ȃ�
% �܂���B�o�̓C���[�W�́A���̓C���[�W�Ɠ����N���X�ł��B
%
%   �Q�l�FIMROTATE, IMTRANSFORM, TFORMARRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
