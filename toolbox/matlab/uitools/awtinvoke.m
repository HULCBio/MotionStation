function awtinvoke(obj, varargin)
%AWTINVOKE Invoke a Java method on the AWT event thread
%   This function is an internal helper function and will
%   likely change in a future release.
%
%   AWTINVOKE(OBJ,METHOD) asynchronously executes on the Java AWT
%   event dispatching thread the method named METHOD of Java object
%   OBJ. The method must not allow any arguments. Multiple calls to
%   AWTINVOKE execute on the AWT thread in the order that MATLAB
%   executed. To execute a static method pass in the fully qualified
%   class name as OBJ.
%
%   AWTINVOKE(OBJ,METHOD,ARG1,ARG2,...) executes the method named
%   METHOD for the Java object OBJ with arguments ARG1,etc.  Any
%   non-primitive agruments must be constructed before calling
%   AWTINVOKE. If the method is overloaded (meaning there is more than
%   one method with that name for the class) then the METHOD must be
%   either a Java Method object or a string of the form 'NAME(SIG)'
%   where SIG is the signature in JNI notation. To obtain the JNI
%   string from a signature convert the type of each input argument
%   according to the table:
%     boolean    Z
%     byte       B
%     char       C
%     short      S
%     int        I
%     long       J
%     float      F
%     double     D
%     class      Lclass;
%     type[]     [type
%   The class name must be fully qualified (eg. java.lang.String). 
%   See http://java.sun.com/j2se/1.4.2/docs/guide/jni/index.html
%
%   Example:
%     f = javax.swing.JFrame('Test');
%     awtinvoke(f,'setVisible(Z)',true);

%   Copyright 1984-2004 The MathWorks, Inc. 

%   AWTINVOKE(...,FUNC) asynchonously calls FUNC when the Java method
%   is finished. FUNC must be a function handle. The function is
%   executed once MATLAB executes a drawnow or returns to the command
%   prompt.
%
%   AWTINVOKE(...,FUNC,FARG1,FARG2,...) passes arguments FARG1, FARG2,
%   ... to FUNC.
%

if ischar(obj) && strcmp(obj,'java callback');
  % execute callback from Java
  data = varargin{1};
  feval(data{:});
else
  funcIndex = 0;
  args = varargin(2:end);
  for k=length(varargin):-1:1
    if isa(varargin{k},'function_handle')
      funcIndex = k;
      args = varargin(2:k-1);
      break;
    end
  end
  % put an event in the AWT queue to call specified Java method 
  if ischar(obj)
    jloader = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager;
    cls = loadClass(jloader,obj);
    obj = []; % is ignored by java.lang.reflect.Method.invoke
  elseif isjava(obj)
    cls = getClass(obj);
  else
    error(['First argument must be a Java object, ' ...
          'a fully qualified Java class name or a function handle.']);
  end
  methodname = varargin{1};
  if isa(methodname,'java.lang.reflect.Method')
    meth = methodname;
  elseif any(methodname == '(')
      
    % Traverse up the class hierarchy until a public class is found
    % (invoking a method on a protected/private class will error).
    [methodname, sig] = parseSig(methodname);
    while ~java.lang.reflect.Modifier.isPublic(getModifiers(cls))    
        cls = getSuperclass(cls);  
        if isempty(cls) 
            break;
        end
    end
    if ~isempty(cls)
        meth = getMethod(cls,methodname,sig);     
    else
        meth = [];
    end
    
  else
    meths = getMethods(cls);
    meth = [];
    for k=1:length(meths)
      if strcmp(getName(meths(k)),methodname)
        if ~isempty(meth)
          error(['Ambiguous method name ''' methodname '''.']);
        end
        meth = meths(k);
      end
    end
    if isempty(meth)
      error(['Method ''' methodname ''' not found.']);
    end
  end
  arglist = [];
  if nargin > 2
    arglist = parseArgs(args,getParameterTypes(meth));
  end
  com.mathworks.mwswing.MJUtilities.invokeLater(obj, meth, arglist);
  if funcIndex > 0
    % put an event in the AWT queue to call back into MATLAB
    persistent matlab;
    if isempty(matlab)
      matlab = com.mathworks.jmi.Matlab;
    end
    cls = getClass(matlab);
    clslist = javaArray('java.lang.Class',3);
    clslist(1) = java.lang.Class.forName('java.lang.String');
    clslist(2) = java.lang.Class.forName('[Ljava.lang.Object;');
    clslist(3) = java.lang.Integer.TYPE;
    clslist(4) = com.mathworks.jmi.ClassLoaderManager.findClass('com.mathworks.jmi.CompletionObserver');
    method = getMethod(cls,'fevalConsoleOutput',clslist);
    fargs = javaArray('java.lang.Object',2);
    fargs(1) = java.lang.String('java callback');
    % make an MLArrayRef using system_depdent(45,...) call so that we
    % don't translate MATLAB data to Java and back.
    fargs(2) = system_dependent(45,varargin(funcIndex:end));
    args = { java.lang.String('awtinvoke'), ...
             fargs, ...
             java.lang.Integer(0), ...
             [] };
    com.mathworks.mwswing.MJUtilities.invokeLater(matlab,method,args);
  end
end

function [methodname,clslist] = parseSig(sig)
ind = find(sig == '(');
methodname = sig(1:ind-1);
% Parse JNI-style signature and convert args to Java values
k=ind+1;
clslist1 = {};
while k <= length(sig)
  switch sig(k)
   case 'I'
    clslist1(end+1) = java.lang.Integer.TYPE;
    k = k+1;
   case 'J'
    clslist1(end+1) = java.lang.Long.TYPE;
    k = k+1;
   case 'Z'
    clslist1(end+1) = java.lang.Boolean.TYPE;
    k = k+1;
   case 'B'
    clslist1(end+1) = java.lang.Byte.TYPE;
    k = k+1;
   case 'C'
    clslist1(end+1) = java.lang.Character.TYPE;
    k = k+1;
   case 'S'
    clslist1(end+1) = java.lang.Short.TYPE;
    k = k+1;
   case 'F'
    clslist1(end+1) = java.lang.Float.TYPE;
    k = k+1;
   case 'D'
    clslist1(end+1) = java.lang.Double.TYPE;
    k = k+1;
   case 'L'
    n = k;
    while (n <= length(sig)) && (sig(n) ~= ';')
      n = n + 1;
    end
    if n > length(sig)
      error(['Illegal signature ''' sig '''.']);
    end
    clsstr = sig((k+1):n-1);
    clsstr(clsstr == '/') = '.';
    clslist1(end+1) = com.mathworks.jmi.ClassLoaderManager.findClass(clsstr);
    k = n+1;
   case '['
    n = k;
    while (n <= length(sig)) && (sig(n) == '[')
      n = n + 1;
    end
    if n > length(sig)
      error(['Illegal signature ''' sig '''.']);
    end
    if sig(n) == 'L'
      while (n <= length(sig)) && (sig(n) ~= ';')
        n = n + 1;
      end
      if n > length(sig)
        error(['Illegal signature ''' sig '''.']);
      end
    end
    clsstr = sig(k:n);
    clsstr(clsstr == '/') = '.';
    clslist1(end+1) = com.mathworks.jmi.ClassLoaderManager.findClass(clsstr);
    k = n+1;
   case ')'
    break;
  end
end

if isempty(clslist1)                                                       
    clslist = [];                                                                                                                          
else
   clslist = javaArray('java.lang.Class',length(clslist1));
   for k=1:length(clslist1)
      clslist(k) = clslist1{k};
   end
end

function arglist = parseArgs(args,clslist)
arglist = javaArray('java.lang.Object',length(clslist));
% store persistent vars in MATLAB workspace as a small performance enhancement
persistent inttype doubletype booltype longtype;
persistent bytetype chartype shorttype floattype;
if isempty(inttype)
  inttype = java.lang.Integer.TYPE;
  doubletype = java.lang.Double.TYPE;
  booltype = java.lang.Boolean.TYPE;
  longtype = java.lang.Long.TYPE;
  bytetype = java.lang.Byte.TYPE;
  chartype = java.lang.Character.TYPE;
  shorttype = java.lang.Short.TYPE;
  floattype = java.lang.Float.TYPE;
end
for n=1:length(clslist)
  if equals(clslist(n),inttype)
    arglist(n) = java.lang.Integer(args{n});
  elseif equals(clslist(n),doubletype)
    arglist(n) = java.lang.Double(args{n});
  elseif equals(clslist(n),booltype)
    arglist(n) = java.lang.Boolean(args{n});
  elseif equals(clslist(n),longtype)
    arglist(n) = java.lang.Long(args{n});
  elseif equals(clslist(n),bytetype)
    arglist(n) = java.lang.Byte(args{n});
  elseif equals(clslist(n),chartype)
    arglist(n) = java.lang.Character(args{n});
  elseif equals(clslist(n),shorttype)
    arglist(n) = java.lang.Short(args{n});
  elseif equals(clslist(n),floattype)
    arglist(n) = java.lang.Float(args{n});
  else
    arglist(n) = args{n};
  end
end

