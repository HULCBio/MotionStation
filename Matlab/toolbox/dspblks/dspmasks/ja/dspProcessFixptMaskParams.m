% [curVis,lastVis] = dspProcessFixptMaskParams(blk,visState,addlParams)
%
% blk          : �Œ菬���_���L���ȃu���b�N���B�f�t�H���g�l�� 'gcb' ��
%                �o�͂ł��B
% visState     : ��Ԃ��X�V���邱�Ƃ��\�ɂ��邱�̊֐��R�[���̎��Ԃł�
%                ���o���̐ݒ�B�T�|�[�g����Ă��Ȃ��ꍇ�A���o��Ԃ́A
%                get_param(blk,'maskvisibilities') ���R�[�����邱�Ƃɂ����
%                ����������܂��B
% lastVisState : �Ō�ɓK�p���ꂽ���o��ԁB�T�|�[�g����Ȃ��ꍇ�A��Ԃ́A
%                visState �ɓ������Ȃ�悤����������܂��B
% addlParams   : 'Show additional parameters' �`�F�b�N�{�b�N�X�ɂ����
%                �I���ƃI�t�̐؂�ւ����s��(�p�����[�^�C���f�b�N�X�ɂ��)
%                �t���I�ȃ}�X�N�p�����[�^�̔z��B
%
% ���̊֐��́A�Œ菬���_���L���ȃu���b�N�ɑ΂��āA���Ɏ������p�����[�^
% �̎��o���̃_�C�i�~�b�N�ȃX�C�b�`���O�𑀍삵�܂��B
%
% ���̊֐��́A2�̒l���o�͂��܂��B:
%  
% curVis  : ���݂̎��o���ݒ�̐ݒ�
% lastVis : �Ō�ɓK�p���ꂽ���o���ݒ�̐ݒ�
%
% ���̊֐��́A�ȉ��̃p�����[�^�ϐ����u���b�N�̃}�X�N�ɑ��݂�����̂Ɖ���
% ���܂��B:
%   
% additionalParams : ���ɕt���I�ȃp�����[�^��\�����邩���Ȃ���������
%                    �`�F�b�N�{�b�N�X
% dataType         : 'Fixed-point' �� 'User-defined' �Ɠ����悤�ɃT�|�[�g
%                    �����g�ݍ��݂̃f�[�^�^�C�v�����X�g����|�b�v�A�b�v
% wordLen          : dataType �� 'Fixed-point' ���I�����ꂽ�Ƃ��ɗL����
%                    �Ȃ�G�f�B�b�g�{�b�N�X
% udDataType       : dataType �� 'User-defined' ���I�����ꂽ�Ƃ��ɗL����
%                    �Ȃ�G�f�B�b�g�{�b�N�X
% fracBitsMode     : 2�̑I�������|�b�v�A�b�v: Best precision' ��
%                    'User-defined'
% numFracBits      : fracBitsMode �� 'User-defined' �̂Ƃ��ɗL����
%                    �`�F�b�N�{�b�N�X
%   
% ����: ���̊֐��́A'Show additional parameters' �{�b�N�X�� VISIBLE ��
%       �Ƃ��̂݃R�[������܂��B�����łȂ��ꍇ�A�Ō�ɑI�����ꂽ�ݒ��
%       �K�v�łȂ��A�Ō�ɓK�p���ꂽ�ݒ�̒l���o�͂��܂��B
%
% ����: ����́ADSP Blockset�̃}�X�N���[�e�B���e�B�ł��B��ʓI�ȖړI��
%       �֐��Ƃ��Ďg�p����邱�Ƃ��Ӑ}���Ă��܂���B


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:26 $
