% IMWRITE   �C���[�W���O���t�B�b�N�X�t�@�C���ɏ����o���܂�
% 
% IMWRITE(A,FILENAME,FMT) �́A�C���[�W A �� FILENAME �ɏ����o���܂��B
% FILENAME �͏o�̓t�@�C�������w�肷�镶����ŁAFMT�̓t�@�C���̏�����
% �w�肷�镶����ł��BA ���O���C�X�P�[���C���[�W(M�~N)�܂��̓g�D���[
% �J���[�C���[�W(M�~N�~3)�̂ǂ���ł��\���܂���B
%
% FMT �̎�肤��l�́A�t�@�C���`���̓o�^�Ō�����܂��B�ڍׂ́A
% "help imformats" ���^�C�v���Ă��������B
%
% IMWRITE(X,MAP,FILENAME,FMT) �́AX �̃C���f�b�N�X�t���C���[�W�Ɗ֘A
% ����J���[�}�b�v MAP ���AFILENAME �ɏ����o���܂��BX �̃N���X�� uint8
% �܂��� uint16 �̏ꍇ�́AIMWRITE �͔z��̎��ۂ̒l���t�@�C���ɏ����o��
% �܂��BX �̃N���X�� double �̏ꍇ�́AIMWRITE �͏����o���O��uint8(X-1)
% ���g���Ĕz����̒l���I�t�Z�b�g���܂��BMAP �́A�L����MATLAB�̃J���[
% �}�b�v�łȂ���΂Ȃ�܂���B�قƂ�ǂ̃C���[�W�t�@�C���̏����́A
% 256�v�f�ȏ�̃J���[�}�b�v�̓T�|�[�g���Ȃ����Ƃɒ��ӂ��Ă��������B
%
% IMWRITE(...,FILENAME) �́A�t�@�C�����̊g���q����g�p���鏑���𐄑�
% ���āA�C���[�W�� FILENAME �ɏ����o���܂��B�g���q�́AFMT �ɑ΂���
% �K�؂Ȓl�łȂ���΂Ȃ�܂���B
%
% IMWRITE(...,PARAM1,VAL1,PARAM2,VAL2,...) �́A�o�̓t�@�C���̎�X��
% �����𐧌䂷��p�����[�^���w�肵�܂��B�p�����[�^�́A�J�����g�ł́A
% HDF, JPEG, TIFF�APNG, PBM, PGM, PPM�t�@�C���ɑ΂��ăT�|�[�g�����
% ���܂��B
%
% �f�[�^�^�C�v
% ------------
% �T�|�[�g����Ă���C���[�W�t�@�C���t�H�[�}�b�g�̑啔����uint8�f�[�^
% �ł��BPNG��TIFF�́Auint16�f�[�^���T�|�[�g���Ă��܂��B�O���[�X�P�[��
% ��RGB�C���[�W�ɑ΂��āA�f�[�^�z��double�̏ꍇ�A���肷��_�C�i�~�b�N
% �����W�� [0,1] �ɂȂ�܂��B�f�[�^�z��́Auint8�Ƃ��ď����o���O��255
% �Ŏ����I�ɃX�P�[�����O����܂��B�f�[�^�z��uint8�܂���uint16�̏ꍇ�A
% ���ꂼ��Auint8 �܂��� uint16 �Ƃ��āA�X�P�[�����O���Ȃ��ŏ����o����
% �܂��B���ӁFlogical �̃f�[�^���ABMP�APNG�A�܂���TIFF�t�@�C���ŏ�����
% �Ă���ꍇ�A����̓o�C�i���C���[�W�Ɖ��肳��A1�̊K���x�ŕ\������܂��B
% 
% �C���f�b�N�X�t���C���[�W�ɑ΂��āA�C���f�b�N�X�t���z�� double 
% �̏ꍇ�A�C���f�b�N�X�Q�́A�܂��A�e�v�f����1�������A�[���x�[�X��
% �C���f�b�N�X�t���ɕϊ����Auint8 �Ƃ��ĕ\�����܂��B�C���f�b�N�X�t��
% �z�� uint8 �܂��� uint16 �̏ꍇ�́Auint8 �܂��� uint16 �ɂȂ�悤��
% �ύX�͍s���܂���B
% 
% PNG�t�@�C���������Ƃ��A'BitDepth' �p�����[�^���g���āA���̋���������
% ���������܂��B�ȉ��ɏڍׂ������܂��B
%
% ��̃C���[�W�f�[�^�͗��p�ł��܂���B
% 
% HDF�ŗL�̃p�����[�^
% -------------------
% 'Compression'   'none' (�f�t�H���g)�A'rle' (�O���C�X�P�[���ƃC���f�b
%                 �N�X�t���C���[�W�ɂ��Ă̂ݗL��)�A'jpeg' (�O���C
%                 �X�P�[����RGB�C���[�W�ɂ��Ă̂ݗL��)�̂����ꂩ�B
% 
% 'Quality'       0����100�̊Ԃ̐����B�p�����[�^�́A'Compression' �� 
%                 'jpeg' �̂Ƃ��̂ݓK�p���܂��B�������傫���قǉ掿��
%                 �ǂ�(���k�ɂ��C���[�W�̗򉻂����Ȃ�)���Ƃ��Ӗ�����
%                 �����A���ʂ̃t�@�C���T�C�Y�͑傫���Ȃ�܂��B
%
% 'WriteMode'     'overwrite' (�f�t�H���g)�܂���'append'�̂����ꂩ�B
%
% JPEG�ŗL�̃p�����[�^
% --------------------
% 'Quality'        0����100�̊Ԃ̐����B�������傫���قǉ掿���ǂ�(���k
%                  �ɂ��C���[�W�̗򉻂����Ȃ�)���Ƃ��Ӗ����܂����A
%                  ���ʂ̃t�@�C���T�C�Y�͑傫���Ȃ�܂��B
%
% 'Comment'        ������܂��͕�����s�񂩂�Ȃ��x�N�g���̃Z���z��B
%                  ���͂̊e�s�́AJPEG�t�@�C���̃R�����g�Ƃ��ď����o��
%                  ��܂��B
%
% TIFF�ŗL�̃p�����[�^
% --------------------
% 'Compression'    'none'�A'packbits'(��o�C�i���C���[�W�̃f�t�H���g)�A
%                  'ccitt'(�o�C�i���C���[�W�̃f�t�H���g), 'fax3', 'fax4'
%                  �̂����ꂩ�B'ccitt', 'fax3', 'fax4' �́A�o�C�i��
%                  �C���[�W�ɂ̂ݗL���ł��B
%
% 'Description'    �C�ӂ̕�����BIMFINFO ���o�͂���ImageDescription
%                  �t�B�[���h�ɏ����o���܂��B
%
% 'Resolution'     �o�̓t�@�C���̒��� XResolution �� YResolution �^�O
%                  �ɑ΂��Ďg�p����X�J���l�B�f�t�H���g�l��72�ł��B
%
% 'WriteMode'      'overwrite' (�f�t�H���g)�܂��� 'append' �̂����ꂩ
%                  ���g�p
% 
% PNG�ŗL�̃p�����[�^
% ------------------- 
%   'Author'       ������
%
%   'Description'  ������
%
%   'Copyright'    ������
%
%   'CreationTime' ������
%
%   'Software'     ������
%
%   'Disclaimer'   ������
%
%   'Warning'      ������
%
%   'Source'       ������
%
%   'Comment'      ������
%
%   'InterlaceType' Either 'none' �܂��� 'adam7'�̂����ꂩ
%
%   'BitDepth'     ��]����r�b�g�f�v�X���w�肷��X�J���l�F
%                  �O���[�X�P�[���C���[�W�ɑ΂��āA1, 2, 4, 8, 
%                  16�r�b�g�BALPHA�`�����l�������O���[�X�P�[��
%                  �C���[�W�ł́A8�܂���16�r�b�g�ł��B�C���f�b�N�X�t��
%                  �C���[�W�ł�1, 2, 4, 8�r�b�g�ŁAALPHA�`�����l����
%                  �����邢�͂����Ȃ��g�D���[�J���[�C���[�W�ł́A
%                  8�܂���16�r�b�g�ł��B
%
% 'Transparency'   ALPHA�`�����l�����g���Ȃ��ꍇ�A�����x(transparency)
%                  �����������߂Ɏg���܂��B
% 
%                  �C���f�b�N�X�C���[�W�F�����W[0,1]�ɓ���Q�v�f�x�N�g���F
%                  Q�̓J���[�}�b�v�̒������Z���l�ł��B�e�l�́A
%                  �Ή�����J���[�}�b�v�v�f�Ɋ֘A���������x�������܂��B
% 
%                  �O���[�X�P�[���C���[�W�F�����W[0,1]�ɓ���X�J���F
%                  �l�́A�l�����ꂽ�����x�ɂȂ�O���[�X�P�[���J���[��
%                  �����܂��B
% 
%                  �g�D���[�J���[�C���[�W�F
%                  �����W[0,1]�ɓ���3�v�f�x�N�g���l�́A�l�����ꂽ�����x
%                  �ɂȂ�g�D���[�J���[�������܂��B
% 				
%	           ���[�U�́A'�����x(Transparency)'��'Alpha'�𓯎���
%		   �ݒ肷�邱�Ƃ͂ł��܂���B
%
% 'Background'     �����x�����s�N�Z������\�������Ƃ��ɁA�g�p����
%                  �o�b�N�O���E���h�J���[���w�肷��l�ł��B
%                    
%                  �C���f�b�N�X�t���C���[�W�F�����W[1,P]�̒��̐����A
%                  P�̓J���[�}�b�v���ł��B
%                  �O���[�X�P�[���C���[�W �F�����W[0,1]�̒��̃X�J���l
%                  �g�D���[�J���[�C���[�W �F�����W[0,1]�̒���3�v�f�x�N�g��
% 
% 'Gamma'          �t�@�C��gamma�������񕉂̃X�J���l
%
% 'Chromaticities' �Q�Ɨp�̔��_�Ɗ�{�I�ȐF�t�����w�肷��8�v�f�x�N�g��
%                  [wx wy rx ry gx gy bx by]
%
% 'XResolution'    ���������̃s�N�Z����/�P�ʂ������X�J��
%
% 'YResolution'    ���������̃s�N�Z����/�P�ʂ������X�J��
%
% 'ResolutionUnit' 'unknown' �܂��� 'meter' �̂����ꂩ
%
% 'Alpha'          �e�s�N�Z���̓����x���w�肷��s��F�s�Ɨ�̑傫����
%                  �f�[�^�z��Ɠ����ŁAuint8, uint16, double���g�p�ł��A
%                  �ǂ̏ꍇ�ł��A�l�̓����W [0,1] �̒��ɓ���܂��B
%
% 'SignificantBits'  �f�[�^�z����ŁA�Ӗ������ƍl������r�b�g����
%                  �����X�J���܂��̓x�N�g���G�l�́A�����W[1,bitdepth]
%                  �ɓ���܂��B
%
%                  �C���f�b�N�X�t���C���[�W    �F3�v�f�x�N�g��
%                  �O���[�X�P�[���C���[�W      �F�X�J��
%                  alpha�`�����l���t���O���[�X�P�[���C���[�W
%                                              �F2�v�f�x�N�g��
%                  �g�D���[�J���[�C���[�W      �F3�v�f�x�N�g��
%                  alpha�`�����l���t���g�D���[�J���[�C���[�W
%                                              �F4�v�f�x�N�g��
%
% PNG�p�����[�^�ɉ����A�L�[���[�h�ɑ΂���PNG�̎d�l���w�肷��p�����[�^
% �����g�����Ƃ��ł��܂��B����\�ȃL�����N�^�́A80�L�����N�^�ȉ��ŁA
% �O�̕����ƍŌ�̕����̃X�y�[�X�͈���ł��܂���B�����̃��[�U�w��
% �p�����[�^�ɑΉ�����l�́A���C���t�B�[�h�������Đ���L�����N�^��
% �܂܂Ȃ�������ł��B
% 
% RAS�ŗL�̃p�����[�^
% -------------------
% 'Type'         'standard'(�񈳏k�A�g�D���[�J���[�C���[�Wb-g-r ),
%	 	 'rgb' ('standard' �Ɠ��l�����A�g�D���[�J���[�C���[�W
%		 �ɑ΂��� r-g-b�J���[�I�[�_�[�𗘗p), 'rle' (1�r�b�g
%                �����8�r�b�g�C���[�W�̎��s���G���R�[�h)
%
% 'Alpha'        �e�s�N�Z���̓����x���ʂɎw�肷��s��B�s�Ɨ��
%	         �傫���́A�f�[�^�z��Ɠ����łȂ���΂Ȃ�܂���B
%                uint8, uint16, double�̂����ꂩ�ł��B�g�D���[�J���[
%                �C���[�W�ɑ΂��Ă̂ݗ��p����܂��B
%
% PBM, PGM, PPM�ŗL�̃p�����[�^
%   ---------------------------
% 'Encoding'     �v���[���G���R�[�h�ɑ΂��� 'ASCII' ���邢�́A�o�C�i��
%                �G���R�[�h�ɑ΂���'rawbits' �B�f�t�H���g�́A'rawbits'�B
% 'MaxValue'     �ő�̃O���C�܂��̓J���[�l�������X�J���BPGM�����PPM
%		 �t�@�C���ɑ΂��Ă̂ݗ��p�\�BPBM�t�@�C���ɑ΂��ẮA
%	         ���̒l�͏��1�ł��B�f�t�H���g�́A�C���[�W�z�� 
%	         'uint16' �̂Ƃ���65535�ŁA�����łȂ��ꍇ��255�ł��B
%
% �e�[�u���F�T�|�[�g�����C���[�W�^�C�v�̗v��
% --------------------------------------------
% BMP   8�r�b�g��24�r�b�g�̈��k����Ă��Ȃ��C���[�W
% 
% TIFF  1�r�b�g�A8�r�b�g�A16�r�b�g�A24�r�b�g�̔񈳏k�C���[�W���܂�
%       �x�[�X���C�� TIFF �C���[�W�ł��B���Ȃ킿�Apackbits ���k��
%       1�r�b�g�A8�r�b�g�A16�r�b�g�A24�r�b�g�BCCITT 1D ��1�r�b�g
%       �C���[�W�A�O���[�v3�A�O���[�v4���k�B
%
% JPEG  �x�[�X���C����JPEG�C���[�W
% 
% PNG   1, 2, 4, 8, 16�r�b�g�O���[�X�P�[���C���[�W�F
%       alpha�`�����l���t��8, 16�r�b�g�O���[�X�P�[���C���[�W
%       1, 2, 4, 8�r�b�g�C���f�b�N�X�t���C���[�W
%       24, 48�r�b�g�g�D���[�J���[�C���[�W
%       alpha�t��24, 48�r�b�g�g�D���[�J���[�C���[�W
% 
% HDF   �֘A����J���[�}�b�v�����A�܂��͂����Ȃ�8�r�b�g���X�^�[
%       �C���[�W�f�[�^�Z�b�g�B24�r�b�g���X�^�[�C���[�W�f�[�^�Z�b�g�B
%       ���k����Ă��Ȃ��C���[�W�A�܂��́ARLE��JPEG���k�C���[�W�B
%
% PCX   8�r�b�g�C���[�W
%
% XWD   8�r�b�gZpixmaps�B
%
% RAS   1�r�b�g�r�b�g�}�b�v�A8�r�b�g�C���f�b�N�X�t���A24�r�b�g�g�D���[
%       �J���[�Aalpha�t��32�r�b�g�g�D���[�J���[���܂ޔC�ӂ�RAS�C���[�W
%
% PBM   �C�ӂ�1�r�b�gPBM�C���[�W�AASCII (plain) �܂��� raw (binary) 
%       �G���R�[�h
%
% PGM   �C�ӂ̕W��PGM�C���[�W�B�C�ӂ̃J���[�[����ASCII (plain)
%       �G���R�[�h�B�O���C�l���Ƃɍő�16�r�b�g��Raw (binary)�G���R�[�h
%
% PPM   �C�ӂ̕W��PPM�C���[�W�B�C�ӂ̃J���[�[����ASCII (plain)
%       �G���R�[�h �B�J���[�R���|�[�l���g���Ƃɍő�16�r�b�g��Raw 
%       (binary) �G���R�[�h
%
% PNM   �����I�����ꂽ PPM/PGM/PBM (��L���Q��)
%
% �Q�l�FIMFINFO, IMREAD, IMFORMATS, FWRITE.


%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:08 $
