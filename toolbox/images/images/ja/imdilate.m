% IMDILATE  �C���[�W�̖c��
% IM2 = IMDILATE(IM,SE) �́A�O���[�X�P�[���A�o�C�i���A�p�b�N���ꂽ�o�C�i
% ���C���[�W IM ��c���������A���ʂ̃C���[�W�� IM2 �ɏo�͂��܂��BSE �́A
% �֐� STREL �ɂ��o�͂����\�����v�f�I�u�W�F�N�g�A�܂��́A�\�����v�f
% �I�u�W�F�N�g�̔z��ł��B
%
% IM �� logical(�o�C�i��)�̏ꍇ�A�\�����v�f�͕��R�łȂ���΂Ȃ�܂���B
% �܂��AIMDILATE �́A�o�C�i���c���������s���܂��B���̑��̏ꍇ�́A
% �O���[�X�P�[���̖c�����s���܂��BSE ���\�����v�f�I�u�W�F�N�g�̔z���
% �ꍇ�AIMDILATE �́ASE �̒��̌X�̍\�����v�f��A���I�Ɏg���āA������
% �c���������s���܂��B
%
% IM2 = IMDILATE(IM,NHOOD) �́A�C���[�W IM �ɖc��������K�p���܂��B����
% �ŁANHOOD �́A�\�����v�f�ߖT���w�肷��0��1�̗v�f����\�������s��ł��B
% ����́A�V���^�b�N�X IMDILATE(IM, STREL(NHOOD)) �Ɠ����ł��BIMDILATE 
% �́AFLOOR((SIZE(NHOOD) + 1)/2) ���g���āA�ߖT�̒��S�v�f�����肵�܂��B
%
% IM2 = IMDILATE(IM,SE,PACKOPT)�A�܂��́AIMDILATE(IM,NHOOD,PACKOPT) �́A
% IM ���p�b�N���ꂽ�o�C�i���C���[�W���ۂ����w�肵�܂��BPACKOPT �́A��
% �̒l�̂����ꂩ��ݒ肵�܂��B
%
%       'ispacked'    IM �́ABWPACK �ŏo�͂����p�b�N���ꂽ�o�C�i���C��
%                     �[�W�Ƃ��Ď�舵���܂��BIM �́A2������ uint32 �z
%                     ��ŁASE �́A���R��2�����\�����v�f�ł��BPACKOPT ��
%                     �l���A'ispacked' �̏ꍇ�APADOPT �́A'same' �ɐݒ肷
%                     ��K�v������܂��B
%
%       'notpacked'   IM �́A�ʏ�̔z��Ɠ��l�Ɏ�舵���܂��B���ꂪ�A�f
%                     �t�H���g�l�ł��B
%
% IM2 = IMDILATE(...,PADOPT) �́A�o�̓C���[�W�̃T�C�Y���w�肵�܂��BPADOPT
% �́A���̒l�̂����ꂩ��ݒ肵�܂��B
%
%       'same'        �o�̓C���[�W���A���̓C���[�W�̃T�C�Y�Ɠ����ɂ���
%                     ���B���ꂪ�A�f�t�H���g�l�ł��BPACKOPT ���A'ispa-
%                     cked'�̏ꍇ�APADOPT �́A'same' �ɐݒ肷��K�v����
%                     ��܂��B
%
%       'full'        �t���̖c���������v�Z���܂��B
%
% PADOPT �́A�֐� CONV2 �� FILTER2 �ւ̃I�v�V������ SHAPE �����Ɏ��Ă��܂��B
%
% �N���X�T�|�[�g
% -------------
% IM �́Alogical �����l�ŁA�����̔�X�p�[�X�łȂ���΂Ȃ�܂���B�����
% �C�ӂ̎����������܂��B�o�͂́A���͂Ɠ����N���X�ɂȂ�܂��B���͂��p�b�N
% ���ꂽ�o�C�i���̏ꍇ�A�o�͂��p�b�N���ꂽ�o�C�i���ɂȂ�܂��B
%
% ���
% --------
% �o�C�i���C���[�W text.tif �𐂒������g���āA�c���������܂��B
%
%       bw = imread('text.tif');
%       se = strel('line',11,90);
%       bw2 = imdilate(bw,se);
%       imshow(bw), title('Original')
%       figure, imshow(bw2), title('Dilated')
%
% �O���[�X�P�[���C���[�W cameraman.tif ���A���[�����O�{�[�����g���āA�c��
% �������܂��B
%
%       I = imread('cameraman.tif');
%       se = strel('ball',5,5);
%       I2 = imdilate(I,se);
%       imshow(I), title('Original')
%       figure, imshow(I2), title('Dilated')
%
% �X�J���l1���A2�̍\�����v�f��A���I�ɓK�p���A'full'�I�v�V�������g���āA
% �c���������s�����Ƃɂ��A2�̕��R�ȍ\�����v�f��g�ݍ��킹�����̂��쐬
% ���܂��B
%
%       se1 = strel('line',3,0);
%       se2 = strel('line',3,90);
%       composition = imdilate(1,[se1 se2],'full')
%
% �Q�l�FBWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, IMERODE, IMOPEN,
%       STREL.



%   Copyright 1993-2002 The MathWorks, Inc. 
