%function y = trsp(sys,input,tfinal,int,x0,texthan)
%
% SYSTEM�s��̎��ԉ������v�Z���܂��B
%   SYS     : SYSTEM�܂���CONSTANT�s��
%   INPUT   : VARYING���̓x�N�g���܂��͒萔
%   TFINAL  : �ŏI����(�I�v�V�����A�f�t�H���g = ���͂̍ŏI����)
%   INT     : �ϕ��X�e�b�v(�I�v�V�����A�f�t�H���g�ł͓��͂�SYS�Ɋ�Â���
%             �肳��܂��BTRSP���I�������Ԃ́A���΂��Δ��ɏ������A�v
%             �Z�Ɏ��Ԃ�v����ꍇ������̂ŁA���[�U�����̈�����ݒ肷��
%             ���Ƃ𐄏����܂�)�B
%   X0      : �������(�I�v�V�����A�f�t�H���g = 0)�B
% �@TEXTHAN : �X�V���p��uicontrol�e�L�X�g�I�u�W�F�N�g�̃n���h���ԍ��B
%             ����́ASIMGUI�ł̂ݎg���܂��B
%
% INT��0�ɐݒ肳���ƁATRSP�́A�K�؂Ȑϕ��X�e�b�v���g���܂��B�o�͂́A�I
% �����ꂽ�ϕ��X�e�b�v�T�C�Y�Ő�������܂��B�o�͓_�̐������炷���߂ɂ́A
% �֐�VDCMATE���g���܂��B
%
% �Q�l: DTRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
