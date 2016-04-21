% HDFGD   HDF-EOS Grid�I�u�W�F�N�g��MATLAB�C���^�t�F�[�X
%
% HDFGD�́AHDF-EOS Grid�I�u�W�F�N�g��MATLAB�C���^�t�F�[�X�ł��B
% HDF-EOS�́ANCSA (National Center for Supercomputing Applications) HDF 
% (Hierarchical Data Format)�̊g���ł��BHDF-EOS�́AEOS (Earth Observing 
% System)�ɑ΂���x�[�X���C���W���Ƃ���NASA���I������Ȋw�f�[�^�t�H�[
% �}�b�g�W���ł��B
% 
% HDFGD�́AHDF-EOS C���C�u������Grid�֐��̃Q�[�g�E�F�C�ŁAEOSDIS (Earth 
% Observing System Data and Information System)�ɂ���ĊJ���A�ێ�����
% �Ă��܂��B�O���b�h�f�[�^�Z�b�g�́A2�����܂��͂���ȏ�̎����̒���
% ���`�z��A�����̒�`�A�֘A����}�b�v�̓��e�ō\������܂��B
% 
% �����ŏq�ׂ����ɉ����āA���̃h�L�������g���Q�Ƃ��邱�Ƃ��������߂�
% �܂��B
% 
%     HDF-EOS Library User's Guide for the ECS Project,
%     Volume 1: Overview and Examples; Volume 2: Function
%     Reference Guide 
% 
% ���̃h�L�������g�́A����web�������\�ł��B
% 
%        http://hdfeos.gsfc.nasa.gov
% 
% ���̃T�C�g����h�L�������g�����ł��Ȃ��ꍇ�AMathWorks Technical 
% Support(support@mathworks.com)�ɂ��A�����������B
% 
% �V���^�b�N�X�̎g����
% ------------------
% HDF-EOS C���C�u������HDFGD�V���^�b�N�X�̒���Grid�֐��Ԃ�1��1�}�b�s���O
% �����݂��܂��B���Ƃ��΁AC���C�u�����́A�ݒ肵�������̑傫���𓾂�̂ɁA
% ���̊֐���p�ӂ��Ă��܂��B
% 
%       int32 GDdiminfo(int32 gridid, char *dimname)
% 
% ������MATLAB�V���^�b�N�X�́A���̂悤�ɂȂ�܂��B
% 
%       DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
% 
% GRID_ID �́A����̃O���b�h�f�[�^�Z�b�g�̎��ʎq(�܂��̓n���h��)�ł��B
% DIMNAME �́A�w�肵�������̖��O���܂ޕ�����ł��BDIMSIZE �́A�w�肵
% �������̃T�C�Y���A���邢�͑��삪���s�����ꍇ��-1�ɂȂ�܂��B
% 
% C���C�u�����֐��̒��ɂ́AC�}�N���Œ�`���ꂽ���͒l���󂯓������̂�
% ����܂��B���Ƃ��΁AC�̊֐� GDopen() �́ADFACC_READ�ADFACC_RDWR�A
% DFACC_CREATE �̂����ꂩ�ł���A�N�Z�X���[�h���͂�K�v�Ƃ��܂��B����
% �ŁA�����̃V���{���͓K�؂�C�w�b�_�t�@�C���̒��ɒ�`����Ă��܂��B
% �}�N���̒�`��C���C�u�����̒��Ŏg���镔���ŁA������MATLAB�V���^�b
% �N�X�́A�}�N�������瓾���镶������g���܂��B���[�U�́A�}�N�����S�̂�
% �܂ޕ�������g�p���邱�Ƃ��A�܂��͋��ʂ���ړ�����ȗ����邱�Ƃ��ł���
% ���B�܂��A�啶�������������g�p���邱�Ƃ��ł��܂��B���Ƃ��΁A����C�֐�
% �R�[��
% 
%       status = GDopen("GridFile.hdf",DFACC_CREATE)
% 
% �́A����MATLAB�֐��R�[���Ɠ����ł��B
% 
%       status = hdfgd('open','GridFile.hdf','DFACC_CREATE')
%       status = hdfgd('open','GridFile.hdf','dfacc_create')
%       status = hdfgd('open','GridFile.hdf','CREATE')
%       status = hdfgd('open','GridFile.hdf','create')   
% 
% C�֐����}�N����`����̒l���o�͂���ꍇ�́A������MATLAB�֐��́A
% �}�N�����������ŕ\�킵���Z�k�`���܂ޕ�����Ƃ��Ēl���o�͂��܂��B   
% 
% HDF�ԍ��̃^�C�v�́A'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8'
% 'uint16', 'uint32', 'float', 'int8', 'int16', 'int32'���܂ޕ�����Ŏw�肳��܂��B
%
% HDF-EOS���C�u������NULL���󂯓����ꍇ�A��s��([])���g���܂��B
% 
% �قƂ�ǂ̃��[�`���́A���[�`�������������ꍇ0�A���s�����ꍇ-1���A�t��
% �O STATUS �ɏo�͂��܂��BSTATUS ���܂܂Ȃ��V���^�b�N�X�������[�`���́A
% �ȉ��̊֐��̃V���^�b�N�X�ł̋L�q�ōs���Ă���悤�ɁA�o�͂̂�����1��
% ���s���Ӗ���������o�͂��܂��B
% 
% �v���O���~���O���f��
% -----------------
% HDFGD���g�����O���b�h�f�[�^�Z�b�g�ւ̃A�N�Z�X�̃v���O���~���O���f���́A
% ���̂悤�ɂȂ�܂��B
% 
% 1. �t�@�C�����I�[�v�����A�t�@�C��������t�@�C��id�𓾂邱�Ƃ�GD�C���^
%    �t�F�[�X�����������܂��B
% 2. �O���b�h������O���b�hid�𓾂邱�Ƃɂ��O���b�h�f�[�^�Z�b�g���I�[
%    �v�����邩�A�쐬���܂��B
% 3. �f�[�^�Z�b�g�Ŋ�]���鑀����s���܂��B
% 4. �O���b�hid��ݒ肵�āA�O���b�h�f�[�^�Z�b�g���N���[�Y���܂��B
% 5. �t�@�C��id��ݒ肵�āA�t�@�C���ւ̃A�N�Z�X���I�����܂��B
% 
% HDF-EOS�t�@�C�����Ɋ��ɑ��݂��Ă���P��O���b�h�f�[�^�Z�b�g�ɃA�N�Z�X
% ���邽�߂ɂ́A����MATLAB�R�}���h���g���܂��B
% 
%       fileid = hdfgd('open',filename,access);
%       gridid = hdfgd('attach',fileid,gridname);
% 
%       % �f�[�^�Z�b�g��ɃI�v�V�����̉��Z��K�p
% 
%       status = hdfgd('detach',gridid);
%       status = hdfgd('close',fileid);
% 
% �����ɕ����̃t�@�C���ɃA�N�Z�X���邽�߂ɂ́A�I�[�v������e�t�@�C����
% �t�@�C�����ʎq���X�Ɏ擾���܂��B�����̃O���b�h�f�[�^�Z�b�g�ɃA�N�Z�X
% ���邽�߂ɂ́A�e�f�[�^�Z�b�g�ɑ΂���X�̃O���b�hid���擾���܂��B
% 
% �o�b�t�@����Ă��鉉�Z���A�f�B�X�N�Ɋ��S�ɋL�q�����悤�ɃO���b�hid��
% �t�@�C��id��K�؂ɔz�u���邱�Ƃ��d�v�ł��BMATLAB���I�����邩�A�I�[�v��
% �����܂܂�GD���ʎq�������ׂĂ�MEX-�t�@�C�����N���A����ƁAMATLAB��
% ���[�j���O��\�����A�����I�ɂ�����z�u���܂��B
% 
% HDFGD�ŏo�͂����t�@�C�����ʎq�́A����HDF-EOS�܂���HDF�֐���
% �o�͂����t�@�C�����ʎq�ƌ݊������Ȃ����Ƃɒ��ӂ��Ă��������B
% 
% �֐��̃J�e�S��
% -------------------
% �O���b�h�f�[�^�Z�b�g���[�`���́A���̃J�e�S���ɕ��ނ���܂��B
%
%     - �A�N�Z�X���[�`���́AGD�C���^�t�F�[�X��O���b�h�f�[�^�Z�b�g(�I�[
%       �v�����Ă���t�@�C����N���[�Y���Ă���t�@�C�����܂�)����������
%       �A�N�Z�X���I�����܂��B
%
%     - ��`���[�`���́A�O���b�h�f�[�^�Z�b�g�̎�v������ݒ肵�܂��B
%
%     - ��{I/O���[�`���́A�O���b�h�f�[�^�Z�b�g�̃f�[�^�⃁�^�f�[�^��ǂ�
%		 ���񂾂菑���o���܂��B
%
%     - ����(Inquiry)���[�`���́A�O���b�h�f�[�^�Z�b�g���Ɋ܂܂��f�[�^
%       �Ɋւ�������o�͂��܂��B
%
%     - �T�u�Z�b�g���[�`���́A�w�肵���􉽓I�ȗ̈悩��f�[�^��ǂݍ��݂�
%       ���B
% 
% �A�N�Z�X���[�`��
% ---------------
% GDopen
%     FILE_ID = HDFGD('open',FILENAME,ACCESS)
%     �t�@�C�����Ɗ�]����A�N�Z�X���[�h��^���āA�O���b�h�f�[�^�Z�b�g���쐬
%     �ǂݍ��݁A�����o�����s�����߂�HDF�t�@�C�����I�[�v���܂��͍쐬���܂��B
%     ACCESS�ɂ́A'read', 'rdwr', 'create' �̂����ꂩ���g�p�ł��܂��B
%     FILE_ID�́A���Z�����s�����ꍇ��-1�ɂȂ�܂��B
% 
% GDcreate
%     GRID_ID = HDFGD('create',FILE_ID,GRIDNAME,...
%                         XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT)
%     �O���b�h�f�[�^�Z�b�g�̍쐬�BGRIDNAME �́A�O���b�h�f�[�^�Z�b�g�̖��O����
%     �ޕ�����ł��BXDIMSIZE �� YDIMSIZE �́A��\���鎟���̑傫��������
%     �X�J���ł��BUPLEFT �́A�O���b�h�̍�����̃s�N�Z����\�킷X���W��Y��
%     �W���܂�2�v�f�x�N�g���ł��BLOWRIGHT �́A�O���b�h�̉E�����̃s�N�Z��
%     ��X���W��Y���W���܂�2�v�f�x�N�g���ł��BGRID_ID �́A���Z�����s������
%     ���ɂ�-1�ɂȂ�܂��B
%   
% GDattach
%     GRID_ID = HDFGD('attach',FILE_ID,GRIDNAME)
%     �t�@�C�����ɑ��݂���O���b�h�f�[�^�Z�b�g�ɃA�^�b�`���܂��BGRID_ID �́A
%     ���Z�����s�����ꍇ�ɂ�-1�ɂȂ�܂��B
% 
% GDdetach
%     STATUS = HDFGD('detach',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g����؂���܂��B
% 
% GDclose
%     STATUS = HDFGD('close', FILE_ID)
%     �t�@�C�����N���[�Y
%   
% ��`�Ɋւ���V���^�b�N�X
% -------------------
% GDdeforigin
%     STATUS = HDFGD('deforigin',GRID_ID,ORIGIN)
%     �O���b�h�̂ǂ̋������_�ɂ��邩���`���܂��B
%     ORIGIN �́A'ul', 'ur', 'll', 'lr' �̂����ꂩ��ݒ�ł��܂��B
%
% GDdefdim
%     STATUS = HDFGD('defdim',GRID_ID,DIMNAME,DIM)
%     �O���b�h�f�[�^�Z�b�g���̐V�����������`���܂��BDIMNAME �͐V����
%     �����̖��O���܂ޕ�����ŁADIM �͐V���������̑傫����\�킷
%     �X�J���ł��B
%
% GDdefproj
%     STATUS = HDFGD('defproj',GRID_ID,PROJCODE,...
%               ZONECODE,SPHERECODE,PROJPARM)
%     �O���b�h�f�[�^�Z�b�g�ɑ΂���ˉe�@���`���܂��BPROJCODE �́A'geo', 
%     'utm', 'lamcc', 'ps', 'polyc', 'tm', 'lamaz', 'hom', 'som', 'good','isinus' 
%     �̂����ꂩ��ݒ�ł��܂��BZONECODE �́AUTM�}�@�R�[�h�ł��B����
%     ���e�@���g���ɂ́A[] �܂���0��ݒ肵�܂��BSPHERECODE �́A�X�J����
%     ���ʃR�[�h�ł��BPROJPARM �́A�ő�13�v�f�����x�N�g���ŁA���e�@
%     �ŗL�̃p�����[�^���܂݂܂��BPROJCODE, ZONECODE, SPHERECODE, 
%     PROJPARM�̏ڍׂɂ��ẮA ECS Project, Volume 1��HDF-EOS 
%     Library Users Guide��6�͂��Q�Ƃ��Ă��������B
%
% GDdefpixreg
%     STATUS = HDFGD('defpixreg',GRID_ID,PIXREG)
%     �O���b�h�Z�����Ɉʒu����s�N�Z�����`���܂��BPIXREG �́A'center' 
%     �܂��� 'corner' �̂����ꂩ��ݒ�ł��܂��B
% 
% GDdeffield
%     STATUS = HDFGD('deffield',GRID_ID,FIELDNAME,...
%                      DIMLIST,NUMBERTYPE,MERGE)
%     �O���b�h���Ɋi�[�����f�[�^�t�B�[���h���`���܂��BFIELDNAME �́A
%     ��`����鎟�������܂ޕ�����ł��BDIMLIST �́A������\�킷
%     �J���}�ŋ�؂�ꂽ������ł��BNUMBERTYPE �́AHDF�ԍ��^�C�v��
%     �w�肷�镶����ł��BMERGE�́A'nomerge'�A 'automerge' �̂����ꂩ
%     �ł��B
%
% GDdefcomp
%     STATUS = HDFGD('defcomp',GRID_ID,COMPCODE,COMPPARM)
%     ���ׂĂ̘A���I�ȃt�B�[���h��`�ɑ΂���t�B�[���h���k��ݒ肵�܂��B
%     COMPCODE�́A'rle','skphuff', 'deflate', 'none' �̂����ꂩ��ݒ�ł��܂��B
%     Deflate���k�́ACOMPPARM ��1����9�܂ł̐����ł��邱�Ƃ�v�����܂��B
%     �����ŁA�����l���傫��������荂�����k�ɂȂ�܂��B���̈��k�@���g�p
%     ����ꍇ�́ACOMPPARM ��0�܂��� [] ��ݒ肵�Ă��������B
%
% GDwritefieldmeta
%     STATUS = HDFGD('writefieldmeta',GRID_ID,...
%                FIELDNAME,DIMLIST,NUMBERTYPE)
%     Grid API���g���Ē�`���Ă��Ȃ������̃O���b�h�t�B�[���h�ɑ΂���
%     �t�B�[���h���^�f�[�^���L�q���܂��BFIELDNAME �́A�t�B�[���h�����܂ޕ�
%     ����ł��BDIMLIST �́A�J���}�ŋ�؂�ꂽ���������܂ޕ�����ł��B
%     NUMBERTYPE�́AHDF�ԍ��^�C�v���w�肷�镶����ł��B
%
% GDblkSOMoffset
%     STATUS = HDFGD('blksomoffset',GRID_ID,OFFSET)
%     �W���̃u���b�NSOM�I�t�Z�b�g�l��SOM���e�@����s�N�Z���P�ʂŏ���
%     ���݂܂��BOFFSET �́ASOM���e�f�[�^�ɑ΂���I�t�Z�b�g�l�̃x�N�g��
%     �ł��B���̃��[�`���́ASOM���e���g�p����O���b�h�Ƌ��ɂ̂ݎg���
%     �܂��B
%
% GDsettilecomp
%     STATUS = HDFGD('settilecomp',GRIDID,FIELDNAME,...
%                   TILEDIMS,COMPCODE,COMPPARM)
%     �ݒ�l�����t�B�[���h�ɑ΂��āA�^�C�����O�p�����[�^�ƈ��k�p�����[�^��
%     �ݒ肵�܂��B���̃��[�`���́AHDF-EOS 2.3 �̃o�O�t�B�b�N�X���s�����߁A
%     HDF-EOS 2.5 �œ�������Ă��܂��BFIELDNAME �́A�w�肵���O���b�h��
%     ���O�ł��BTIELDIMS �́A�^�C�����O�̎������܂ރx�N�g���ł��B
%     COMPCODE �́A'rle', 'skphuff'�A'deflate'�A'none' �̂����ꂩ��ݒ�ł�
%     �܂��Bdeflate���k�ł́ACOMP PARM ��1����9�̊Ԃ̐����ł��邱�Ƃ�
%     �K�v�ɂȂ�܂��B�����āA�傫���l�́A��荂�����k�ɑΉ����܂��B
%     COMPPARM �� 0 �܂���[]���w�肷��ƁA���̈��k���@���̗p����܂��B
%     ���̊֐����Ăяo����鏇�Ԃ������܂��B
%
%		   hdfgd('gddeffield'... 
%                  hdfgd('gdsetfillvalue'...
%		   hdfgd('gdsettilecomp'...
%	
% ��{�I�� I/O �Ɋւ���V���^�b�N�X
% ------------------
% GDwritefield
%     STATUS = HDFGD('writefield',GRID_ID,FIELDNAME,...
%                 START,STRIDE,EDGE,DATA)
%     �O���b�h�f�[�^�Z�b�g�̎w�肵���t�B�[���h�Ƀf�[�^���������݂܂��B
%     FIELDNAME�́A�w�肳�ꂽ�O���b�h�̖��O�ł��BSTART�́A�e�������ŁA
%     (�[�����x�[�X�ɂ���)�J�n�_���w�肷��ʒu��\�킷�x�N�g���ł��B
%     STRIDE �́A�e�����ɉ����ăX�L�b�v�����l���w�肷��x�N�g���ł��B
%     EDGE �́A�e�����ɉ����ď������܂��l�̐��ł��BDATA �́A��������
%     ���l�̔z��ł��BSTART�� [] ���w�肷�邱�Ƃ́AZEROS(1,NUMDIMS) 
%     ���w�肷�邱�ƂƓ����ł��BEDGE �� [] ���w�肷�邱�Ƃ́A
%     FLIPLR(SIZE(DATA)) ���w�肷�邱�ƂƓ����ł��B
% 
%     DATA �̃N���X�́A�^����ꂽ�t�B�[���h�ɐݒ肳��Ă���HDF�ԍ��^�C�v
%     �ƈ�v���Ȃ���΂Ȃ�܂���BMATLAB������́AHDF char�^�C�v�̂���
%     �ꂩ�ƈ�v����悤�Ɏ����I�ɕϊ�����܂��B���̃f�[�^�^�C�v�́A������
%     �Ӗ��ň�v���Ȃ���΂Ȃ�܂���B
%
%     ���ӁFHDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����g��
%     �܂��B����AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g���܂��B����́A
%     MATLAB�z��̑傫�����AHDF�f�[�^�t�B�[���h�̒�`���ꂽ�����̑傫
%     ���ɑ΂��āA�]�u����Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����Ă��܂��B���Ƃ��΁A
%     �O���b�h�t�B�[���h���A3 x 4 x 5�Œ�`����Ă���ꍇ�́ADATA��5 x 4 x 3
%     �̑傫���łȂ���΂Ȃ�܂���BPERMUTE �R�}���h�́A�����ŕK�v�ȕϊ�
%     ���s�����߂̃R�}���h�ł��B
%
% GDreadfield
%     [DATA,STATUS] = HDFGD('readfield',GRID_ID,...
%                      FIELDNAME,START,STRIDE,EDGE)
%     �w�肵���O���b�h�t�B�[���h����f�[�^��ǂݍ��݂܂��BFIELDNAME �́A
%     �ǂݍ��ރt�B�[���h���ł��BSTART�́A�e��������(�[�����x�[�X�ɂ���)
%     �J�n�_���w�肷��ʒu��\�킷�x�N�g���ł��BSTRIDE �́A�e�����ɉ���
%     �āA�X�L�b�v�����l���w�肷��x�N�g���ł��BEDGE �́A�e�����ɉ�����
%     �������܂��l�̐��ł��BDATA �́A�������܂��l�̔z��ł��BSTART 
%     �� [] ���w�肷�邱�Ƃ́AZEROS(1,NUMDIMS) ���w�肷�邱�ƂƓ����ł��B
%     STRIDE �� [] ���w�肷�邱�Ƃ́AONES(1,NUMDIMS) ���w�肷�邱�ƂƓ���
%     �ł��BEDGE �� [] ���w�肷��ƁA�t�B�[���h�S�̂��ǂݍ��܂�܂��B
%
%     ���ӁFHDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����g��
%     �܂��B����AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g���܂��B����́A
%     MATLAB�z��̑傫�����AHDF�f�[�^�t�B�[���h�̒�`���ꂽ�����̑傫
%     ���ɑ΂��āA�]�u����Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����Ă��܂��B���Ƃ��΁A
%     �O���b�h�t�B�[���h��3 x 4 x 5�Œ�`����Ă���ꍇ�́ADATA �́A5 x 4 x 3
%     �̑傫���łȂ���΂Ȃ�܂���BPERMUTE �R�}���h�́A�����ŕK�v�ȕϊ�
%     ���s�����߂̃R�}���h�ł��B
% 
%     ���삪���s�����ꍇ�́ADATA�� [] �ŁASTATUS ��-1�ɂȂ�܂��B
% 
% GDwriteattr
%     STATUS = HDFGD('writeattr',GRID_ID,ATTRNAME,DATA)
%     �w�肵�����O�̑��������O���b�h�f�[�^���������ނ��A�܂��͍X�V���܂��B
%     ���������ɑ��݂��Ă�����̂łȂ��ꍇ�́A�쐬���܂��B
% 
% GDreadattr
%     [DATA,STATUS] = HDFGD('readattr',GRID_ID,ATTRNAME)
%     �w�肵����������A���̑����̃f�[�^��ǂݍ��݂܂��B���Z�����s������
%     ���́ADATA �� [] �ŁASTATUS ��-1�ɂȂ�܂��B
% 
% GDsetfillvalue
%     STATUS = HDFGD('setfillvalue',GRID_ID,...
%                              FIELDNAME,FILLVALUE)
%     �w�肳�ꂽ�t�B�[���h�ɑ΂���l��ݒ肵�܂��BFILLVALUE�́A�X�J����
%     �ŁA���̃N���X���w�肵���t�B�[���h��HDF�����^�C�v�Ɉ�v���Ă������
%     �ł��BMATLAB������́AHDF char�^�C�v�̂����ꂩ�ƈ�v����悤��
%     �����I�ɕϊ�����܂��B���̃f�[�^�^�C�v�́A�����ȈӖ��ň�v���Ȃ�
%     ��΂Ȃ�܂���B
% 
% GDgetfillvalue
%     [FILLVALUE,STATUS] = HDFGD('getfillvalue',GRID_ID, ...
%                          FIELDNAME)
%     �w�肳�ꂽ�t�B�[���h�ɑ΂��Đݒ�l��ǂݍ��݂܂��B���Z�����s�����ꍇ
%     �́AFILLVALUE �� [] �ŁASTATUS ��-1�ɂȂ�܂��B
%
% Inquiry ���[�`��
% ----------------
% GDinqdims
%     [NDIMS,DIMNAME,DIMS] = HDFGD('inqdims',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g�̒��Œ�`����Ă��邷�ׂĂ̎����Ɋւ������
%     �擾���܂��BNDIMS �́A�������ł��BDIMNAME �́A�J���}�ŋ�؂�ꂽ
%     �������̃��X�g���܂ޕ�����ł��BDIMS�́A�e�����̑傫�����܂ރx�N
%     �g���ł��B���Z�����s�����ꍇ�́ANDIMS��-1�ŁADIMNAME �� DIMS ��
%     [] �ɂȂ�܂��B
%
% GDinqfields
%     [NFIELDS,FIELDLIST,RANK,NUMBERTYPE] = HDFGD( ...
%              'inqfields', GRID_ID)
%     �O���b�h�f�[�^�Z�b�g���ɒ�`���ꂽ���ׂẴt�B�[���h�Ɋւ��������
%     �����܂��BNFILEDS �́A�t�B�[���h�̐��ł��BFILEDLIST �́A�J���}�ŋ�
%     �؂�ꂽ�t�B�[���h���̃��X�g���܂ޕ�����ł��BRANK �́A�e�t�B�[���h
%     �̃����N���܂ރx�N�g���ł��BNUMBERTYPE �́A�e�t�B�[���h��HDF�ԍ�
%     �^�C�v���܂ޕ�����̃Z���z��ł��B
%
% GDinqattrs
%     [NATTRS,ATTRLIST] = HDFGD('inqattrs',GRID_ID)
%     �O���b�h���ɒ�`���ꂽ���ׂĂ̑����Ɋւ�������擾���܂��BNATTRS 
%     �ͤ�����̐��ł��BATTRLIST �́A�J���}�ŋ�؂�ꂽ�������̃��X�g��
%     �܂ޕ�����ł��B���Z�����s�����ꍇ�́ANATTRS ��-1�ŁAATTRLIST �� 
%     [] �ɂȂ�܂��B
%
% GDnentries
%     [NENTRIES,STRBUFSIZE] = HDFGD('nentries',GRID_ID,...
%               ENTRYCODE)
%     �w�肵���Ώە��ɑ΂���v�f�����擾���܂��BENTRYCODE �́A������
%     �����߂�ɂ� 'nentdim' ���A�t�B�[���h�������߂�ɂ� 'nestdfld' ��ݒ肵
%     �܂��BSTRBUFSIZE �́A�J���}�ŋ�؂�ꂽ�t�B�[���h���̎����̃��X�g��
%     �����ɂȂ�܂��B
%
% GDgridinfo
%     [XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT,STATUS] = ...
%              HDFGD('gridinfo',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g�̈ʒu�Ƒ傫�����o�͂��܂��BXDIMSIZE �� YDIMSIZE 
%     �́A���ꂼ��A�����̑傫�����܂ރX�J���ł��BUPLEFT �́A�O���b�h�̍���
%     ����X���W��Y���W���܂�2�v�f�x�N�g���ł��BLOWRIGHT �́A�O���b�h��
%     �E������X���W��Y���W���܂�2�v�f�x�N�g���ł��B���Z�����s�����ꍇ�́A
%     STATUS ��-1�ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�܂��B
%
% GDprojinfo
%     [PROJCODE,ZONECODE,SPHERECODE,PROJPARM,STATUS] = ...
%               HDFGD('projinfo',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g�Ɋւ��铊�e�����擾���܂��B�o�̓p�����[�^�̋L�q
%     �ɂ��ẮAGDdefproj ���Q�Ƃ��Ă��������B���Z�����s�����ꍇ�́A
%     STATUS ��-1�ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�܂��B
% 
% GDdiminfo
%     DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
%     �w�肵�������̑傫�����擾���܂��BDIMNAME �́A���������܂ޕ�����
%     �ł��B���Z�����s����ƁADIMSIZE ��-1�ɂȂ�܂��B
%
% GDcompinfo
%     [COMPCODE,COMPPARM,STATUS] = HDFGD('compinfo',...
%                        GRID_ID,FIELDNAME)
%     �w�肵���t�B�[���h�Ɋւ��鈳�k�����擾���܂��B�o�̓p�����[�^�̋L�q
%     �Ɋւ��ẮAGDdefcomp ���Q�Ƃ��Ă��������B���Z�����s�����ꍇ�́A
%     STATUS ��-1�ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�܂��B
% 
% GDfieldinfo
%     [RANK,DIMS,NUMBERTYPE,DIMLIST,STATUS] = ...
%           HDFGD('fieldinfo',GRID_ID,FIELDNAME)
%     �w�肵���t�B�[���h�Ɋւ�������擾���܂��BRANK �́A�t�B�[���h��
%     �����N�ł��BDIMS �́A�t�B�[���h�̎����̑傫�����܂ރx�N�g���ł��B
%     NUMBERTYPE�́A�t�B�[���h��HDF�ԍ��^�C�v���܂ޕ�����ł��B
%     DIMLIST �́A�J���}�ŋ�؂�ꂽ�������̃��X�g���܂ޕ�����ł��B
%     ���Z�����s�����ꍇ�́ASTATUS ��-1�ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�
%     �܂��B
%
% GDinqgrid
%     [NGRID,GRIDLIST] = HDFGD('inqgrid',FILENAME)
%     HDF-EOS�t�@�C�����̃O���b�h�f�[�^�Z�b�g�Ɋւ�������擾���܂��B
%     NGRID �̓O���b�h���ŁAGRIDLIST �̓J���}�ŋ�؂�ꂽ�O���b�h�f�[�^
%     �Z�b�g���̃��X�g���܂ޕ�����ł��B���Z�����s�����ꍇ�́ANGRID ��-1
%     �ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�܂��B
%
% GDattrinfo
%     [NUMBERTYPE,COUNT,STATUS] = HDFGD('attrinfo',...
%                 GRID_ID,ATTRNAME)
%     �w�肵�������̃T�C�Y(�o�C�g�P��)�Ɣԍ��^�C�v���o�͂��܂��BATTRNAME 
%     �́A�������ł��BNUMBERTYPE �́A������HDF�ԍ��^�C�v�ɑΉ���������
%     ��ł��BCOUNT �́A�����f�[�^�ɂ��g�p�����o�C�g���ł��B���Z����
%     �s�����ꍇ�́ASTATUS ��-1�ŁANUMBERTYPE �� COUNT �� [] �ɂȂ�
%     �܂��B
%
% GDorigininfo
%     ORIGINCODE = HDFGD('origininfo',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g�Ɋւ��錴�_�R�[�h���o�͂��܂��BORIGINCODE �́A
%     'ul', 'ur', 'll', 'lr' �̂����ꂩ���g�p�ł��܂��B
%
% GDpixreginfo
%     PIXREGCODE = HDFGD('pixreginfo',GRID_ID)
%     �O���b�h�f�[�^�Z�b�g�Ɋւ���pixreg�R�[�h���o�͂��܂��BPIXREGCODE �́A
%     'center' �܂��� 'corner' �̂����ꂩ�ł��B
%
% �T�u�Z�b�g���[�`��
% ---------------
% GDdefboxregion
%     REGION_ID = HDFGD('defboxregion',GRID_ID,...
%                          CORNERLON,CORNERLAT)
%     �O���b�h�f�[�^�Z�b�g�ɑ΂���o�x-�ܓx�ň͂܂ꂽ�{�b�N�X�̈���`��
%     �܂��BCORNERLON �́A�{�b�N�X�̔��Α��̋��̌o�x���܂�2�v�f�x�N
%     �g���ł��BCORNERLAT �́A�{�b�N�X�̔��Α��̋��̈ܓx���܂�2�v�f�x
%     �N�g���ł��B���Z�����s�����ꍇ�́AREGION_ID ��-1�ɂȂ�܂��B
% 
% GDregioninfo
%      [NUMBERTYPE,RANK,DIMS,BYTESIZE,UPLEFT,LOWRIGHT, ...
%           STATUS] = HDFGD('regioninfo',GRID_ID,...
%                              REGION_ID,FIELDNAME)
%     �T�u�Z�b�g�����ꂽ�̈�Ɋւ�������擾���܂��BNUMBERTYPE �́A
%     �t�B�[���h��HDF�ԍ��^�C�v�ł��BRANK �́A�t�B�[���h�̃����N�ł��B
%     DIMS �́A�T�u�Z�b�g�����ꂽ�����̑傫�����܂ރx�N�g���ł��B
%     BYTESIZE �́A�T�u�Z�b�g�����ꂽ�̈���̃f�[�^�̑傫��(�o�C�g�P��)��
%     �\�킵�܂��BUPLEFT �́A�O���b�h�̍������X���W��Y���W���܂�2�v�f
%     �x�N�g���ł��BLOWRIGHT �́A�O���b�h�̉E������X���W��Y���W���܂�
%     2�v�f�x�N�g���ł��B���Z�����s�����ꍇ�́ASTATUS��-1�ŁA���̂��ׂ�
%     �̏o�͂� [] �ɂȂ�܂��B
% 
% GDextractregion
%     [DATA,STATUS] = HDFGD('extractregion',GRID_ID,...
%                REGION_ID,FIELDNAME)
%     �w�肵���t�B�[���h�̃T�u�Z�b�g�����ꂽ�̈悩��f�[�^��ǂݍ��݂܂��B
%     ���Z�����s�����ꍇ�́ASTATUS ��-1�ŁADATA �� [] �ɂȂ�܂��B
% 
%     ���ӁFHDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����g��
%     �܂��B����AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g���܂��B����́A
%     MATLAB�z��̑傫�����AHDF�f�[�^�t�B�[���h�̒�`���ꂽ�����̑傫
%     ���ɑ΂��āA�]�u����Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����Ă��܂��B���Ƃ��΁A
%     �O���b�h�t�B�[���h��3 x 4 x 5�Œ�`����Ă���ꍇ�́ADATA ��5 x 4 x 3
%     �̑傫���łȂ���΂Ȃ�܂���BPERMUTE �R�}���h�́A�����ŕK�v�ȕϊ�
%     ���s�����߂̃R�}���h�ł��B
%
% GDdeftimeperiod
%     PERIOD_ID2 = HDFGD('deftimeperiod',GRID_ID,...
%                 PERIOD_ID,STARTTIME,STOPID)
%     �O���b�h�f�[�^�Z�b�g�ɑ΂��鎞�Ԏ������`���܂��BPERIOD_ID �́A�O��
%     �Ăяo������̏o�� PERIOD_ID �� -1�̂����ꂩ�ł��BSTARTTIME �� 
%     STOPTIME�́A�����̊J�n���ԂƏI�����Ԃ��w�肷��X�J���ł��B���Z��
%     ���s�����ꍇ�́A�o�� PERIOD_ID2 ��-1�ł��B
%
% GDdefvrtregion
%     REGION_ID2 = HDFGD('defvrtregion',GRID_ID,...
%                 REGION_ID,VERTOBJ,RANGE)
%     �P��t�B�[���h�܂��͎����̘A������v�f�Ɋւ��ăT�u�Z�b�g�����܂��B
%     REGION_ID �́A�O�̃T�u�Z�b�g�Ăяo������̎��� ID �̗̈悩�A�܂���
%     -1�̂����ꂩ�ɂȂ�܂��BVERTOBJ �́A�T�u�Z�b�g�����ꂽ�t�B�[���h�܂�
%     �͎����̖��O���܂ޕ�����ł��BRANGE �́A�T�u�Z�b�g�ɑ΂���ŏ��͈�
%     �ƍő�͈͂��܂�2�v�f�x�N�g���ł��A���Z�Ɏ��s�����ꍇ�́AREGION_ID2 
%     ��-1�ɂȂ�܂��B
%
% GDgetpixels
%     [ROW,COL,STATUS] = HDFGD('getpixels',GRID_ID,...
%                          LON,LAT)
%     �ܓx�ƌo�x�ɑΉ�����s�N�Z�����W���擾���܂��BLON �� LAT �́A
%     �x�P�ʂŕ\�킵���o�x�ƈܓx�̍��W���܂ރx�N�g���ł��BROW �� COL �́A
%     �Ή�����[���x�[�X�̍s�Ɨ�̍��W���܂ރx�N�g���ł��B���Z�����s����
%     �ꍇ�́ASTATUS ��-1�ŁAROW �� COL �� [] �ɂȂ�܂��B
%
% GDgetpixvalues
%     [DATA,BYTESIZE] = HDFGD('getpixvalues',GRID_ID, ...
%                 ROW,COL,FIELDNAME)
%     �w�肵���s�Ɨ�̍��W�Ŏw�肵���t�B�[���h����f�[�^��ǂݍ��݂܂��B
%     ROW �� COL �́A�[���x�[�X�̍s���W�Ɨ���W���܂ރx�N�g���ł��B
%     ��􉽊w�I�Ȏ���(���Ȃ킿�AXDim��YDim�łȂ�)�ɉ��������ׂĂ̗v�f
%     �́A�P��̗�x�N�g���Ƃ��ďo�͂���܂��B���Z�����s�����ꍇ�́A
%     DATA �� [] �ŁABYTESIZE ��-1�ɂȂ�܂��B
%
% GDinterpolate
%     [DATA,BYTESIZE] = HDFGD('interpolate',GRID_ID,...
%                 LON,LAT,FIELDNAME)
%     �t�B�[���h�O���b�h��̑o�ꎟ���}���s���܂��BLON �� LAT �́A�o�x�ƈܓx
%     ���W���܂ރx�N�g���ł��B��􉽊w�I�Ȏ���(���Ȃ킿�AXDim��YDim�ł�
%     ��)�ɉ��������ׂĂ̗v�f�����}����܂��B���ʂ̒l�́A�{���x��x�N�g��
%     �Ƃ��ďo�͂���܂��B���Z�����s�����ꍇ�́ADATA �� [] �ŁABYTESIZE ��
%     -1�ɂȂ�܂��B
%
% GDdupregion
%     REGION_ID2 = HDFGD('dupregion',REGION_ID)
%     �̈�𕡐����܂��B���̃��[�`���́A�J�����g�̈���Ɋi�[����Ă�����
%     ���R�s�[���A�V�������ʎq���쐬���܂��B���[�U���̈�����������ɕ���
%     �̕��@�Őݒ肵�����ꍇ�ɖ𗧂��܂��B���Z�����s�����ꍇ�́A
%     REGION_ID2 ��-1�ɂȂ�܂��B
% 
% Tiling ���[�`��
% ---------------
% GDdeftile
%     STATUS = HDFGD('deftile',GRID_ID,TILECODE,TILEDIMS)
%     ��ɑ����t�B�[���h��`�ɑ΂���tiling�̎������`���܂��B
%     tile�̎������Ƃ��̌�̃t�B�[���h�̎������́A�����łȂ���΂Ȃ�܂���B
%     �����āAtile�����́A�Ή�����t�B�[���h�����𕪉��������̂ł��B
%     TILECODE�́A'tile' �܂��� 'notile' �̂����ꂩ�ł��BTILEDIMS �́Atile��
%     �������܂ރx�N�g���ł��B
%
% GDtileinfo
%     [TILECODE,TILEDIMS,TILERANK,STATUS] = HDFGD( ...
%               'tileinfo',GRID_ID,FIELDNAME)
%     �t�B�[���h�Ɋւ���tiling�����擾���܂��B���Z�����s�����ꍇ�́A�o��
%     STUTAS ��-1�ŁA���̏o�͂� [] �ɂȂ�܂��B
%
% GDsettilecache
%     STATUS = HDFGD('settilecache',GRID_ID,FIELDNAME,...
%                    MAXCACHE)
%     tile�L���b�V���p�����[�^��ݒ肵�܂��BMAXCACHE �́A���������ŃL���b�V��
%     ���s��tile�̍ő吔�������X�J���ł��B
%
% GDreadtile
%     [DATA,STATUS] = HDFGD('readtile',GRID_ID, ...
%              FIELDNAME,TILECOORDS)
%     �w�肵���t�B�[���h�̒���tile����ǂݍ��݂܂��BTILECOORDS �́A�ǂ�
%     ���܂��tile�̃[���x�[�X�̍��W���w�肷��x�N�g���ł��B���W�́Atile��
%     ����ĕ\�킳��A�f�[�^�v�f�ł͕\����܂���B���Z�����s�����ꍇ�́A
%     STATUS ��-1�ŁA���̂��ׂĂ̏o�͂� [] �ɂȂ�܂��B
% 
%     ���ӁFHDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����g��
%     �܂��B����AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g���܂��B����
%     �́AMATLAB�z��̑傫�����Atile�̎����̑傫���ɑ΂��āA����ւ���
%     ��邱�Ƃ��Ӗ����Ă��܂��B���Ƃ��΁Atile��3�s4��̎��������ꍇ�́A
%     DATA ��4�s3��̑傫���ɂȂ�܂��BPERMUTE �R�}���h�́A�K�v�ȕϊ�
%     ���s�����߂ɖ𗧂R�}���h�ł��B
%
% GDwritetile
%     STATUS = HDFGD('writetile',GRID_ID,FIELDNAME, ...
%                  TILECOORDS,DATA)
%     �t�B�[���h����tile�ɏ������݂܂��BTILECOORDS �́A�������܂��
%     �t�B�[���h�̃[���x�[�X�̍��W���w�肷��x�N�g���ł��B���W�́Atile�ɂ��
%     �Ďw�肵�A�f�[�^�v�f�ł͎w�肵�܂���BDATA�̃N���X�́A�w�肷��
%     �t�B�[���h��HDF�ԍ��^�C�v�ƈ�v���Ă��Ȃ���΂Ȃ�܂���BMATLAB
%     ������́AHDF char�^�C�v�̂����ꂩ�ƈ�v����悤�Ɏ����I�ɕϊ�����
%     �܂��B���̃f�[�^�^�C�v�́A�����Ɉ�v���Ȃ���΂Ȃ�܂���B
% 
%     ���ӁFHDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����g��
%     �܂��B����AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g���܂��B����
%     �́AMATLAB�z��̑傫�����Atile�̎����̑傫���ɑ΂��āA����ւ���
%     ��邱�Ƃ��Ӗ����Ă��܂��B���Ƃ��΁Atile��3�s4��̎��������ꍇ�́A
%     DATA ��4�s3��̑傫���ɂȂ�܂��BPERMUTE �R�}���h�́A�K�v�ȕϊ�
%     ���s�����߂ɖ𗧂R�}���h�ł��B
% 
% ���ۂɍ�Ƃ��s���ɂ́AHDF.MEX���R�[�����܂��B
% 
% �Q�l�FHDF, HDFSW, HDFPT.


%   Copyright 1984-2003 The MathWorks, Inc. 
