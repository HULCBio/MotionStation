% dTypeID = dspCalcSLBuiltinDataTypeID(blk,dtInfo)
%
%   blk    : �Œ菬���_���L���ł���u���b�N��
%   dtInfo : blk �ɑ΂��� dspGetDataTypeInfo ����̍\����
%  
% �����K�p�����ꍇ�A�u���b�N�ɑ΂���Simulink�̑g�ݍ��݂̃f�[�^�^�C�v
% ID���v�Z���܂��B; �u���b�N���o�b�N�v���p�Q�[�V�������[�h�̏ꍇ-1���A
% �f�[�^�^�C�v���g�ݍ��݂łȂ��ꍇ-2���o�͂��܂��B
%  
% ����: ���̊֐��́A�ȉ��̃p�����[�^���u���b�N���ɑ��݂�����̂Ɖ��肵�܂��B:
%   
%   dataType : 'Fixed-point' �� 'User-defined' �Ɠ����悤�ɃT�|�[�g
%               �����g�ݍ��݂̃f�[�^�^�C�v�����X�g����|�b�v�A�b�v
%   
% ����: ���̊֐��́AdataType �}�X�N�p�����[�^�� VISIBLE �̂Ƃ��̂݃R�[��
%       ����܂��B(���Ȃ킿�A'Show additional parameters' �{�b�N�X��
%       �`�F�b�N����Ă���Ƃ��ł�)�B�����łȂ��ꍇ�A�Ō�ɑI�����ꂽ
%       �l��K�v�Ƃ����A�Ō�ɓK�p���ꂽ�ݒ�̒l���o�͂��܂��B
%
% ����: ����́ADSP Blockset�̃}�X�N���[�e�B���e�B�֐��ł��B��ʓI��
%       �ړI�̊֐��Ƃ��Ďg�p����邱�Ƃ��Ӑ}���Ă��܂���B


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:23 $
