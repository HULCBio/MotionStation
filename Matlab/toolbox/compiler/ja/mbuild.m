% MBUILD   C�\�[�X�R�[�h������s�\�t�@�C�����R���p�C��
%
%   MBUILD [options1 ... optionN] sourcefiles1 [... sourcefileN]
%          [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
%          [exportfile1 ... exportfileN]
%
% ����:
%   MBUILD�́A�X�^���h�A�������s�\�t�@�C���⋤�L���C�u�����ɁAMATLAB
%   C/C++ Math Library��MATLAB C/C++ Graphics Library�ɂ���֐����R�[��
%   ����\�[�X�t�@�C�����R���p�C���A�����N���܂��B
%   
%   �ŏ��Ɏw�肳���(�t�@�C�����̊g���q�̂Ȃ�)�t�@�C�����́A�쐬�����
%   ���s�\�t�@�C�����ɂȂ�܂��B�ǉ�����\�[�X��I�u�W�F�N�g�A���C�u
%   �����t�@�C�����A�O���Q�Ƃ𖞂������߂Ɏw�肷�鎖���ł��܂��BC��C++
%   �\�[�X�t�@�C���̂ǂ��炩������A���s�\�t�@�C���쐬���Ɏw�肳��܂��B
%   �X�ɁAC��C++�̃\�[�X�t�@�C���͋��ɁAC�t�@�C����C++���݊���������΁A
%   �����Ɏw�肷�鎖���ł��A-lang cpp �I�v�V�������w�肳��܂��B
%   (���L-lang �Q��)
%   
%   �I�v�V�����t�@�C���ƃR�}���h���C���I�v�V�����͋���MBUILD�̍s����
%   �e����^���܂��B�I�v�V�����t�@�C���ɂ́A�R���p�C���A�����J�A���̑�
%   �v���b�g�t�H�[���ˑ��̃c�[��(Windows�̃��\�[�X�����J�Ȃ�)�ȂǗl�X��
%   �c�[���Ɉ�����n���ϐ����X�g������܂��BMBUILD�ւ̃R�}���h���C��
%   �I�v�V�����ɂ́A�����c�[���ɓn���������ɉe����^���邩������
%   �܂���B�܂�MBUILD�̍s���̑��̖ʂ��R���g���[�����邩������܂���B
%   
% �R�}���h���C���I�v�V����:
%   �S�Ẵv���b�g�t�H�[���ɂ����ė��p�\�ȃI�v�V�����́A�ȉ��̒ʂ�ł��B
%   
%   -c
%       �R���p�C���̂݁B�����N�͍s���܂���B
% 
%   -D<name>
%       C/C++�v���v���Z�b�T�ɃV���{�������`���܂��B
%   -D<name>[#<def>]
%       C/C++�v���v���Z�b�T�ɃV���{�����ƒl���`���܂��B�\�[�X����
%       "#define <name> <value>" directive �Ɠ����ł��B
%   -f <optionfile>
%       ���p����I�v�V�����t�@�C���̈ʒu�Ɩ��O���w�肵�܂��BMBUILD��
%       �f�t�H���g�̃I�v�V�����t�@�C���������J�j�Y���𖳌��ɂ��܂��B
%   -g
%       �f�o�b�O�\���s�t�@�C�����쐬���܂��B���̃I�v�V�������w�肳��
%       ��ƁAMBUILD�͑��������{�̕ϐ�������DEBUGFLAGS�ŏI���I�v
%       �V�����t�@�C���ϐ��l�������܂��B(�Ⴆ�΁ALINKDEBUGFLAGS�l�́A
%       �����J�̃R�[���O��LINKFLAGS�l�ɉ������܂��B) ���̃I�v�V������
%       �I�u�W�F�N�g�R�[�h���œK������MBUILD�̃f�t�H���g�̍s����
%       �ł��Ȃ��悤�ɂ����܂��B
%   -h[elp]
%       ���̃��b�Z�[�W���v�����g���܂��B
%   -I<pathname>
%       <pathname>��#include�t�@�C������������f�B���N�g�����X�g�ɒǉ�
%       ���܂��B
%   -inline
%       �s��A�N�Z�X�֐�(mx*)���C�����C�������܂��B�쐬���ꂽ���s�\��
%       �t�@�C���́AMATLAB C/C++ Math Library��MATLAB C/C++ Graphics 
%       Library�̏����̃o�[�W�����Ƃ͌݊������Ȃ���������܂���B
%   -lang <language>
%       �R���p�C��������w�肵�܂��B<language>�́Ac��������cpp�ƂȂ�܂��B
%       �f�t�H���g�ł́AMBUILD�̓\�[�X�t�@�C���̊g���q�𒲂ׂė��p����
%       �R���p�C��(C���邢��C++)�����肵�܂��B���̃I�v�V�����́A����
%       ���J�j�Y���𖳌��ɂ��܂��B
%   -n
%       ���s���s��Ȃ��t���O�BMBUILD���ʂ̕��@�Ŏ��s����R�}���h���o��
%       ���܂����A���ۂɂ͎��s����܂���B
%   -O
%       �I�v�V�����t�@�C�����Ń��X�g����Ă���œK���t���O���܂ނ��Ƃ�
%       ���A�I�u�W�F�N�g�R�[�h���œK�����܂��B�������̃I�v�V������
%       �w�肳��Ȃ���΁AMBUILD�ɂ͑��������{�ϐ�������OPTIMFLAGS��
%       �I���I�v�V�����t�@�C���̕ϐ��l���������܂��B(�Ⴆ�΁A�����J
%       �R�[���O�ɁALINKOPTIMFLAGS�̒l��LINKFLAGS�l�ɉ������܂��B)
%       �Ȃ��œK���́A�f�t�H���g�ł͗L���ŁA-g�I�v�V�����ɂ�薳����
%       �Ȃ�܂����A-O�ɂ��ĂїL���ɂȂ�܂��B
%   -outdir <dirname>
%       �S�Ă̏o�̓t�@�C�����f�B���N�g��<dirname>�ɒu���܂��B
%   -output <resultname>
%       ���s�\�t�@�C��<resultname>���쐬���܂�(�K�؂Ȏ��s�\�g���q
%       �������I�ɕt�����܂�)�BMBUILD�̃f�t�H���g�ł̎��s�t�@�C������
%       ���J�j�Y���𖳌��ɂ��܂��B
%   -setup
%       "<UserProfile>\Application Data\MathWorks\MATLAB\R12"(Windows
%       �̏ꍇ)�������́A$HOME/.matlab/R12 (UNIX�̏ꍇ)�ɒu�����ɂ��
%       MBUILD�̎��񂩂�̋N���Ńf�t�H���g�Ƃ��ė��p�����R���p�C��
%       �I�v�V�����t�@�C����Θb�`���Ŏw�肵�܂��B���̃I�v�V�������w��
%       �����ƁA���̃R�}���h���C�����͎͂󂯕t���܂���B
%   -U<name>
%       C�v���v���Z�b�T�V���{��<name>�̏�����`���O���܂��B
%       (-D�I�v�V�����̋t�ł��B)
%   -v
%       �I�v�V�����t�@�C������������A�S�ẴR�}���h���C���̈���������
%       ���ꂽ��ŁA�d�v�ȓ����ϐ��̒l���o�͂��܂��B���̃I�v�V������
%       �t�@�C�������p���ꂽ�������؂��邽�߂ɏ\���ɕ]�������e�R���p
%       �C���̃X�e�b�v��Ō�̃����N�X�e�b�v���o�͂��܂��B�f�o�b�O��
%       �΂��Ĕ��ɗL���ł��B
%   <name>#<value>
%       �ϐ�<name>�ŁA�I�v�V�����t�@�C���ϐ����d�ˏ������ď����܂��B��
%       �ׂ̏��́A��q�̃v���b�g�t�H�[���ˑ��̃I�v�V�����t�@�C���̋c
%       �_���Q�Ƃ��ĉ������B
%       ���̃I�v�V�����́A�I�v�V�����t�@�C������������A�S�ẴR�}���h
%       ���C���������������ꂽ��ŏ�������܂��B
% 
% Windows�v���b�g�t�H�[���ł́A�ȉ��̒ǉ��I�v�V���������p�\�ł��B:
% 
%   @<rspfile>
%       MBUILD�ɃR�}���h���C�������Ƃ��āA�e�L�X�g�t�@�C��<rspfile>��
%       ���e��g�ݍ��݂܂��B
% 
% Unix�v���b�g�t�H�[���ł́A�ȉ��̒ǉ��I�v�V���������p�\�ł��B:
% 
%   -<arch>
%       ���[�J���z�X�g���A�[�L�e�N�`��<arch>�ł���Ɖ��肵�܂��B
%       <arch>�Ŏ�蓾��l�ɂ́Asol2, hpux, hp700, alpha, ibm_rs, sgi,
%       glnx86������܂��B
%   -D<name>=<value>
%       C�v���v���Z�b�T�ɃV���{�����ƒl���`���܂��B�\�[�X����
%       "#define <name> <value>" �f�B���N�e�B�u�Ɠ����ł��B
%   -l<name>
%       ("ld(1)"�ɑ΂���) �I�u�W�F�N�g���C�u����"lib<name>"�ƃ����N
%       ���܂��B
%   -L<directory>
%       ("ld(1)"�𗘗p���ă����N����) �I�u�W�F�N�g���C�u�������[�`����
%       ����f�B���N�g�����X�g��<directory>��ǉ����܂��B
%   <name>=<value>
%       �ϐ�<name>�ŃI�v�V�����t�@�C���ϐ����d�ˏ������ď����܂��B�ڍ�
%       �ɂ��ẮA��q�̃v���b�g�t�H�[���ˑ��̃I�v�V�����t�@�C����
%       �c�_���Q�Ƃ��ĉ������B
% 
% ���L���C�u�����ƃG�N�X�|�[�g�t�@�C��:
%   MBUILD��C�\�[�X�R�[�h���狤�L���C�u�������쐬���鎖���ł��܂��B
%   ����1�������͕����̊g���q".export"�̃t�@�C����MBUILD�ɓn�����ƁA
%   ���L���C�u�������쐬���܂��B.export�t�@�C���́A�G�N�X�|�[�g�����
%   �V���{�����������́A(�R�����g�s�Ƃ��Ĉ�����悤��)�ŏ��̍s�� # 
%   ���邢�� * �Ŏn�܂�悤�ȍs���܂܂��S���̃e�L�X�g�t�@�C���łȂ����
%   �Ȃ�܂���B����������.export�t�@�C�����w�肳�ꂽ�ꍇ�́A�S�Ă̎w��
%   ���ꂽ.export�t�@�C���ɂ���S�ẴV���{�������G�N�X�|�[�g����܂��B
% 
% �I�v�V�����t�@�C���̏ڍ�:
%   Windows�ł�:
%     �I�v�V�����t�@�C����DOS�̃o�b�`�t�@�C���Ƃ��ċL�q����܂��B����
%     �I�v�V�����t�@�C�����ƈʒu���w�肷�邽�߂ɁA-f�I�v�V���������p
%     ����Ȃ��ꍇ�́AMBUILD��compopts.bat�Ƃ����I�v�V�����t�@�C����
%     �T���܂��B�T���f�B���N�g���́A�悸�J�����g�f�B���N�g���A������
%     ���� "<UserProfile>\ApplicationData\MathWorks\MATLAB\R12" �ł��B
%     �I�v�V�����t�@�C�����Ŏw�肳��Ă���ǂ̕ϐ����A�R�}���h���C����
%     ���� <name>#<value> �𗘗p���邱�ƂŁA�R�}���h���C���ŏd�ˏ�������
%     �������Ƃ��ł��܂��B����<value>�ɃX�y�[�X���܂܂�Ă���ꍇ�A
%     �_�u���N�H�[�g�ŋ��܂�Ȃ���΂Ȃ�܂���(��FCOMPFLAGS#"opt1 opt2")�B
%     ���̒�`�́A�I�v�V�����t�@�C�����Œ�`����Ă��鑼�̕ϐ��ɓK�p����
%     ���Ƃ��ł��܂��B���̏ꍇ�A�Q�Ƃ����ϐ��̑O��"$"��t���܂��B
%     (��FCOMPFLAGS#"$COMPFLAGS opt2")
% 
%   UNIX�ł�:
%     �I�v�V�����t�@�C���́AUNIX�̃V�F���X�N���v�g�ŏ�����Ă��܂��B
%     ����-f�I�v�V�������A�I�v�V�����t�@�C�����₻�̈ʒu���w�肷�邽�߂�
%     ���p����Ȃ��ꍇ�́AMBUILD���I�v�V�����t�@�C����mbuildopts.sh��
%     �T���܂��B�T���f�B���N�g���́A�悸�J�����g�f�B���N�g��(.)�A������
%     $HOME/.matlab/R12�A���ꂩ�玟��$MATLAB/bin�ł��B�I�v�V�����t�@�C��
%     ���Ŏw�肳��Ă��邻�̕ϐ����A�R�}���h���C������<name>=<def> ��
%     ���p���邱�ƂŁA�R�}���h���C���ŏd�ˏ������ď������Ƃ��ł��܂��B
%     ����<def>�ɃX�y�[�X���܂܂�Ă���ꍇ�A�V���O���N�H�[�g�ŋ��܂�
%     �Ȃ���΂Ȃ�܂���(��FCFLAGS='opt1 opt2')�B���̒�`�́A�I�v�V����
%     �t�@�C�����Œ�`����鑼�̕ϐ��ɓK�p���邱�Ƃ��ł��܂��B���̏ꍇ�A
%     �Q�Ƃ����ϐ��̑O��"$"��t���܂�(��FCFLAGS='$CFLAGS opt2')�B
% 
% ��:
%     ���̃R�}���h�́A"myprog.c"���R���p�C�����āA(Windows��Ŏ��s����
%     �ꍇ��)"myprog.exe"���쐬���܂��B:
% 
%       mbuild myprog.c
% 
%     �f�o�b�O����ꍇ�́A�V���{���b�N�ȃf�o�b�O�����܂ނ悤��"�璷"
%     ���[�h�𗘗p����ƁA�L���ł��B
% 
%       mbuild -v -g myprog.c
% 
%     ���̃R�}���h�́A"mylib.c"���R���p�C�����āA(Windows��Ŏ��s����
%     �ꍇ��)"mylib.dll"���쐬���܂��B"mylib.dll"�́A"mylib.exports"��
%     �Ń��X�g���ꂽ�V���{�����G�N�X�|�[�g���܂��B
% 
%       mbuild mylib.c mylib.exports


% $Revision: 1.8.4.1 $  $Date: 2003/06/25 14:31:24 $
% Copyright 1984-2002 The MathWorks, Inc.
