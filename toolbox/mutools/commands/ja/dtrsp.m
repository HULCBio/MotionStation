%function y = dtrsp(sys,input,T,tfinal,x0,texthan)
%
% ���U�V�X�e���̎��ԉ������v�Z���܂��B
%	SYS    : �p�b�N���ꂽ�`����A,B,C,D SYSTEM�s��܂���CONSTANT�s��
%	INPUT  : VARYING�`���̓��̓x�N�g���܂���CONSTANT�s��
%	T      : �T���v�����O����
%	TFINAL : �ŏI�����̒l(�I�v�V�����A�f�t�H���g = ���͂̍ŏI����)
%	X0     : �������(�I�v�V�����A�f�t�H���g = 0)
%       TEXTHAN: �X�V���ɑ΂���uicontrol�e�L�X�g�I�u�W�F�N�g�̃n���h��
%                �ԍ��B����́ASIMGUI�ł̂ݎg���܂��B
%
% �Q�l: TRSP, SAMHLD, SIMGUI, TUSTIN, VINTERP, VDCMATE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
