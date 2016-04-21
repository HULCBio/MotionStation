% BWMORPH   �o�C�i���C���[�W�Ɍ`�Ԋw�I���Z�����s
% BW2 = BWMORPH(BW1,OPERATION) �́A�o�C�i���C���[�W BW1 �ɐݒ肵���`�Ԋw
% �I���Z��K�p���܂��B
% 
% BW2 = BWMORPH(BW1,OPERATION,N) �́A���Z�� N ��K�p���܂��BN �� Inf ��
% �ݒ肷�邱�Ƃ��ł��܂��B���̏ꍇ�A���Z�͏������ʂ��ω����Ȃ��Ȃ�܂ŌJ
% ��Ԃ��܂��B
% 
% OPERATION �ɂ́A���̒l��1����������ł��B
% 'bothat'   ���̓C���[�W������ closing ���甲���o���܂��B
% 'bridge'   �A������Ă��Ȃ��s�N�Z���ɋ���������悤�ɂȂ��܂��B
% 'clean'    �Ǘ������s�N�Z��(1��\���s�N�Z����0�ň͂܂�Ă������)��
%            �������܂��B
% 'close'    �o�C�i�� closure (�c���̌�ɏk��)�����s���܂��B
% 'diag'     �w�ʂ�8�A�����������āA�Ίp����1�ɂ��܂��B
% 'dilate'   �\�������ꂽ�v�f ones(3)���g���āA�c�������s���܂��B
% 'erode'    �\�������ꂽ�v�f ones(3)���g���āA�k�ނ����s���܂��B
% 'fill'     ���S��0�Ŏ����1�ň͂܂ꂽ�s�N�Z����1�ɂ��܂��B
% 'hbreak'   H-�A���s�N�Z������菜���܂��B
% 'majority' 3�s3��̋ߖT����5�ȏ�̃s�N�Z����1�̏ꍇ�A�s�N�Z����1���
%            �肵�܂��B
% 'open'     �o�C�i�� opening (�k�ތ�ɖc��)�����s���܂��B
% 'remove'   4�A���ߖT�̂��ׂĂ�1�̏ꍇ�A�s�N�Z����0�ɐݒ肵�܂��B������
%            ���E��̃s�N�Z���݂̂���菜���܂��B
% 'shrink'   N = Inf �Ɛݒ肵�āA�I�u�W�F�N�g��_�ɂ��܂��B�܂��A������
%            �I�u�W�F�N�g�͘A�����ꂽ�����O�ɂȂ�悤�ɏ��������܂��B
% 'skel'     N = Inf �Ɛݒ肵�āA�I�u�W�F�N�g�𕪒f���邱�Ƃ̂Ȃ��悤��
%            �I�u�W�F�N�g�̋��E����̃s�N�Z������菜���܂��B
% 'spur'     �����ȃI�u�W�F�N�g�����S�Ɏ�菜�����ƂȂ��A���C���̒[�_��
%            ��菜���܂��B
% 'thicken'  N = Inf �Ɛݒ肵�āA����܂ŘA������Ă��Ȃ��I�u�W�F�N�g��
%            �A������邱�ƂȂ��A���̃I�u�W�F�N�g�̊O���Ƀs�N�Z����t��
%            ���邱�Ƃɂ��A�I�u�W�F�N�g���g�債�܂��B
% 'thin'     N = Inf �Ɛݒ肵�āA���������Ȃ��I�u�W�F�N�g���ŏ��̘A���X
%            �g���[�N�ɁA�����āA�������I�u�W�F�N�g���z�[���h�ƊO����
%            ���E�̋����̔����̃����O�ɂȂ�悤�Ƀs�N�Z������菜���܂��B
% 'tophat'   ���̓C���[�W���� opening ����菜���܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W BW1 �́A���l�� logical �ł��B2�����ŁA�����̔�X�p�[�X��
% �Ȃ���΂Ȃ�܂���B�o�̓C���[�W BW2 �́Alogical �ł��B
% 
% ���
%  --------
%  BW1 = imread('circles.tif');
%  imshow(BW1)
%  BW2 = bwmorph(BW1,'remove');
%  BW3 = bwmorph(BW1,'skel',Inf);
%  figure, imshow(BW2)
%  figure, imshow(BW3)
% 
%
% �Q�l�FERODE, DILATE, BWEULER, BWPERIM.



%   Copyright 1993-2002 The MathWorks, Inc.  
