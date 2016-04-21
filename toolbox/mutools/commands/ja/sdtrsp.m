%function [v,y,u] = sdtrsp(sys,K,input,h,tfinal,int,x0,z0,texthan)
%
% �T���v���l�f�[�^�t�B�[�h�o�b�N���݌����̎��ԉ������v�Z���܂��B����́A
% �@�\�I�ɁA���̃X�e�[�g�����g�Ɠ����ł��B
%
%  v = starp(sys,K) * input
%
% �����ŁASYS�͘A�����ԃv�����g�ŁAK�͗��U���ԃR���g���[���ł��BY�̓R��
% �g���[���ւ̓��͂ŁAU�̓R���g���[���o�͂ł��B���̓��͂́A���̂悤��
% �Ȃ�܂��B
%
%   SYS    : �A���n�v�����g(SYSTEM�܂���CONSTANT)
%   K      : ���U���ԃR���g���[��(SYSTEM�܂���CONSTANT)
%   INPUT  : VARYING���̓x�N�g���܂��͒萔
%   H      : ���U�n�R���g���[���̃T���v�����O����
%   TFINA L: �ŏI���Ԃ̒l(�I�v�V�����A�f�t�H���g = ���͂̍ŏI����)
%   INT    : �ϕ��X�e�b�v(�I�v�V�����A�f�t�H���g�ł͓��͂�SYS�Ɋ�Â���
%            �肳��܂��BSDTRSP���I�������Ԃ́A���΂��Δ��ɏ������A
%            �v�Z�Ɏ��Ԃ�v����ꍇ������̂ŁA���[�U�����̈�����ݒ肷
%            �邱�Ƃ𐄏����܂�)�B
%	     �v���O�����́A1�ȏ�̐���n�ɂ��āAint = h/n�Ƃ��܂��B
%   X0     : �A���n�v�����g�̏������(�I�v�V�����A�f�t�H���g = 0)
%   Z0     : ���U�n�R���g���[���̏������(�I�v�V�����A�f�t�H���g = 0)
%   TEXTHAN: �X�V���p��uicontrol�e�L�X�g�I�u�W�F�N�g�̃n���h���ԍ��B��
%            ��́ASIMGUI�ł̂ݎg���܂��B
%
% INT��0�ɐݒ肳���ƁASDTRSP�́A�K�؂Ȑϕ��X�e�b�v���g���܂��B�o�͂́A
% �I�����ꂽ�ϕ��X�e�b�v�T�C�Y�Ő�������܂��B�o�͓_�̐������炷���߂ɂ́A
% �֐�VDCMATE���g���܂��B
%
% �Q�l: DHFNORM, DHFSYN, SDHFNORM, SDHFSYN, TRSP, DTRSP,
%       SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
