% IMERODE  �C���[�W�̏k�ޏ���
%
% IM2 = IMERODE(IM,SE) �́A�O���[�X�P�[���A�o�C�i���A�p�b�N���ꂽ�o�C�i
% ���C���[�W IM ���k�ޏ������A���ʂ̃C���[�W�� IM2 �ɏo�͂��܂��BSE �́A
% �֐� STREL �ɂ��o�͂����\�����v�f�I�u�W�F�N�g�A�܂��́A�\�����v�f
% �I�u�W�F�N�g�̔z��ł��B
%
% IM �� logical �ŁA�\�����v�f�����R�ȏꍇ�AIMERODE �́A�o�C�i���k�ޏ���
% ���s���A���̑��̏ꍇ�́A�O���[�X�P�[���k�ނ��s���܂��BSE ���A�\�����v
% �f�I�u�W�F�N�g�̔z��̏ꍇ�AIMERODE �́ASE �̒��̌X�̍\�����v�f��A
% ���I�Ɏg���āA�����̏k�ޏ������s���܂��B
%
% IM2 = IMERODE(IM,NHOOD) �́A�C���[�W IM �ɏk�ޏ�����K�p���܂��B����
% �ŁANHOOD �́A�\�����v�f�ߖT���w�肷��0��1�̗v�f����\�������s���
% ���B����́A�V���^�b�N�X IMERODE(IM,STREL(NHOOD)) �Ɠ����ł��BIMERODE
% �́AFLOOR((SIZE(NHOOD) + 1)/2) ���g���āA�ߖT�̒��S�v�f�����肵�܂��B
%
% IM2 = IM2 = IMERODE(IM,SE,PACKOPT,M)�A�܂��́AIMERODE(IM,NHOOD,.....
% PACKOPT,M) �́AIM ���p�b�N���ꂽ�o�C�i���C���[�W���ۂ����A�܂��A�I���W
% �i���̃p�b�N����Ă��Ȃ��C���[�W�̍s���� M ��^���邩�ۂ����w�肵�܂��B
% PACKOPT �́A���̒l�̂����ꂩ��ݒ肵�܂��B
% 
%       'ispacked'    IM �́ABWPACK �ŏo�͂����p�b�N���ꂽ�o�C�i���C
%                     ���[�W�Ƃ��Ď�舵���܂��BIM �́A2������uint32 
%                     �z��ŁASE �́A���R��2�����\�����v�f�ł��BPACKOPT 
%                     �̒l���A'ispacked' �̏ꍇ�APADOPT �́A'same' �ɐ�
%                     �肷��K�v������܂��B
%
%       'notpacked'   IM �́A�ʏ�̔z��Ɠ��l�Ɏ�舵���܂��B���ꂪ�A
%                     �f�t�H���g�l�ł��B
%
% PACKOPT ���A'ispacked' �̏ꍇ�AM �ɑ΂���l��ݒ肷��K�v������܂��B
%
% IM2 = IMERODE(...,PADOPT) �́A�o�̓C���[�W�̃T�C�Y���w�肵�܂��BPADOPT
% �́A���̒l�̂����ꂩ��ݒ肵�܂��B
%
%       'same'        �o�̓C���[�W���A���̓C���[�W�̃T�C�Y�Ɠ����ɂ���
%                     ���B���ꂪ�A�f�t�H���g�l�ł��BPACKOPT ���A'isp-
%                     acked'�̏ꍇ�APADOPT �́A'same' �ɐݒ肷��K�v��
%                     ����܂��B
%
%       'full'        �t���̏k�ޏ������v�Z���܂��B
%
% PADOPT �́A�֐� CONV2 �� FILTER2 �ւ̃I�v�V������ SHAPE �����Ɏ��Ă���
% ���B
%
% �N���X�T�|�[�g
% -------------
% IM �́A���l�܂��� logical �ŁA�C�ӂ̎����ł��BIM �� logical �ŁA�\����
% �v�f�����R�Ȃ�΁A�o�͂́Auint8 �̃o�C�i���C���[�W�ɂȂ�A���̑���
% �ꍇ�A�o�͂́A���͂Ɠ����N���X�ɂȂ�܂��B���͂��p�b�N���ꂽ�o�C�i��
% �̏ꍇ�A�o�͂��p�b�N���ꂽ�o�C�i���ɂȂ�܂��B 
% 
% ���
%   --------
% �o�C�i���C���[�W text.tif �𐂒������g���āA�k�ޏ������܂��B
%
%
%       bw = imread('text.tif');
%       se = strel('line',11,90);
%       bw2 = imerode(bw,se);
%       imshow(bw), title('Original')
%       figure, imshow(bw2), title('Eroded')
%
% �O���[�X�P�[���C���[�W cameraman.tif ���A���[�����O�{�[�����g���āA�k��
% �������܂��B
%
%       I = imread('cameraman.tif');
%       se = strel('ball',5,5);
%       I2 = imerode(I,se);
%       imshow(I), title('Original')
%       figure, imshow(I2), title('Eroded')
%
% �Q�l�FBWPACK, BWUNPACK, CONV2, FILTER2, IMCLOSE, IMDILATE, IMOPEN,
%       STREL.



%   Copyright 1993-2002 The MathWorks, Inc. 
