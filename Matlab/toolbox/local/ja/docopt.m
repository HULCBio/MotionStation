%DOCOPT Web �u���E�U�̃f�t�H���g
% DOCOPT �́A���[�U�A�܂��́A�V�X�e���Ǘ��҂��A�g�p���� Web �u���E�U��
% �ݒ肷�邽�߂ɃG�f�B�b�g�ł��� M-�t�@�C���ł��B���̒��ɂ́AJava �x�[�X
% �� Desktop GUI ���T�|�[�g���Ă��Ȃ�(���̂悤�ȃv���b�g�t�H�[���Ɋւ���
% ���́A�����[�X�m�[�g���Q�Ƃ��Ă�������)�v���b�g�t�H�[���ɑ΂���
% MATLAB �I�����C���h�L�������g�̈ʒu���ݒ肷�邱�Ƃ��ł��܂��B�ʏ�A
% Desktop �̃w���v�u���E�U�́AHTML �̓��e��\������֐� DOC �� Web ��
% �g�p�ł��܂��B�����āA�h�L�������g�̈ʒu�́ADesktop �̊��ݒ�E�B���h�E
% ���ɐݒ肷�邱�Ƃ��ł��܂��BDOCOPT �́A�֐�WEB ���A-BROWSER �I�v�V����
% �t���ŁA�g�p���ꂽ�ꍇ�A�E�F�u�u���E�U��ݒ肷�邽�߂Ɏg�����Ƃ��ł�
% �܂��BDOCOPT �́AUNIX �v���b�g�t�H�[���݂̂Ŏg�p�ł��܂��B
%
% [DOCCMD,OPTIONS,DOCPATH] = DOCOPT �́A3�̕����� DOCCMD, OPTIONS, 
% DOCPATH ���o�͂��܂��BDOCCMD �́A(Desktop �̃w���v�u���E�U�̑����)
% Web �u���E�U���N�����邽�߂ɁADOC �܂��� WEB ���g�p����R�}���h���܂�
% ������ł��B
%
%	   Unix:      netscape
%	   Mac:       -na-	
%	   Windows:   -na-
%
% OPTIONS �́ADOC �R�}���h���Ăяo�����Ƃ��ɁADOCCMD �̌Ăяo���ɕt��
% ����ǉ��̃R���t�B�M�����[�V�����I�v�V�������܂ޕ�����ł��B�f�t�H���g�́A
% �ȉ��̒ʂ�ł��B
%
%	   Unix:      ''
%	   Mac:       -na-
%	   Windows:   -na-
%
% DOCPATH �́AMATLAB �I�����C���h�L�������g�t�@�C���ւ̃p�X���܂ޕ�����ł��B
% DOCPATH ����̏ꍇ�A�֐� DOC �́A�f�t�H���g�̈ʒu�̃w���v�t�@�C��������
% ���܂��B
%
% Unix ��ł̃R���t�B�M�����[�V����:
% ----------------------------------
% 1. �O���[�o���ȃf�t�H���g�ɑ΂���A���̃t�@�C���̕ҏW�ƒu������
%         $MATLAB/toolbox/local/docopt.m
%
% 2.���[�U�ݒ�̗D�揇�ʂɑ΂��āA1�̒��Őݒ肵���l�̏�������
% 
%   $MATLAB/toolbox/local/docopt.m
% 
% ��
% 
%   $HOME/matlab/docopt.m
% 
% �ɃR�s�[���A���̈ʒu�ŁA���[�U�ɂ��ύX���s���܂��BMATLAB�̒��ŁA
% �f�B���N�g�����쐬���A������R�s�[����Unix�R�}���h�́A���̂��̂ł��B
%
%         !mkdir $HOME/matlab
%         !cp $MATLAB/toolbox/local/docopt.m $HOME/matlab
%
% �J�����gMATLAB�Z�b�V�����ŁA�������̂��ߕύX���s���ɂ́A$HOME/matlab ���A
% ���[�U��MATLABPATH��ɑ��݂��邱�Ƃ��m�F���Ă��������B���̃f�B���N�g��
% ���AMATLAB�̃X�^�[�g�A�b�v�ȑO�ɑ��݂���΁A���ɂȂ邩������܂���B
% �܂��A���[�U�̃p�X��ɑ��݂��Ȃ��ꍇ�́A���̂悤�Ƀ^�C�v���āA
%
%               addpath([getenv('HOME') '/matlab'])
%
% ���[�U�� MATLABPATH �̍ŏ��ɁA����������Ă��������B
%
% �Q�l DOC.

%   Copyright 1984-2004 The MathWorks, Inc.
