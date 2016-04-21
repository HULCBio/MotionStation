% FOPEN   �t�@�C���̃I�[�v��
% 
% FID = FOPEN(FILENAME) �́A�ǂݍ��݂̃A�N�Z�X�p�Ƀt�@�C�� FILENAME 
% ���I�[�v�����܂�(PC�V�X�e���ł́Afopen �̓o�C�i���ǂݍ��݃A�N�Z�X�p��
% �t�@�C�����I�[�v�����܂�)
%
% FILENAME �́AMATLABPATH ���Ε����p�X���ł��\���܂���B�ǂݍ���
% �p�Ƀt�@�C�����I�[�v�����Ă��āA�J�����g�̍�ƃf�B���N�g���Ō�����Ȃ�
% �ꍇ�́AFOPEN �͂��̃f�B���N�g���̉���MATLAB�T�[�`�p�X��T���܂��B
%
% FID �́A�t�@�C�����ʎq�ƌĂ΂��X�J����MATLAB�����ł��B�t�@�C����
% ���o�̓��[�`���ւ̍ŏ��̈����Ƃ��āAfid ���g�p���܂��BFOPEN �Ńt�@�C
% �����I�[�v���ł��Ȃ��ꍇ�́A-1 ���o�͂���܂��B
%
% FID = FOPEN(FILENAME,PERMISSION) �́APERMISSION �Ŏw�肵�����[�h
% �Ńt�@�C��FILENAME ���I�[�v�����܂��BPERMISSION �́A���̕�����̂�
% ���ꂩ�ł��B
%   
%     'r'     �ǂݍ���
%     'w'     �����o��(�K�v�Ȃ�΍쐬���܂�)
%     'a'     �ǉ�(�K�v�Ȃ�΍쐬���܂�)
%     'r+'    �ǂݍ��݂Ə����o��(�쐬���܂���)
%     'w+'    �ǂݍ��݂Ə����o���̂��߂ɑł��؂�܂��͍쐬
%     'a+'    �ǂݍ��݂ƒǉ�(�K�v�Ȃ�΍쐬���܂�)
%     'W'     �����I�ȃt���b�V���Ȃ��ŏ����o��
%     'A'     �����I�ȃt���b�V�����Ȃ��Œǉ�
%   
% �t�@�C���́A�o�C�i�����[�h(�f�t�H���g)�܂��̓e�L�X�g���[�h�ŃI�[�v��
% ���邱�Ƃ��ł��܂��B�o�C�i�����[�h�ł́A���ʂȎ�舵����ݒ肷��L
% �����N�^�͂���܂���BPC�ł̃e�L�X�g���[�h�ł́A�j���[���C���L�����N
% �^�̑O�Ɉʒu����L�����b�W���^�[���́A���͂ł͍폜����A�o�͂Ńj���[
% ���C���L�����N�^�̑O�ɕt������܂��B�e�L�X�g���[�h�ŃI�[�v������ɂ́A
% �p�[�~�b�V����������� 't' �������Ă��������B���Ƃ��΁A'rt' �� 'wt+' 
% �ł�(Unix�ł́A�e�L�X�g���[�h�ƃo�C�i�����[�h�͓����Ȃ̂ŁA���̂��Ƃ�
% �Ӗ�������܂���B�������APC ��ł͌���I�ȈႢ�������Ă��܂�)�B
%
% �t�@�C�����X�V���[�h('+')�ŃI�[�v�������ꍇ�́AFREAD, FSCANF, 
% FGETS, FGETL �̂悤�ȓ��̓R�}���h�́AFSEEK �� FREWIND �����荞��
% ���Ȃ��ƁAFWRITE �� FPRINTF �̂悤�ȏo�̓R�}���h�������Ɏ��s�ł���
% ����B�t�������ł��B�܂�AFWRITE �� FPRINTF �̂悤�ȏo�̓R�}���h�́A
% FSEEK �� FREWIND �����荞�܂��Ȃ��ƁAFREAD, FSCANF, FGETS, FGETL 
% �̂悤�ȓ��̓R�}���h�������Ɏ��s�ł��܂���B
% 
% 2�̃t�@�C�����ʎq�������I�Ɏg�p�\�ɂȂ�A�I�[�v������K�v�͂����
% ����B�����́AFID = 1(�W���o��)��FID = 2(�W���G���[)�ł��B
% 
% [FID�AMESSAGE] = FOPEN(FILENAME,PERMISSION) �́A�t�@�C���𐳏��
% �I�[�v���ł��Ȃ��ꍇ�́A�V�X�e���ˑ��̃G���[���b�Z�[�W���o�͂��܂��B
%
% [FID�AMESSAGE] = FOPEN(FILENAME,PERMISSION,MACHINEFORMAT) �́A
% �w�肵�� PERMISSION ���g���Ďw�肵���t�@�C�����J���AFREAD ���g����
% �f�[�^��ǂݍ��ނ��AFWRITE ���g���� MACHINEFORMAT �ŗ^�����鏑
% �������f�[�^�������o���܂��BMACHINEFORMAT �́A���̕�����̂���
% �ꂩ�ł��B
%
% 'native'      �܂���'n' - ���݉ғ����Ă���}�V���̐��l����(�f�t�H���g)
% 'ieee-le'     �܂���'l' - little-endian�o�C�g��IEEE���������_
% 'ieee-be'     �܂���'b' - big-endian�o�C�g��IEEE���������_
% 'vaxd'        �܂���'d' - VAX D���������_�����VAX ordering
% 'vaxg'        �܂���'g' - VAX G���������_�����VAX ordering
% 'cray'        �܂���'c' - big-endian�o�C�g��Cray���������_
% 'ieee-le.l64' �܂���'a' - little-endian�o�C�g��IEEE���������_��64�r�b�g
%                           �����O�f�[�^�^�C�v
% 'ieee-be.l64' �܂���'s' - big-endian�o�C�g��IEEE���������_��64�r�b�g
%                           �����O�f�[�^�^�C�v
% 
% [FILENAME,PERMISSION,MACHINEFORMAT] = FOPEN(FID) �́A�^����ꂽ
% �t�@�C�����ʎq�Ɋւ���t�@�C�����A�p�[�~�b�V�����A�}�V���t�H�[�}�b�g��
% �o�͂��܂��BFID �����݂��Ȃ���΁A�e�ϐ��ɑ΂��ċ�̕����񂪏o�͂���܂��B
%
% FIDS = FOPEN('all') �́A���[�U�ɂ��J�����g�ɊJ����Ă��邷�ׂẴt�@�C��
% �̎��ʎq(1�܂���2�ł͂���܂���)�ł���s�x�N�g�����o�͂��܂��B
% 
% �p�[�~�b�V���� 'W' �� 'A' �́A�e�[�v�h���C�o�p�ɐ݌v����A�o�͑���̌�ɃJ
% �����g�̏o�̓o�b�t�@�̃t���b�V���������I�ɍs���܂���B���Ƃ��΁A�����t
% ���b�V���Ȃ��̏����o���̂��߂ɁASPARCstation���1/4"�J�[�g���b�W�e�[�v
% ���J���ɂ́A���̂悤�ɂ��܂��B
% 
%           fid = fopen('/dev/rst0','W')
%   
% �Q�l�FFCLOSE, FREWIND, FREAD, FWRITE, FPRINTF.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:08 $
%   Built-in function.
