% CSVREAD   �J���}�ŋ�؂�ꂽ�l�̃t�@�C���̓ǂݍ���
% 
% M = CSVREAD('FILENAME') �́A�J���}�ŋ�؂�ꂽ�l�ŏ��������ꂽ�t�@�C��
% FILENAME��ǂݍ��݂܂��B���ʂ́AM �ɏo�͂���܂��B�t�@�C���́A���l�̂�
% ���܂ނ��̂ł��B
%
% M = CSVREAD('FILENAME',R,C) �́A�J���}�ŋ�؂�ꂽ�l�ŏ��������ꂽ�t�@
% �C���̍s R �Ɨ� C ����f�[�^��ǂݍ��݂܂��BR �� C �́A�[������Ƃ���
% ����̂ŁAR = 0 �� C = 0 �̓t�@�C�����̍ŏ��̒l���w�肵�܂��B
%
% M = CSVREAD('FILENAME',R,C,RNG) �́A(R1,C1) ���ǂݍ��܂��f�[�^��
% ������ŁA(R2,C2) ���E�����̂Ƃ��ARNG = [R1 C1 R2 C2] �Ŏw�肳���
% �͈݂͂̂�ǂݍ��݂܂��BRNG �́ARNG = 'A1..B7' �̂悤�ȃX�v���b�h�V�[�g
% �̎w��@���g���Ă��w��ł��܂��B
%
% CSVREAD �́A��̃f���~�^�t�B�[���h��0�ɐݒ肵�܂��B�J���}�Ń��C�����I��
% ���Ă���f�[�^�t�@�C���́A���ׂĂ̗v�f���[���Őݒ肵������ŏI��ɒǉ�
% �������ʂ��쐬���܂��B
%
% �Q�l�FCSVWRITE, DLMREAD, DLMWRITE, LOAD, FILEFORMATS


%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:57:57 $
