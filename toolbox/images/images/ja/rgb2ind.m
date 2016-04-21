% RGB2IND   RGB �C���[�W���C���f�b�N�t���C���[�W�ɕϊ�
%   RGB2IND  �́A3��ނ̕��@(��l�ʎq���A�ŏ��ϓ��ʎq���A�J���[�}�b�s
%   ���O�@) �̂����ꂩ���g���āARGB �C���[�W����C���f�b�N�X�t���C���[
%   �W�ւ̕ϊ����s���܂��BRGB2IND �́ADITHER_OPTION �� 'nodither' �ɐ�
%   �肵�Ȃ�����f�U�����O���s���܂��B
%
%   [X,MAP] = RGB2IND(RGB,N) �́ARGB �C���[�W���ŏ��ϓ��ʎq���@���g��
%   �āA�C���f�b�N�X�t���C���[�W X �ɕϊ����܂��BMAP �́A�ő�ł� N �F
%   �����܂݂܂���B N �́AN <= 65536 �łȂ���΂Ȃ�܂���B
%
%   X = RGB2IND(RGB,MAP) �́ARGB �C���[�W�̒��̃J���[���J���[�}�b�v 
%   MAP ���̍ł��߂��J���[�Ƀ}�b�`�����邱�Ƃɂ��ARGB �C���[�W���J
%   ���[�}�b�v MAP �����C���f�b�N�X�C���[�W X �ɕϊ����܂��B  
%   SIZE(MAP,1) �� 65536 �ȉ��łȂ���΂Ȃ�܂���B
%
%   [X,MAP] = RGB2IND(RGB,TOL) �́ARGB �C���[�W�Ɉ�l�ʎq���@���g��
%   �āA�C���f�b�N�X�t���C���[�W X �ɕϊ����܂��BMAP �́A�ő�ł�
%   (FLOOR(1/TOL)+1)^3 �F�����܂݂܂���BTOL �́A0.0����1.0�̊Ԃ̒l��
%   �Ȃ���΂Ȃ�܂���B
%
%   [...] = RGB2IND(...,DITHER_OPTION) �́A�f�U�����O��K�p���邩�A�K
%   �p���Ȃ�����ݒ肵�܂��BDITHER_OPTION �ɂ́A���̂����ꂩ�̕�����
%   ���g�����Ƃ��ł��܂��B
%
%       'dither'   �K�v�ȏꍇ�A��ԓI�ȉ𑜓x���]���ɂ��Ă��J���[�̉�
%                  ���x�����߂邽�߂Ƀf�U�����O��K�p(�f�t�H���g)
%
%       'nodither' �I���W�i���C���[�W�̃J���[��V�����}�b�v�̒��̍ł�
%                  �߂��J���[�Ƀ}�b�s���O�B�f�U�����O�͓K�p����܂�
%                  ��B
%
%   �N���X�T�|�[�g
% -------------
%   ���̓C���[�W�́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X���T
%   �|�[�g���Ă��܂��B�B�o�̓C���[�W�́AMAP �̒�����256�ȉ��̏ꍇ�́A
%   �N���X uint8 �ŁA���̏ꍇ�́A�N���X uint16 �ł��B
%
%   ���
%   ----
%       RGB = imread('flowers.tif');
%       [X,map] = rgb2ind(RGB,128);
%       imshow(X,map)
%
%   �Q�l�FCMUNIQUE, DITHER, IMAPPROX, IND2RGB, RGB2GRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
