% DICOMWRITE   DICOM �t�@�C���Ƃ��ăC���[�W����������
% 
% DICOMWRITE(X, FILENAME) �́AFILENAME �Ɩ��Â���ꂽ�t�@�C���ɁA�o�C
% �i���A�O���[�X�P�[���A�܂��̓g�D���[�J���[�C���[�W X ���������݂܂��B
%
% DICOMWRITE(X, MAP, FILENAME) �́A�J���[�}�b�v MAP ���g���ăC���f�b�N
% �X�t���C���[�W X ���������݂܂��B
%
% DICOMWRITE(..., PARAM1, VALUE1, PARAM2, VALUE2, ...) �́ADICOM�t�@�C
% ���̏������݂ɉe������p�����[�^���A�܂���DICOM�t�@�C���ɏ������ނ�
% �߂̃I�v�V�����̃��^�f�[�^���w�肵�܂��BPARAM1 �́A���^�f�[�^�̑���
% �����A�܂���DICOMWRITE �̎w��I�v�V�������܂񂾕�����ł��BVALUE1 �́A
% �����A�܂��̓I�v�V�����ɑΉ�����l�ł��B
%
% �����𖞂����������́A�f�[�^���� dicom-dict.txt ���Ƀ��X�g����Ă�
% �܂��B����ɁA�ȉ��� DICOM �w��I�v�V���������p�\�ł��B:
%
%   'Endian'           �t�@�C���ɑ΂��� byte-ordering: 
%                      'Big' �܂��� 'Little'(�f�t�H���g)
%
%   'VR'               �l�̕\�����t�@�C���ɏ������ނ��ǂ���:  
%                      'Explicit' �܂��� 'Implicit'(�f�t�H���g)
%
%   'CompressionMode'  �C���[�W�Ɋi�[����Ƃ��Ɏg���鈳�k�^�C�v: 
%                      'JPEG lossy', 'RLE' �܂��� 'None' (�f�t�H���g)
%
%   'TransferSyntax'   Endian �� VR ���[�h�Ŏw�肳��� DICOM UID
%
% ����: �f�t�H���g�ł́ADICOMWRITE �́AVR �� 'Implicit'�Abyte-ordering
% �� little-endian�A���k���[�h���Ȃ��Ƃ��āA�L�������ꂽ�t�@�C�����쐬
% ���܂��B��L�Ƀ��X�g�����I�v�V������1������ȏオ DICOMWRITE ��
% �^������ƁA�f�t�H���g�̐ݒ�𖳌��ɂ��܂��BTransferSyntax �p��
% ���[�^���^����ꂽ�ꍇ�A�g�p�����l�͈�����ł��B����ȊO�ł́A
% �w�肳��Ă���� CompressionMode �p�����[�^���g���܂��B�ŏI�I�ɂ́A
% VR �� Endian �p�����[�^���g���܂��BEndian �� 'Big' �̒l�ɂ��AVR ��
% 'Implicit' �̒l�Ƃ��Ďw�肷�邱�Ƃ͂ł��܂���B
%
% DICOMWRITE(..., META_STRUCT, ...) �́A�\���̂ɂ��A�I�v�V�����̃��^
% �f�[�^���t�@�C���ɑ΂���I�v�V�������w�肵�܂��B�\���̂̃t�B�[���h��
% �́A��L�Ɏ������\�����̃p�����[�^������ɗގ����Ă���A�t�B�[���h
% �l�̓p�����[�^�l�ł��B
%
% DICOMWRITE(..., INFO, ...) �́ADICOMINFO �ɂ���č��ꂽ���^�f�[�^
% �\���� INFO ���g�p���܂��B
%
% STATUS = DICOMWRITE(...) �́A���^�f�[�^�p�����[�^�ɂ��Ă̏����o
% �͂��A�I�v�V������ DICOMWRITE �ɗ^�����邩�A�����w�肳��Ȃ��ꍇ��
% ��ɂȂ�܂��B
%
% ���^�f�[�^�̍\���̂��A DICOMINFO �̌��ʂƂ��ăp�����[�^�l���y�A�Ŏw
% �肷��ꍇ�ADICOMWRITE �ɉe�����Ȃ��p�����[�^���Q�Ƃ��邱�Ƃ��ł���
% ���BSTATUS �́A�����̎g���Ă��Ȃ��p�����[�^���܂ލ\���̂ŁA�ȉ�
% �̃t�B�[���h�������܂��B:
%
%   'dicominfo_fields'  ���̃t�B�[���h���̒l�́A�t�@�C���̏������ݕ��@
%                       �ɂ͉e�����Ȃ��ADICOMINFO �ŕԂ��ꂽ����̃��^
%                       �f�[�^�ł��B
%
%   'wrong_IOD'         ���̃t�B�[���h�́A�C���[�W�̏������݂̃^�C�v��
%                       �֌W���Ȃ����^�f�[�^�������܂݂܂��B
%
%   'not_modifiable'    �����̒l�͏������܂ꂽ�C���[�W�ɑ΂��ėL����
%                       ���^�f�[�^�t�B�[���h�ł����A���[�U�w��̒l����
%                       �ނ��Ƃ͂ł��܂���B
%
% �Q�l:  DICOMINFO, DICOMREAD.


%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 17:15:54 $
