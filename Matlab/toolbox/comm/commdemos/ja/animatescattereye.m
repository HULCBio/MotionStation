% ANIMATESCATTEREYE - scattereyedemo �ɂ����Ĉړ�����I�t�Z�b�g��
%                     �A�j���[�V����
%
% ANIMATESCATTEREYE(X, N, PAUSETIME, NUMSHIFTS, ACTION, SEPARATION) �́A
% �A�C�p�^�[���ƃX�L���^�v���b�g�𓯊����ăA�j���[�V�������Acomm/commdemos 
% �� SCATTEREYEDEMO �f�����X�g���[�V�������T�|�[�g���܂��B���̃t�@�C���́A
% �A�C�p�^�[�����X�N���[���̏�E�p�ɁA�X�L���^�v���b�g���X�N���[����
% �����p�Ɏ����Ă����܂��B�����āA�t�B�M���A�� X �̃f�[�^���v���b�g���܂��B
% �v�����������́A���̂Ƃ���ł��B:
%
% X �͎����܂��͕��f���́A�ϒ�/�t�B���^�����O��́A�m�C�Y�L��܂��͖���
% �̐M���ł��B
%
% N �̓X�L���^�v���b�g�̊Ԉ����t�@�N�^�ł���A�A�C�p�^�[���̎����ł��B
% �ʏ�A�I�[�o�[�T���v���t�@�N�^�i�V���{��������̃T���v�����j���ݒ�
% ����܂��B�I�[�o�[�T���v���t�@�N�^�̍ŏ����{����ݒ肷�邱�Ƃ��ł��܂��B
%
% PAUSETIME �́A�A�j���[�V�����X�e�b�v�̊ԁA��~���鎞�Ԃł��B
%
% NUMSHIFTS �́A���s����A�j���[�V�����X�e�b�v���ł��B
%
% ACTION �̓A�j���[�V�����̃^�C�v�����肵�܂��B���̃I�v�V������I��
% ���Ƃ��ł��܂��B
%
%     'lin' - ���`�A�j���[�V�����ł́A�I�t�Z�b�g���[������n�܂葝����
%             �܂��B�����ăA�C�p�^�[���ƃX�L���^�v���b�g�́ANUMSHIFTS 
%             �A�j���[�V�����X�e�b�v�ɓ��B����܂Ńv���b�g����܂��B
%             �A�C�p�^�[���͉E�ɃV�t�g���Ă����܂��B
%
%     'lr' - �E�V�t�g/���V�t�g�ł́A�͈� -4 ���� 4 �̊ԂŁA�I�t�Z�b�g
%            �𑝉�/���������A�M�� X �̃T���v�����O�ɑ΂���^�C�~���O
%            �̃f�B�U�����O��\�����܂��B
%
% SEPARATION - �X�L���^�v���b�g��̃h�b�g�̋��������肵�܂��B������
% �h�b�g�́A�X�L���^�v���b�g�̒ʏ�̃v���b�g�ɕt���������̂ł��B�V�A��
% �̃��C���^�C�v�ł���X�L���^�v���b�g�ƁA�V���{���T���v�����O���Ԃňړ�
% ������A�X�^���X�N�v���b�g���܂݂܂��B
%
% SEPARATION > 0 - �X�L���^�v���b�g�̓T���v�����O�_�ō����h�b�g��
% �v���b�g���A�T���v�����O�_ + SEPARATION �ŐԂ��h�b�g���v���b�g���A
% �T���v�����O�_ - SEPARATION �ŐԂ��h�b�g���v���b�g���܂��B
%
% SEPARATION == 0 - �X�L���^�v���b�g�͂��T���v�����O�_�݂̂ō����h�b�g��
% �v���b�g���܂��B
%
% SEPARATION < 0 - �t���I�ȃh�b�g�͂���܂���B
%
% �Q�l : SCATTERPLOT, EYEDIAGRAM, SCATTEREYEDEMO.


%   Author(s): Michael Clune
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2003/06/23 04:35:25 $
