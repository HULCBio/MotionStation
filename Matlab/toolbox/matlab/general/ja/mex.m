% MEX MEX-�֐��̃R���p�C�� 
%   MEX [option1 ... optionN] sourcefile1 [... sourcefileN]
%       [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
%   
% �ڍׁF
% MEX �́AMEX-�t�@�C�����R�[�����鋤�L���C�u�����̒��̃\�[�X���R���p�C
% �����A�����N���āAMATLAB�Ŏ��s�\�ɂ��܂��B���ʂ̃t�@�C���́A����
% �����悤�ɁA�v���b�g�t�H�[���Ɉˑ������g���q�������Ă��܂��B
%   
%   
%       solaris         - .mexsol
%       hpux            - .mexhpux
%       glnx86          - .mexglx
%       glnxi64         - .mexi64
%       Mac OS X        - .mexmac
%       Windows         - .dll
%   
% �ŏ��̃t�@�C����(�t�@�C�����̊g���q���t���Ȃ�)�́A���ʂƂ���
% MEX-�t�@�C���ɂȂ�Ƃ��̖��O�ł��B�O���Q�Ƃ𖞑����邽�߂ɁA�t���I��
% �\�[�X�A�I�u�W�F�N�g�A���C�u�����t�@�C����^���邱�Ƃ��ł��܂��B
% Windows�ł́AC�܂���Fortran�̂����ꂩ(�����ɗ��҂͕s��)���w�肷�邱��
% ���ł��܂��BUNIX�ł́AC��Fortran�̃\�[�X�t�@�C�����ɁAMEX-�t�@�C����
% �쐬����ꍇ�ɐݒ�ł��܂��BC��Fortran�����݂���ꍇ�A�^������ŏ�
% �̃\�[�X�t�@�C����MEX-�t�@�C������G�N�X�|�[�g�����G���g���|�C���g
% �����肵�܂�(MATLAB�́AC�܂���Fortran��MEX-�t�@�C���ɑ΂��āA��X��
% �G���g���|�C���g�V���{�������[�h�ł��A���s�ł��܂�)�B
%   
% �I�v�V�����t�@�C���ƃR�}���h���C���I�v�V�����͋��ɁAMEX �̋����ɉe��
% ��^���܂��B�I�v�V�����t�@�C���́A�R���p�C���A�����J�A���̃v���b�g
% �t�H�[���ˑ��̃c�[��(Windows��̃��\�[�X�����J�̂悤�Ȃ���)�̂悤��
% ��X�̃c�[���ɁA�����Ƃ��ēn�����ϐ��̃��X�g���܂݂܂��BMEX �̃R�}
% ���h���C���I�v�V�����́A�����̃c�[���ɂǂ̈������n���������ɉe��
% ��^������A���邢�� MEX �̋����̑��̖ʂ𐧌䂷�邱�Ƃ��ł���\��
% ������܂��B
%   
% �R�}���h���C���I�v�V�����F
%     ���ׂẴv���b�g�t�H�[���Ŏg�p�\�ȃI�v�V����
%   
%     -ada <sfcn.ads>
%         ���̃I�v�V�������g���āAAda�ŏ����ꂽSimulink S-function��
%         �R���p�C�����܂��B�����ŁA<sfcn.ads> �́AS-function�ɑ΂��� 
%         Package Specification�ł��B���̃I�v�V�������ݒ肳���ꍇ�A
%         -v(verbose), -g(debug), -I<pathname> �I�v�V�����݂̂��A�֘A����
%         ���܂��B���ׂĂ̑��̃I�v�V�����͖�������܂��B���ƃT�|�[�g���Ă���
%         �R���p�C���⑼�̕K�v�����́A$MATLAB/simulink/ada/examples/README
%         ���Q�Ƃ��Ă��������B
%     -argcheck
%         �����̃`�F�b�N�̕t���B����́AMATLAB API�֐��ɕs���ɓn�����
%         �������A�ݒ�ɊԈႢ�𐶂������錴���ɂȂ�܂��B-DARGCHECK ��
%         C�R���p�C���t���O�ɉ����A$MATLAB/extern/src/mwdebug.c ���\�[�X
%         �t�@�C���̃��X�g�ɉ����Ă�������(C�֐��̂�)�B
%     -c
%         �R���p�C���̂݁B�I�u�W�F�N�g�t�@�C�����쐬���܂����A
%         MEX-�t�@�C�����쐬���܂���B
%     -D<name>
%         �V���{������C�v���v���Z�b�T�ɒ�`���܂��B�\�[�X���� 
%         "#define <name>" �̎w���Ɠ����ł��B
%     -D<name>#<value>
%         �V���{�����ƒl��C�v���v���Z�b�T�ɒ�`���܂��B�\�[�X���� 
%         "#define <name> <value>" directive  �Ɠ����ł��B
%     -f <optionsfile>
%         �g�p����I�v�V�����t�@�C���̈ʒu�Ɩ��O���w�肵�܂��BMEX ��
%         �f�t�H���g�I�v�V�����t�@�C���������J�j�Y�������������܂��B
%     -g
%         �f�o�b�O�\��MEX-�t�@�C�����쐬���܂��B���̃t�@�C�����w��
%         ����ƁAMEX �́A�I�v�V�����t�@�C���̕ϐ��̒l���A�Ή�����x�[�X
%         �ϐ����g���� DEBUGFLAGS �̍Ō�ɕt�����܂�(���Ƃ��΁A
%         LINKDEBUGFLAGS �̒l�́A�����J���R�[������O�ɁALINKFLAGS �ϐ�
%         �ɕt������܂�)�B���̃I�v�V�����́A�쐬�����I�u�W�F�N�g�R�[�h
%         ���œK������MEX �����f�t�H���g�̋@�\���~���܂��B
%     -h[elp]
%         ���b�Z�[�W�����
%     -I<pathname>
%         <pathname> ���f�B���N�g���̃��X�g�ɉ����A#include �t�@�C����
%         �T�[�`���܂��B
%     -inline
%         �C�����C���s��A�N�Z�X�֐�(mx*)�B�쐬���ꂽMEX-�֐��́A
%	  MATLAB�̏����̃o�[�W�����Ƃ͐��������Ƃ�Ȃ��\��������܂��B
%	  
%     -n
%         ���s���[�h�ł͂���܂���BMEX �����s���邠����R�}���h��
%         ������܂����A���ۂɂ́A���̂ǂ�����s���܂���B
%     -O
%         �I�v�V�����t�@�C���̒��Ƀ��X�g����Ă���œK���t���O���܂܂�
%         �邱�Ƃɂ��A�I�u�W�F�N�g�R�[�h���œK�����܂��B���̃I�v�V����
%         ���w�肷��ƁAMEX �́A����ɑΉ�����x�[�X�ϐ������� OPTIMFLAGS
%         �̒��̃I�v�V�����t�@�C���ϐ��̒l��t�����܂�(���Ƃ��΁A
%         LINKOPTIMFLAGS �̒l�́A�����J���R�[������O�ɁALINKFLAGS �ϐ�
%         �ɕt������܂�)�B�f�t�H���g�Ŏ��s�����œK���́A-g �I�v�V����
%         �Ŏ��s�s�ɂȂ�A-0 �ōĎ��s�\�ɂȂ�܂��B
%     -outdir <dirname>
%         �f�B���N�g��<dirname> �ɂ��ׂĂ̏o�̓t�@�C����ݒ�
%     -output <resultname>
%         <resultname> �Ɩ��t����MEX-�t�@�C�����쐬(�K�؂�MEX-�t�@�C��
%         �g���q�������I�ɕt������܂�)�BMEX�����f�t�H���g��MEX�t�@�C��
%         �̖��O��t����@�\��ύX���܂��B
%     -setup
%         MEX �̏����̎g�p�̂��߂ɁA�f�t�H���g�Ƃ��Ďg�p���邽�߂ɁA
%         PREFDIR �ɂ��Ԃ���郆�[�U�v���t�@�C���f�B���N�g���ɔz�u����
%         ���Ƃɂ��A�R���p�C���̃I�v�V�����t�@�C����Θb�I�Ɏw�肵�܂��B
%         ���̃I�v�V�������w�肷��ƁA���̃R�}���h���C�����͉͂����󂯓���
%         ���܂���B
%     -U<name>
%         C �v���v���Z�b�T�V���{�� <name> �̔C�ӂ̏�����`���폜(-D �I�v
%         �V�����̋t)
%     -v
%         �I�v�V�����t�@�C�����������ꂽ��A�d�v�ȓ����ϐ��̒l��������A
%         ���ׂẴR�}���h���C���������l������܂��B�e�R���p�C���X�e�b�v
%         ��������A�ŏI�����N�X�e�b�v�́A�ǂ̃I�v�V������t�@�C�����g��
%         ��Ă��邩�𖾂炩�ɂ��邽�߂Ƀt���ɕ\�����܂��B�f�o�b�O���
%         �ɂ͔��ɕ֗��ł��B
%     -V5
%         MATLAB �o�[�W���� 5 �l����MEX-�t�@�C�����R���p�C�����܂��B
%         ���̃I�v�V�����́A�ڐA�̖ړI�Ŏg�����̂ŁA�P�v�I�ȉ��Ƃ��Ă�
%         �����߂ł��܂���B
%     <name>#<value>
%         �ϐ� <name> �Ɋւ���I�v�V�����t�@�C���ϐ���ύX���܂��B�ڍ�
%         �́A���L�̃v���b�g�t�H�[���ˑ��̕������Q�Ƃ��Ă��������B����
%         �I�v�V�����́A�I�v�V�����t�@�C�����������ꂽ��ɏ�������A
%         ���ׂẴR�}���h���C���̈������ΏۂɂȂ�܂��B
%   
%   Windows�v���b�g�t�H�[���ŗ��p�\�ȕt���I�ȃI�v�V����
%   
%     @<rspfile>
%         �e�L�X�g�t�@�C��<rspfile>�̓��e���R�}���h���C�������̂悤��
%         MEX �Ɋ܂܂��܂��B
%   
%   Unix�v���b�g�t�H�[���ŗ��p�\�ȕt���I�ȃI�v�V����
%   
%     -<arch>
%         �A�[�L�e�N�`��<arch>�������[�J���z�X�g�����肵�܂��B<arch>��
%         �g�p�\�Ȓl�́Asol2, hpux, hp700, alpha, ibm_rs, sgi, glnx86 
%         �̂����ꂩ�ł��B
%     -D<name>=<value>
%         C �v���v���Z�b�T�̃V���{�����ƒl���`���܂��B�\�[�X�̒��ŁA
%         "#define <name> <value>" directive �Ɠ����ł��B
%     -fortran
%         �Q�[�g�E�G�C���[�`����Fortran�ł��邱�Ƃ��w�肵�܂��B����ɂ��A
%         ���X�g���̍ŏ��̃\�[�X�t�@�C�����Q�[�g�E�G�C���[�`���ł���A�ʏ�
%         ���肵�Ă���X�N���v�g��ύX���܂��B
%     -l<name>
%         �I�u�W�F�N�g���C�u����"lib<name>"�������N���܂�("ld(1)"�ɑ΂���)�B
%     -L<directory>
%         <directory> ���I�u�W�F�N�g���C�u�������[�`�����܂ރf�B���N�g��
%         ���X�g�ɉ����܂�(�����N�ɂ�"ld(1)"�𗘗p)�B
%     <name>=<value>
%         �ϐ� <name> �ɑ΂���I�v�V�����t�@�C���ϐ���ύX���܂��B�ڍ�
%         �́A�I�v�V�����t�@�C���̃v���b�g�t�H�[���ˑ��������Q�Ƃ���
%         ���������B
%   
%   �I�v�V�����t�@�C���̏ڍׁF
%     Windows�Ɋւ���
%       �I�v�V�����t�@�C���́ADOS�o�b�`�t�@�C���ŋL�q����Ă��܂��B-f 
%       �I�v�V�������A�I�v�V�����t�@�C������ʒu���w�肷�邽�߂Ɏg�p
%       ����Ȃ��ꍇ�́AMEX �͂��̃f�B���N�g���̒��� mexopts.bat ��
%       ���t�����I�v�V�����t�@�C�����T�[�`���܂��B���Ȃ킿�A�܂��A�J��
%       ���g�f�B���N�g���A���ɁA(�֐� PREFDIR �ɂ��o�͂����)���[�U
%�@�@�@ �v���t�B�[���f�B���N�g���A�Ō�ɁA[matlabroot'\bin\win32\mexopts']
%       �ɂ��w�肳���f�B���N�g���ł��B�I�v�V�����t�@�C���Ŏw�肳���
%       ����ϐ��́A<name>#<value> �R�}���h���C���������g�p���邱�ƂŁA
%       �R�}���h���C���ŕύX���邱�Ƃ��ł��܂��B
%       <value> �̒��ɃX�y�[�X���܂܂��ꍇ�́A
%       �_�u���R�[�e�[�V�����ň͂�ł�������(���Ƃ��΁A
%       COMPFLAGS#"opt1 opt2" �̂悤�ɂ��܂�)�B��`�́A�I�v�V�����t�@
%       �C���̒��Œ�`����Ă��鑼�̕ϐ����Q�l�ɂ��܂��B���̏ꍇ�A�Q�Ƃ�
%       ���ϐ��́A�O�u�q"$"(���Ƃ��΁ACOMPFLAGS#"$COMPFLAGS opt2")
%	���g���܂��B
%       
%       ���ӁF*engmatopts.bat �Ƃ������O�� $MATLAB\bin\mexopts ���̃I
%             �v�V�����t�@�C���́A�X�^���h�A������MATLAB Engine��MATLAB 
%             MAT-API�̎��s���W���[�����쐬���邽�߂ɁAMEX(-f �I�v�V��
%             ��)�Ƌ��Ɏg�p�ł������ȏꍇ�̃I�v�V�����t�@�C���ł��B��
%             �̂悤�Ȏ��s�\�t�@�C���́A�g���q".exe"��t�����܂��B
%   
%     UNIX�Ɋւ���
%       �I�v�V�����t�@�C���́AUNIX�̃V�F���X�N���v�g�Ƃ��ċL�q����܂��B
%       -f �I�v�V�������A�I�v�V�����t�@�C������ʒu���w�肷�邽�߂Ɏg�p��
%       ��Ȃ��ꍇ�́AMEX �͂��̃f�B���N�g���̒��̃I�v�V�����t�@�C��
%       �� mexopts.sh ���T�[�`���܂��B�f�B���N�g���́A�J�����g�f�B���N�g��
%       ���̂��ɁA(�֐� PREFDIR �ɂ��o�͂����)�A�Ō�ɁA
%       [matlabroot '/bin'] �ɂ��w�肳���f�B���N�g���ł��B�I�v�V����
%       �t�@�C���Ŏw�肵���ϐ��́A<name>=<def> �R�}���h���C�������̎g�p
%       �ɂ��A�R�}���h���C���ŕύX���邱�Ƃ��ł��܂��B<def> �̒��ɃX
%       �y�[�X���܂܂��ꍇ�́A�V���O���R�[�e�[�V�����ň͂�ł�������
%	(���Ƃ��΁ACFLAGS='opt1 opt2'�̂悤�ɂ��܂�)�B��`�́A�I�v�V����
%	�t�@�C���̒��Œ�`����Ă��鑼�̕ϐ����Q�l�ɂ��܂��B���̏ꍇ�A
%	�Q�Ƃ����ϐ��́A�O�u�q�Ƃ��� "$"(���Ƃ��΁ACFLAGS='$CFLAGS opt2')
%       ���g���܂��B
%   
%       ���ӁFengopts.sh �� matopts.sh �Ƃ������O�� $MATLAB/bin ����
%             �I�v�V�����t�@�C���́A�X�^���h�A������MATLAB Engine��MATLAB
%             MAT-API�̎��s���W���[�����쐬���邽�߂ɁAMEX(-f �I�v�V����)
%             �Ƌ��Ɏg�p�ł������ȏꍇ�̃I�v�V�����t�@�C���ł��B����
%             �悤�Ȏ��s�\�t�@�C���́A�f�t�H���g�̊g���q���^������
%             ����B
%   
% ���F
% ���̃R�}���h�́A"myprog.c"��"myprog.mexsol"(Solaris���g���Ă���ꍇ)
% �ɃR���p�C�����܂��B
%   
%         mex myprog.c
%   
% �f�o�b�O���s���ꍇ�A"verbose"���[�h���g�����Ƃ́A�V���{���b�N��
% �f�o�b�O�����܂߂邱�ƂƓ��l�ɗL���ɂȂ�܂��B
%   
%         mex -v -g myprog.c
%
% �Q�l MEXDEBUG, JAVA, PCODE, PERL, PREFDIR

%   Copyright 1984-2002 The MathWorks, Inc. 
