% function [erow1, erow] = emargin(system,controller,ttol)
%
% �^����ꂽSYSTEM��CONTROLLER�������̃t�B�[�h�o�b�N���[�v�ɑ΂��āA��
% �K�����ꂽ������q/�M���b�v�v�ʃ��o�X�g����]�T���v�Z���܂��B
%
% SYSTEM    : �e�X�g������ԋ�ԃV�X�e��
% CONTROLLER: �e�X�g�����R���g���[��
% TTOL      : �K�v�Ȑ��x(�f�t�H���g��0.001)
%
% EROW1     : ���K�����ꂽ������q/�M���b�v�v�ʃ��o�X�g����]�T�ɑ΂���
%             ��E
% EROW      : 1�s3��̍s�x�N�g���ŁA��E�A���E�A��E�̎��g����v�f�Ƃ���
%             ���܂��B
%
% �Q�l�F HINFNORM, SNCFBAL, GAP, NUGAP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
