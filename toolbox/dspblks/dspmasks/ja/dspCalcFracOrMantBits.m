% numBits = dspCalcFracOrMantBits(blk,dtObject,maxVal)
%    blk      : �r�b�g�����v�Z���邽�߂̃u���b�N
%    dtObject : �u���b�N�ɑ΂���N���X�I�u�W�F�N�g(sfix(), uint(), �Ȃ�)
%    maxVal   : fixptbestprec ���R�[�����邽�߂̍ő�l�B�f�t�H���g��-1�B
%
% ���̊֐��́A�u���b�N�̃}�X�N�f�[�^�^�C�v�p�����[�^�� 'Fixed-point' �܂���
% 'User-defined' �̂Ƃ��A�r�b�g�̐��A�܂��͕����A�܂��͉������v�Z���܂��B
% 
% �u���b�N���Œ菬���_�f�[�^�^�C�v�ŁA'Best precision' �ɐݒ肳��Ă���
% �ꍇ�AmaxVal ��ݒ肵�Ȃ���΂Ȃ�܂���B
%
% ����: ���̊֐��́A�ȉ��̃p�����[�^���u���b�N�ɂ�����̂Ɖ��肵�܂��B:
%   
%   fracBitsMode : 2�̑I�������|�b�v�A�b�v: 'Best precision' �� 
%                  'Userdefined'
%   numFracBits  : fracBitsMode �� 'User-defined' �̂Ƃ��ɗL���ȃG�f�B�b�g
%                  �{�b�N�X
%   
% ����: ����́ADSP Blockset�̃}�X�N���[�e�B���e�B�֐��ł��B�ʏ�̖ړI��
%       �g�p�����֐��Ƃ��ĈӐ}�������̂ł͂���܂���B


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:22 $
