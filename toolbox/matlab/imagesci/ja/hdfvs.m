% HDFVS   HDF Vdata�C���^�t�F�[�X��VS�֐���MATLAB�Q�[�g�E�F�C
% 
% HDFVS�́AHDF Vdata�C���^�t�F�[�X����VS�֐��̃Q�[�g�E�F�C�ł��B���̊�
% �����g�����߂ɂ́AHDF version 4.1r3��User's Guide��Reference Manual��
% �܂܂�Ă���AVdata�C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ��
% ����B���̃h�L�������g�́ANational Center for Supercomputing 
% Applications (NCSA�A<http://hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFVS�̈�ʓI�ȃV���^�b�N�X�́AHDFVS(funcstr,param1,param2,...) �ł��B
% HDF���C�u��������V�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ�����
% ���B���Ƃ��΁AHDFVS('detach',vdata_id) �́AC���C�u�����R�[��
% VSdetach(vdata_id) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
%
% �A�N�Z�X�Ɋւ���֐�
% --------------------
% �A�N�Z�X�Ɋւ���֐��́Avdata��t����������A�A�N�Z�X���s���܂��B
% �f�[�^�̓]���́Avdata���A�N�Z�X���ꂽ��ł̂ݍs���܂��B�����̃��[�`���́A
% vdata������������A�f�[�^�]�����I�������Ƃ��ɃA�N�Z�X�𐳏�ɏI�����܂��B
%
%   vdata_id = hdfvs('attach',file_id,vdata_ref,access)
%   �w�肵��vdata�ւ̃A�N�Z�X���s���܂��Baccess �́A'r' �܂��� 'w' �ł��B
%
%   status = hdfvs('detach',vdata_id)
%   �w�肵��vdata�ւ̃A�N�Z�X���I�����܂��B
%
% �ǂݍ��݂Ə����o���Ɋւ���֐�
% ------------------------------
% �ǂݍ��݂Ə����o���Ɋւ���֐��́Avdata�̓��e�̓ǂݍ��݂Ə����o����
% �s���܂��B
%
%   status = hdfvs('fdefine',vdata_id,fieldname,data_type,order)
%   �V����vdata�̃t�B�[���h���`���܂��Bdata_type �́AHDF�̐��l�^�C�v��
%   �w�肷�镶����ł��B���̕����񂪗��p�ł��܂��B
% 
%     'uchar8'�A'uchar'�A'char8'�A'char'�A'double','uint8'�A'uint16'�A
%     'uint32'�A'float'�A'int8'�A'int16'�A'int32'
%
%   status = hdfvs('setclass',vdata_id,class)
%   vdata�ɃN���X�����蓖�Ă܂��B
%
%   status = hdfvs('setfields',vdata_id,fields)
%   �����o�����vdata�̃t�B�[���h���w�肵�܂��B
%
%   status = hdfvs('setinterlace',vdata_id,interlace)
%   vdata�ɑ΂��� interlace ���[�h��ݒ肵�܂��Binterlace �́A'full' �܂���
%   'no' �ł��B
% 
%   status = hdfvs('setname',vdata_id,name)
%   vdata�ɖ��O�����蓖�Ă܂��B
%
%   count = hdfvs('write', vdata_id, data)
%   vdata�ɏ����o���܂��Bdata �́Anfields�s1��̃Z���z��łȂ���΂Ȃ�
%   �܂���B�e�Z���́Adata �� order(i )�s n ��̃x�N�g�����܂܂Ȃ����
%   �Ȃ�܂���B�����ŁAorder(i)�́A�e�t�B�[���h�̃X�J���l�̌��ł��B
%   data �̃^�C�v�́Ahdfvs('setfields') �Őݒ肳���t�B�[���h�^�C�v�A
%   �܂��͊��ɑ��݂���vdata�̃t�B�[���h�Ɉ�v���Ȃ���΂Ȃ�܂���B
%
%   [data,count] = hdfvs('read',vdata_id,n)
%   vdata����ǂݍ��݂܂��B�f�[�^�́Anfields�s1��̃Z���z��ɏo�͂����
%   ���B�e�Z���́Adata �� order(i) �s n��̃x�N�g�����܂܂Ȃ���΂Ȃ�܂�
%   ��B�����ŁAorder�́A�e�t�B�[���h�̃X�J���l�̌��ł��B�t�B�[���h�́A
%   hdfvs('setfields',...) �Ŏw�肳�ꂽ���������ŏo�͂���܂��B
%
%   pos = hdfvs('seek',vdata_id,record)
%   vdata���̎w�肵�����R�[�h��{���܂��B
%
%   status = hdfvs('setattr',vdata_id,field_index,name,A)
%   vdata�̃t�B�[���h�܂���vdata�̑�����ݒ肵�܂��B
%
%   status = hdfvs('setexternalfile',vdata_id,filename,offset)
%   vdata�̏����A�O���t�@�C���Ɋi�[���܂��B
%
% �t�@�C���̏��Ɋւ���֐�
% --------------------------
% �t�@�C���̏��Ɋւ���֐��́Avdata���t�@�C�����ɕۑ�������@�Ɋւ���
% ����񋟂��܂��B�����́Avdata���t�@�C�����ɔz�u���邽�߂ɁA�֗���
% ���@�ł��B
%
%   vdata_ref = hdfvs('find',file_id,vdata_name)
%   �w�肵��HDF�t�@�C�����ŁA�^����ꂽvdata�����������܂��B
%
%   vdata_ref = hdfvs('findclass',file_id,vdata_class)
%   �w�肵��vdata�̃N���X�ɑΉ�����ŏ���vdata�̎Q�Ɣԍ����o�͂��܂��B
%
%   next_ref = hdfvs('getid',file_id,vdata_ref)
%   �t�@�C�����̂���vdata�̎��ʎq���o�͂��܂��B
%
%   [refs,count] = hdfvs('lone',file_id,maxsize)
%   vgroup�Ƀ����N����Ă��Ȃ�vdata�̎Q�Ɣԍ����o�͂��܂��B
%
% Vdata�̏��Ɋւ���֐�
% -----------------------
% Vdata�̏��Ɋւ���֐��́A�^����ꂽvdata�Ɋւ������񋟂��܂��B
% ����́Avdata�̖��O�A�N���X�A�t�B�[���h���A���R�[�h���A�^�O�ƎQ�Ɣԍ���
% �g���킹�Ainterlace���[�h�A�T�C�Y���܂݂܂��B
%
%   status = hdfvs('fexist',vdata_id,fields)
%   �w�肵��vdata���Ƀt�B�[���h�����݂��邩�ǂ������e�X�g���܂��B
%
%   [n,interlace,fields,nbytes,vdata_name,status] = ....
%                                   hdfvs('inquire',vdata_id)
%   �w�肵��vdata�Ɋւ�������o�͂��܂��B
%
%   count = hdfvs('elts',vdata_id)
%   �w�肵��vdata���̃��R�[�h�����o�͂��܂��B
%
%  [class_name,status] = hdfvs('getclass',vdata_id)
%   �w�肵��vdata���̃��R�[�h�����o�͂��܂��B
%
%   [field_names,count] = hdfvs('getfields',vdata_id)
%   �w�肵��vdata���̂��ׂẴt�B�[���h�����o�͂��܂��B
%
%   [interlace,status] = hdfvs('getinterlace',vdata_id)
%   �w�肵��vdata��interlace���[�h���擾���܂��B
%
%   [vdata_name,status] = hdfvs('getname',vdata_id)
%   �w�肵��vdata�����擾���܂��B
%
%   version = hdfvs('getversion',vdata_id)
%   vdata�̃o�[�W�����ԍ����o�͂��܂��B
%
%   nbytes = hdfvs('sizeof',vdata_id,fields)
%   �w�肵��vdata�̃t�B�[���h�T�C�Y���o�͂��܂��B
%
%   [fields,status] = hdfvs('Queryfields',vdata_id)
%   �w�肵��vdata�̃t�B�[���h�����o�͂��܂��B
% 
%   [name,status] = hdfvs('Queryname',vdata_id)
%   �w�肵��vdata�����o�͂��܂��B
%
%   ref = hdfvs('Queryref',vdata_id)
%   �w�肵��vdata�̎Q�Ɣԍ����擾���܂��B
%
%   tag = hdfvs('Querytag',vdata_id)
%   �w�肵��vdata�̃^�O���擾���܂��B
%
%   [count,status] = hdfvs('Querycount',vdata_id)
%   �w�肵��vdata���̃��R�[�h�����o�͂��܂��B
%
%   [interlace,status] = hdfvs('Queryinterlace',vdata_id)
%   �w�肵��vdata��interlace���[�h���o�͂��܂��B
%
%   vsize = hdfvs('Queryvsize',vdata_id)
%   �w�肵��vdata�̃��R�[�h�̃��[�J���T�C�Y���o�C�g�P�ʂŎ擾���܂��B
%   
%   [field_index,status] = hdfvs('findex',vdata_id,fieldname)
%   �^����ꂽ�t�B�[���h��������vdata�̃t�B�[���h�̃C���f�b�N�X���m�F����
%   ���B
%
%   status = hdfvs('setattr',vdata_id,field_index,name,A)
%   vdata�̃t�B�[���h�܂���vdata�̑�����ݒ肵�܂��Bfield_index �́A�C���f
%   �b�N�X�ԍ��܂��� 'vdata' �ł��B
%
%   count = hdfvs('nattrs',vdata_id)
%   �w�肵��vdata�Ƃ��̒��Ɋ܂܂��vdata�̃t�B�[���h�̑��������o�͂��܂��B
% 
%   count = hdfvs('fnattrs',vdata_id,field_index)
%   vdata�̑����̑������m�F���܂��B
%
%   attr_index = hdfvs('findattr',vdata_id,field_index,attr_name)
%   �^����ꂽ���������������̃C���f�b�N�X���擾���܂��B
%
%   tf = hdfvs('isattr',vdata_id)
%   �^����ꂽvdata���������ǂ������w�肵�܂��B
%
%   [name,data_type,count,nbytes,status] = .....
%                   hdfvs('attrinfo',vdata_id,field_index,attr_index)
%   �w�肵��vdata�̃t�B�[���h�܂���vdata�̎w�肵�������̖��O�A�f�[�^
%   �^�C�v�A�l�̌��A�l�̃T�C�Y���o�͂��܂��B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH.


%   Copyright 1984-2001 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:05 $
