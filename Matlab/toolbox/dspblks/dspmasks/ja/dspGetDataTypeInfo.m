% dtInfo = dspGetDataTypeInfo(blk,maxVal)
%
%   blk    : �Œ菬���_�̗L���ȃu���b�N���B�f�t�H���g�l��'gcb'�̏o�͂ł��B
%   maxVal : 'best precision' �̏ꍇ�̕����̃r�b�g�����v�Z���邽�߂Ɏg�p
%            �����l�B�f�t�H���g�́A-1�ł��B
%   
% ���̊֐��́A�u���b�N�� dtat �^�C�v�ɂ��Ă̏����܂񂾍\���̂��o��
% ���܂��B�\���̂́A�ȉ��̃t�B�[���h�������܂��B:
% DataTypeDeterminesFracBits : �f�[�^�^�C�v�������r�b�g�̐��Œ�`����̂�
%                              �\���ł���ꍇ1�ł��B���̃t�B�[���h�́A
%                              �g�ݍ��݂ɑ΂��ĂƁAFIX �ɓ������Ȃ��f�[�^
%                              �I�u�W�F�N�g�̃N���X�ɑ΂���1�ł��B
% DataTypeIsCustomFloat      : �P���x�Ɣ{���x�Ƃ��Ĉ����� float(32,8)�A
%                              float(64,11) �������N���X FLOAT �Ŏ������
%                              ���̂�1��
% DataTypeIsSigned           : �����t���������Ȃ����̂ǂ��炩
% DataTypeWordLength         : �r�b�g�̃g�[�^���Ȑ�; -1�ɓ������u�[���A��
% DataTypeFracOrMantBits     : �����r�b�g�̐�(�Œ菬���_)�܂��́A�����r�b�g
%                              (���������_)
% DataTypeObject             : sint, uint, sfrac, ufrac, sfix, ufix, fload
%                              �R�}���h�ɂ���ďo�͂��ꂽ�N���X�I�u�W�F�N�g�B
%                              ���̏ꍇ�͂��ׂ� [] �ɓ�����
%   
% ����: ���̊֐��́A�ȉ��̃p�����[�^�ϐ����u���b�N�̃}�X�N�ɑ��݂����
%       ���肵�܂��B:
%   
% dataType     : 'Fixed-point' �� 'User-defined' �Ɠ����悤�ɃT�|�[�g�����
%                �g�ݍ��݂̃f�[�^�^�C�v��\������|�b�v�A�b�v
% wordLen      : dataType �� 'Fixed-point' ���I�����ꂽ�Ƃ��A�L���ƂȂ�
%                �G�f�B�b�g�{�b�N�X
% udDataType   : dataType �� 'User-defined' ���I�����ꂽ�Ƃ��A�L���ƂȂ�
%                �G�f�B�b�g�{�b�N�X
% fracBitsMode : 2�̑I�������|�b�v�A�b�v: 'Best precision' ��
%                'User-defined'
% numFracBits  : fracBitsMode �� 'User-defined' �̂Ƃ��L���ɂȂ�G�f�B�b�g
%                �{�b�N�X
%   
% ����: ���̊֐��́A�}�X�N�p�����[�^�� VISIBLE �̂Ƃ��̂݃R�[������܂��B
%       (���Ȃ킿�A'Show additional parameters' �{�b�N�X���`�F�b�N�����
%       ����Ƃ��ł�)�B�����łȂ��ꍇ�A�Ō�ɑI�����ꂽ�ݒ�͕K�v�ł͂Ȃ��A
%       �Ō�ɓK�p���ꂽ�ݒ�̒l���o�͂��܂��B
%
% ����: ����́ADSP Blockset�̃}�X�N���[�e�B���e�B�ł��B��ʓI�ȖړI��
%       �֐��Ƃ��Ďg�p����邱�Ƃ��Ӑ}���Ă��܂���B


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/07/22 21:04:24 $
