% DICOMREAD  DICOM �C���[�W��ǂݍ���
%
% X = DICOMREAD(FILENAME) �́A�������Ă��� DICOM �t�@�C�� FILENAME ����C
% ���[�W�f�[�^��ǂ݂܂��B�P��t���[���̃O���[�X�P�[���C���[�W�ɑ΂��āA
% X �́AM �s N ��̔z��ŁA�P��t���[���̃g�D���[�J���[�C���[�W�ɑ΂��āA
% X �́AM x N x 3 �̔z��ɂȂ�܂��B�}���`�t���[���C���[�W�́A���4�����z
% ��ɂȂ�܂��B
%
% X = DICOMREAD(INFO) �́ADICOM ���^�f�[�^�\���� INFO ���ŎQ�Ƃ��ꂽ���b
% �Z�[�W����C���[�W�f�[�^��ǂ݂܂��B�\���� INFO �́A�֐� DICOMINFO ��
% �����ꂽ���̂ł��B
%
% [X, MAP] = DICOMREAD(...) �́A�C���[�W X �̃J���[�}�b�v MAP ���o�͂���
% ���BX ���O���[�X�P�[���A�܂��́A�g�D���[�J���[�C���[�W�̏ꍇ�́AMAP ��
% ��ɂȂ�܂��B
%
% [X, MAP, ALPHA] = DICOMREAD(...) �́AX �p�� alpha �`�����l���s����o��
% ���܂��BALPHA �̒l�́A�s�N�Z�����ڂ₯��ꍇ0�A���̑��̏ꍇ�AMAP �̒���
% �s�C���f�b�N�X�ɂȂ�܂��BMAP �̒��� RGB �l���AALPHA ���g�p���邽��X ��
% ���̒l�ɑ������܂��BALPHA �́AX �Ɠ��������ƕ��������A�}���`�C���[�W
% �ɑ΂��ẮA4�����ɂȂ�܂��B
%
% [X, MAP, ALPHA, OVERLAYS] = DICOMREAD(...) �́ADICOM �t�@�C�����炢����
% ���̃I�[�o���C���߂��܂��B�e�I�[�o���C�́AX �Ɠ��������ƕ�������1�r�b�g
% �����C���[�W�ł��B�}���`�I�[�o���C���A�t�@�C�����ɑ��݂���ꍇ�AOVERL-
% AYS �́A4�����}���`�C���[�W�ł��B�t�@�C�����ɃI�[�o���C�����݂��Ȃ��ꍇ
% OVERLAY �͋�ɂȂ�܂��B
%
% �ŏ��̓��͈����A FILENAME�A�܂��́AINFO �́A���̂悤�ɁA�p�����[�^��
% ���O�ƒl��g�Ƃ��Đݒ肳��܂��B
%
%       [...] = DICOMREAD(FILENAME,PARAM1,VALUE1,PARAM2,VALUE2,...)
%       [...] = DICOMREAD(INFO,PARAM1,VALUE1,PARAM2,VALUE2,...)
%
% �T�|�[�g���Ă���p�����[�^���ƒl�́A���̂��̂��܂�ł��܂��B
%
%       'Frames', V        DICOMREAD �́A�C���[�W����x�N�g�� V �̒��̃t
%                          ���[���݂̂�ǂ݂܂��BV �́A�����X�J���A�����x
%                          �N�g���A������'all'�̂����ꂩ�ł��B�f�t�H���g
%                          �́A'all'�ł��B
%
%       'Dictionary', D    DICOMREAD �́A������ D �ɓ����Ă���f�[�^�f�B
%                          ���N�g���t�@�C���̃t�@�C�������g���܂��B�f�t
%                          �H���g�l�́A'dicom-dict.txt' �ł��B
%
%       'Raw', TF          DICOMREAD �́ATF ��1�A�܂��́A0�̒l�Ɉˑ�����
%                          �s�N�Z�����x���̕ϊ����s���܂��BTF ��1(�f�t�H
%                          ���g)�̏ꍇ�ADICOMREAD �́A�C���[�W����X��
%                          �s�N�Z����ǂ݁A�s�N�Z�����x���̕ϊ����s����
%                          ����BTF ��0�̏ꍇ�A�C���[�W�́A�t���̃_�C�i
%                          �~�b�N�����W���g���āA�ăX�P�[�����O����A�J��
%                          �[�C���[�W�́A�����I�� RGB�J���[��Ԃɕϊ�����
%                          �܂��B
%
%                          ���� 1: HSV �J���[��Ԃ́ADICOM �W���ɕs�K�؂�
%                                  ��`����Ă���̂ŁADICOMREAD �́A����
%                                  ��������I�� RGB �ɕϊ����܂���B
%
%                          ���� 2: DICOMREAD �́A�����t���f�[�^���܂ރC��
%                                  �[�W�̃J���[��Ԃ��ăX�P�[�����O������A
%                                  �ύX�����肵�܂���B
%
%                          ���� 3: �l���ăX�P�[�����O��J���[��ԕϊ��̓K
%                                  �p�́A�����āA���^�f�[�^��ω���������
%                                  ���܂���B���ǁA(�E�B���h�E�̒��S/���A
%                                  �܂��́ALUT�̂悤��)�s�N�Z���l�Ɋ֘A��
%                                  �����^�f�[�^�l�́A�s�N�Z�����X�P�[����
%                                  �O���ꂽ��A�ϊ����ꂽ�Ƃ��ɁA��������
%                                  ���Ȃ�\��������܂��B
%
% ���
% --------
% DICOMREAD ���g���āA�����^�[�W���쐬�ɕK�v�ȃf�[�^�z�� X �ƃJ���[�s�� 
% MAP ��ǂݍ��݂܂��B
%
%      [X, map] = dicomread('US-PAL-8-10x-echo.dcm');
%      montage(X, map);
%
% DICOMINFO ���g���āADICOM �t�@�C������ǂݍ��ޏ��Ƌ��� DICOMREAD ��
% �R�[�����܂��B�I�[�g�X�P�[�����O�̃V���^�b�N�X���g���āAIMSHOW �ɂ��A
% �C���[�W��\�����邱�Ƃ��ł��܂��B
%
%      info = dicominfo('CT-MONO2-16-ankle.dcm');
%      Y = dicomread(info);
%      imshow(Y, []);
%
% �Q�l�FDICOMINFO.



%   Copyright 1993-2002 The MathWorks, Inc.
