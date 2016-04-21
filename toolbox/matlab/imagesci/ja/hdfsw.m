% HDFSW   HDF-EOS Swath�I�u�W�F�N�g��MATLAB�C���^�t�F�[�X
%
% HDFSW�́AHDF-EOS Swath�I�u�W�F�N�g��MATLAB�C���^�t�F�[�X�ł��B
% HDF-EOS�́ANCSA(National Center for Supercomputing Applications) HDF 
% (Hierarchical Data Format)�̊g���ł��BHDF-EOS�́AEOS (Earth Observing 
% System)�ɑ΂���x�[�X���C���W���Ƃ���NASA���I������Ȋw�f�[�^�t�H�[�}�b�g
% �W���ł��B
% 
% HDFSW�́AHDF-EOS C���C�u������Swath�֐��̃Q�[�g�E�F�C�ŁAEOSDIS 
% (Earth Observing System Data and Information System)�ɂ���ĊJ������ێ�
% ����Ă��܂��Bswath�f�[�^�Z�b�g�́A�f�[�^�t�B�[���h�Ageolocation�t�B�[���h
% �����A�����}�b�v�ō\������܂��B�f�[�^�t�B�[���h�́A�t�@�C���̐��f�[�^
% �ł��Bgeolocation�t�B�[���h�́Aswath�ƒn���̕\�ʂ̓���̒n�_�����ѕt��
% �邽�߂Ɏg�p����܂��B�����́A�f�[�^�̎��ƒn���I�Ȉʒu�t�B�[���h���`
% ���A������\�킷�}�b�v�̓f�[�^�̎����ƒn���I�Ȉʒu�t�B�[���h�̊Ԃ̊֌W
% ���`���܂��B�t�@�C���́Aswath�S�̂Œn���I�Ȉʒu�̏�񂪈��̊Ԋu��
% �J��Ԃ��Ȃ��ꍇ�ɁA�C���f�b�N�X�ƌ�����5�Ԗڂ̕������I�v�V�����ł�
% ���Ƃ�����܂�(�C���f�b�N�X�́ALandsat 7 data products�ɑ΂��Đ݌v��
% ��܂���)�B
% 
% �����ŏq�ׂ����ɉ����āA���̃h�L�������g���Q�Ƃ��邱�Ƃ������߂���
% ���B
% 
%     HDF-EOS Library User's Guide for the ECS Project,
%     Volume 1: Overview and Examples; Volume 2: Function
%     Reference Guide 
% 
% ���̃h�L�������g�́A����web�������\�ł��B
% 
%     http://hdfeos.gsfc.nasa.gov
% 
% ��������h�L�������g�����ł��Ȃ��ꍇ�́AMathWorks Technical Support
% �ɁA���₢���킹��������(support@mathworks.com)�B
% 
% �V���^�b�N�X�̎g����
% --------------------
% HDF-EOS C���C�u������Switch�֐���HDFSW�̃V���^�b�N�X�ɂ́A1��1�̎ʑ�
% �֌W������܂��B���Ƃ��΁AC���C�u�����́A����̎����̃T�C�Y�𓾂邽�߂�
% �֐����܂݂܂��B
% 
%     int32 SWdiminfo(int32 swathid�Achar *dimname)
% 
% ������MATLAB�̗p�@�́A���̒ʂ�ł��B
% 
%     DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
% 
% SWATH_ID �́A�����swath�f�[�^�Z�b�g�̎��ʎq(�܂��̓n���h��)�ł��B
% DIMNAME�́A�w�肵�����������܂ޕ�����ł��BDIMSIZE �́A�w�肵������
% �̃T�C�Y���A���邢�͑��삪���s�����ꍇ��-1�ɂȂ�܂��B
%
% C���C�u�����֐��̒��ɂ́AC�}�N���Œ�`���ꂽ���͒l���󂯓������̂�
% ����܂��B���Ƃ��΁AC�̊֐� SWopen() �́ADFACC_READ�ADFACC_RDWR�A
% DFACC_CREATE�̂����ꂩ�ł���A�N�Z�X���[�h���͂�K�v�Ƃ��܂��B�����ŁA
% �����̃V���{���́A�K�؂�C�̃w�b�_�t�@�C���Œ�`����Ă��܂��B�}�N����
% ��`��C���C�u�����Ŏg�p����Ă���Ƃ��A������MATLAB�V���^�b�N�X�́A�}�N
% �������瓾���镶������g���܂��B�}�N�����S�̂��܂ޕ�������g�p���邱
% �Ƃ��A�܂��͋��ʂ̐ړ�����ȗ����邱�Ƃ��ł��܂��B�啶�������������g�p
% ���邱�Ƃ��ł��܂��B���Ƃ��΁A����C�֐��Ăяo��
% 
%     status = SWopen("SwathFile.hdf",DFACC_CREATE)
% 
% �́A����MATLAB�֐��Ăяo���Ɠ����ł��B
% 
%     status = hdfsw('open','SwathFile.hdf','DFACC_CREATE')
%     status = hdfsw('open','SwathFile.hdf','dfacc_create')
%     status = hdfsw('open','SwathFile.hdf','CREATE')
%     status = hdfsw('open','SwathFile.hdf','create')
% 
% C�֐����}�N����`����̒l���o�͂���ꍇ�́A������MATLAB�֐��̓}�N��
% ���������ŕ\�킵���Z�k�`���܂ޕ�����Ƃ��Ēl���o�͂��܂��B
%
% HDF ���l�^�C�v�́A���̕�����Ŏw�肳��܂��B
% 
%    'uchar8'�A'uchar'�A'char8'�A'char'�A'double'�A'uint8'�A'uint16'�A
%    'uint32'�A'float'�A'int8'�A'int16'�A'int32'.
%
% HDF-EOS���C�u������NULL���󂯓����ꍇ�́A��s��([])���g���܂��B
% 
% �قƂ�ǂ̃��[�`���́A���[�`�������������ꍇ0�A���s�����ꍇ-1���A�t��
% �O STATUS �ɏo�͂��܂��BSTATUS ���܂܂Ȃ��V���^�b�N�X�������[�`����
% �ȉ��̊֐��̃V���^�b�N�X�ł̋L�q�ōs���Ă���悤�ɁA�o�͂̂�����1�ɁA
% ���s���Ӗ���������o�͂��܂��B
% 
% �v���O���~���O���f��
% --------------------
% HDFSW���g����swath�f�[�^�Z�b�g�ւ̃A�N�Z�X�̃v���O���~���O���f���́A��
% �̂悤�ɂȂ�܂��B
% 
% 1. �t�@�C�����I�[�v�����A�t�@�C��������t�@�C��id�𓾂邱�Ƃ�SW�C���^
%    �t�F�[�X�����������܂��B
% 2. swath������swath id�𓾂邱�Ƃɂ���āAswath�f�[�^�Z�b�g���I�[�v��
%    �܂��͍쐬���܂��B
% 3. �f�[�^�Z�b�g�Ŋ�]���鑀����s���܂��B
% 4. swath id��j�����邱�Ƃɂ���āAswath�f�[�^�Z�b�g���N���[�Y���܂��B
% 5. �t�@�C��id��j�����邱�Ƃɂ���āA�t�@�C���ւ�swath�A�N�Z�X���I����
%    �܂��B 
% 
% HDF-EOS�t�@�C�����̊����̒P���swath�f�[�^�Z�b�g�ɃA�N�Z�X����ɂ́A��
% ����MATLAB�R�}���h���g�p���܂��B
% 
%     fileid = hdfsw('open',filename,access);
%     swathid = hdfsw('attach',fileid,swathname);
% 
%     % �f�[�^�Z�b�g�ւ̃I�v�V�����̑���
% 
%     status = hdfsw('detach',swathid);
%     status = hdfsw('close',fileid);
% 
% �����ɕ����̃t�@�C���ɃA�N�Z�X���邽�߂ɂ́A�I�[�v������e�t�@�C����
% �t�@�C�����ʎq���X�Ɏ擾���܂��B������swath�f�[�^�Z�b�g�ɃA�N�Z�X����
% ���߂ɂ́A�e�f�[�^�Z�b�g�ɑ΂���X��swath���ʎq���擾���܂��B
% 
% �o�b�t�@�����ꂽ���삪�f�B�X�N�Ɋ��S�ɏ������܂��悤�ɁAswath id�ƃt�@�C
% ��id��K�؂ɔj�����邱�Ƃ��d�v�ł��BMATLAB���I�����邩�A�I�[�v����
% ���܂܂�SW���ʎq�������ׂĂ�MEX-�t�@�C������������ƁAMATLAB�̓��[
% �j���O��\�����A�����I�ɂ�����j�����܂��B
%
% HDFSW�ŏo�͂����t�@�C�����ʎq�́A����HDF�܂���HDF�֐��ŏo�͂�
% ���t�@�C�����ʎq�ƌ݊������Ȃ����Ƃɒ��ӂ��Ă��������B
% 
% �֐��̃J�e�S��
% --------------
% Swath�f�[�^�Z�b�g�̃��[�`���́A���̃J�e�S���ɕ��ނ���܂��B
% 
% - �A�N�Z�X���[�`���́ASW�C���^�t�F�[�X��swath�f�[�^�Z�b�g�ւ̃A�N�Z�X
%   (�t�@�C���̃I�[�v���ƃN���[�Y���܂�)������������яI�����܂��B
% 
% - ��`���[�`���́Aswath�f�[�^�Z�b�g�̎�ȋ@�\��ݒ肵�܂��B  
% 
% - ��{I/O���[�`���́Aswath�f�[�^�Z�b�g�̃f�[�^�⃁�^�f�[�^�̓ǂݍ���
%   ����я����o�����s���܂��B
% 
% - ����(Inquiry)���[�`���́Aswath�f�[�^�Z�b�g���Ɋ܂܂��f�[�^�Ɋւ�����
%   ���o�͂��܂��B
% 
% - �T�u�Z�b�g���[�`���́A�w�肵���n���̈悩��f�[�^�̓ǂݍ��݂��ł��܂��B
% 
% �A�N�Z�X���[�`��
% ----------------
% SWopen
%     FILE_ID = HDFSW('open',FILENAME,ACCESS)
%     FILENAME �Ɗ�]����A�N�Z�X���[�h��^���āAswath�f�[�^�Z�b�g�̍쐬�A
%     �ǂݍ��݁A�����o���̂��߂�HDF�t�@�C�����I�[�v���܂��͍쐬���܂��B
%     ACCESS�́A'read'�A'rdwr'�A'create' �̂����ꂩ�ł��BFILE_ID �́A
%     ���삪���s�����ꍇ��-1�ł��B
% 
% SWcreate
%     SWATH_ID = HDFSW('create',FILE_ID,SWATHNAME)
%     �t�@�C������swath�f�[�^�Z�b�g���쐬���܂��BSWATHNAME �́Aswath�f�[�^
%     �Z�b�g�����܂ޕ�����ł��BSWATH_ID �́A���삪���s�����ꍇ��-1�ł��B
%
% SWattach
%     SWATH_ID = HDFSW('attach',FILE_ID,SWATHNAME)
%     �t�@�C�����̊�����swath�f�[�^�Z�b�g��id��t���܂��BSWATH_ID�́A���삪
%     ���s�����ꍇ��-1�ł��B
%
% SWdetach
%     STATUS = HDFSW('detach',SWATH_ID)
%     swath�f�[�^�Z�b�g����id���������܂��B
%
% SWclose
%     STATUS = HDFSW('close',FILE_ID)
%     �t�@�C�����N���[�Y���܂��B
% 
% ��`�Ɋւ��郋�[�`��
% --------------------
% SWdefdim
%     STATUS = HDFSW('defdim',SWATH_ID,FIELDNAME,DIM)
%     swath���̐V�K�̎������`���܂��BFIELDNAME �́A��`����鎟�������w��
%     ���镶����ł��BDIM �́A�V�K�̎����̃T�C�Y�ł��B�����̂Ȃ��������w��
%     ����ɂ́ADIM ��0�܂��� Inf �̂����ꂩ�łȂ���΂Ȃ�܂���B
%
% SWdefdimmap
%     STATUS = ....
%       HDFSW('defdimmap',SWATH_ID,GEODIM,DATADIM,OFFSET,INCREMENT);
%     �n���I�Ȉʒu�ƃf�[�^�̎����Ԃ̒P���ȃ}�b�s���O���`���܂��BGEODIM ��
%     �n���I�Ȉʒu�̎������ŁADATADIM �̓f�[�^�̎������ł��BOFFSET �����
%     INCREMENT �́A�f�[�^�̎����ɑ΂���n���I�Ȉʒu�̎����̃I�t�Z�b�g��
%     �������w�肵�܂��B
% 
% SWdefidxmap
%     STATUS = HDFSW('defidxmap',SWATH_ID,GEODIM,DATADIM,INDEX)
%     �n���I�Ȉʒu�ƃf�[�^�̎����Ԃ̕s�K���ȃ}�b�s���O���`���܂��BGEODIM 
%     �͒n���I�Ȉʒu�̎������ŁADATADIM �̓f�[�^�̎������ł��BINDEX �́A
%     �e�X�̒n���I�Ȉʒu�̗v�f���Ή�����f�[�^�����̃C���f�b�N�X���܂�
%     �z��ł��B
%
% SWdefgeofield
%  STATUS = HDFSW('defgeofield',SWATH_ID,FIELDNAME,DIMLIST,NTYPE,MERGE)
%     swath���̐V�K��geolocation�t�B�[���h���`���܂��BFIELDNAME �́A��`��
%     ���t�B�[���h�����܂ޕ�����ł��BDIMLIST �́A�t�B�[���h���`����n��
%     �I�Ȉʒu�̎����̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��BNTYPE �́A
%     �t�B�[���h��HDF ���l�^�C�v���܂ޕ�����ł��BMERGE �̓}�[�W�R�[�h�ŁA
%    'nomerge' �܂��� 'automerge' �̂����ꂩ�ł��B
% 
% SWdefdatafield
%     STATUS = ....
%       HDFSW('defdatafield',SWATH_ID,FIELDNAME,DIMLIST,NTYPE,MERGE)
%     swath���̐V�K�̃f�[�^�t�B�[���h���`���܂��BFIELDNAME �́A��`
%     �����t�B�[���h�����܂ޕ�����ł��BDIMLIST �́A�t�B�[���h���`
%     ����n���I�Ȉʒu�̎����̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��B
%     NTYPE �́A�t�B�[���h��HDF���l�^�C�v���܂ޕ�����ł��BMERGE ��
%     �}�[�W�R�[�h�ŁA'nomerge' �܂��� 'automerge' �̂����ꂩ�ł��B
% 
% SWdefcomp
%     STATUS = HDFSW('defcomp',SWATH_ID,COMPCODE,COMPPARM) 
%     ��ɑ������ׂẴt�B�[���h�̒�`�ɑ΂���t�B�[���h�̈��k��ݒ肵�܂��B
%     COMPCODE ��HDF���k�R�[�h�ŁA'rle'�A'skphuff'�A'deflate'�A'none' ��
%     �����ꂩ�ł��BCOMPPARM �́A�K�p�����ꍇ�͈��k�p�����[�^�̔z��ł��B
%     �p�����[�^���K�p����Ȃ��ꍇ�́ACOMPPARM �� [] �ł��B
% 
% SWwritegeometa
%     STATUS = HDFSW('writegeometa',SWATH_ID,FIELDNAME,DIMLIST,NTYPE)
%     FIELDNAME �Ƃ���������swath geolocation�t�B�[���h�ɑ΂���t�B�[���h��
%     ���^�f�[�^�������o���܂��BDIMLIST �́A�t�B�[���h���`����n���I��
%     �ʒu�̎����̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��BNTYPE �́A
%     �t�B�[���h���Ɋi�[���ꂽ�f�[�^��HDF���l�^�C�v���܂ޕ�����ł��B
% 
% SWwritedatameta
%     STATUS = HDFSW('writedatameta',SWATH_ID,FIELDNAME,DIMLIST,NTYPE)
%     FIELDNAME �Ƃ���������swath�f�[�^�t�B�[���h�ɑ΂���t�B�[���h�̃��^
%     �f�[�^�������o���܂��BDIMLIST �́A�t�B�[���h���`����n���I�Ȉʒu
%     �̎����̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��BNTYPE �́A
%     �t�B�[���h���Ɋi�[���ꂽ�f�[�^��HDF���l�^�C�v���܂ޕ�����ł��B
%
% ��{ I/O ���[�`��
% -----------------
% SWwritefield
%     STATUS = ....
%       HDFSW('writefield',SWATH_ID,FIELDNAME,START,STRIDE,EDGE,DATA)
%     �f�[�^��swath�t�B�[���h�ɏ����o���܂��BFIELDNAME �́A�����o�����
%     �t�B�[���h�����܂ޕ�����ł��BSTART �́A�e�X�̎������ł̊J�n�ʒu��
%     �w�肷��z��(�f�t�H���g��0)�ł��BSTRIDE �́A�e�����ŃX�L�b�v����
%     �l���w�肷��z��(�f�t�H���g��1)�ł��BEDGE �́A�e�X�̎����ɏ����o��
%     �l�̌����w�肷��z��(�f�t�H���g�� {dim - start}/stride)�ł��B
%     start, stride, edge �ɑ΂��ăf�t�H���g�l���g�p����ɂ́A��s��([])
%     ��n���Ă��������B  
% 
%     DATA �̃N���X�́A�^����ꂽ�t�B�[���h�ɑ΂��Ē�`���ꂽHDF ���l�^�C�v��
%     ��v���Ȃ���΂Ȃ�܂���BMATLAB������́A�C�ӂ�HDF char�^�C�v�ƈ�v��
%     ��悤�Ɏ����I�ɕϊ�����܂��B����ȊO�̃f�[�^�^�C�v�́A���m�Ɉ�v����
%     ����΂Ȃ�܂���B
%
%     ����: HDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����s���܂�
%     ���AMATLAB��FORTRAN�X�^�C���̏��ԕt�����g�p���܂��B����́AMATLAB
%     �z��̑傫�����AHDF�f�[�^�t�B�[���h�̒�`���ꂽ�����̑傫���ɑ΂��ē]�u
%     ����Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����܂��B���Ƃ��΁Aswath�t�B�[���h�� 
%     3 * 4 * 5 �̃T�C�Y�����ƒ�`���ꂽ�ꍇ�ADATA �̃T�C�Y�� 5 * 4 * 3 ��
%     �Ȃ���΂Ȃ�܂���BPERMUTE �R�}���h�́A�����ŕK�v�Ȍ������s�����߂�
%     �R�}���h�ł��B
%
% SWreadfield
%     [DATA,STATUS] = ....
%       HDFSW('readfield',SWATH_ID,FIELDNAME,START,STRIDE,EDGE)
%     swath�t�B�[���h����f�[�^��ǂݍ��݂܂��BFIELDNAME �́A�ǂݍ���
%     �t�B�[���h�����܂ޕ�����ł��BSTART �́A�e�X�̎������̊J�n�ʒu��
%     �ݒ肷��z��(�f�t�H���g��0)�ł��BSTRIDE �́A�e�X�̎����ŃX�L�b�v
%     ����l��ݒ肷��z��(�f�t�H���g��1)�ł��BEDGE �́A�e�X�̎�����
%     �����o���l�̌���ݒ肷��z��(�f�t�H���g�� {dim - start}/stride)
%     �ł��Bstart�Astride�Aedge�ɑ΂��ăf�t�H���g�l���g�p����ɂ́A
%     ��s��([])��n���Ă��������B�f�[�^�l�́A�z�� DATA �ɏo�͂���܂��B
% 
%     ����:HDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏��ԕt�����s���܂����A
%     MATLAB�́AFORTRAN�X�^�C���̏��ԕt�����g�p���܂��B����́AMATLAB�z
%     ��̑傫�����AHDF�f�[�^�t�B�[���h�̒�`���ꂽ�����̃T�C�Y�ɑ΂��ē]�u��
%     ��Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����܂��B���Ƃ��΁A�O���b�h�t�B�[���h�� 
%     3 * 4 * 5 �̃T�C�Y�����ƒ�`���ꂽ�ꍇ�ADATA �̃T�C�Y�� 5 * 4 * 3 
%     �łȂ���΂Ȃ�܂���BPERMUTE �R�}���h�́A�����ŕK�v�Ȍ������s��
%     ���߂̃R�}���h�ł��B
%
%     ���삪���s�����ꍇ�́ADATA �� [] �ŁASTATUS ��-1�ł��B
%
% SWwriteattr
%     STATUS = HDFSW('writeattr',SWATH_ID,ATTRNAME,DATA)
%     swath�̑����̏����o���ƍX�V���s���܂��BATTRNAME �́A���������܂ޕ���
%     ��ł��BDATA �́A�����l���܂ޔz��ł��B
% 
% SWreadattr
%     [DATA,STATUS] = HDFSW('readattr',SWATH_ID,ATTRNAME)
%     swath���瑮����ǂݍ��݂܂��BATTRNAME �́A���������܂ޕ�����ł��B��
%     ���l�́A�z�� DATA �ɏo�͂���܂��B���삪���s�����ꍇ�́ADATA �� [] �ŁA
%     STATUS ��-1�ł��B
%
% SWsetfillvalue
%     STATUS = HDFSW('setfillvalue',SWATH_ID,FIELDNAME,FILLVALUE)
%     �w�肵���t�B�[���h�ɂ���fill �l��ݒ肵�܂��BFILLVALUE �́A�X�J���ŁA
%     ���̃N���X�͎w�肵���t�B�[���h��HDF ���l�^�C�v�ƈ�v���Ȃ���΂Ȃ�܂�
%     ��BMATLAB������́A�C�ӂ�HDF char�^�C�v�Ɉ�v����悤�Ɏ����I�ɕ�
%     ������܂��B����ȊO�̃f�[�^�^�C�v�́A���m�Ɉ�v���Ȃ���΂Ȃ�܂���B
%
% SWgetfillvalue
%     [FILLVALUE,STATUS] = HDFSW('getfillvalue',SWATH_ID,...
%                            FIELDNAME)
%     �w�肵���t�B�[���h�ɑ΂���fill�l���擾���܂��B���삪���s�����ꍇ�́A
%     FILLVALUE �� [] �ŁASTATUS ��-1�ł��B
% 
% Inquiry ���[�`��
% -----------------
% SWinqdims
%     [NDIMS,DIMNAME,DIMS] = HDFSW('inqdims',SWATH_ID)
%     swath���Œ�`���ꂽ���ׂĂ̎����Ɋւ�������擾���܂��BNDIMS �́A��
%     �����ł��BDIMNAME �́A�������̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ������
%     ���BDIMS �́A�e�X�̎����̃T�C�Y���܂ޔz��ł��B���[�`�������s����ƁA
%     NDIMS ��-1�ŁA����ȊO�̏o�͈����� [] �ł��B
%   
% SWinqmaps
%     [NMAPS,DIMMAP,OFFSET,INCREMENT] = HDFSW('inqmaps',SWATH_ID)
%     swath���Œ�`���ꂽ���ׂĂ�(�C���f�b�N�X�̕t���Ă��Ȃ�)�n���I�Ȉʒu��
%     �֌W�Ɋւ�������擾���܂��B�X�J�� NMAPS �́A���߂�ꂽ�n���I�Ȉʒu
%     �̊֌W�̌��ł��BDIMMAP �́A�����}�b�v���̃J���}�ŋ�؂�ꂽ���X�g����
%     �ޕ�����ł��B�e�X�̃}�b�s���O����2�̎����́A�X���b�V��(/)�ŋ�؂���
%     ���BOFFSET ����� INCREMENT �́A�f�[�^�̎����ɑ΂���n���I�Ȉʒu�̎�
%     ���̃I�t�Z�b�g�Ƒ������܂ޔz��ł��B���[�`�������s�����ꍇ�́ANMAPS ��
%     -1�ŁA����ȊO�̏o�͈����� [] �ł��B
%
% SWinqidxmaps
%     [NIDXMAPS,IDXMAP,IDXSIZES] = HDFSW('inqidxmaps',SWATH_ID)
%     swath���Œ�`���ꂽ���ׂẴC���f�b�N�X�t���n���I�Ȉʒu/�f�[�^�̃}�b�s
%     ���O�Ɋւ�������擾���܂��BNIDXMAPS �́A�}�b�s���O���ł��BIDXMAP
%     �́A�}�b�s���O�̃J���}�ŋ�؂�ꂽ���X�g���܂ޕ�����ł��BIDXSIZES �́A��
%     ������C���f�b�N�X�z��̃T�C�Y���܂ޔz��ł��B���[�`�������s�����ꍇ�́A
%     NIDXMAPS ��-1�ŁA����ȊO�̏o�͈����� [] �ł��B
% 
% SWinqgeofields
%     [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqgeofields',SWATH_ID)
%     swath���Œ�`���ꂽ���ׂĂ�geolocation�t�B�[���h�̏����擾���܂��B
%     NFLDS �́A���߂�ꂽ�n���I�Ȉʒu�t�B�[���h���ł��BFIELDLIST �́A
%     �t�B�[���h�����J���}�ŋ�؂������X�g���܂ޕ�����ł��BRANK �́A
%     �e�X�̃t�B�[���h�ɑ΂��郉���N(������)���܂ޔz��ł��BNTYPE �́A
%     �e�X�̃t�B�[���h��number�^�C�v������������̃Z���z��ł��B���[�`��
%     �����s�����ꍇ�́ANFLDS ��-1�ŁA����ȊO�̏o�͈����� [] �ł��B
% 
% SWinqdatafields
%     [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqdatafields',SWATH_ID)
%     swath���Œ�`���ꂽ���ׂẴf�[�^�t�B�[���h�Ɋւ�������擾���܂��B
%     NFLDS �́A���߂�ꂽ�n���I�Ȉʒu�t�B�[���h���ł��BFIELDLIST �́A
%     �t�B�[���h�����J���}�ŋ�؂������X�g���܂ޕ�����ł��BRANK �́A
%     �e�X�̃t�B�[���h�ɑ΂��郉���N(������)���܂ޔz��ł��BNTYPE�́A
%     �e�X�̃t�B�[���h�� number�^�C�v������������̃Z���z��ł��B
%     ���[�`�������s�����ꍇ�́ANFLDS ��-1�ŁA����ȊO�̏o�͈����� [] �ł��B
% 
% SWinqattrs
%     [NATTR,ATTRLIST] = HDFSW('inqattrs',SWATH_ID)
%     swath���Œ�`���ꂽ�����Ɋւ�������擾���܂��BNATTR �́A���o�����
%     �������ł��BATTRLIST �́A���������J���}�ŋ�؂������X�g���܂ޕ������
%     ���B���[�`�������s����ƁANATTR ��-1�ŁAATTRLIST �� [] �ł��B
% 
% SWnentries
%     [NENTS,STRBUFSIZE] = HDFSW('nentries',SWATH_ID,ENTRYCODE)
%     �w�肵���v�f�ɑ΂���G���g�����ƋL�q���ꂽ������o�b�t�@�T�C�Y���擾��
%     �܂��BENTRYCODE �́A'HDFE_NENTDIM'(����)�A'HDFE_NENTMAP'(������
%     �}�b�s���O)�A'HDFE_NENTIMAP'(�C���f�b�N�X�t���̎����̃}�b�s���O)�A
%     'HDFE_NENTGFLD'(�n���I�Ȉʒu�t�B�[���h)�A'HDFE_NENTDFLD'(�f�[�^
%     �t�B�[���h)�̂����̂����ꂩ1�ł��BNENTS �́A���o���ꂽ�G���g�����ŁA
%     STRBUFSIZE �͋L�q���ꂽ������̃T�C�Y�ł��B���[�`�������s�����ꍇ�́A
%     NENTS ��-1�ŁASTRBUFSIZE �� [] �ł��B
%
% SWdiminfo
%     DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
%     �w�肵�������̃T�C�Y���擾���܂��BDIMNAME �́A�������ł��BDIMSIZE �́A
%     �����̃T�C�Y�ł��B���[�`�������s�����ꍇ�́ADIMSIZE ��-1�ł��B
%
% SWmapinfo
%     [OFFSET,INCREMENT,STATUS] = ....
%             HDFSW('mapinfo',SWATH_ID,GEODIM,DATADIM)
%     �w�肳�ꂽ�P���Ȓn���I�Ȉʒu�}�b�s���O�̃I�t�Z�b�g�Ƒ������擾���܂��B
%     GEODIM �́A�n���I�Ȉʒu�̎������ł��BDATADIM �́A�f�[�^�̎�������
%     ���BOFFSET ����� INCREMENT �́A�f�[�^�̎����ɑ΂���n���I�Ȉʒu�̎�
%     ���̃I�t�Z�b�g�Ƒ����ł��B���삪���s�����ꍇ�́ASTATUS ��-1�ŁA�����
%     �O�̏o�͂� [] �ł��B
%
% SWidxmapinfo
%     [IDXSZ,INDEX] = HDFSW('idxmapinfo',SWATH_ID,GEODIM,DATADIM)
%     �w�肳�ꂽ�n���I�Ȉʒu�}�b�s���O�̃C���f�b�N�X�t���z����擾���܂��B
%     GEODIM �́A�n���I�Ȉʒu�̎������ł��BDATADIM �́A�f�[�^�̎�������
%     ���BIDXSZ �́A�C���f�b�N�X�t���z��̃T�C�Y�ł��BINDEX �́A�}�b�s���O
%     �̃C���f�b�N�X�z��ł��B���[�`�������s�����ꍇ�́AIDXSZ ��-1�ŁA
%     INDEX �� [] �ł��B
% 
% SWattrinfo
%     [NTYPE,COUNT,STATUS] = HDFSW('attrinfo',SWATH_ID,ATTRNAME)
%     swath�̑����Ɋւ�������o�͂��܂��BATTRNAME �́A���������܂ޕ�����
%     �ł��BNTYPE �́A������HDF���l�^�C�v���܂ޕ�����ł��BCOUNT �́A
%     ATTRIUTE ���̃o�C�g���ł��B���삪���s�����ꍇ�́ASTATUS ��-1�ŁA����
%     �ȊO�̏o�͂�[]�ł��B
%
% SWfieldinfo
%     [RANK,DIMS,NTYPE,DIMLIST,STATUS] = ....
%         HDFSW('fieldinfo',SWATH_ID,FIELDNAME)
%     swath���̎w�肵��geolocatoion�t�B�[���h�܂��̓f�[�^�t�B�[���h�Ɋւ���
%     �����o�͂��܂��BFIELDNAME �́A�t�B�[���h�����܂ޕ�����ł��BRANK �́A
%     �t�B�[���h�̃����N(�����̌�)�ł��BDIMS �́A�t�B�[���h�̎����̃T�C�Y��
%     �܂ޔz��ł��BNTYPE �́A�t�B�[���h��HDF���l�^�C�v���܂ޕ�����ł��B
%     DIMLIST�́A�t�B�[���h���̎������J���}�ŋ�؂������X�g���܂ޕ�����ł��B
%     ���삪���s�����ꍇ�́ASTATUS ��-1�ŁA����ȊO�̏o�͂� [] �ł��B
%
% SWcompinfo
%     [COMPCODE,COMPPARM,STATUS] = HDFSW('compinfo',SWATH_ID,FIELDNAME)
%     �t�B�[���h�Ɋւ��鈳�k�����擾���܂��BFIELDNAME �́A�t�B�[���h������
%     �ޕ�����ł��BCOMPCODE ��HDF���k�R�[�h�ŁA'rle'�A'skphuff'�A'deflate'
%     'none' �̂����ꂩ�ł��BCOMPPARM �́A���k�p�����[�^�̔z��ł��B���삪��
%     �s�����ꍇ�́ASTATUS ��-1�ŁA����ȊO�̏o�͂� [] �ł��B
% 
% SWinqswath
%     [NSWATH,SWATHLIST] = HDFSW('inqswath',FILENAME)
%     HDF-EOS�t�@�C�����Œ�`���ꂽswath�̌��Ɩ��O���擾���܂��BFILENAME
%     �́A�t�@�C�������܂ޕ�����ł��BNSWATH �́A�t�@�C�����Ō��o���ꂽswath
%     �f�[�^�Z�b�g���ł��BSWATHLIST �́Aswath���̃J���}�ŋ�؂�ꂽ���X�g����
%     �ޕ�����ł��B���[�`�������s�����ꍇ�́ANSWATH ��-1�ŁASWATHLIST ��
%     [] �ł��B
%   
%   SWregionindex
%       [REGIONID, GEODIM, IDXRANGE] = HDFSW('defboxregion',... 
%	        		 SWATHID, CORNERLON, CORNERLAT, MODE); 
%     Swatch �����ɑ΂���ܓx�A�o�x�ɂ��̈�����肵�܂��B���̃��[�`����
%     SWdefboxregion �Ƃ̈Ⴂ�́A�n�`�I�Ȉʒu�̒ǐՎ����Ƃ��̎����͈̔͂��t
%     ���I�� regionID �ɏo�͂���邱�Ƃł��B���������͂Ɋւ���L�q�́A
%     SWdefboxregion �̃w���v���Q�Ƃ��Ă��������B
%       
%   SWupdateidxmap
%�@     [INDEXOUT, INDICES, IDXSZ] = HDFSW('updateidxmap',SWATHID,...
%					   REGIONID,INDEXIN);
%     �w�肵���̈�ɑ΂��āA�w�肵���n�`�I�ȃ}�b�s���O�̃C���f�b�N�X�z��
%     ��ǂݍ��݂܂��BREGIONID �́Aswatch �̈�̎��ʎq�ł��B
%     INDEXIN �́A�X�̒n�`�I�ȗv�f���Ή�����f�[�^�����̃C���f�b�N�X���܂�
%     �z����o�͂��܂��BINDEXOUT �́A�X�̒n�`���A�T�u�Z�b�g�̈���ɑΉ���
%     ��f�[�^�̈�̃C���f�b�N�X���܂ޔz��ł��BINDICES �́A�̈�̃X�^�[�g��
%     �X�g�b�v�ɑ΂���C���f�b�N�X���܂ޔz��ł��BIDXSZ �́AINDICES �z���
%     �T�C�Y�ł��邩�A���s���Ӗ����� -1 �ɂȂ�܂��B
%
%   SWgeomapinfo
%	    REGMAP = HDFSW('geomapinfo',SWATHID, GEODIM)
%     ���O GEODIM ���������ɑ΂��āA�����}�b�s���O�̃^�C�v��ǂݍ��݂܂��B
%     �߂�l REGMAP �́A0�̏ꍇ�̓}�b�s���O�Ȃ��A1�̏ꍇ�͒ʏ�̃}�b�s���O�A
%     2�̏ꍇ�̓C���f�b�N�X�t���}�b�s���O�A3�̏ꍇ�͒ʏ�̕��@���g�����C��
%     �f�b�N�X�t���}�b�s���O�A-1 �͎��s���Ӗ����܂��B
% 
% �T�u�Z�b�g���[�`��
% ------------------
%   SWdefboxregion
%     REGIONID = HDFSW('defboxregion',SWATH_ID,CORNERLON,CORNERLAT,MODE)
%     swath�̌o�x-�ܓx�{�b�N�X�̗̈���`���܂��BCORNERLON �����
%     CORNERLAT�́A�{�b�N�X�̋��̌o�x�ƈܓx���p�x�P�ʂŊ܂�2�v�f�z��ł��B
%     MODE �́A�q�Ղ̕\�����[�h�ŁA'HDFE_MIDPOINT', 'HDFE_ENDPOINT', 
%     'HDFE_ANYPOINT' �̂����ꂩ�ł��B���[�`�������������ꍇ�́AREGIONID 
%     ��swath�̈�̎��ʎq�ŁA���s�����ꍇ��-1�ł��B
% 
%   SWregioninfo
%     [NTYPE,RANK,DIMS,SIZE,STATUS] = ....
%             HDFSW('regioninfo',SWATH_ID,REGIONID,FIELDNAME)
%     �T�u�Z�b�g�����ꂽ�̈�Ɋւ�������擾���܂��BREGIONID �́Aswath�̗�
%     ��̎��ʎq�ł��BFIELDNAME �́A�T�u�Z�b�g�������t�B�[���h�����܂ޕ���
%     ��ł��BNTYPE �́A�t�B�[���h��HDF���l�^�C�v���܂ޕ�����ł��BRANK �́A
%     �t�B�[���h��RANK�ł��BDIMS �́A�T�u�Z�b�g�̈�̎�����^����z��ł��B
%     SIZE �́A�T�u�Z�b�g�̈�̃o�C�g�P�ʂ̃T�C�Y�ł��B
%
%   SWextractregion
%     [DATA,STATUS] = HDFSW('extractregion',....
%                 SWATH_ID,REGIONID,FIELDNAME,EXTERNAL_MODE)
%     �T�u�Z�b�g�����ꂽ�̈�𒊏o���܂�(�ǂݍ��݂܂�)�BREGIONID �́Aswath��
%     ��̎��ʎq�ł��BFIELDNAME �́A�T�u�Z�b�g�������t�B�[���h�����܂ޕ���
%     ��ł��BEXTERNAL_MODE �́A�O���̒n���I�Ȉʒu���[�h���܂ޕ�����ŁA
%     'external'(�f�[�^�ƒn���I�Ȉʒu�t�B�[���h���قȂ�swath���ɂ���)�A�܂���
%     'internal'(�f�[�^�ƒn���I�Ȉʒu�t�B�[���h������swath�\���̓��ɂ���)��
%     ���BDATA�́A�T�u�Z�b�g�����ꂽ�̈�Ɋ܂܂��f�[�^�ł��B
%
%   SWdeftimeperiod
%     PERIODID = HDFSW('deftimeperiod',SWATH_ID,STARTTIME,STOPTIME,MODE)
%     swath�̎��ԋ�Ԃ��`���܂��BSTARTTIME ����� STOPTIME �́A�J�n����
%     �ƏI�����Ԃł��BMODE �́A�q�Ղ̕\�����[�h�ŁA'midpoint'�A'endpoint'�A
%     'anypoint' �̂����ꂩ�ł��BPERIODID �́A���ԋ�Ԃ̎��ʎq�ł��B
%     ���[�`�������s�����ꍇ�́APERIODID ��-1�ł��B
% 
%   SWperiodinfo
%     [NTYPE,RANK,DIMS,SIZE,STATUS] = ....
%                      HDFSW('periodinfo',SWATH_ID,PERIODID,FIELDNAME)
%     �T�u�Z�b�g�����ꂽ�̈�Ɋւ�������擾���܂��BPERIODID �́A��Ԃ�
%     ���ʎq�ŁAFIELDNAME �̓T�u�Z�b�g�������t�B�[���h�����܂ޕ�����
%     �ł��BNTYPE�́A�t�B�[���h��HDF���l�^�C�v���܂ޕ�����ł��BRANK �́A
%     �t�B�[���h�̃����N�ł��BDIMS �́A�T�u�Z�b�g�������̈�̎�����
%     �܂ޔz��ł��BSIZE �́A�T�u�Z�b�g�������̈�̃o�C�g�P�ʂ̃T�C�Y
%     �ł��B���삪���s�����ꍇ�́ASTATUS ��-1�ŁA����ȊO�̏o�͂� [] �ł��B
%
%   SWextractperiod
%     [DATA,STATUS] = HDFSW('extractperiod',SWATH_ID,....
%                          PERIODID,FIELDNAME,EXTERNAL_MODE)
%     �T�u�Z�b�g�����ꂽ���ԋ�Ԃ𒊏o���܂�(�ǂݍ��݂܂�)�BPERIODID �́A���
%     �̎��ʎq�ł��BFIELDNAME �́A�T�u�Z�b�g�������t�B�[���h�����܂ޕ�����
%     �ł��BEXTERNAL_MODE �́A�O���̒n���I�Ȉʒu���[�h�ŁA'external'(�f�[�^��
%     �n���I�Ȉʒu�t�B�[���h���قȂ�swath���ɂ���)�A�܂���'internal'(�f�[�^��
%     �n���I�Ȉʒu�t�B�[���h������swath�\���̓��ɂȂ���΂Ȃ�Ȃ�)�ł��B
%     DATA �́A�T�u�Z�b�g�����ꂽ���ԋ�ԂɊ܂܂��f�[�^�ł��B
%
%   SWdefvrtregion 
%     ID2 = HDFSW('defvrtregion',SWATH_ID,ID,VERTOBJ,RANGE)
%     �P���ȃt�B�[���h�܂��͎����̘A���I�ȗv�f�ɂ��ăT�u�Z�b�g�����܂��BID
%     �́A�O�̃T�u�Z�b�g�Ăяo���̗̈�܂��͋�Ԏ��ʎq�A�܂��͍ŏ��̌Ăяo��
%     �̏ꍇ-1�ł��BVERTOBJ �́A�������܂��̓T�u�Z�b�g�������t�B�[���h����
%     �܂ޕ�����ł��BRANGE �́A�T�u�Z�b�g�������̈���܂�2�v�f�̃x�N�g����
%     ���B���[�`�������������ꍇ�́AID2 �͐V�K�̗̈�܂��͋�Ԃ̎��ʎq�ŁA��
%     �s�����ꍇ��-1�ł��B
%
%   SWdupregion
%     ID2 = HDFSW('dupregion',ID)
%     �̈�܂��͋�Ԃ𕡐����܂��BID �͗̈�܂��͋�Ԃ̎��ʎq�ł��BID2 �́A�V
%     �K�̗̈�܂��͋�Ԃ̎��ʎq�ł��B���[�`�������s�����ꍇ�́AID2 ��-1
%     �ł��B
%
% �Q�l�F HDF, HDFPT, HDFGD.


%	Copyright 1984-2003 The MathWorks, Inc. 
