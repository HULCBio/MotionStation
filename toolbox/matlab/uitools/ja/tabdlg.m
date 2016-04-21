% TABDLG   �^�u�t���̃_�C�A���O�{�b�N�X�̍쐬�ƊǗ�
% 
% [hfig�AsheetPos] = tabdlg(...
%   'create',strings,tabDims,callback,sheetDims,offsets,default_page)
%
% create       - �_�C�A���O�̍쐬��v������t���O�B
% strings      -  �^�u�̃��x����v�f�Ƃ���Z���z��B
% tabDims      - ����2�̃Z���z��B
% tabDims{1}   - �e�X�̃^�u�̕����s�N�Z���P�ʂŎw�肷�� 'strings' �Ɠ���
%                �����̃x�N�g���B
% tabDims{2}   - strings �̍������w�肷��X�J��(�s�N�Z���P��)�B
%
% �ڍׂ́A���̃w���v��"�ǉ��I�ȋ@�\"�̃Z�N�V�������Q�Ƃ��Ă��������B
% 
% callback     - �V���ȃ^�u���I������閈�ɌĂяo�����R�[���o�b�N�֐����B
%                �R�[���o�b�N�֐��́A���̈������g���ČĂяo����܂��B
%            1) 'tabcallbk'     - �e�L�X�g�t���O
%            2) pressedTab      - �I�������^�u�̕�����
%            3) pressedTabNum   - �I�������^�u�̌�
%            4) previousTab     - �ȑO�ɑI�������^�u�̕�����
%            5) previouTabNum   - �ȑO�ɑI�������^�u�̌�
%            6) hfig            - figure�̃n���h���ԍ�
%
%                �R�[���o�b�N�֐��́A���ۂ̃^�u�̊Ǘ������ł͂Ȃ��A�^�u
%                �t���̃_�C�A���O�{�b�N�X���Ǘ����Ȃ���΂Ȃ�܂���(����
%                ���΁A�R���g���[���̉����@�\�̐؂�ւ�)�B
%
% sheetDims    - �^�u�V�[�g��[width�Aheight](�s�N�Z���P��)�B  
% offsets      - �V�[�g�̃G�b�W��figure�̋��E�̊Ԃ̃I�t�Z�b�g����Ȃ�4�v
%                �f�̃x�N�g��(�s�N�Z���P��)�B
%          [ figure�̍��[����̃I�t�Z�b�g
%            figure�̏㕔����̃I�t�Z�b�g
%            figure�̉E�[����̃I�t�Z�b�g
%            figure�̒ꂩ��̃I�t�Z�b�g ]
%
% default_page - �쐬���ɕ\�������y�[�W�ԍ��B
%
% �I�v�V��������
% font         - 2�v�f�̃Z���z��(8�Ԗڂ̈���)�B
%                {'fontname'�Afontsize}
%        
%                FactoryUicontrolFontName��FactoryUiControlFontSize�́A
%                �f�t�H���g�Ŏg�p����܂��B
%
% hfig         - figure�E�B���h�E�̃n���h��(9�Ԗڂ̈���)�B
%                ���̃I�v�V�������g�p�����ꍇ�A����'font'���w�肳��
%                �Ȃ���΂Ȃ�܂���B�f�t�H���g�̃t�H���g����]����ꍇ��
%                {} ���g�p���Ă��������B�􉽓I�Ȍv�Z�ɑ΂���e�L�X�g��
%                �͈͂𓾂邽�߂ɁAfigure ���쐬����K�v������ꍇ������
%                �܂��B���̏ꍇ�Afigure���쐬���A�􉽊w�v�Z���s���A����
%                ���� tabdlg ���Ăяo���Ă��������B������figure���A
%                �^�u�_�C�A���O�{�b�N�X�ɑ΂��Ďg�p����܂��Btabdlg���Ă�
%                �o���܂ŁAfigure��ɂ̓R���g���[����u���Ȃ��ł��������B
%
%                ����: 
%                hfig�͔񐮐��̃n���h���ԍ��ŁAfigue�͎��o�s�\�ł����
%                ���肳��Ă��܂��B
%
% �o��:
% hfig         - �V���ɍ쐬���ꂽ�^�u�_�C�A���O�{�b�N�X�̃n���h���ԍ��B
% sheetPos     - �V�[�g�ɑ΂���4�v�f�̈ʒu�x�N�g���B
%
% ����: 
% ����ȍ~�̏������s����ꍇ������̂ŁA�_�C�A���O�{�b�N�X�́A���o�s��
% �\�ł��B
%
% �ǉ��I�ȋ@�\
%
%      tabDims = tabdlg('tabdims'�Astrings�Afont)
% 
% �^����ꂽfont��string���g���ƁA��L�ŋL�q�����`���̃Z���z��tabDims��
% �o�͂��܂��B����͌����̈�������ŁA�^�u�_�C�A���O�{�b�N�X���쐬�����
% ���ɁA�����Ɏ��s����܂���B�O�����Ă��̑�����s���A�쐬����Ăяo����
% width��^����ƁA���ǂ����ʂ��o�͂��܂��B
% 
%   strings - ��L�̐������Q�ƁB
%   font    - ��L�̐������Q�ƁB
%
% ���: 
% 
%     tabDims = tabdlg('tabdims'�A{'cat'�A'bird'});
%
% ����: font�́A�I�v�V�����̈����ł��B
% ����: height�́Astring�̍����ł��B�^�u�̍����ł͂���܂���B


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:52 $
