% MCC   MATLAB ���� C/C++ Compiler (Version 3.0)��
%
% MCC [-options] fun [fun2 ...] [mexfile1 ...] [mlibfile1 ...]
%
% fun.m��fun.c�܂���fun.cpp�ɕϊ����A�I�v�V�����Ƃ��ăT�|�[�g����Ă���
% �o�C�i���t�@�C�����쐬���܂��B�f�t�H���g�ł́A�����t�@�C�����J�����g
% �f�B���N�g���ɕۑ����܂��B
%
% ������M-�t�@�C�����w�肳�ꂽ�ꍇ�́AC�܂���C++�t�@�C���́A�e�X��
% M-�t�@�C���ɑ΂��Đ�������܂��B
%
% C�܂��̓I�u�W�F�N�g�t�@�C�����w�肳�ꂽ�ꍇ�́A�����͐������ꂽ
% C�t�@�C���Ƌ���MEX�܂���MBUILD�ɓn����܂��B
%
% MEX-�t�@�C�����w�肳�ꂽ�ꍇ�́AMCC�̓��b�p�[�R�[�h���쐬���A�R���p�C��
% ���ꂽM-�t�@�C������w�肳�ꂽMEX-�t�@�C�����쐬���܂��B�܂��A����
% ���O��MEX-�t�@�C����M-�t�@�C���������f�B���N�g���ɂ���ꍇ�AMEX-�t�@�C��
% ���w�肷��΁AMCC��M-�t�@�C���̑����MEX-�t�@�C���𗘗p���܂����A
% ����ȊO�ł́AMEX-�t�@�C�������AM-�t�@�C�����D�悳��܂��B
%
% MLIB�t�@�C���́AMCC�ɂ���č쐬����鋤�L���C�u�������̃t�@���N�V����
% ���L�q���܂�(��q��-W lib���Q��)�BMLIB�t�@�C�����w�肷��ƁA����
% ���C�u�������ɂ���t�@���N�V�����𗘗p����K�v������Ώ��MLIB�t�@�C��
% �̑Ή����鋤�L���C�u�����ƃ����N����悤��MCC�ɓ`���܂��B
% MLIB�t�@�C���ƑΉ����鋤�L���C�u�����t�@�C���́A����f�B���N�g������
% �Ȃ���΂Ȃ�܂���B
%
% �����R���t���N�g�����I�v�V������MCC�ɓn���ꂽ�ꍇ�́A�R���t���N�g����
% �I�v�V�����̈�ԉE�̂��̂����p����܂��B
%
% �I�v�V����:
%
% A <option> ���߂�ݒ肵�܂��B���̕\�́A�g�p�\�� <option>������
% �Ƃ��̌��ʂ��܂Ƃ߂Ă��܂��B
%
%       annotation:all (*)  - �\�[�XM-�t�@�C�����̑S�Ă̍s�́A�쐬�����
%                             �o�̓t�@�C���ɃR�����g�Ƃ��ċL�q����܂��B
%
%       annotation:comments - �\�[�XM-�t�@�C�����̃R�����g�́A�쐬�����
%                             �o�̓t�@�C���ɃR�����g�Ƃ��ċL�q����܂��B
%
%       annotation:none     - �\�[�XM-�t�@�C�����̃e�L�X�g�́A�쐬�����
%                             �o�̓t�@�C���ɂ͋L�q����܂���B
%
%       line:on             - �������ꂽ�o�̓t�@�C���̊e�s�ɁA
%                             �Ή�����M-�t�@�C���̍s�ԍ����ǉ�����܂��B
%
%       line:off (*)        - #line���߂͐�������܂���B
%
%       debugline:on        - ���s���G���[���b�Z�[�W�́A�\�[�X�t�@�C����
%                             �ƃG���[���������s�ԍ������|�[�g���܂��B
%
%       debugline:off (*)    - ���s���G���[���b�Z�[�W�́A�G���[��������
%                              �\�[�X�Ɋւ���������|�[�g���܂���B
%
%       (*) �́A�f�t�H���g�̐ݒ�������܂��B
%
%   b  M-�t�@�C���̗^����ꂽ���X�g�ɑ΂��āAMS Excel �݊��\���̊֐�
%      ���쐬���܂��B
%
%   B <filename>  �o���h���t�@�C�����w�肵�܂��B<filename> �́ACompiler
%       �̃R�}���h���C���I�v�V�������܂ރe�L�X�g�t�@�C���ł��BCompiler��
%       "-B <filename>" ���o���h���t�@�C���̓��e�Œu������������̂悤��
%       ���삵�܂��B�����̃t�@�C�����̐V�����s��������A�󔒂Ƃ��Ĉ���
%       ��܂��B
%       The MathWorks�́A�ȉ��ɑ΂��ăI�v�V�����t�@�C����p�ӂ��Ă��܂��B
%
%           ccom      Windows��ŁAC COM �ƌ݊����̂���I�u�W�F�N�g��
%                     �r���h����ꍇ�Ɏg�p���܂��B(COM Builder���K�v�ł�)
%
%           cexcel    Windows��ŁAC MS Excel Compatable COM ���r���h����
%                     �ꍇ�Ɏg�p���܂��B(Excel�p��MATLAB Add-In Builder��
%                     �K�v�ł�)
%
%           csglcom   Windows��ŁAC Graphics Library���g�p���āAC COM 
%                     �ƌ݊����̂���I�u�W�F�N�g���r���h����ꍇ�Ɏg�p
%                     ���܂��B(COM Builder���K�v�ł�)  
%
%           csglexcel Windows��ŁAC Graphics Library���g�p���āAC MS 
%                     Excel �ƌ݊����̂���I�u�W�F�N�g���r���h����ꍇ��
%                     �g�p���܂��B(Excel�p��MATLAB Add-In Builder���K�v�ł�)
%
%           csglsharedlib
%                     C Graphics Library���L���C�u�������r���h����ꍇ�Ɏg�p
%                     ���܂��B
%
%           cppcom    Windows��ŁAC++ COM �ƌ݊����̂���I�u�W�F�N�g���r���h
%                     ����ꍇ�Ɏg�p���܂��B(COM Builder���K�v�ł�) 
%
%           cppexcel  Windows��ŁAC++ MS Excel Compatiable COM �I�u�W�F�N�g
%                     ���r���h����ꍇ�Ɏg�p���܂��B
%                     (Excel�p��MATLAB Add-In Builder���K�v�ł�)  
%
%           cppsglcom Windows��ŁAGraphics Library���g�p���āAC++ COM��
%                     �݊����̂���I�u�W�F�N�g(COM Builder���K�v�ł�)
%
%           cppsglexcel
%                     Windows��ŁAGraphics Library���g�p���āAC++ MS 
%                     Excel �ƌ݊����̂���I�u�W�F�N�g���r���h����ꍇ��
%                     �g�p���܂��B(Excel�p��MATLAB Add-In Builder ���K�v�ł�)
%
%           cpplib    C++ ���C�u�������r���h����ꍇ�Ɏg�p���܂��B
%
%           csharedlib
%                     C ���L���C�u�������r���h����ꍇ�Ɏg�p���܂��B
%
%           csglsharedlib
%                     C Graphics���L���C�u�������r���h����ꍇ�Ɏg�p���܂��B
%
%           pcode     MATLAB P-Code �t�@�C�����r���h����ꍇ�Ɏg�p���܂��B
%
%           sgl       �X�^���h�A����C Graphics Library�A�v���P�[�V������
%                     �쐬����ꍇ�Ɏg�p���܂��B
%
%           sglcpp    �X�^���h�A����C++ Graphics Library�A�v���P�[�V����
%                     ���쐬����ꍇ�Ɏg�p���܂��B
%
%   c  C�R�[�h�̂݁BM-�t�@�C����C�ɕϊ����܂����AMEX-�t�@�C���A�܂��̓X
%       �^���h�A�����A�v���P�[�V�����𐶐����܂���B����́A�R�}���h���C
%       ���ň�ԉE�̈����Ƃ��āA"-T codegen"��p����ꍇ�Ɠ����ł��B
%
%   d <directory>  �o�̓f�B���N�g���B�S�Ă̐����t�@�C���́A<directory> 
%       �ɒu����܂��B
%
%   F list  �J�����g�̒l�ƊȒP�Ȑ��������ɁA���̃R�}���h�`���ŗ��p�\��
%       <option>�̈ꗗ��\�����܂��B
%
%   F <option>:<number>  �ݒ�t�H�[�}�b�g�I�v�V�����B�t�H�[�}�b�g�I�v
%       �V����<option>�ɁA�l<value>�����蓖�Ă܂��B<option>�ɂ��ẮA
%       "F list"���Q�Ƃ��ĉ������B
%
%   f <filename>  MEX��MBUILD���R�[�����鎞�A�w�肳�ꂽ�I�v�V�����t�@�C
%       �����g�p���܂��B����ő���ANSI�R���p�C���𗘗p�ł��܂��B���̃I�v
%       �V�����́AMEX��MBUILD�X�N���v�g�ɒ��ړn���܂��B�ڍׂ̏��ɂ�
%       �ẮA"External Interfaces/API"���Q�Ƃ��ĉ������B
%
%   G   �f�o�b�O�̂ݍs�Ȃ��܂��B�P��debugging on��Ԃ��̂ŁA�f�o�b�O�V��
%       �{����񂪊܂܂�܂��B
%
%   g   �f�o�b�O�B�f�o�b�O�V���{�������܂݂܂��B���̃I�v�V�����ł́A
%       -A debugline:on �X�C�b�`���܂݂܂��B����́A�����R�[�h�̐��\�ɉe
%       ����^����ł��傤�B�Ⴆ�f�o�b�O����v�����Ă��A�f�o�b�O���C��
%       ���̗��p -g -A debugline:off �Ŋ֘A���鐫�\�̒ቺ�͂���܂���B
%       ���̃I�v�V�����ɂ́A-O none �X�C�b�`�����܂܂�܂��B���̃X�C�b�`
%       �ŁA�S�ẴR���p�C���̍œK���͎~�߂��܂��B��������̍œK����
%       �I���Ƃ������ꍇ�́A�f�o�b�O�̃X�C�b�`�̌�Ŏw�肵�܂��B
%
%   h   �⏕�֐����R���p�C�����܂��B�R�[�������S�Ă�M-�t�@���N�V������
%       �쐬�����MEX-�t�@�C����X�^���h�A�����A�v���P�[�V�����ɃR���p�C
%       ������܂��B
%
%   i   ���C�u�������쐬����ꍇ�A�G�N�X�|�[�g�����V���{���̃��X�g��
%       �R�}���h���C���ŏq�ׂ�ꂽ�G���g���[�|�C���g�̂݊܂݂܂��B
%
%   I <path>  �C���N���[�h�p�X�BM-�t�@�C������������p�X�̃��X�g��<path>
%       �ɒǉ����܂��BMATLAB�̃p�X�́AMATLAB���s���Ɏ����I�ɓǂݍ��܂��
%       �����ADOS��Unix�V�F������̎��s���ɂ͓ǂݍ��܂�܂���B
%       "help mccsavepath"���Q�Ƃ��ĉ������B
%
%   L <option>  ����B�^�[�Q�b�g�����ݒ肵�܂��B<option>��C�ɑ΂��Ă�
%       "C"�AC++�ɑ΂��Ă�"Cpp"�AMATLAB P-�R�[�h�ɑ΂��Ă�"P"�ƂȂ�܂��B
%
%   l   �s�B���s���G���[�����������t�@�C�����ƍs�ԍ������|�[�g����R�[�h
%       �𐶐����܂��B(-A debugline:on �Ɠ����ł�)
%
%   m   C�X�^���h�A�����A�v���P�[�V�������쐬����}�N���B����́A�I�v
%       �V����"-t -W main -L C -h -T link:exe libmmfile.mlib"�Ɠ����ł��B
%       ���̃I�v�V�����́A���̃t�@�C�����ɂ���܂��B
%       <MATLAB>/toolbox/compiler/bundles/macro_option_m
%       ����: "-h"�́A�⏕�֐����܂܂�邱�Ƃ��Ӗ����܂��B
%
%   M "<string>"  ���s�t�@�C�����쐬���邽�߂ɗ��p�����MBUILD��MEX�X�N
%       ���v�g��<string>��n���܂��B-M������g�p�����ƁA��ԉE�̂��̂�
%       ���p����܂��B
%
%   o <outputfilename>  �o�͖��B(MEX��X�^���h�A�����A�v���P�[�V�����Ȃ�)
%       �ŏI�I�Ȏ��s�\�ȏo�̓t�@�C������<outputfilename>�Ɛݒ肵�܂��B
%       �K���ȁA���邢�̓v���b�g�t�H�[���ˑ��̊g���q��<outputfilename>��
%       �ǉ�����܂��B(�Ⴆ�΁APC�X�^���h�A�����A�v���P�[�V�����ɑ΂��Ă�
%       ".exe"�ASolaris��MEX-�t�@�C���ɑ΂��Ă�".mexsol")
%
%   O <optimization>   �œK���B3�̉\�Ȃ��Ƃ�����܂��B
%
%       <optimization class>:[on|off] - �N���X�̃I���I�t�B
%       ��:  -O fold_scalar_mxarrays:on
%
%       list - �L���ȍœK���N���X�����X�g���܂��B
%
%       <optimization level> - �œK���̃I���I�t�����肷�邽�߂�
%       opt_bundle_<level>���R�[�������o���h���t�@�C���𗘗p���܂��B
%       �Ⴆ�΁A"-O all"��opt_bundle_all���R�[�������o���h���t�@�C����
%       �T���A���̎��̃X�C�b�`�𗘗p���܂��B�ʏ�̍œK���̃��x����"all"
%       ���邢��"none"�ł��B�f�t�H���g�ł́A�S�Ă̍œK�����I���ƂȂ��Ă�
%       �܂��B
%
%   p   C++�X�^���h�A�����A�v���P�[�V�����𐶐�����}�N���B����́A
%       "-t -W main -L Cpp -h -T link:exe libmmfile.mlib"�Ɠ����ł��B
%       ���̃I�v�V�����́A���̃t�@�C�����ɂ���܂��B
%       <MATLAB>/toolbox/compiler/bundles/macro_option_p
%       ����: "-h"�́A�⏕�֐����܂܂�邱�Ƃ��Ӗ����܂��B
%
%   S   Simulink C-MEX S-function�𐶐�����}�N���B����́A
%       "-t -W simulink -L C -T link:mex libmatlbmx.mlib"�Ɠ����ł��B
%       ���̃I�v�V�����́A���̃t�@�C�����ɂ���܂��B
%       <MATLAB>/toolbox/compiler/bundles/macro_option_S
%       ����: "-h"���Ȃ��̂́A�⏕�֐����܂܂�Ȃ����Ƃ��Ӗ����܂��B
%
%   t   M�R�[�h���^�[�Q�b�g����ɕϊ��B�R�}���h���C���Ŏw�肳�ꂽM-�t�@
%       ���N�V������C�܂���C++�֐��ɕϊ����܂��B���̃I�v�V�����́A�S�Ă�
%       �}�N���I�v�V�������Ɋ܂܂�܂��B�ȗ�����ƁAM-�t�@�C���ɑΉ�����
%       C/C++�t�@�C���𐶐������Ƀ��b�p�[C/C++�t�@�C���𐶐����邱�Ƃ���
%       ���܂��B
%
%   T <option>  �^�[�Q�b�g�̒i�K�ƃ^�C�v���w�肵�܂��B���̕\�ɁA�L����
%   <option>�̕�����Ƃ����̌��ʂ������܂��B
%
%       codegen            - M-�t�@�C����C/C++�t�@�C���ɕϊ����A���b�p�[
%                            �t�@�C�����쐬���܂��B(�����-T�̃f�t�H���g
%                            �ݒ�ł��B)
%       compile:mex        - codegen�Ɠ����ł����A�X��C/C++�t�@�C����
%                            Simulink S-Fuction MEX-�t�@�C���ւ̃����N
%                            �\�ȃI�u�W�F�N�g�`���ɃR���p�C�����܂��B
%       compile:mexlibrary - codegen�Ɠ����ł����A�X��C/C++�t�@�C����
%                            �ʏ��(��S-Fuction) MEX-�t�@�C���ւ̃����N
%                            �\�ȃI�u�W�F�N�g�`���ɃR���p�C�����܂��B
%       compile:exe        - codegen�Ɠ����ł����A�X��C/C++�t�@�C����
%                            �X�^���h�A�����̎��s�t�@�C���ւ̃����N�\��
%                            �I�u�W�F�N�g�`���ɃR���p�C�����܂��B
%       compile:lib        - codegen�Ɠ����ł����AC/C++�t�@�C�������L
%                            ���C�u����/DLL�ւ̃����N�\�ȃI�u�W�F�N�g
%                            �`���ɃR���p�C�����܂��B
%       link:mex           - compile:mex�Ɠ����ł����ASimulink S-fuction
%                            Mex-�t�@�C���ɃI�u�W�F�N�g�t�@�C���������N
%                            ���܂��B
%       link:mexlibrary    - compile:mexlibrary�Ɠ����ł����A�ʏ��
%                            (��S-Fuction) MEX-�t�@�C���ɃI�u�W�F�N�g
%                            �t�@�C���������N���܂��B
%       link:exe           - compile:exe�Ɠ����ł����A�X�^���h�A�������s
%                            �t�@�C���ɃI�u�W�F�N�g�t�@�C���������N���܂��B
%       link:lib           - compile:lib�Ɠ����ł����A���L���C�u����/DLL
%                            �ɃI�u�W�F�N�g�t�@�C���������N���܂��B
%
%   u <number>  ���������Simulink S-Fuction�ւ̓��͐����A<number>�ł���
%       ���Ƃ��w�肵�܂��B"-S"��������"-W simulink"�I�v�V�����̈�����w
%       �肳��Ă���ꍇ�ɂ̂ݗL���ł��B
%
%   v   �璷�B�R���p�C���X�e�b�v��\�����܂��B
%
%   w list   ���̃R�}���h�ŗ��p�\��<msg>������Ƌ��ɁA����炪�Ή�����
%       ���[�j���O���b�Z�[�W�̃t���e�L�X�g�ŕ\�����܂��B
%
%   w <option>[:<msg>] ���[�j���O�B���p�\�ȃI�v�V�����́A"enable"��
%       <disable>�A<error>�ł��B"enable:<msg>"���邢��"disable:<msg>"��
%       �w�肳���ƁA<msg>�Ɋ֘A���郏�[�j���O��\�����邢�͔�\���ɂ�
%       �܂��B"error:<msg>"���w�肳���ƁA<msg>�Ɋ֘A���郏�[�j���O��
%       �\�������A�G���[�Ƃ��Ă��̃��[�j���O�̗�Ƃ��Ĉ����܂��B":<msg>"
%       ���Ȃ�<option>���w�肳���ƁACompiler�͂��̓�����S���[�j���O
%       ���b�Z�[�W�ɓK�p���܂��B�OCompiler�o�[�W�����Ƃ̌�ތ݊����Ƃ��āA
%       (option��t���Ȃ�)"-w"�́A"-w enable"�Ɠ����ł��B
%
%   W <option>  ���b�p�[�֐��BCompiler�ɂ���Đ�������郉�b�p�[�t�@�C��
%       �̃^�C�v���w�肵�܂��B<option>�́A"mex", "main", "simulink", 
%       "lib:<string>", "none" (�f�t�H���g)�̒���1�ƂȂ�܂��Blib���b�p�[
%       �ł́A<string>�͍쐬����鋤�L���C�u�������Ɠ����ł��B"lib"���b�p�[
%       �쐬���ɁAMCC�͋��L���C�u�������̊֐����L�q����MLIB�t�@�C����
%       �쐬���܂��B
%
%   x   MEX-�t�@�C���𐶐�����}�N���B����̓I�v�V����
%       "-t -W mex -L C -T link:mex libmatlbmx.mlib"�Ɠ����ł��B����
%       �I�v�V�����́A���̃t�@�C�����ɂ���܂��B
%       <MATLAB>/toolbox/compiler/bundles/macro_option_x
%       ����: "-h"���Ȃ��̂́A�⏕�֐����܂܂�Ȃ����Ƃ��Ӗ����܂��B
%
%   y <number>  ���������Simulink S-Fuction����̏o�͐����A<number>��
%       ���邱�Ƃ��w�肵�܂��B"-S"��������"-W simulink"�I�v�V�����̈����
%       �w�肳��Ă���ꍇ�ɂ̂ݗL���ł��B
%
%   Y <license.dat file>  �f�t�H���g��license.dat���w�肳�ꂽ�����Œu��
%       �����܂��B
%
%   z <path>  ���C�u�����ƃC���N���[�h�t�@�C���ɑ΂��ė��p����p�X���w��
%       ���܂��B���̃I�v�V�����́AMATLABROOT�̑����Compiler�̃��C�u����
%       �ɑ΂��Ďw�肵���p�X���g�p���܂��B
%
%   ?   �w���v�B���̃w���v���b�Z�[�W��\�����܂��B
%
% ��:
%
% myfun.m��C�ɕϊ����AMEX-�t�@�C�����쐬���܂��B
%       mcc -x myfun
%
% myfun.m��C�ɕϊ����A�X�^���h�A�������s�t�@�C�����쐬���܂��B
%       mcc -m myfun
%
% myfun.m��C++�ɕϊ����A�X�^���h�A�������s�t�@�C�����쐬���܂��B
%       mcc -p myfun
%
% myfun.m��C�ɕϊ����ASimulink S-Fuction���쐬���܂��B
% (�σT�C�Y�̓��o�͂𗘗p):
%       mcc -S myfun
%
% myfun.m��C�ɕϊ����ASimulink S-Fuction���쐬���܂��B
% (1����2�o�͂ł̃R�[���𖾎�):
%       mcc -S -u 1 -y 2 myfun
%
% myfun.m��C�ɕϊ����X�^���h�A�������s�t�@�C�����쐬���܂��B/files/source
% �f�B���N�g������myfun.m���������A/files/target�f�B���N�g�����ɐ���
% �����C�t�@�C���Ǝ��s�t�@�C����u���܂��B
%       mcc -m -I /files/source -d /files/target myfun
%
% myfun.m��C�ɕϊ���MEX-�t�@�C�����쐬���܂��B�܂�myfun.m�ɂ�蒼�ڂ�
% �邢�͊ԐړI�ɃR�[�����ꂽ�S�Ă�M-�t�@���N�V������ϊ����A�C���N���[�h
% ���܂��B�I���W�i����M-�t�@�C���̃t���e�L�X�g��C�̃R�����g�Ƃ��đΉ�
% ����C�t�@�C���ɑg�ݍ��݂܂��B
%       mcc -x -h -A annotation:all myfun
%
% myfun.m����ʓI��C�ɕϊ����܂��B
%       mcc -t -L C myfun
%
% myfun.m����ʓI��C++�ɕϊ����܂��B
%       mcc -t -L Cpp myfun
%
% myfun1.m��myfun2.m����C MEX���b�p�[�t�@�C�����쐬���܂��B
%       mcc -W mex -L C libmatlbmx.mlib myfun1 myfun2
%
% (1���mcc�̃R�[����)myfun1.m��myfun2.m����C�ɕϊ����A�X�^���h�A����
% ���s�t�@�C�����쐬���܂��B
%       mcc -m myfun1 myfun2
%
% (�e�X��mcc�̃R�[�����ɏo�̓t�@�C�����쐬����)myfun1.m��myfun2.m����
%   C�ɕϊ����A�X�^���h�A�������s�t�@�C�����쐬���܂��BMLIB�t�@�C��
% "libmmfile.mlib"�̓��b�p�[�t�@�C���쐬���ƍŏI���s�t�@�C���쐬���̂�
% �w�肪�K�v�ł��B
%
%     mcc -t -L C myfun1                            % myfun1.c �쐬
%     mcc -t -L C myfun2                            % myfun2.c �쐬
%     mcc -W main -L C myfun1 myfun2 libmmfile.mlib % myfun1_main.c �쐬
%     mcc -T compile:exe myfun1.c                   % myfun1.o �쐬
%     mcc -T compile:exe myfun2.c                   % myfun2.o �쐬
%     mcc -T compile:exe myfun1_main.c              % myfun1_main.o �쐬
%     mcc -T link:exe myfun1.o myfun2.o myfun1_main.o libmmfile.mlib
%   
% a0.m��a1.m����"liba"�Ƃ������L/�_�C�i�~�b�N�����N���C�u�������쐬���܂��B
% �����ŁAa0��a1���ǂ����libmmfile���̊֐����R�[�����܂���B
%       mcc -t -W lib:liba -T link:lib a0 a1
%   
% a0.m��a1.m����"liba"�Ƃ������L/�_�C�i�~�b�N�����N���C�u�������쐬���܂��B
% �����ŏ��Ȃ��Ƃ�a0��a1�̓���1��libmmfile����1�ȏ�̊֐����R�[��
% ���܂��BC�R�[�h�R���p�C�����ɂ́ALIBMMFILE��1�ɒ�`���܂��B
%    mcc -t -W lib:liba -T link:lib a0 a1 libmmfile.mlib -M "-DLIBMMFILE=1"
%   
% (1��� mcc �̌Ăяo����)myfun.m ����C�ɕϊ����A�O���t�B�b�N�X���C�u����
% ��p����X�^���h�A�������s�\�t�@�C�����쐬���܂��B
%       mcc -B sgl myfun1 
%   
% (1��� mcc �̌Ăяo����)myfun.m ����C++�ɕϊ����A�O���t�B�b�N�X���C�u����
% ��p����X�^���h�A�������s�\�t�@�C�����쐬���܂��B
%       mcc -B sglcpp myfun1 
%        
% MATLAB C/C++ Graphics Library���R�[������Aa0.m��a1.m����"liba"��
% �������L/�_�C�i�~�b�N�����N���C�u�������쐬���܂��B
%       mcc -B sgl -t -W libhg:liba -T link:lib a0 a1 
%   
% ����: PC�ł́A��L��.o�ŏI���t�@�C�����́A���ۂɂ�.obj�ƂȂ�܂��B
%
% �Q�l : COMPILER/FUNCTION, MCCSAVEPATH, REALONLY, REALSQRT, REALLOG, 
%        REALPOW, COMPILER_SURVEY, COMPILER_BUG_REPORT, MEX, MBUILD.


% Copyright 1984-2000 The MathWorks, Inc.
