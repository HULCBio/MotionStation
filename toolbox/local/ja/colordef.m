function hh = colordef(arg1,arg2)
%COLORDEF   �F�̃f�t�H���g�̐ݒ�
%   COLORDEF WHITE�܂���COLORDEF BLACK�́A�A������figure��
%   axes�̃o�b�N�O���E���h�J���[�����܂��͍��Ńv���b�g�����悤�ɁA
%   ���[�g�̐F�̃f�t�H���g��ύX���܂��Bfigure�̃o�b�N�O���E���h�J���[
%   �̓O���C�̐F���ɕύX����A���̑����̃f�t�H���g�́A�قƂ�ǂ̃v
%   ���b�g�œK�؂ȃR���g���X�g�ɂȂ�悤�ɕύX����܂��B
%
%   COLORDEF NONE�́A�f�t�H���g��MATLAB 4�̃f�t�H���g�l�ɐݒ�
%   ���܂��B�ł��ڗ��Ⴂ�́Aaxis�̃o�b�N�O���E���h�J���[��figure��
%   �o�b�N�O���E���h�J���[�𓯂��ɂ��邽�߂ɁAaxis�̃o�b�N�O���E���h
%   ��'none'�ɐݒ肳��邱�Ƃł��Bfigure�̃o�b�N�O���E���h�J���[�́A
%   ���ɐݒ肳��܂��B
%
%   COLORDEF(FIG,OPTION)�́AFIG�Ŏ��ʂ����figure�̃f�t�H���g��
%   OPTION�Ɋ�Â��ĕύX���܂��BOPTION�́A'white','black'�܂���
%   'none'�ł��Bfigure�́A����COLORDEF�ɂ��ύX���g���O�ɁA(CLF
%   ���g����)�ŏ��ɏ�������Ȃ���΂Ȃ�܂���B
%
%   H = COLORDEF('new',OPTION)�́A�w�肵���f�t�H���g��OPTION��
%   �g���č쐬���ꂽ�V����figure�̃n���h���ԍ����o�͂��܂��B
%   ���̌`���̃R�}���h�́AGUI�Ńf�t�H���g�̊��𐧌䂵�����Ƃ��ɁA
%   �֗��Ȃ��̂ł��Bfigure�́A�t���b�V����h�����߂�'visible','off'��
%   �쐬����܂��B
%
%   �Q�l    WHITEBG.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2001/03/01 23:07:38 $
