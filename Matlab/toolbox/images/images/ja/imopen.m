% IMOPEN �C���[�W�̃I�[�v������
% IM2 = IMOPEN(IM,SE) �́A�\�����v�f SE ���g���āA�O���[�X�P�[���C���[�W
% �܂��́A�o�C�i���C���[�W��Ɍ`�Ԋw�I�I�[�v��������K�p���܂��BSE �́A�P
% ��̍\�����v�f�I�u�W�F�N�g�ŁA�I�u�W�F�N�g�̔z��ł͂���܂���B
%
% IM2 = IMOPEN(IM,NHOOD) �́A�\�����v�f STREL(NHOOD) ���g���āA�I�[�v����
% �����s���܂��B�����ŁANHOOD �́A�\�����v�f�ߖT���w�肷��0��1�̗v�f����
% �Ȃ�z��ł��B
%
% �N���X�T�|�[�g
% -------------
% IM �́A���l�܂��� logical �ŁA�C�ӂ̃N���X�ƔC�ӂ̎����������܂��B
% �܂��A��X�p�[�X�łȂ���΂Ȃ�܂���BIM �� logical �̏ꍇ�ASE ��
% ���R�łȂ���΂Ȃ�܂���BIM2 �́AIM �Ɠ����N���X�ɂȂ�܂��B
%
% ���
% -------
% nodules1.tif �C���[�W�ɃX���b�V���z�[���h��K�p���A�␔���v�Z���܂��B
% �����āA���a5�̉~�Ղ��g�����I�[�v�������ɂ��A��菬���ȃI�u�W�F�N�g
% �𔲂��o���܂��B
%
%       I = imread('nodules1.tif');
%       bw = ~im2bw(I,graythresh(I));
%       se = strel('disk',5);
%       bw2 = imopen(bw,se);
%       imshow(bw), title('Thresholded image')
%       figure, imshow(bw2), title('After opening')
%
% �Q�l�F IMCLOSE, IMDILATE, IMERODE, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
