% HDFPT   HDF-EOS Point�I�u�W�F�N�g�ւ�MATLAB�C���^�t�F�[�X
%
% HDFPT�́AHDF-EOS Point�I�u�W�F�N�g�ւ�MATLAB�C���^�t�F�[�X�ł��BHDF-
% EOS�́ANCSA(National Center for Supercomputing Applications) HDF (Hi-
% erarchical Data Format)�̊g���ł��BHDF-EOS�́AEOS (Earth Observing 
% System)�ɑ΂���x�[�X���C���W���Ƃ���NASA���I������Ȋw�f�[�^�t�H�[�}
% �b�g�W���ł��B
% 
% HDFPT�́AHDF-EOS C���C�u������Point�֐��̃Q�[�g�E�F�C�ŁAEOSDIS (Earth
% Observing System Data and Information System)�ɂ���ĊJ������ێ�����
% �Ă��܂��BPoint�f�[�^�Z�b�g�́A(������������)�s�K���Ȏ��ԊԊu��A�U��
% ����n���I�Ȉʒu�œ���ꂽ�f�[�^���R�[�h���܂݂܂��B�e�f�[�^���R�[�h�́A
% ���Ԃ܂��͋�Ԃł̂���_�̏�Ԃ�\�킷1�܂��͕����̃f�[�^�l�̏W����
% �\������܂��B
% 
% ���̃w���v�̏��ɉ����A���[�U�͂��̃h�L�������g���Q�l�ɂ��Ă��������B
% 
%       HDF-EOS Library User's Guide for the ECS Project,
%       Volume 1: Overview and Examples; Volume 2: Function
%       Reference Guide 
% 
% ���̃h�L�������g�́A����web���痘�p�ł��܂��B
%   
%       http://hdfeos.gsfc.nasa.gov
%   
% ���̃T�C�g����h�L�������g���擾�ł��Ȃ��ꍇ�AMathWorks Technical Su-
% pport(support@mathworks.com)�ɂ��A�����������B
% 
% �V���^�b�N�X�̎g����
% ------------------
% HDF-EOS C���C�u������HDFPT �V���^�b�N�X�̒���Point�֐��Ԃ�1��1�}�b�s��
% �O�����݂��܂��B���Ƃ��΁AC���C�u�����́A�^�������x���C���f�b�N�X�ɑ�
% ���������x�����𓾂邽�߂ɁA���̊֐���p�ӂ��Ă��܂��B
% 
%       intn PTgetlevelname(int32 pointid, int32 level, 
%                           char *levelname, int32 *strbufsize)
% 
% ������MATLAB�V���^�b�N�X�́A���̂悤�ɂȂ�܂��B
% 
%       [LEVELNAME,STATUS] = HDFPT('getlevelname',POINTID,LEVEL)
% 
% LEVELNAME�́A������ł��BSTATUS��(�����̏ꍇ)0�A(���s�̏ꍇ)-1�̂�����
% ���ɂȂ�܂��B
% 
% ��������C���C�u�����֐��́AC�}�N���Œ�`���ꂽ���͒l���󂯓���܂��B
% ���Ƃ��΁AC PTopen()�֐��́ADFACC_READ�ADFACC_RDWR�A�܂���
% DFACC_CREATE�ɂȂ�A�N�Z�X���[�h���͂�K�v�Ƃ��܂��B�����ŁA�����̃V
% ���{���́A�K�؂�C�w�b�_�t�@�C���̒��ɒ�`����Ă��܂��B�}�N���̒�`��
% C���C�u�����̒��Ŏg���镔���ŁA������MATLAB�V���^�b�N�X�́A�}�N����
% ���瓾���镶������g���܂��B���[�U�́A�}�N�����S�̂��܂ޕ�������g�p
% ������A���邢�͋��ʂ���ړ�����ȗ����邱�Ƃ��ł��܂��B�܂��A�啶����
% ���������g�p���邱�Ƃ��ł��܂��B���Ƃ��΁A����C�֐��̌Ăяo��
% 
%       status = PTopen("PointFile.hdf",DFACC_CREATE)
% 
% �́A����MATLAB�֐��Ăяo���Ɠ����ł��B  
% 
%       status = hdfpt('open','PointFile.hdf','DFACC_CREATE')
%       status = hdfpt('open','PointFile.hdf','dfacc_create')
%       status = hdfpt('open','PointFile.hdf','CREATE')
%       status = hdfpt('open','PointFile.hdf','create')
% 
% C�֐����}�N����`����̒l���o�͂���ꍇ�A������MATLAB�֐��́A�}�N��
% ���������ŕ\�킵���Z�k�`���܂ޕ�����Ƃ��Ēl���o�͂��܂��B
% 
% HDF�ԍ��̃^�C�v�́A'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8','uint16', 
% 'uint32', 'float', 'int8', 'int16', 'int32'���܂ޕ�����Œ�`����܂��B
%
% HDF-EOS���C�u������NULL���󂯓����ꍇ�A��s��([])���g���܂��B
% 
% �قƂ�ǂ̃��[�`���́A���[�`�������������ꍇ��0�A���s�����ꍇ-1���A�t
% ���O STATUS �ɏo�͂��܂��BSTATUS ���܂܂Ȃ��V���^�b�N�X�������[�`��
% �́A���̊֐��̃V���^�b�N�X�ł̋L�q�ōs���Ă���悤�ȁA�o�͂̒��Ɏ��s��
% �Ӗ���������o�͂��܂��B
% 
% �v���O���~���O���f��
% -----------------
% 
% HDFPT���g�����|�C���g�f�[�^�Z�b�g���A�N�Z�X����v���O���~���O���f���́A
% ���̂悤�ɂȂ�܂��B
% 
% 1. �t�@�C�����I�[�v�����A�t�@�C��������t�@�C��id�𓾂邱�ƂŁAPT�C��
%    �^�t�F�[�X�����������܂��B
% 2. �|�C���g������|�C���gid�𓾂邱�Ƃɂ��|�C���g�f�[�^�Z�b�g���I�[
%    �v�����邩�A�쐬���܂��B
% 3. �f�[�^�Z�b�g��Ŋ�]���鉉�Z�����s���܂��B
% 4. �|�C���gid��ݒ肵�āA�|�C���g�f�[�^�Z�b�g���N���[�Y���܂��B
% 5. �t�@�C��id��ݒ肵�āA�t�@�C���ւ̃A�N�Z�X���I�����܂��B
% 
% HDF-EOS�t�@�C�����Ɋ��ɑ��݂��Ă���P��̃|�C���g�f�[�^�Z�b�g�ɃA�N�Z�X
% ���邽�߁A����MATLAB�R�}���h���g���܂��B
% 
%       fileid = hdfgd('open',filename,access);
%       pointid = hdfgd('attach',fileid,pointname);
% 
%       % �f�[�^�Z�b�g��ɃI�v�V�����̉��Z��K�p
% 
%       status = hdfgd('detach',pointid);
%       status = hdfgd('close',fileid);
% 
% �����ɕ����̃t�@�C���ɃA�N�Z�X���邽�߂ɂ́A�I�[�v������e�t�@�C����
% �t�@�C�����ʎq���X�Ɏ擾���܂��B�����̃|�C���g�f�[�^�Z�b�g�ɃA�N�Z�X
% ���邽�߂ɂ́A�e�f�[�^�Z�b�g�ɑ΂���X�̃|�C���gid���擾���܂��B
% 
% �o�b�t�@���ꂽ���삪�f�B�X�N�Ɋ��S�ɏ������܂��悤�ɁA�|�C���gid��
% �t�@�C��id��K�؂ɔj�����邱�Ƃ��d�v�ł��BMATLAB���I�����邩�A�I�[�v��
% �����܂܂�PT���ʎq�������ׂĂ�MEX-�t�@�C������������ƁAMATLAB�̓�
% �[�j���O��\�����A�����I�ɂ�����j�����܂��B
% 
% HDFPT�ŏo�͂����t�@�C�����ʎq�́A����HDF-EOS�܂���HDF�֐��ŏo��
% �����t�@�C�����ʎq�ƌ݊������Ȃ����Ƃɒ��ӂ��Ă��������B
% 
% �֐��̃J�e�S��
% -------------------
% �|�C���g�f�[�^�Z�b�g���[�`���́A���̃J�e�S���ɕ��ނ���܂��B
% 
%     - �A�N�Z�X���[�`���́APT�C���^�t�F�[�X��|�C���g�f�[�^�Z�b�g�ւ̃A�N�Z�X
%        (�t�@�C���̃I�[�v���ƃN���[�Y���܂�)������������яI�����܂��B
% 
%     - ��`���[�`���́A�|�C���g�f�[�^�Z�b�g�̎�v������ݒ肵�܂��B
% 
%     - ��{I/O���[�`���́A�|�C���g�f�[�^�Z�b�g�̃f�[�^�⃁�^�f�[�^�̓ǂݍ���
%       ����я����o�����s���܂��B
% 
%     - Index I/O ���[�`���́A����|�C���g�f�[�^�Z�b�g�̒���2�̃e�[�u
%       ���������N�������ǂݍ��񂾂菑���o���܂��B
% 
%     - ����(Inquiry)���[�`���́A�|�C���g�f�[�^�Z�b�g���Ɋ܂܂��f�[�^
%       �Ɋւ�������o�͂��܂��B
% 
%     - �T�u�Z�b�g���[�`���́A�ݒ肵���􉽓I�ȗ̈悩��f�[�^��ǂݎ���
%       ���B
% 
% �A�N�Z�X���[�`��
% ---------------
% PTopen
%      FILE_ID = HDFPT('open',FILENAME,ACCESS)
%      �t�@�C�����Ɗ�]����A�N�Z�X���[�h��^���āA�|�C���g���쐬�A�ǂݍ��݁A
%      �����o�����s�����߂�HDF�t�@�C�����I�[�v���܂��͍쐬���܂��BACCESS
%      �ɂ́A'read', 'readwrite', 'create' �̂����ꂩ���g�p�ł��܂��BFILE_ID�́A
%      ���삪���s�����-1�ɂȂ�܂��B
% 
% PTcreate
%      POINT_ID = HDFPT('create',FILE_ID,POINTNAME)
%      �w�肵�����O�����|�C���g�f�[�^�Z�b�g�̍쐬�BPOINTNAME �́A�|�C���g
%      �f�[�^�Z�b�g�̖��O���܂ޕ�����ł��BPOINT_ID �́A���삪���s������
%      ����-1�ł��B
% 
% PTattach
%      POINT_ID = HDFPT('attach',FILE_ID,POINTNAME)
%      �t�@�C�����ɑ��݂���|�C���g�f�[�^�Z�b�g�ɃA�^�b�`���܂��BPOINT_ID �́A
%      ���Z�����s�����ꍇ��-1�ł��B
% 
% PTdetach
%      STATUS = HDFPT('detach',POINT_ID)
%      �|�C���g�f�[�^�Z�b�g����؂���܂��B
% 
% PTclose
%      STATUS = HDFPT('close', FILE_ID)
%      �t�@�C�����N���[�Y���܂��B
% 
% ��`�Ɋւ��郋�[�`��
% -------------------
% PTdeflevel
%    STATUS = HDFPT('deflevel',POINT_ID,LEVELNAME,...
%                  FIELDLIST,FIELDTYPES,FIELDORDERS)
%    �|�C���g�f�[�^�Z�b�g���ŐV�������x�����`���܂��BLEVELNAME�́A��`��
%    �郌�x���̖��O�ł��BFIELDLIST�́A�V�������x���̒��ŁA�J���}�ŋ�؂��
%    ���t�B�[���h���̃��X�g���܂ޕ�����ł��BFIELDTYPES�́A�e�t�B�[���h�ɑ�
%    ���鐔���^�C�v��������܂ރZ���z��ł��B�g�p�ł��鐔���^�C�v�́A
%    'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8', 'uint16', 'uint32', 'float', 
%    'int8', 'int16', 'int32'���܂ޕ�����ł��BFIELDORDERS �́A�e�t�B�[���h�ɑ�
%    ���鏇�Ԃ��܂ރx�N�g���ł��B
% 
% PTdeflinkage
%     STATUS = HDFPT('deflinkage',POINT_ID,PARENT,...
%                         CHILD,LINKFIELD)
%     2�ׂ̗荇�������x���Ԃ̃����N�t�B�[���h���`���܂��BPARENT �́A�e
%     ���x���̖��O�ł��BCHILD �́A�q���x���̖��O�ł��BLINKFILED �́A2��
%     �̃��x���Œ�`���ꂽ�t�B�[���h�̖��O�ł��B
% 
% ��{�I�� I/O ���[�`��
% ------------------
% PTwritelevel
%     STATUS = HDFPT('writelevel',POINT_ID,LEVEL,DATA)
%     �|�C���g�f�[�^�Z�b�g�̒��Ɏw�肵�����x���ɐV�������R�[�h��t�����܂��B
%     LEVEL �́A��]���郌�x���C���f�b�N�X(�[���x�[�X)�ł��BDATA �́AP�s1
%     ��̃Z���z��ŁAP �͎w�肵�����x���ɑ΂��Ē�`���ꂽ�t�B�[���h����
%     ���BDATA �̊e�X�̃Z���́A�f�[�^�� M(k) �s N ��̍s����܂�ł��܂��B
%     �����ŁAM(k) �� k �Ԗڂ̃t�B�[���h�̎���(�t�B�[���h���̃X�J���l�̐�)�ŁA
%     N �̓��R�[�h���ł��B�Z����MATLAB�N���X�́A�Ή�����t�B�[���h�ɑ΂���
%     ��`���ꂽHDF�f�[�^�^�C�v�Ɉ�v���Ă��Ȃ���΂Ȃ�܂���BMATLAB��
%     ����́AHDF char�^�C�v�̂����ꂩ�Ɉ�v����悤�Ɏ����I�ɕϊ������
%     ���B���̃f�[�^�^�C�v�́A�����ȈӖ��ň�v���Ă��Ȃ���΂Ȃ�܂���B
%   
% PTreadlevel
%     [DATA,STATUS] = HDFPT('readlevel',POINT_ID,LEVEL,FIELDLIST,RECORDS)
% 
%     �|�C���g�f�[�^�Z�b�g���ɗ^����ꂽ���x������f�[�^��ǂ݂܂��BLEVEL
%     �́A��]���郌�x����(�[���x�[�X��)�C���f�b�N�X�ł��BFIELDLIST�́A�ǂ�
%     ���ރt�B�[���h���J���}�̋�؂���g�������X�g���܂ޕ�����ł��B
%      RECORDS �́A�ǂݍ��܂�郌�R�[�h��(�[���x�[�X��)�C���f�b�N�X���܂�
%     �x�N�g���ł��BDATA�́AP�s1��̃Z���z��ŁAP �͗v�������t�B�[���h��
%     �ł��BDATA �̊e�X�̃Z���́A�f�[�^�� M(k) �s N ��̍s����܂�ł���
%     ���B�����ŁAM(k) �� k �Ԗڂ̃t�B�[���h�̎����ŁAN �̓��R�[�h�����܂���
%     LENGTH(RECORDS) �̂����ꂩ�ł��B
% 
% PTupdatelevel
%      STATUS = HDFPT('updatelevel',POINT_ID,LEVEL,...
%                         FIELDLIST,RECORDS,DATA)
%      �|�C���g�f�[�^�Z�b�g�̓���̃��x���̒��̃f�[�^���X�V(������)���܂��B
%      LEVEL �́A��]���郌�x����(�[���x�[�X��)�C���f�b�N�X�ł��BFIELDLIST
%      �́A�X�V����t�B�[���h�̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��B
%      DATA �́AP�s1��̃Z���z��ŁAP �͎w�肵���t�B�[���h�̐��ł��BDATA
%      �̊e�X�̃Z���́A�f�[�^�� M(k) �s N ��̍s����܂�ł��܂��B�����ŁA
%      M(k) �� k �Ԗڂ̃t�B�[���h�̎����ŁAN �̓��R�[�h�����܂���
%      LENGTH(RECORDS) �̂����ꂩ�ł��B�Z����MATLAB�N���X�́A�Ή�����
%      �t�B�[���h�ɑ΂��Ē�`���ꂽHDF�f�[�^�^�C�v�ƈ�v���Ă��Ȃ���΂Ȃ��
%      ����BMATLAB������́AHDFchar�^�C�v�̂����ꂩ�Ɉ�v����悤�Ɏ���
%      �I�ɕϊ�����܂��B���̃f�[�^�^�C�v�́A�����ȈӖ��ň�v���Ă��Ȃ����
%      �Ȃ�܂���B
% 
% PTwriteattr
%      STATUS = HDFPT('writeattr',POINT_ID,ATTRNAME,DATA)
%      �w�肵�����O�̑��������|�C���g�f�[�^���������ނ��A�܂��͍X�V����
%      ���B���������ɑ��݂��Ă��Ȃ��ꍇ�́A�쐬���܂��B
% 
% PTreadattr
%      [DATA,STATUS] = HDFPT('readattr',POINT_ID,ATTRNAME)
%      �ݒ肵����������A����ɋA������f�[�^��ǂݍ��݂܂��B
% 
% Inquiry ���[�`��
% ----------------
% PTnlevels
%      NLEVELS = HDFPT('nlevels',POINT_ID)
%      �|�C���g�f�[�^�Z�b�g�̒��̃��x�������o�͂��܂��B���Z�Ɏ��s�����ꍇ�A
%      NLEVELS ��-1�ɂȂ�܂��B
% 
% PTnrecs
%      NRECS = HDFPT('nrecs',POINT_ID,LEVEL)
%      �w�肵�����x���̒��̃��R�[�h�����o�͂��܂��B���Z�Ɏ��s�����ꍇ�A
%      NRECS ��-1�ɂȂ�܂��B
% 
% PNnfields
%      [NUMFIELDS,STRBUFSIZE] = HDFPT('nfields',POINT_ID,LEVEL)
%      �w�肵�����x���̒��̃t�B�[���h�����o�͂��܂��BSTRBUFSIZE �́A�J���}
%      �ŋ�؂�ꂽ�t�B�[���h���̕�����̒����ł��B���Z�Ɏ��s�����ꍇ�A
%      NUMFIELDS ��-1�ASTRBUFSIZE �� [] �ɂȂ�܂��B
% 
% PTlevelinfo
%      [NUMFIELDS,FIELDLIST,FIELDTYPE,FIELDORDER] = ...
%                        HDFPT('levelinfo',POINT_ID,LEVEL)
%      �w�肵�����x���ɑ΂���t�B�[���h�Ɋւ�������o�͂��܂��BFIELDLIST
%      �́A�X�V����t�B�[���h�̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��B
%      FIELDTYPE �́A�e�X�̃t�B�[���h�Ɗ֘A����(�X�J���l�̐�)�������܂ރx�N
%      �g���ł��B���Z�Ɏ��s�����ꍇ�ANUMFIELDS ��-1�A���̏o�͂͋�ɂȂ��
%      ���B
% 
% PTlevelindx
%      LEVEL = HDFPT('levelindx',POINT_ID,LEVELNAME)
%      �w�肵�����O�������x����(�[���x�[�X��)���x���C���f�b�N�X���o�͂���
%      ���B���Z�Ɏ��s�����ꍇ�ALEVEL ��-1�ɂȂ�܂��B
% 
% PTbcklinkinfo
%      [LINKFIELD,STATUS] = HDFPT('bcklinkinfo',POINT_ID,LEVEL)
%     �O�̃��x���ւ̃����N�t�B�[���h���o�͂��܂��B���Z�Ɏ��s�����ꍇ�A
%     STATUS ��-1�ALINKFIELD �� [] �ɂȂ�܂��B
% 
% PTfwdlinkinfo
%      [LINKFIELD,STATUS] = HDFPT('fwdlinkinfo',POINT_ID,LEVEL)
%     ���̃��x���ւ̃����N�t�B�[���h���o�͂��܂��B���Z�Ɏ��s�����ꍇ�A
%     STATUS ��-1�ALINKFIELD �� [] �ɂȂ�܂��B
% 
% PTgetlevelname
%      [LEVELNAME,STATUS] = HDFPT('getlevelname',POINT_ID,LEVEL)
%     ���x���C���f�b�N�X��^���āA���x���̖��O���o�͂��܂��B���Z�Ɏ��s����
%     �ꍇ�ASTATUS ��-1�ALEVELNAME �� [] �ɂȂ�܂��B
% 
%   PTsizeof
%      [BYTESIZE,FIELDLEVELS] = HDF('sizeof',POINT_ID,FIELDLIST)
%     �w�肵���t�B�[���h�̃t�B�[���h���x���ƃo�C�g�����o�͂��܂��BFIELDLIST
%     �́A�J���}�ŋ�؂�ꂽ�t�B�[���h�����܂ޕ�����ł��BBYTESIZE �͎w
%     �肵���t�B�[���h�̃o�C�g���̑����ŁAFIELDLEVELS �͊e�t�B�[���h�ɑΉ�
%     �������x���C���f�b�N�X���܂ރx�N�g���ł��B���Z�����s�����ꍇ�A
%     BYTESIZE ��-1�ŁAFIELDLEVELS �� [] �ɂȂ�܂��B
% 
% PTattrinfo
%      [NUMBERTYPE,COUNT,STATUS] = HDFPT('attrinfo',POINT_ID,ATTRNAME)
%     �w�肵�������̃o�C�g���ŕ\�킵���傫���Ɛ��l�^�C�v���o�͂��܂��B
%     ATTRNAME �́A�����̖��O�ł��BNUMBERTYPE �́A������HDF�f�[�^�^
%     �C�v�ɑΉ����镶����ł��BCOUNT �́A�����f�[�^�Ŏg����o�C�g����
%     ���B���Z�����s�����ꍇ�ASTATUS ��-1�ŁANUMBERTYPE �� COUNT ��
%     [] �ɂȂ�܂��B
% 
% PTinqattrs
%      [NATTRS,ATTRNAMES] = HDFPT('inqattrs',POINT_ID)
%      �|�C���g�f�[�^�Z�b�g�̒��ɒ�`���Ă��鑮���Ɋւ�������o�͂��܂��B
%      NATTRS �� ATTRNAMES �́A��`���ꂽ���ׂĂ̑����̐��Ɩ��O������
%      ���ꎦ���܂��B���Z�����s�����ꍇ�ANUMPOINTS ��-1�ŁAATTRNAMES
%      �� [] �ł��B
% 
% PTinqpoint
%      [NUMPOINTS,POINTNAMES] = HDFPT('inqpoint',FILENAME)
%      HDF-EOS�t�@�C�����ɒ�`����Ă���|�C���g�f�[�^�Z�b�g�̐��Ɩ��O���o
%      �͂��܂��BPOINTNAMES �́A�J���}�ŋ�؂�ꂽ�|�C���g�����܂ޕ�����
%      �ł��B���Z�����s�����ꍇ�ANUMPOINTS ��-1�ŁAPOINTNAMES �� [] ��
%      ���B
% 
% ���[�e�B���e�B���[�`��
% ----------------
% PTgetrecnums
%      [OUTRECORDS,STATUS] = HDFPT('getrecnums',...
%                           POINT_ID,INLEVEL,OUTLEVEL,INRECORDS)
%      ���x�� INLEVEL ���� INRECORDS �ɂ��w�肳��郌�R�[�h�Q�ɑΉ���
%      �� OUTLEVEL ���̃��R�[�h�����o�͂��܂��BINLEVEL �� OUTLEVEL �́A
%      �[���x�[�X�̃��x���C���f�b�N�X�ł��BINRECORDS �́A�[���x�[�X�̃�
%      �R�[�h�C���f�b�N�X�̃x�N�g���ł��B���Z�����s�����ꍇ�ASTATUS ��-1
%      �ŁAOUTRECORDS �� [] �ɂȂ�܂��B
% 
% �T�u�Z�b�g���[�`��
% ---------------
% PTdefboxregion
%      REGION_ID = HDFPT('defboxregion',POINT_ID,...
%                            CORNERLON,CORNERLAT)
%      ����|�C���g�ɑ΂���o�x-�ܓx�{�b�N�X�̈���`���܂��BCORNERLON
%      �́A�{�b�N�X�̔��Α��̋��̌o�x���܂�2�v�f�x�N�g���ł��BCORNERLAT
%      �́A�{�b�N�X�̔��Α��̋��̈ܓx���܂�2�v�f�x�N�g���ł��B���Z�����s��
%      ���ꍇ�AREGION_ID ��-1�ɂȂ�܂��B
% 
% PTdefvrtregion
%      PERIOD_ID = HDFPT('defvrtregion',POINT_ID,REGION_ID,,...
%                            VERT_FIELD,RANGE)
%      �|�C���g�ɑ΂��鐂���̈���`���܂��BVERT_FIELD �́A�T�u�Z�b�g������
%      �t�B�[���h���ł��BRANGE �́A�����l�̍ŏ��l�ƍő�l���܂�2�v�f�x�N�g
%      ���ł��B���Z�����s�����ꍇ�APERIOD_ID ��-1�ɂȂ�܂��B
% 
% PTregioninfo
%      [BYTESIZE,STATUS] = HDFPT('regioninfo',POINT_ID,...
%                           REGION_ID,LEVEL,FIELDLIST)
%     �w�肵�����x���̃T�u�Z�b�g�����ꂽ�̈�̃f�[�^�T�C�Y���o�C�g�P�ʂŏo
%     �͂��܂��BFIELDLIST �́A�J���}�ŋ�؂�ꂽ���o�����t�B�[���h���܂ޕ�
%     ����ł��B���Z�����s�����ꍇ�ASTATUS �� BYTESIZE ��-1�ɂȂ�܂��B
% 
% PTregionrecs
%      [NUMREC,RECNUMBERS,STATUS] = HDFPT('regionrecs',...
%                                     POINT_ID,REGION_ID,LEVEL)
%     �w�肵�����x���̃T�u�Z�b�g�����ꂽ�̈���̃��R�[�h�ԍ����o�͂��܂��B
%     ���Z�����s�����ꍇ�ASTATUS �� NUMREC ��-1�ŁARECNUMBERS �� []
%     �ɂȂ�܂��B
% 
% PTextractregion
%      [DATA,STATUS] = HDFPT('extractregion',POINT_ID,...
%                                REGION_ID,LEVEL,FIELDLIST)
%     �w�肵���T�u�Z�b�g�̈悩��f�[�^��ǂݍ��݂܂��BFIELDLIST �́A�v����
%     ���t�B�[���h�̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��BDATA �́AP
%     �s1��̃Z���z��ŁAP �͗v�������t�B�[���h���ł��BDATA �̊e�Z��
%     �́A�f�[�^�� M(k) �s N ��̍s����܂�ł��܂��B�����ŁAM(k) �� k �Ԗ�
%     �̃t�B�[���h�̎����ŁAN �̓��R�[�h���ł��B���Z�����s�����ꍇ�A
%     STATUS ��-1�ŁADATA �� [] �ɂȂ�܂��B
% 
% PTdeftimeperiod
%      PERIOD_ID = HDFPT('deftimeperiod',POINT_ID,...
%                            STARTTIME,STOPTIME)
%      �|�C���g�f�[�^�Z�b�g�ɑ΂��鎞�Ԏ������`���܂��B���Z�����s������
%      ���APERIOD_ID ��-1�ɂȂ�܂��B
% 
% PTperiodinfo
%      [BYTESIZE,STATUS] = HDFPT('periodinfo',POINT_ID,...
%                           PERIOD_ID,LEVEL,FIELDLIST)
%     �T�u�Z�b�g�����ꂽ�������o�C�g���ŕ\�킵���傫�����o�͂��܂��B
%     FIELDLIST�́A�J���}�ŋ�؂�ꂽ��]����t�B�[���h���̃��X�g���܂ޕ���
%     ��ł��B���Z�����s�����ꍇ�ABYTESIZE �� STATUS ��-1�ɂȂ�܂��B
% 
% PTperiodrecs
%      [NUMREC,RECNUMBERS,STATUS] = HDFPT('periodrecs',...
%                             POINT_ID,PERIOD_ID,LEVEL)
%     �w�肵�����x���̃T�u�Z�b�g�����ꂽ���Ԏ������ł̃��R�[�h�����o�͂���
%     ���B���Z�����s�����ꍇ�ANUMREC �� STATUS ��-1�ɂȂ�܂��B
% 
% PTextractperiod
%      [DATA,STATUS] = HDFPT('extractregion',...
%                       POINT_ID,REGION_ID,LEVEL,FIELDLIST)
%     �w�肵���T�u�Z�b�g�����ꂽ���Ԏ�������f�[�^��ǂ݂܂��BFIELDLIST 
%     �́A�J���}�ŋ�؂�ꂽ�v�����ꂽ�t�B�[���h���X�g���܂ޕ�����ł��B
%     DATA �́AP�s1��̃Z���z��ŁAP �͗v�������t�B�[���h�̐��ł��B
%     DATA �̊e�X�̃Z���́A�f�[�^�� M(k) �s N ��̍s����܂݁AM(k) �� k 
%     �Ԗڂ̎����AN �̓��R�[�h���ł��B���Z�����s�����ꍇ�ASTATUS ��-1�ŁA
%     DATA �� [] �ɂȂ�܂��B
% 
% ���ۂ̏����́AHDF.MEX���R�[�����܂��B
%   
% �Q�l�FHDF, HDFSW, HDFGD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:57 $
% 

