% SURFL   ���C�e�B���O�ɂ��3�����̃V�F�[�f�B���O�T�[�t�F�X
% 
% SURFL(...) �́A�������狭�����ăT�[�t�F�X��`�悷�邱�Ƃ������΁A
% SURF(...) �Ɠ����ł�
%
% SURFL(Z)�ASURFL(X,Y,Z)�ASURFL(Z,S)�ASURFL(X,Y,Z,S )�́A���ׂĐ�����
% �V���^�b�N�X�ł��BS ���w�肳��Ă���΁AS �͌����̕�����ݒ肷��3��
% �̃x�N�g�� S = [Sx,Sy,Sz] �ł��BS �́A���_�̍��W S = [AZ,EL] �ɂ����
% ���ݒ肳��܂��B
%
% SURFL(...,'light') �́ALIGHT�I�u�W�F�N�g���g���ĐF�t������A���C�e�B��
% �O���ꂽ�T�[�t�F�X���쐬���܂��B����́A�f�t�H���g�̃��C�e�B���O��
% ���@ SURFL(...,'cdata') �Ƃ͈قȂ錋�ʂ��o�͂��܂��BSURFL(...,'cdata') 
% �́A�T�[�t�F�X�̔��˂ƂȂ�悤�ɁA�T�[�t�F�X�ɑ΂���J���[�f�[�^��ύX
% ���܂��B
%
% H = SURFL(...) �́A�T�[�t�F�X�ƃ��C�g�̃n���h���ԍ����o�͂��܂��B
%
% �V�F�[�f�B���O�́A�g�U���A���ʌ��A���͌����f���̑g���킹�Ɋ�Â���
% ���܂��B
%
% S �̃f�t�H���g�l�́A�J�����g�̎��_�̕�������45�������ł��B���_��
% ������ (AZ,EL) �ł��郉�C�e�B���O���ꂽ�T�[�t�F�X���v���b�g����ɂ́A
% CLA�AHOLD ON�AVIEW(AZ,EL)�ASURFL(...)�AHOLD OFF ���g���Ă��������B
%
% ���͌��A�g�U���ˁA���ʔ��ˁA���ʓ`�d�W���ɂ�鑊�ΓI�ȗʂ́A
% K = [ka,kd,ks,spread] �̂Ƃ��A5�̈��� SURFL(X,Y,Z,S,K) �ɂ���Đݒ�
% ����܂��B
%
% �p�����g���b�N�T�[�t�F�X�̓����ƊO�����`���邽�߂ɂ́AX�AY�AZ �s���
% �̓_�̏����ɏ]���Ă��������B���̊֐��̌��ʂ��C�ɓ���Ȃ��ꍇ�́A
% SURFL(X',Y',Z') �����s���Ă��������B�T�[�t�F�X�̖@���x�N�g�����v�Z
% �������@�ɂ����āASURFL �ł͏��Ȃ��Ƃ�3�s3��̍s�񂪕K�v�ł��B
%
% �Q�l�FSURF, SHADING.


%   Clay M. Thompson 4-24-91, 6-5-96
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:17 $
