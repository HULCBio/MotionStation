% IMCLOSE  �C���[�W�̃N���[�Y����
% IM2 = IMCLOSE(IM,SE) �́A�\�����v�f SE ���g���āA�O���[�X�P�[���C���[�W
% �܂��́A�o�C�i���C���[�W��Ɍ`�Ԋw�I�N���[�Y������K�p���܂��BSE �́A�P
% ��̍\�����v�f�I�u�W�F�N�g�ŁA�I�u�W�F�N�g�̔z��ł͂���܂���B
%
% IMCLOSE(IM,NHOOD) �́A�\�����v�f STREL(NHOOD) ���g���āA�N���[�Y������
% �s���܂��B�����ŁANHOOD �́A�\�����v�f�ߖT���w�肷��0��1�̗v�f����Ȃ�
% �z��ł��B
%
% �N���X�T�|�[�g
% -------------
% IM �́A�C�ӂ̐��l�܂��� logical �̃N���X�ŁA�C�ӂ̎����ł��B�܂���X
% �p�[�X�łȂ���΂Ȃ�܂���BIM �� logical �̏ꍇ�ASE �͕��R�łȂ����
% �Ȃ�܂���BIM2 �� IM �Ɠ����N���X�ɂȂ�܂��B
%
% ���
% -------
% pearlite.tif �C���[�W�ɃX���b�V���z�[���h��K�p���A���a6�̉~�ՂɃN���[
% �Y�������s���A�N���[�Y�����ɔ��������Ȍ`����}�[�W���܂��B�Ǘ����Ă���
% ���F�s�N�Z������������ɂ́A���̌�ŁA�I�[�v���������s���܂��B
%
%       I = imread('pearlite.tif');
%       bw = ~im2bw(I,graythresh(I));
%       imshow(I), title('Original')
%       figure, imshow(bw), title('Step 1: threshold')
%       se = strel('disk',6);
%       bw2 = imclose(bw,se);
%       bw3 = imopen(bw2,se);
%       figure, imshow(bw2), title('Step 2: closing')
%       figure, imshow(bw3), title('Step 3: opening')
%
% �Q�l�FIMDILATE, IMERODE, IMOPEN, STREL.



%   Copyright 1993-2002 The MathWorks, Inc.  
