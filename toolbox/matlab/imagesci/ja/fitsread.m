% FITSREAD    FITS�t�@�C������f�[�^��ǂݍ���
%
% DATA = FITSREAD(FILENAME) �́AFITS(Flexible Image Transport System)
% �t�@�C�� FILENAME �̊�{�f�[�^����f�[�^��ǂݍ��݂܂��B���ʂł��Ȃ�
% �f�[�^�l�́ANaN �Œu���������܂��B���l�f�[�^�́A���z�ƃC���^�Z�v�g
% �l�ŃX�P�[�����O����A��ɔ{���x�Ŗ߂���܂��B
%   
% DATA = FITSREAD(FILENAME,OPTIONS) �́AOPTIONS �Ŏw�肳�ꂽ�I�v
% �V�����ɏ]���āAFITS�t�@�C������f�[�^��ǂ݂܂��B�g�p�\�ȃI�v�V�����́A
% ���̂��̂ł��B
%   
%  EXTNAME      EXTNAME �́A��{�f�[�^�z��AASCII table extension, 
%               Binary table extension, Image extension, Unknown 
%               extension ����f�[�^��ǂݍ��ނ��߁A'Primary', 'Table',
%               'BinTable', 'Image', 'Unknown' �̂����ꂩ��ݒ肵�܂��B
%               �����̊g���q���w�肵���ꍇ�́A�t�@�C�����ōŏ��Ɍ�����
%               ���̂��ǂݍ��܂�܂��BASCII�� Binary table extension �ɑ΂���
%               DATA �́A�t�B�[���h���̃Z���z��ɂ��1�ɂȂ�܂��B
%               FITS�t�@�C���̓��e�́AFITSINFO �ŏo�͂����\���̂� 
%               Content �t�B�[���h�Ɉʒu���܂��B
%   
% EXTNAME,IDX  �����̊g���^�C�v���w�肵���ꍇ�� IDX �Ԗڂ̂��̂��ǂ�
%					 ���܂�邱�Ƃ������āAEXTNAME �Ɠ����ł��B
%   
% 'Raw'      �t�@�C������ǂݍ��܂�� DATA �́A�X�P�[�����O���ꂸ�A����`��
%             �l��NaN �Œu���������܂���BDATA �́A�t�@�C���̒��Ɋi�[
%			  �������̂Ɠ����N���X�ɂȂ�܂��B
%
% �Q�l�FFITSINFO.



%   Copyright  1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:42 $
