function [mesh,data_v]=Uise2pde(grid_file,pref,data_file_v,load_data,out_file)


## [mesh,data]=ise2pde3(grid_file,pref,data_file,load_data,out_file)
## ise2pde3
## estrae dati dal formato DF-ISE di ISE a pdetool di Matlab
## grid_file contiene il nome del file di griglia da estrarre
## pref un prefisso che verra' dato ai files temporanei creati da grep
## data_file e' un cell array delle file da estrarre
## load_data e' un cell array che contiene i nomi delle grandezze da estrarre 
## out_file e' il nome del file matlab opzionale per salvare i dati estratti
##
## 17-3-2004 ver 3.1 
## Marco Bellini marco_bellini_1@yahoo.it
## 14.02.2007 ver 3.2
## Octave porting and bug fixes Carlo de Falco 

##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
##  CHANGES:
##   - riconosce i nomi dei contatti e delle regioni
##   - tratta anche dispositivi con una sola regione
##   - fornisce informazioni sulla conversione
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
##  TO DO LOG:
##
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



##esempio per debug
## prova a costruire una grid per pdetool
##data_file="/home/marco/IseDB/jfet/jsdd2_mdr.dat";
##grid_file="/home/marco/IseDB/jfet/jsdd2_mdr.grd";
##pref="/home/marco/IseDB/jfet/jsdd2";

## esempio per struttura onda viaggiante
## data_file={"/home/marco/IseDB/prova/spice/on1_onda1_tr_des.dat"};
## grid_file="/home/marco/IseDB/prova/spice/on_mdr.grd";
## pref="/home/marco/IseDB/prova/spice/on";
## load_data={"ElectrostaticPotential"};

## dati da estrarre
##load_data={"DopingConcentration","BoronActiveConcentration","PhosphorusActiveConcentration"};
##load_data={"ElectrostaticPotential","eDensity","hDensity","eCurrentDensity","BeamGeneration"};

##pdeplot(p1,e1,t1,"xydata",log10(abs(data(1,:)))',"zdata",log10(abs(data(1,:))));
##[p1,e1,t1]=ise2pde(grid_file,pref);

## leggo i vertici
## i punti sono ordinati per regione
## se la prima regione e' l'ossido ed ha 269 punti
## i primi 269 valori in p1 si riferiscono ai punti dell'ossido
## 
## nei file di des.cmd di simulazione i punti vengono dati per ogni regione
## quindi i punti della frontiera tra ossido e silicio vengono ripetuti due
## volte (tra l'ossido e tra il silicio): e' necessario prenderli una volta
## sola
## siccome con piu' di due materiali diversi il discorso e' piu' complicato
## si sceglie di considerare in questo programma solo un ossido ed il 
## silicio


## p1 conterra' le coordinate x e y dei vertici
[s,w]=unix(sprintf("grep Vertices %s",grid_file));
n_vert_str = regexp(w,'([0-9]+)',"Tokens");
n_vert=str2num(n_vert_str{1}{1});
unix(sprintf("grep Vertices -A %d %s | tail -n+2 > %s_vertex.txt",n_vert,grid_file,pref));
p1=load(strcat(pref,"_vertex.txt"));
unix(sprintf("rm %s_vertex.txt",pref));
p1(:,2)=-p1(:,2);


fprintf("Found %d vertex\n",n_vert);

##leggo gli edge
## el conterra' l'indice dei vertici degli edges degli elementi
## cioe' l'indice dei vertici dei lati dei triangoli e l'indice dei vertici
## dei segmenti
[s,w]=unix(sprintf("grep Edges %s",grid_file));
n_edges_str = regexp(w,'([0-9]+)',"Tokens");
n_edges=str2num(n_edges_str{1}{1});
unix(sprintf("grep Edges -A %d %s | tail -n+2  > %s_edges.txt",n_edges,grid_file,pref));
el=load(strcat(pref,"_edges.txt"));
unix(sprintf("rm %s_edges.txt",pref));
fprintf("Found %d edges\n",n_edges);
clear n_edges;
el=el+1;


##leggo gli elementi triangolari
## el_tr contiene gli indici degli edge dei triangoli
[s,w]=unix(sprintf("grep Elements %s",grid_file));
n_els_str = regexp(w,'([0-9]+)',"Tokens");
n_els=str2num(n_els_str{1}{1});
## leggo solo gli elementi che iniziano per 2 e che corrispondono ai
## triangoli, creando un file che contiene solo gli elementi triangolari
unix(sprintf("grep Elements -A %d %s | head -n %d  | tail -n %d | awk '$1==2 {print $2,$3,$4}'  > %s_elements2.txt",n_els,grid_file,n_els+1,n_els,pref));
el_tr=load(strcat(pref,"_elements2.txt"));
unix(sprintf("rm %s_elements2.txt",pref));
fprintf("Found %d triangular elements out of %d elements\n",length(el_tr),n_els);


## creo un file che contiene gli elementi "segmenti"
unix(sprintf("grep Elements -A %d %s | head -n %d  | tail -n %d | awk '$1==1 {print $2,$3}'  > %s_elements1.txt",n_els,grid_file,n_els+1,n_els,pref));
##el_lin=load(strcat(pref,"_elements1.txt"));
##unix(sprintf("rm %s_elements1.txt",pref));


## creo un indice che dice se l'elemento e' un triangolo o una linea 
## e lo salvo nel file pref_linee1.txt; ci sara' un 1 se l'elemento i-esimo
## e' una linea o un 2 se e' un triangolo
unix(sprintf("grep Elements -A %d %s | head -n %d  | tail -n %d  | awk ' {print $1} ' > %s_linee1.txt",n_els,grid_file,n_els+1,n_els,pref));
clear n_els;

## leggo le regions
## cosi posso distinguere tra silicio, contatti e ossido
## al max e' possibile leggere 60 regions
[s,w]=unix(sprintf("grep regions -n %s  | grep -v nb_regions | tr -d []=",grid_file));
w2=w(11:length(w));
n_regions=0;
l2=length(w2);cont=1;num=1;str="";begin=0;
while (cont<l2)
    c=w2(cont);
    cont=cont+1;
    if (c=="""")
        if begin==0
            begin=1;
            str="";
        else
            begin=0;
            regions{num}=str;
            num=num+1;  n_regions= n_regions+1;
        end; %begin
    end; ## "
    if ((c~="""") & (c~=" ") & (begin==1) )
        str=strcat(str,c);
    end; ## aggiungo carattere
end ## while

fprintf("Found %d regions/contacts:\n",n_regions);
for cont=1:n_regions
    fprintf("%d: %s\n",cont,char(regions(cont)));
end

## leggo le locations
## trova le righe tra cui Ãš compreso Locations
[s,w]=unix(sprintf("grep Locations -n %s  | awk '/Locations/ {print $1}'",grid_file));
loc_u=sscanf(w,"%d:Locations\n");
[s,w]=unix(sprintf("grep Elements -n %s  | awk '/Elements/ {print $1}'",grid_file));
tmp=sscanf(w,"%d:Elements\n");
loc_d=tmp(1);
## generazione file
unix(sprintf(" head -n %d %s | tail -n+%d | tr [:cntrl:] ' ' | tr -d }| tr ief 012 > %s_loc.txt",...
    loc_d-1,grid_file ,loc_u+1,pref) );
loc=load(sprintf("%s_loc.txt",pref));
## loc contiene
## 0 per gli elementi interni
## 1 per gli esterni
## 2 per la frontiera
unix(sprintf("rm %s_loc.txt",pref));
clear loc_u;clear loc_d;




##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##   CONVERSIONE DELLA GRIGLIA
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_ed=max(size(el));
n_el=max(size(el_tr));

##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## calcolo di E1
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

## trova gli elementi sul bordo (esterni)
## del dispositivo (quelli rossi)
ind=find(loc==1);
e1=el(ind,:);

##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## calcolo di T1
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

el_si=sign(el_tr)+1;
el_si=sign(el_si);
## el_si  contiene le posizioni degli elementi positivi
t1=zeros(n_el,4);

## elementi tutti positivi: vertice di testa
ind=find( el_si(:,:)==1);
t1(ind)=el(el_tr(ind)+1,1);

## elementi negativi: vertice di coda
ind=find( el_si(:,:)==0);
t1(ind)=el(-el_tr(ind),2);

## inserisco il numero di subdominio

## trovo il delimitatore inferiore di una regione
[s,w]=unix(sprintf("grep material -n %s | grep -v materials  | awk '/material/ {print $1 }'",grid_file));
mat_pos=sscanf(w,"%d:\n");
[s,w]=unix(sprintf("grep material -n %s | grep -v materials  | awk '/material/ {print $2 }' |tr -d =",grid_file));
mat_type_lim=findstr(w,"\n");
if isempty(mat_type_lim)
  mat_type=w;
else
  for ii=1:length(mat_type_lim)-1
    mat_type{ii}=w(mat_type_lim(ii)+1:mat_type_lim(ii+1)-1);
  end
  mat_type{ii+1}=w(mat_type_lim(ii)+1:end);
end

[s,w]=unix(sprintf("grep material -n %s | grep -v materials  | awk '/material/ {print $4 }' |tr -d =",grid_file));
mat_name_lim=findstr(w,"\n");
if isempty(mat_name_lim)
  mat_name=w;
else
  for ii=1:length(mat_name_lim)-1
    mat_name{ii}=w(mat_name_lim(ii)+1:mat_name_lim(ii+1)-1);
  end
  mat_name{ii+1}=w(mat_name_lim(ii)+1:end);
end


## leggo il tipo di elemento
## se e' un materiale i triangoli appartenenti a quel materiale otterranno
## indice pari all'indice della regione. t1(4,:)' perche' non ho ancora
## trasposto

## se e' un contatto, i segmenti appartenenti a quel contatto saranno
## indicati con un numero in e(5,:)' (non trasposto)

el_type=load(strcat(pref,"_linee1.txt"));
indice_tr=zeros(size(el_type));
## indice_tr e' 1 nelle posizioni che corrispondono agli elementi triangolari nella lista
## totale degli elementi nel file *.grd
indice_tr(find(el_type==2))=1;
## ora faccio la somma cumulativa in modo che nella posizione i-esima del
## vettore degli elementi totali ci sia l'indice che identifica il triangolo
## i-esimo in el_tr : ho costruito una tabella di conversione dall'indice di
## ISE unico per triangoli e segmenti -> indice dei soli triangoli.
indice_tr=cumsum(indice_tr);
clear ind;

## leggo gli elementi "segmento"
try
el_lin=load(strcat(pref,"_elements1.txt"));
catch
el_lin=-1;
end_try_catch

## aggiungo 1 perche' gli elementi partono da 0
el_lin=el_lin+1;
unix(sprintf("rm %s_elements1.txt",pref));
## costruisco una mappa di conversione anche per gli elementi lineari (indicati da 1 in el_tr).
indice_lin=zeros(size(el_type));
indice_lin(find(el_type==1))=1;
indice_lin=cumsum(indice_lin);
##
## creo un vettore che indica il tipo di elemento di frontiera
## 1 per i lati del dispositivo (elementi esterni)
## 2 per l'interfaccia ossido-silicio
## da 3 in poi per i contatti

e_fron=ones(max(size(e1)),1);

## AGGIUNGO LA FRONTIERA
##
clear ind1;
ind1=find(loc==2);
name_contact{1}="External";
name_contact{2}="I. Frontier";

if (isempty(ind1)==0)
## aggiungo gli elementi di frontiera trovati al vettore degli edges e1
## mettendo indice 2
    e1=[e1;el(ind1,:)];
    e_fron=[e_fron;2*ones(length(ind1),1)];
end

clear el_type

## numero del contatto
n_contact=3;
## name_material contiene il nome del materiale i-esimo
## name_contact contiene il nome del contatto i-esimo


for n=1:n_regions
    
    if strcmp(mat_type{n},"Contact")==0
        
## leggo gli elementi che costituiscono una regione
        if (n~=n_regions)        
            unix(sprintf(" head -n %d %s | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", mat_pos(n+1)-2,grid_file,mat_pos(n)+2,pref));
        else
## trattare l'ultima regione che e' diversa
            unix(sprintf(" tail -n+%d %s |  tr -d [:cntrl:]}  > %s_tmp2.txt",mat_pos(n)+2, grid_file,pref) );
        end ## e' l'ultima regione?
        tmp_el=load(strcat(pref,"_tmp2.txt"));
        tmp_el=tmp_el+1;
## trova i triangoli che fanno parte della regione n
        t1(indice_tr(tmp_el),4)=n;
        name_material{n}=mat_name{n};        
    else
## la regione e' un contatto
        
        if (n~=n_regions)        
            unix(sprintf(" head -n %d %s | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", mat_pos(n+1)-2,grid_file,mat_pos(n)+2,pref));
        else
## trattare l'ultima regione che e' diversa
            unix(sprintf(" tail -n+%d %s |  tr -d [:cntrl:]}  > %s_tmp2.txt", mat_pos(n)+2,grid_file,pref) );
        end ## e' l'ultima regione?
        tmp_el=load(strcat(pref,"_tmp2.txt"));
## tmp_el contiene gli indici dei vertici che appartengono al
## contatto: aggiungo 1 perche' ise parte da 0.
        tmp_el=tmp_el+1;
        
## predo i vertici la cui posizione e' in tmp_el e la converto da
## dessis a pde
        e1=[e1;el_lin(indice_lin(tmp_el),:)];
        
## aggiungo il numero del contatto
        tmp_el=tmp_el';
        e_fron=[e_fron;n_contact*ones(size(tmp_el))];
        
        name_contact{n_contact}=regions(n);        
        n_contact=n_contact+1;
        
        
    end ## non e' un contatto
end ## fine scansione regioni

unix(sprintf("rm %s_linee1.txt",pref));


## trasposizione
t1=t1';
e1=e1';
p1=p1';



## individuo a che regione appartengono dei vertici
## fondamentale per leggere i set di dati prodotti dalle simulazioni

tmpt1=[t1(1,:),t1(2,:),t1(3,:);t1(4,:),t1(4,:),t1(4,:)];
stmpt1=sortrows(tmpt1',1)';
dtmpt1=diff(stmpt1(1,:));
##clear stmpt1;
ind1=find(dtmpt1==1);
##%%% questa prende i valori dei vertici in ordine solo per TEST 
##%%% reg_vert=[stmpt1(1,ind1),stmpt1(1,length(dtmpt1)+1)];

## reg_vert contiene la regione a cui il punto appartiene
reg_vert=[stmpt1(2,ind1),stmpt1(2,length(dtmpt1)+1)];
clear tmpt1 stmpt1 dtmpt1 ind1;


## individuo i vertici appartenenti alla frontiera
##  le righe precedenti hanno assegnato questi punti
##  a una o all'altra regione. Nei file delle simulazioni questi
##  punti sono assegnati casualmente ad una delle regioni secondo
##  un criterio arbitrario. E' necessario individuare i punti alla
##  frontiera per tenerne conto.

## costruisco e1 completo
e1=[e1;zeros(size(e1))];
e1=[e1;e_fron'];

## trovo i punti di frontiera
ind1=find(loc==2);
## nel caso la frontiera non esista non fa niente



if (isempty(ind1)~=1)
## controlla se c'e' una frontiera tra diversi elementi
    
    el=el';
    tmpe1=[el(1,ind1),el(2,ind1)];
    stmpe1=sortrows(tmpe1',1)';
    dtmpe1=diff(stmpe1(1,:));
    clear ind1;
## non e' detto che i vertici di frontiera siano ad incrementi unitari
    ind1=find(dtmpe1>0);
    
## in teoria dovrei controllare che non ci sia un solo elemento di 
## frontiera
##    if (length(ind1)>1)
    front_vert=[stmpe1(1,ind1),stmpe1(1,length(dtmpe1)+1)];
##   else
## c'e' solo 1 punto di frontiera
##front_vert=[stmpe1(1,ind1)];
##end
    
    
    
## inserisco anche nel reg_vert l'informazione se un punto e' di frontiera
## in questo modo il valore assoluto indica la regione alla quale e' 
## attribuito il valore.
## i punti con valore negativo sono punti di frontiera
    
    reg_vert(front_vert)=-reg_vert(front_vert);
    
    clear tmpe1 stmpe1 dtmpe1 ind1;
end % esiste la frontiera

## % % test
##   ind1=find(reg_vert==2);
##   plot(p1(1,ind1),p1(2,ind1),'b.')
##   whos ind1
##   hold on;
##   ind1=find(reg_vert==1);
##   whos ind1
##   plot(p1(1,ind1),p1(2,ind1),'g.')
##   plot(p1(1,front_vert),p1(2,front_vert),'ro')
##   whos front_vert



## es. testato: ok
## ind=find(reg_vert==2);
## plot(p1(1,:),p1(2,:),'b.')
## hold on;
## plot(p1(1,ind1),p1(2,ind1),'g.')


##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##         DATASETS             %
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (exist("data_file_v")~=0)
## guardo quanti file devo leggere
    n_data_file=max(size(data_file_v));
    
    
    for nf=1:n_data_file
        
        data_file=char(data_file_v(nf));
        
## leggo i nomi dei datasets
        [s,w]=unix(sprintf("grep datasets %s",data_file));
        w2=w(18:length(w)-1);
        
        ndatasets=0;
        datasets=cell(30,1);
        l2=length(w2);cont=1;num=1;str="";begin=0;
        while (cont<l2)
            c=w2(cont);
            cont=cont+1;
            if (c=="""")
                if begin==0
                    begin=1;
                    str="";
                else
                    begin=0;
## controllo che non ci siano due regioni in cui e'
## presente lo stesso dato
##%  if (num==1) || (strcmp(str,datasets(num-1))==0)
##% tolgo cosi' ho le label con la molteplicita' giusta
                    datasets(num)={str};
                    num=num+1;  ndatasets= ndatasets+1;
##%  end % non e' lo stesso dataset
                end; %begin
            end; ## "
            if ((c~="""") & (c~=" ") & (begin==1) )
                str=strcat(str,c);
            end; ## aggiungo carattere
        end ## while
        
        
## estrae i valori di tutte le variabili in un unico file
        unix(sprintf("grep Values  -A %d %s > %s_tmp.txt",n_vert,data_file,pref));
        
## estrae le righe che delimitano i dati da estrarre 
        
## del contiene le righe sotto le quali si trovano i valori sui vertici
## dei triangoli (Values)
        [s,w]=unix(sprintf("grep Values -n %s_tmp.txt  | awk '/Values/{print $1}' | tr -d : > %s_del.txt",pref,pref));
        del=load(sprintf("%s_del.txt",pref));
        unix(sprintf("rm %s_del.txt",pref));
        
## uel contiene le righe sopra le quali si trovano i valori sui vertici
## dei triangoli (})
        [s,w]=unix(sprintf("grep } -n %s_tmp.txt  | awk '/}/ {print $1}' | tr -d :  > %s_del.txt",pref,pref));
        uel=load(sprintf("%s_del.txt",pref));
        unix(sprintf("rm %s_del.txt",pref));
        
## nval contiene il numero valori sui vertici contenuto in questa
## sezione del file
        [s,w]=unix(sprintf("grep Values %s_tmp.txt |  tr -d  [:alpha:]{\\(\\) > %s_nval.txt",pref,pref));
        nval=load(sprintf("%s_nval.txt",pref));
        unix(sprintf("rm %s_nval.txt",pref));
        
        nload=max(size(load_data));
        data=zeros(nload,n_vert);
        
##calcolo gli elementi ripetuti alla frontiera
        n_rip=sum(loc==2)+1;
        
        nl=1;nd=1;
        while(nl<=nload)
            while(nd<=ndatasets)
                if strcmp(load_data(nl),datasets(nd))==1
                    
## controllo se il numero dati sui vertici e' < del
## numero totale dei vertici: accade quando c'e' dell'
## ossido
                    
                    if (nval(nd)<n_vert)
## caso in presenza di ossido
                        
## ho trovato il set
## controllo se e' un caso particolare (ho un set di dati per l'ossido e uno per il silicio)
                        if strcmp(load_data(nl),"ElectrostaticPotential")==1 | ...
                                strcmp(load_data(nl),"ElectricField")==1  ...
                                | strcmp(load_data(nl),"LatticeTemperature")==1
                            
                            
## leggo la prima regione 
                            dup=del(nd)+1;
                            c=1; ## trova il delimitatore successivo 
                            while uel(c)<=dup
                                c=c+1;
                            end;
                            ddo=uel(c);
                            [s,w]=unix(sprintf(" head -n %d %s_tmp.txt | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", ddo, pref,dup,pref));
                            tmp=load(strcat(pref,"_tmp2.txt")); ## tmp2 e' il vettore riga dei dati cercati
## inserisco i primi elementi: ossido, cioe'
## regione 2: gli elementi nel file .dat (var: tmp) sono
## ossido interno + frontiera. 
## ind1 e' appunto dato da ossido + frontiera
                            
                            ind1=find(abs(reg_vert)==2 | reg_vert<0);
                            
                            data(nl,ind1)=tmp;
                            
## leggo la seconda regione
                            nd=nd+1;
                            dup=del(nd)+1;
                            c=1; ## trova il delimitatore successivo 
                            while uel(c)<=dup
                                c=c+1;
                            end;
                            ddo=uel(c);
                            [s,w]=unix(sprintf(" head -n %d %s_tmp.txt | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", ddo, pref,dup,pref));
                            tmp=load(strcat(pref,"_tmp2.txt")); ## tmp2 e' il vettore riga dei dati cercati
## inserisco i secondi elementi
## silicio + frontiera
                            clear ind;
                            ind=find(abs(reg_vert)==1 | reg_vert<0 );
                            data(nl,ind)=tmp;
                            
                        else
## caso non particolare
## metto a zero i dati della regione mancante
                            ind1=find(abs(reg_vert)==2 | reg_vert<0);
                            data(nl,ind1)=0;
                            
## leggo la regione 
                            dup=del(nd)+1;
                            c=1; ## trova il delimitatore successivo 
                            while uel(c)<=dup
                                c=c+1;
                            end;
                            ddo=uel(c);
                            [s,w]=unix(sprintf(" head -n %d %s_tmp.txt | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", ddo, pref,dup,pref));
                            tmp=load(strcat(pref,"_tmp2.txt")); ## tmp2 il vettore riga dei dati cercati
                            
## inserisco i primi elementi
                            ind=find(abs(reg_vert)==1 | reg_vert<0 );
                            data(nl,ind)=tmp;
                            
##n_prev_region=length(tmp);
##data(nl,1:n_prev_region)=tmp;
                            
                        end ## trattamento casi particolari
                        
                    else
## il numero dei dati sui vertici e' = al numero
## dei vertici: uso lo stesso codice di ise2pde 
                        dup=del(nd)+1;
                        c=1; ## trova il delimitatore successivo 
                        while uel(c)<=dup
                            c=c+1;
                        end;
                        ddo=uel(c);
                        [s,w]=unix(sprintf(" head -n %d %s_tmp.txt | tail -n+%d |  tr -d [:cntrl:]}  > %s_tmp2.txt", ddo, pref,dup,pref));
                        data(nl,:)=load(strcat(pref,"_tmp2.txt")); ## tmp2 e' il vettore riga dei dati cercati
                    end ## numero dei vertici =
                end %if trovato il set
                nd=nd+1;   
            end %nd
            nd=1;
            nl=nl+1;
        end %nl
        
        clear nd nl;
        
        data_v(:,:,nf)=data(:,:);
    end ## fine lettura n-esimo data_file
    
end ## if c'e' un data_file
clear n_vert w2 l2 cont num str c;

mesh.p=p1;
mesh.e=e1;
mesh.t=t1;
mesh.materials=name_material;
mesh.contacts=name_contact;

for cont=1:length(name_material)
    fprintf("Extracted region %d : %s\n",cont,char(name_material{cont}));
end;
for cont=3:length(name_contact)
    fprintf("Extracted contact %d : %s\n",cont,char(name_contact{cont}));
end;


if exist("out_file")
    if (exist("data_file_v")~=0)
        save (out_file,"mesh","data");
        fprintf("mesh and data saved");
    else
        save (out_file,"mesh");
        fprintf("mesh saved");
    end;
end

unix(sprintf("rm %s_tmp.txt",pref));
unix(sprintf("rm %s_tmp2.txt",pref));

##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Cdf: Fix edge matrix and build output structure
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return
mesh.e(7,end)=0;
mesh = Umeshproperties(mesh);

alledges = [mesh.t([1,2,4],:),mesh.t([2,3,4],:),mesh.t([3,1,4],:)];


for iedge = 1:size(mesh.e,2)
    whatedgeL = find((mesh.e(1,iedge)==alledges(1,:)& mesh.e(2,iedge)==alledges(2,:)));
    whatedgeR = find((mesh.e(1,iedge)==alledges(2,:)& mesh.e(2,iedge)==alledges(1,:)));
    
    if (length(whatedgeL)==1)
        mesh.e(6,iedge)=alledges(3,whatedgeL);
    end
    
    if (length(whatedgeR)==1)
        mesh.e(7,iedge)=alledges(3,whatedgeR);
    end
    
end

maxedge  = max(mesh.e(5,:));
intedges = find((mesh.e(6,:)~=0)&((mesh.e(7,:)~=0)&((mesh.e(7,:)~=(mesh.e(6,:)) ) )));
mesh.e (5,intedges) = maxedge+1;
mesh.contacts{end+1} = "Interface";

return;