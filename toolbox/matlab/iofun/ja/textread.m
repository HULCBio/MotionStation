% TEXTREAD �@�e�L�X�g�t�@�C������t�H�[�}�b�g�t���f�[�^�̓ǂݍ���
%
% A = TEXTREAD('FILENAME')
% A = TEXTREAD('FILENAME','',N)
% A = TEXTREAD('FILENAME','',param,value, ...)
% A = TEXTREAD('FILENAME','',N,param,value, ...) 
% �́A�t�@�C�� FILENAME ���琔�l�f�[�^��ǂ݁A1�̕ϐ��ɂ��܂��B
% �t�@�C���Ƀe�L�X�g�f�[�^���܂܂�Ă���ƁA�G���[�������܂��B
%
% [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT')
% [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N)
% [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',param,value, ...)
% [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N,param,value, ...) 
% �́A�t�@�C�� FILENAME ����f�[�^��ǂݍ���ŁA�ϐ� A,B,C,���X�ɏo�͂�
% �܂��B�X�̖߂�l�̃^�C�v�́AFORMAT ������ŗ^�����܂��B�߂������
% ���́AFORMAT ������̒��Őݒ肳��Ă���ϊ��w��q�̐��ƈ�v���Ȃ�
% ��΂Ȃ�܂���BFORMAT ������̒��̃t�B�[���h�����t�@�C���̒���
% �t�B�[���h����菭�Ȃ��ꍇ�́A�G���[�ɂȂ�܂��B�ڍׂ́AFORMAT STRING 
% ���Q�Ƃ��Ă��������B
%
% N ���w�肳��Ă���ƁAFORMAT ������� N ��g���܂��BN ��-1(�܂��́A
% �w�肳��Ă��Ȃ�)�̏ꍇ�́ATEXTREAD �͂��ׂẴt�@�C����ǂ݂܂��B
%
% param �� value �̑g���^�����Ă���ꍇ�A���[�U�́ATEXTREAD �̋����� 
% ���[�U�ݒ�\�ȃI�v�V�������g���ăJ�X�^�}�C�Y�ł��܂��BUSER CONFIG-
% URABLE OPTIONS ���Q�Ƃ��Ă��������B
%
% TEXTREAD �́A�t�@�C���̃L�����N�^�O���[�v����v�����A�ϊ����邱��
% ���ł��܂��B���̓t�B�[���h�́A�ŏ��̃X�y�[�X�܂��͋�؂�܂ł̃X�y
% �[�X���܂܂Ȃ��L�����N�^������A�܂��̓t�B�[���h������ɂȂ�܂ł�
% �ǂ��炩�Œ�`����܂��B�J��Ԃ��̋�؂�L�����N�^�́A�J��Ԃ��X�y�[�X
% �L�����N�^�𓯂����̂Ƃ��Ď�舵�����ŁA�d�v�Ȃ��̂ł��B
%
% FORMAT STRINGS(�t�H�[�}�b�g������)
%
% FORMAT �����񂪋�̏ꍇ�ATEXTREAD �͐��l�f�[�^�݂̂ɂȂ�܂��B
%
% FORMAT ������́A�X�y�[�X�L�����N�^(��������)�A�ʏ�̃L�����N�^(���͂�
% ���̂��̃X�y�[�X�łȂ��L�����N�^����v���邱�Ƃ�v��)�A�܂��͕ϊ�
% �q���܂ނ��Ƃ��ł��܂��B
%
% �󔒂��A'' �Ƃ��Đݒ肳��Ă���ꍇ�A�t�H�[�}�b�g�^�C�v�́A%s,%q,%[...]
% ����� %[^...] �ł��B�����łȂ���΁A�󔒃L�����N�^�͖�������܂��B
%
% �T�|�[�g���Ă���ϊ��q�́A���̂��̂ł��B
%        %n - ���l��ǂ� - ���������_�A���� (�{���x�z����o��)
%             %5n �́A5���܂œǂނ��A�܂��͂��̋�؂�܂œǂ�
%        %d - �����t�������l��ǂ�(�{���x�z����o��)
%             %5d �́A5���A�܂��͂��̋�؂�܂ł�ǂ�
%        %u - �����l��ǂ� (�{���x�z����o��)
%             %5u �́A5���A�܂��͂��̋�؂�܂ł�ǂ�
%        %f - ���������_�l��ǂ� (�{���x�z����o��)
%             %5f �́A5���A�܂��͂��̋�؂�܂ł�ǂ�
%        %s - �X�y�[�X�ŋ�؂�ꂽ�������ǂ� (cellstr ���o��)
%             %5s �́A5�L�����N�^�A�܂��͂��̃X�y�[�X�܂ł�ǂ�
%        %q - (�_�u���R�[�e�V�������܂�)�������ǂ�(cellstr ���o��)
%             %5q �́A5�܂ł̃R�[�e�V�������܂܂Ȃ��L�����N�^�A�܂���
%             �X�y�[�X�܂ł�ǂ�
%        %c - �L�����N�^�A�܂��́A�X�y�[�X��ǂ�(char �z����o��)
%             %5c �́A�X�y�[�X���܂� 5 �L�����N�^�܂ł�ǂ݂܂��B
%        %[...]  - ���ʂ̒��̃L�����N�^�ƈ�v���Ȃ��L�����N�^�A�܂���
%              �X�y�[�X�܂łŁA��v����L�����N�^��ǂ�(cellstr ���o��)�B
%              ] ���܂�ŁA%[]...] ���g�p
%             %5[...] 5�̃L�����N�^�܂ł�ǂ�
%        %[^...] - ���ʂ̒��̃L�����N�^�ƈ�v����܂ŁA�܂��̓X�y�[�X
%              �܂ŁA��v���Ȃ��L�����N�^��ǂ�(cellstr ���o��)�B
%              ] ���܂�ŁA%[]...] ���g�p
%             %5[^...] 5�̃L�����N�^�܂ł�ǂ�
%
% ���ӁF
% FORMAT ������́A���@���߂���O�� sprintf ���g���ĉ��߂��܂��B���Ƃ�
% �΁Atextread('mydata.dat','%s\t') �́A�L�����N�^ '\' �ɑ����L�����N�^
% 't' �ƈقȂ�^�u���T�[�`���܂��B�ڍׂ́ALanguage Reference Guide�A
% �܂���C�}�j���A�����Q�Ƃ��Ă��������B
%
% �ϊ��ŁA% �̑���� %* ���g�p���邱�Ƃɂ��ATEXTREAD �͓��͂̒���
% ��v����L�����N�^���X�L�b�v�����A���̕ϊ��ł̏o�͂͂���܂���B% �́A
% �I�v�V�����̃t�B�[���h���ɑ����A�Œ肵�����̃t�B�[���h����舵�����Ƃ�
% �ł��܂��B���Ƃ��΁A%5d �́A5���̐�����ǂ݂܂��B�����āA%f �t�H�[�}�b�g
% �́A%<width>.<prec>f �̌^���T�|�[�g���܂��B
%
% USER CONFIGURABLE OPTIONS(���[�U�ݒ�\�I�v�V����)
%
% �ݒ�\�ȃI�v�V�����̃p�����[�^��/�l
%       'bufsize'    - �o�C�g�P�ʂŕ\�����ő啶����̒���(�f�t�H���g�́A4095)
%       'commentstyle' - ���̂�����1��
%              'matlab'  -- % �̌�̃L�����N�^�͖������܂�
%              'shell'   -- # �̌�̃L�����N�^�͖������܂�
%              'c'       -- /* �� */ �Ԃ̃L�����N�^�͖������܂�
%              'c++'     -- // �̌�̃L�����N�^�͖������܂�
%       'delimiter'    - ��؂�q (�f�t�H���g�͂Ȃ�)
%       'emptyvalue'   - ��؂�q�����t�@�C�����̋�̃Z���l(�f�t�H���g��0)
%       'endofline'    - ���C���L�����N�^�̏I���(�f�t�H���g�́A�t�@�C��
%                        ���猈��)
%       'expchars'     - �w���L�����N�^(�f�t�H���g�́A'eEdD')
%       'headerlines'  - �t�@�C���̎n�߂���X�L�b�v���郉�C����
%       'whitespace'   - �X�y�[�X�L�����N�^(�f�t�H���g�́A' \b\t')
%  
% TEXTREAD �́A���m�t�H�[�}�b�g���g���ăe�L�X�g�t�@�C����ǂݍ��ނ̂�
% �𗧂��܂��B�Œ�t�H�[�}�b�g�܂��̓t���[�t�H�[�}�b�g�t�@�C�����������Ƃ�
% �ł��܂��B
%
% ���F
% �e�L�X�g�t�@�C�� mydata.dat �́A���̌^�Ńf�[�^���܂ނƉ��肵�܂��B
%        Sally    Type1 12.34 45 Yes
%        Joe      Type2 23.54 60 No
%        Bill     Type1 34.90 12 No
%          
% �e�����ϐ��ɓǂލ��݂܂�
%       [names,types,x,y,answer] = textread('mydata.dat','%s%s%f%d%s');
%
% �ŏ��̗��1�̃Z���z��ɓǂލ��݂܂�(���C���̎c��̓X�L�b�v)
%       [names]=textread('mydata.dat','%s%*[^\n]')
%
% �ŏ��̃L�����N�^�� char �z��ɓǂލ���(���C���̎c��̓X�L�b�v)
%       [initials]=textread('mydata.dat','%c%*[^\n]')
%
% Double���X�L�b�v���āA�Œ�t�H�[�}�b�g�Ƃ��ăt�@�C����ǂݍ��݂܂�
%       [names,types,y,answer] = textread('mydata.dat','%9c%5s%*f%2d%3s');
%
% �t�@�C����ǂݍ���ŁAType�ƈ�v������̂𒲂ׂ܂�
%       [names,typenum,x,y,answer]=textread('mydata.dat',.....
%                                               '%sType%d%f%d%s');
%
% M-�t�@�C����ǂݍ���ŁA������̃Z���z��ɂ��܂�
%       file = textread('fft.m','%s','delimiter','\n','whitespace','');
%
% ��؂�e�L�X�g�����t�@�C�����炷�ׂĂ̐��l�f�[�^��ǂނ��߂ɁA1��
% �o�͈����A��t�H�[�}�b�g������A�K�؂ȋ�؂�q���g���܂��B���Ƃ��΁A
% data.csv �́A�ȉ��̂��̂��܂ނƉ��肵�܂��B
% 
%       1,2,3,4
%       5,6,7,8
%       9,10,11,12
%
% �s��S�̂�P��̕ϐ��ɓǂݍ��݂܂�
%       [data] = textread('data.csv','','delimiter',',');
%
% �ŏ���2���2�̕ϐ��ɓǂݍ��݂܂�
%       [col1, col2] = textread('data.csv','%n%n%*[^\n]','delimiter',',');
%    
% ��̃Z�������t�@�C���ɑ΂��āA��̒l�̃p�����[�^���g���܂��B
% data.csv ���A�ȉ��̓��e���܂ނƂ��܂�
%       1,2,3,4,,6
%       7,8,9,,11,12
%
% ���̂悤�ȃt�@�C����ǂނɂ́A��̃Z����NaN���g���܂��B
%       [data] = textread('data.csv','','delimiter',',','emptyvalue',NaN);
%
% �Q�l�FDLMREAD, LOAD, STRREAD, SSCANF, XLSREAD.


%   Clay M. Thompson 3-3-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 01:58:28 $
