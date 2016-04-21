% FREAD   �o�C�i���f�[�^���t�@�C������ǂݍ��݂܂�
% 
% [A, COUNT] = FREAD(FID,SIZE,PRECISION) �́A�w�肵���t�@�C������o�C�i��
% �f�[�^��ǂݍ��݁A�s�� A �ɏ����o���܂��B�I�v�V�����̏o�͈��� COUNT 
% �ɂ́A����ɓǂݍ��܂ꂽ�v�f�����o�͂���܂��B
%
% FID �́AFOPEN �œ����鐮���̃t�@�C�����ʎq�ł��B
% 
% size �����́A�I�v�V�����ł��B�w�肳��Ȃ���΁A�t�@�C���̏I�[�܂œǂݍ�
% �݁A�t�@�C���̃|�C���^�̓t�@�C���̖����ɂȂ�܂�(�ڍׂ� FEOF ���Q��)�B
% �w�肷��ꍇ�̗L���Ȓl�����Ɏ����܂��B
%
%     N      ��x�N�g����N�v�f��ǂݍ��݂܂�
%     inf    �t�@�C���̍Ō�܂œǂݍ��݂܂�
%     [M,N]  M�sN��̍s��𖞂����v�f��񏇂ɓǂݍ��݂܂��BN��inf���w��
%            �ł��܂����AM�͂ł��܂���B
%   
% ���� PRECISION �́A�ǂݍ��ރf�[�^�̃t�H�[�}�b�g���w�肷�镶����ł��B
% 'int' �܂��� 'float' �̂悤�ȃf�[�^�^�C�v���ʎq�Ƀo�C�g�P�ʂő傫�����w��
% ���鐮������ɑ��������̂��܂݂܂��B���̕�����ŁAMATLAB�ł܂���
% C�AFortran�ł𗘗p���邱�Ƃ��ł��܂��B�w�肵�Ȃ��ꍇ�́A�f�t�H���g��
% 'uchar' �ł��B 
%   
%     MATLAB  C�܂���Fortran     ����
%
%     'uchar'   'unsigned char'  �����Ȃ��L�����N�^�A8�r�b�g
%     'schar'   'signed char'    �����t���L�����N�^�A8�r�b�g
%     'int8'    'integer*1'      �����A8�r�b�g
%     'int16'   'integer*2'      �����A16�r�b�g
%     'int32'   'integer*4'      �����A32�r�b�g
%     'int64'   'integer*8'      �����A64�r�b�g
%     'uint8'   'integer*1'      �����Ȃ������A8�r�b�g
%     'uint16'  'integer*2'      �����Ȃ������A16�r�b�g
%     'uint32'  'integer*4'      �����Ȃ������A32�r�b�g
%     'uint64'  'integer*8'      �����Ȃ������A64�r�b�g
%     'single'  'real*4'         ���������_�A32�r�b�g
%     'float32' 'real*4'         ���������_���A32�r�b�g
%     'double'  'real*8'         ���������_�A64�r�b�g
%     'float64' 'real*8'         ���������_���A64�r�b�g
%
% ���Ƃ��΁A
%
%       type fread.m
%
% �́AFREAD �w���v���܂�M-�t�@�C����\�����܂��B���̃R�}���h���V�~��
% ���[�V��������ɂ́A���̂悤�ɓ��͂��Ă��������B
%
%       fid = fopen('fread.m','r');
%       F = fread(fid);
%       s = char(F')
%
% �R�}���h FOPEN �́A�ǂݍ��ݗp��MATLAB�p�X��̖��O'fread.m'������
% M-�t�@�C�����I�[�v�����܂��B�R�}���h FREAD �́A�f�t�H���g SIZE �Ƃ��� inf
% �������A�f�t�H���g�� PRECISION �Ƃ��� 'uchar' �����肵�Ă��܂��B�t�@�C��
% �S�̂�ǂݍ���ŁA�����Ȃ��L�����N�^���N���X 'double' (�{���x���������_)
% �̗�x�N�g���ɕϊ����܂��B�ǂݎ��\�ȃe�L�X�g�Ƃ��Č��ʂ�\������
% ���߁A'double' �̗�x�N�g���͍s�x�N�g���ɓ]�u����A�֐� CHAR ���g���ăN
% ���X 'char' �ɕϊ�����܂��B
%
% ���̃v���b�g�t�H�[���ŗL�̏����̓T�|�[�g����Ă��܂����A���ׂẴv
% ���b�g�t�H�[����œ����T�C�Y�ł��邱�Ƃ͕ۏ؂���Ă��܂���B
% 
%     MATLAB    C�܂���Fortran   ����
%     'char'    'char*1'         �L�����N�^�A8�r�b�g(�����t���܂��͕����Ȃ�)
%     'short'   'short'          �����A16�r�b�g
%     'int'     'int'            �����A32�r�b�g
%     'long'    'long'           �����A32�܂���64�r�b�g
%     'ushort'  'unsigned short' �����Ȃ������A16�r�b�g
%     'uint'    'unsigned int'   �����Ȃ������A32�r�b�g
%     'ulong'   'unsigned long'  �����Ȃ������A32�r�b�g�܂���64�r�b�g
%     'float'   'float'          ���������_���A32�r�b�g
%
% ���̏����́A�o�C�g�ł͂Ȃ��A�r�b�g�̓��̓X�g���[���Ɏʑ����܂��B
%
%     'bitN'                     �����t�������AN�r�b�g (1< = N< = 64)
%     'ubitN'                    �����Ȃ������AN�r�b�g (1< = N< = 64)
%
% ���̓X�g���[�����o�C�g�ŁAFREAD ������v�f�ɑ΂��ĕK�v�ȃo�C�g����
% �ǂ�ł���r���Ńt�@�C���̏I�[(FEOF���Q��)�ɒB�����ꍇ�́A�����I�Ȍ���
% �͖�������܂��B�������A���̓X�g���[�����r�b�g�̏ꍇ�́A�����I�Ȍ��ʂ�
% �Ō�̒l�Ƃ��ďo�͂���܂��B�t�@�C���̏I�[�ɒB����O�ɃG���[��������
% �ꍇ�́A���̓_�܂łɓǂݍ��܂ꂽ�v�f�݂̂����p����܂��B
%
% �f�t�H���g�ł́A���l�́A�N���X'double'�̔z��ɏo�͂���܂��Bdouble �ȊO��
% �N���X�Ɋi�[���ꂽ���l���o�͂��邽�߂ɂ́A���[�U�̃\�[�X�t�H�[�}�b�g��
% �܂��w�肵�� PRECISION �������쐬���A���̌�� '=>' �𑱂��āA�ŏI�I��
% ���[�U�w��t�H�[�}�b�g���w�肵�܂��B�w��̂��߂�MATLAB�N���X�^�C�v��
% ���m�Ȗ��O���g���K�v�͂���܂���(�ڍׂ� CLASS ���Q��)�B���O�́A�ł�
% �K�؂� MATLAB �N���X�^�C�v�̖��O�ɕϊ�����܂��B�\�[�Y�t�H�[�}�b�g�Ƒ�
% ��̃t�H�[�}�b�g�������ꍇ�́A���̏ȗ������L�@���g���܂��B
%
%       *source
%
% �́A���̂��Ƃ��Ӗ����܂��B
%
%       source=>source
%
%  ���Ƃ��΁A
%
%       uint8=>uint8               ����́A�����Ȃ���8�r�b�g�����œǂݍ��݁A
%                                  �����Ȃ�8�r�b�g�����z��ŕۑ����܂��B  
%
%       *uint8                     ��̏ȗ��`�ł��B
%
%       bit4=>int8                 �o�C�g�P�ʂň��k���ꂽ�����t��4�r�b�g
%                                  ������ǂݍ��݁A�����t��8�r�b�g�����z��
%                                  �ɕۑ����܂�(�e4�r�b�g�����́A1��
%                                  8�r�b�g�����ɂȂ�܂�)�B
%
%       double=>real*4             �{���x�œǂݍ��݁A32�r�b�g�̕��������_
%                                  �z��Ƃ��ĕϊ����A�ۑ����܂��B
%
% [A, COUNT] = FREAD(FID,SIZE,PRECISION,SKIP) �́A�e PRECISION �l��
% �ǂݍ��܂ꂽ��ŃX�L�b�v����o�C�g�����w�肷����� SKIP ���܂�ł��܂��B
% PRECISION ���A�r�b�g�\�[�X�t�H�[�}�b�g�A���Ƃ��΁A'bitN' �� 'ubitN' ��
% �w�肷��ꍇ�́ASKIP �����̓X�L�b�v����o�C�g���Ɖ��߂��܂��B
%
% SKIP ���g����ꍇ�A������ PRECISION �́A���� PRECISION �̃\�[�X
% �t�H�[�}�b�g�̑O�ɁA'N*'�̌^�̐��̐����̌J��Ԃ��t�@�N�^���܂�ł��܂��B
% ���Ƃ��΁A'40*uchar' �̂悤�ɂł��BPRECISION �ɑ΂��� 40*uchar ��
% '40*uchar=>double' �Ɠ����ł����A'40*uchar=>uchar' �Ƃ͈قȂ�܂��BSKIP
% �������w�肳�ꂽ�ꍇ�AFREAD �͍ő�Œl�̌J��Ԃ��t�@�N�^(�f�t�H���g��1)
% ��ǂݍ��݁ASKIP �����ɂ��w�肳�ꂽ���������͂��X�L�b�v���܂��B������
% ���̃u���b�N��ǂݍ��݁A���͂��X�L�b�v���ASIZE �Ŏw�肵�������ǂݍ�
% �܂��܂ő����܂��BSKIP �������w�肳��Ă��Ȃ��ꍇ�́A�J��Ԃ��t�@�N�^
% �͖�������܂��B�X�L�b�v�t���̌J��Ԃ��́A�Œ蒷�̃��R�[�h�����A����
% �t�B�[���h���̃f�[�^�𒊏o����̂ɗL���ł��B
%
% ���Ƃ��΁A
%
%       s = fread(fid,120,'40*uchar=>uchar',8);
%
% �́A8�L�����N�^���������ꂽ40�u���b�N�̒���120�L�����N�^��ǂݍ���
% �܂��Bs �̃N���X�^�C�v�́A'uint8' �ł��邱�Ƃɒ��ӂ��Ă��������B
% ����́A�����̃t�H�[�}�b�g 'uchar' �ɑΉ�����K�؂ȃN���X�ł��B40��
% 120�̖񐔂Ȃ̂ŁA�Ō�̃u���b�N�̓ǂݍ��݂́A�t���u���b�N�ɂȂ�܂��B
% �t���u���b�N�Ƃ́A�ŏI�̃X�L�b�v���A�R�}���h���I������O�Ɏ��s�����
% ���̂ł��B�Ō�̃u���b�N�ǂݍ��݂��t���u���b�N�łȂ��ꍇ�́AFREAD ��
% �X�L�b�v�t���ŏI�����܂���B
%
% Big Endian�t�@�C����Little Endian�t�@�C���̓ǂݍ��ݕ��ɂ��ẮA
% FOPEN ���Q�Ƃ��Ă��������B
%
% �Q�l�FFWRITE, FSEEK, FSCANF, FGETL, FGETS, LOAD, FOPEN, FEOF.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:10 $
%   Built-in function.
