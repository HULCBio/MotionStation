% POLY2TRELLIS   �������L�q���g�����X�\���ɕϊ�
%
% TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR) �́A�t�B�[�h
% �t�H�[���[�h��ݍ��ݕ�����̑������\�����g�����X�\���ɕϊ����܂��B
% ���[�g k/n �����ɑ΂��āA��������͂͒��� k �̃x�N�g���ŁA������o�͂�
% ���� n �̃x�N�g���ł��B���̂��߁A���̂悤�ɂȂ�܂��B
% 
%  - CONSTRAINTLENGTH �́A�e k �̓��̓r�b�g�X�g���[���ɑ΂��āA�x��
%    ��ݒ肷��1 �s k ��̃x�N�g���ł��B
%
%  - CODEGENERATOR �́A�� k �̓��͂ɑ΂��āAn �̏o�͌�����ݒ肷��
%    8�i���� k �s n ��̍s��ł��B
%
% TRELLIS = POLY2TRELLIS(CONSTRAINTLENGTH, CODEGENERATOR,FEEDBACKCONNECTION)
% �́A�ŏ��̃V���^�b�N�X�Ɠ����ł����A�t�B�[�h�o�b�N��ݍ��ݕ�����ɑ΂���
% ���̂ł��B
%
%  - FEEDBACKCONNECTION �́A�� k �̓��͂ɑ΂��āA�t�B�[�h�o�b�N������
%    �w�肷��8�i����1�s k ��̃x�N�g���ł��B
%
% �g�����X�́A���̃t�B�[���h�����\���̂Ƃ��ĕ\������܂��B
%      numInputSymbols,  (���̓V���{���̐�)
%      numOutputSymbols, (�o�̓V���{���̐�)
%      numStates,        (��Ԑ�)
%      nextStates,       (���̏�ԍs��)
%      outputs,          (�o�͍s��)
%
% �g�����X�\���̂Ɋւ�����ڂ������́AMATLAB�v�����v�g�� 'help istrellis'
% �ƃ^�C�v���Ă��������B


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:02 $
