% IMSHOW   �C���[�W�̕\��
% IMSHOW(I,N) �́A���x�C���[�W I �� N �̃O���[�̗��U���x���ŕ\������
% ���BN ���ȗ�����ƁAIMSHOW ��24�r�b�g�\���ł�256�̃O���[���x�����A
% ���̃V�X�e���ł�64�̃O���[���x�����g���܂��B
%
% IMSHOW(I,[LOW HIGH]) �́A�C���[�W I �̃f�[�^�͈͂ɐ����t���āA��
% �͈̔͂ŃO���[�X�P�[�����x�C���[�W�Ƃ��ĕ\�����܂��B�l LOW(��LOW ��
% �菬�����l)�͍��ŁA�l HIGH(��HIGH ���傫���l)�͔��ŕ\������A����
% �Ԃ̒l�́A�O���[�̒��ԐF�ŕ\������܂��BIMSHOW �́A�f�t�H���g�̃O
% ���[���x�������g���܂��B[LOW HIGH]����s��Őݒ肷��ƁAIMSHOW �́A
% [min(I(:)) max(I(:))] ���g���܂��B�����ŁAI �̍ŏ��l�͍��ŁA�ő�l��
% ���ŕ\������܂��B
%
% IMSHOW(BW) �́A�o�C�i���C���[�W BW ��\�����܂��B�l0�͍��Ƃ��ĕ\��
% ���A�l1�͔��Ƃ��ĕ\�����܂��B
%
% IMSHOW(X,MAP) �́A�J���[�}�b�v MAP ���g���āA�C���f�b�N�X�t���C
% ���[�W X ��\�����܂��B
%
% IMSHOW(RGB) �́A�g�D���[�J���[�C���[�W RGB ��\�����܂��B
%
% IMSHOW(...,DISPLAY_OPTION) �́ADISPLAY_OPTION �� 'truesize' �̏ꍇ�A
% �֐� TRUESIZE ���g���A�܂��A'notruesize' �̏ꍇ�A�֐� TRUESIZE���g��
% �Ȃ��ŃC���[�W��\�����܂��B�ǂ���̃I�v�V�����̕�������ȗ����ď���
% ���Ƃ��ł��܂��B�����̈�����ݒ肵�Ȃ��ƁAIMSHOW �́A'ImshowTruesize' 
% �̗D�揇�ʂ̐ݒ���x�[�X�ɁA�֐� TRUESIZE ��ǂݍ��ނ��ǂ��������肵�܂��B
%
% IMSHOW(x,y,A,...) �́A�f�t�H���g�łȂ���ԍ��W�n����邽�߂ɁA�C���[�W
% �� XData �� YData ��ݒ肷��2�v�f�x�N�g�� x �� y ���g���܂��B
% x �� y �́A2�ȏ�̗v�f���������Ă��܂����A�ŏ��ƍŌ�̗v�f�݂̂��A
% ���ۂɎg���邱�Ƃɒ��ӂ��Ă��������B
%
% IMSHOW(FILENAME) �́A�O���t�B�b�N�X�t�@�C�� FILENAME �Ɋi�[�����
% ����C���[�W��\�����܂��BIMSHOW �́A�t�@�C������C���[�W��ǂݍ�
% �ނ��߂� IMREAD ���g���܂����AMATLAB ���[�N�X�y�[�X�ɃC���[�W
% �f�[�^���i�[���邱�Ƃ͂���܂���B�t�@�C���́A�J�����g�f�B���N�g��
% ���A�܂��́AMATLAB �p�X��ɂȂ���΂Ȃ�܂���B
%
% H = IMSHOW(...) �ɂ��쐬�����C���[�W�I�u�W�F�N�g�̃n���h�����o
% �͂��܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Alogical�Auint8�Auint16�Adouble �̂�����̃N���X��
% �T�|�[�g���Ă��܂��B���̓C���[�W�́A��X�p�[�X�ł���K�v������܂��B
%
% ����
% ----
% IPTSETPREF �֐����g�p���āA�������̃c�[���{�b�N�X�̗D�揇�ʂ��
% �肵�āAIMSHOW �̓����ύX���邱�Ƃ��ł��܂��B
%
%   - 'ImshowBorder' �́AIMSHOW ���C���[�W�̂܂��ɋ��E��\�����邩��
%     �����𐧌䂵�܂��B
%
%   - 'ImshowAxesVisible' �́AIMSHOW �����{�b�N�X�Ǝ����x����\������
%     ���ǂ����𐧌䂵�܂��B
%
%   - 'ImshowTruesize' �́AIMSHOW �� TRUESIZE �֐����Ăяo�����ǂ�����
%     ���䂵�܂��B
%
% �����̗D�揇�ʂ̏ڍׂɂ��ẮAIPTSETPREF �̃��t�@�����X�̍���
% ���Q�Ƃ��Ă��������B
%
% �Q�l�FIMREAD, IPTGETPREF, IPTSETPREF, SUBIMAGE, TRUESIZE, WARP, 
%         IMAGE, IMAGESC



%   Copyright 1993-2002 The MathWorks, Inc.  
