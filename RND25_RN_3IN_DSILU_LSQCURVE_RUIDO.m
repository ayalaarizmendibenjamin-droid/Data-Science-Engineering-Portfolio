
%% Codigo lsqcurvefit Ruido
clear all
clc
%Extracción de datos
BDe=xlsread('LINuevo12.xlsx','B2:D897');
BDs=xlsread('LINuevo12.xlsx','F2:F897');
% ----------------------Normalización------------------------
N=[4 -4];
x1m=mean(BDe(:,1)); %media entrada 1
x2m=mean(BDe(:,2)); %media entrada 2
x3m=mean(BDe(:,3)); %media entrada 3
x4m=mean(BDs); %media salida
x1s=std(BDe(:,1)); %desviación estandar entrada 1
x2s=std(BDe(:,2)); %desviación estandar entrada 1
x3s=std(BDe(:,3)); %desviación estandar entrada 1
x4s=std(BDs); %desviacion estandar salida
% xdata=[minmaxnorm(BDe(:,1),N(1),N(2)),minmaxnorm(BDe(:,2),N(1),N(2)),...
%        minmaxnorm(BDe(:,3),N(1),N(2))];
xdata=[normT(BDe(:,1),x1m,x1s),normT(BDe(:,2),x2m,x2s),...
        normT(BDe(:,3),x3m,x3s)];
%target real   
yreal=BDs;
%numero de elementos del vector
tm=numel(yreal);
%target normalizado
% ydata =minmaxnorm(BDs,N(1),N(2));
ydata =normT(BDs,x4m,x4s);
% Creación de las bases de datos de test y validación
% Porcentaje de Entrenamiento (restante se toma para test y validación)
%Ent=70; %En porcentaje
% ndE=round((Ent/100)*tm); %Cantidad de datos para entrenamiento
% ndT=round((tm-ndE)/2);%Cantidad de datos test
% ndV=tm-(ndE+ndT); %Cantidad de datos validación
ndE=717; %Cantidad de datos para entrenamiento
ndT=89;%Cantidad de datos test
ndV=89; %Cantidad de datos validación
vdT=1:1:tm; %Vector de datos para muestreo 
% mt19937ar metodo generador Mersenne Twister
% mcg16807 Generador congruencial multiplicativo
% swb2712 Generador modificado de resta con préstamo
sem = RandStream('twister'); % generador de numeros pseudoaleatorios
inE = datasample(sem,vdT,ndE,'Replace',false); %indices aleatorios entrenamiento
ci=1; % Contador de los indices para validacion y test
ci2=1;
for ws=1:tm
    dis=find(inE==ws); %localiza si existe el dato en el vector
    pd=isempty(dis); %prueba si el valor es vacio (1) no (0)
    if pd==1 % condición para guardar
        inT0(ci)=ws; %almacena el dato de la interación
        ci=ci+1;
    end
end 

sem2 = RandStream('twister'); % generador de numeros pseudoaleatorios
inT = datasample(sem,inT0,ndV,'Replace',false); %indices aleatorios entrenamiento

for ws2=1:tm
    dis2=find(inT==ws2); %localiza si existe el dato en el vector
    pd2=isempty(dis2); %prueba si el valor es vacio (1) no (0)
    dis3=find(inE==ws2); %localiza si existe el dato en el vector
    pd3=isempty(dis3); %prueba si el valor es vacio (1) no (0)
    if (pd2==1) && (pd3==1)% condición para guardar
        inV(ci2)=ws2; %almacena el dato de la interación
        ci2=ci2+1;
    end
end 

inE1=sort(inE); %ordena los datos del indice entrenamiento
inT1=sort(inT); %ordena los datos del indice test
inV1=sort(inV); %ordena los datos del indice validación
for se=1:ndE %ciclo para guadar los datos de Entrenamiento
    xdatE(se,:)=[xdata(inE1(se),1),xdata(inE1(se),2),xdata(inE1(se),3)];
    ydatE(se,1)= ydata(inE1(se)); %salida Entrenamiento normalizada
    yrdatE(se,1)=yreal(inE1(se)); %salida Entrenamiento real
end
for st=1:ndT %ciclo para guadar los datos de test
    xdatT(st,:)=[xdata(inT1(st),1),xdata(inT1(st),2),xdata(inT1(st),3)];
    ydatT(st,1)= ydata(inT1(st)); %salida Test normalizada
    yrdatT(st,1)= yreal(inT1(st)); %salida Test real
end
for sv=1:ndV %ciclo para guadar los datos de validación
    xdatV(sv,:)=[xdata(inV1(sv),1),xdata(inV1(sv),2),xdata(inV1(sv),3)];
    ydatV(sv,1)= ydata(inV1(sv)); %salida Test normalizada
    yrdatV(sv,1)= yreal(inV1(sv)); %salida Test real
end


%Borramos variables de extracción
clear BDe BDs

%Ciclo para cambiar a guardar
for j=7:15
    
         if j==1
 
%Crear carpeta para guardar
             nomap=strcat('\N1_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Entrenamiento
fun = @(x,xdatE) (((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+x(6)); %N1
 
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(6,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(6,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(6,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Entrenamiento
R0=(((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+x2(6)); %N1


% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target Entrenamiento
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Entrenamiento
if r>=0.97 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 %--------------Test--------------------   
 RT=(((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+x2(6)); %N1

%R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en Test
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en test
MaxRT=max(valrt); %Valor maximo de r en test

if rt>=0.80 && rt<0.999999
%Guardar grafico de figura postreg test
nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
saveas(gcf,nomgraf2);
end

 %---------------------Validación-------------
RV=(((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+x2(6)); %N1

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en validación
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación

if rv>=0.80 && rv<0.999999
%Guardar grafico de figura postreg validación
nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
saveas(gcf,nomgraf3);
end

% Salvado de valores si cumple con el criterio de test y validacion 
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)

       if r>=0.97 && r<0.999999
        B1=x2(4);
        B2=x2(6);    
        IW=[x2(1) x2(2) x2(3)];
        LW=x2(5);
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end


 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');  
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==2
 
%Crear carpeta para guardar
             nomap=strcat('\N2_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10)))+x(11)); %N2 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(11,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(11,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(11,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10)))+x2(11)); %N2  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Test
if r>=0.97 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Validación (se cambia a los valores de validación con los pesos obtenidos en el Test

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10)))+x2(11)); %N2  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
if rt>=0.80 && rt<0.999999
%Guardar grafico de figura postreg
nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
saveas(gcf,nomgraf2);
end

 RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10)))+x2(11)); %N2  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
if rv>=0.80 && rv<0.999999
%Guardar grafico de figura postreg
nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
saveas(gcf,nomgraf3);
end

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)

       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9)];
        B2=x2(11);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8)];
        LW=[x2(5) x2(10)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');  
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');   
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==3
 
%Crear carpeta para guardar
             nomap=strcat('\N3_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15)))+x(16)); %N3 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(16,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(16,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(16,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15)))+x2(16)); %N3  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2  
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15)))+x2(16)); %N3  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2   
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15)))+x2(16)); %N3  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14)];
        B2=x2(16);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13)];
        LW=[x2(5) x2(10) x2(15)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==4
 
%Crear carpeta para guardar
             nomap=strcat('\N4_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20)))+x(21)); %N4 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(21,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(21,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(21,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20)))+x2(21)); %N4  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3  
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20)))+x2(21)); %N4  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3   
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20)))+x2(21)); %N4  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19)];
        B2=x2(21);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18)];
        LW=[x2(5) x2(10) x2(15) x2(20)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==5
 
%Crear carpeta para guardar
             nomap=strcat('\N5_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25)))+x(26)); %N5 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(26,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(26,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(26,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4  
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25)))+x2(26)); %N5  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.90 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.90 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4   
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25)))+x2(26)); %N5  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);

% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4    
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25)))+x2(26)); %N5  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24)];
        B2=x2(26);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==6
 
%Crear carpeta para guardar
             nomap=strcat('\N6_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30)))+x(31)); %N6 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(31,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(31,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(31,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5    
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30)))+x2(31)); %N6  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5     
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30)))+x2(31)); %N6  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5     
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30)))+x2(31)); %N6  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29)];
        B2=x2(31);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
       if j==7
 
%Crear carpeta para guardar
             nomap=strcat('\N7_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35)))+x(36)); %N7 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(36,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(36,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(36,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35)))+x2(36)); %N7  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35)))+x2(36)); %N7  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35)))+x2(36)); %N7  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34)];
        B2=x2(36);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');        
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==8
 
%Crear carpeta para guardar
             nomap=strcat('\N8_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40)))+x(41)); %N8 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(41,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(41,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(41,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40)))+x2(41)); %N8  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40)))+x2(41)); %N8  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40)))+x2(41)); %N8  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39)];
        B2=x2(41);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==9
 
%Crear carpeta para guardar
             nomap=strcat('\N9_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45)))+x(46)); %N9 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(46,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(46,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(46,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45)))+x2(46)); %N9  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45)))+x2(46)); %N9  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45)))+x2(46)); %N9  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44)];
        B2=x2(46);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');        
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==10
 
%Crear carpeta para guardar
             nomap=strcat('\N10_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50)))+x(51)); %N10 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(51,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(51,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(51,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50)))+x2(51)); %N10  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.83 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.83 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50)))+x2(51)); %N10  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50)))+x2(51)); %N10  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49)];
        B2=x2(51);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==11
 
%Crear carpeta para guardar
             nomap=strcat('\N11_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55)))+x(56)); %N11 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(56,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(56,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(56,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55)))+x2(56)); %N11  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55)))+x2(56)); %N11  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55)))+x2(56)); %N11  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54)];
        B2=x2(56);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
       if j==12
 
%Crear carpeta para guardar
             nomap=strcat('\N12_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60)))+x(61)); %N12 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(61,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(61,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(61,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60)))+x2(61)); %N12  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60)))+x2(61)); %N12  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60)))+x2(61)); %N12  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59)];
        B2=x2(61);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');         
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
       if j==13
 
%Crear carpeta para guardar
             nomap=strcat('\N13_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65)))+x(66)); %N13 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(66,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(66,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(66,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65)))+x2(66)); %N13  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65)))+x2(66)); %N13  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65)))+x2(66)); %N13  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64)];
        B2=x2(66);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');         
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
       if j==14
 
%Crear carpeta para guardar
             nomap=strcat('\N14_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70)))+x(71)); %N14 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(71,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(71,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(71,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70)))+x2(71)); %N14  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.97 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.97 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70)))+x2(71)); %N14  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70)))+x2(71)); %N14  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.97 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69)];
        B2=x2(71);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==15
 
%Crear carpeta para guardar
             nomap=strcat('\3INHaru-3oct_N15_softplus_norm_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75)))+x(76)); %N15 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(76,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(76,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(76,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75)))+x2(76)); %N15  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x4m,x4s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<1.1
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<1.1
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75)))+x2(76)); %N15  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<1.1
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75)))+x2(76)); %N15  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x4m,x4s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<1.1
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<1.1) && (rv>=0.80 && rv<1.1)
       if r>=0.99 && r<1.1
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74)];
        B2=x2(76);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==16
 
%Crear carpeta para guardar
             nomap=strcat('\N16_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80)))+x(81)); %N16 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(81,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(81,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(81,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80)))+x2(81)); %N16  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80)))+x2(81)); %N16  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80)))+x2(81)); %N16  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79)];
        B2=x2(81);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');         
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==17
 
%Crear carpeta para guardar
             nomap=strcat('\N17_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85)))+x(86)); %N17 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(86,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(86,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(86,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85)))+x2(86)); %N17  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85)))+x2(86)); %N17  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85)))+x2(86)); %N17  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84)];
        B2=x2(86);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==18
 
%Crear carpeta para guardar
             nomap=strcat('\N18_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90)))+x(91)); %N18 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(91,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(91,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(91,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90)))+x2(91)); %N18  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90)))+x2(91)); %N18  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90)))+x2(91)); %N18  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89)];
        B2=x2(91);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==19
 
%Crear carpeta para guardar
             nomap=strcat('\N19_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95)))+x(96)); %N19 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(96,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(96,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=1000;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(96,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95)))+x2(96)); %N19  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95)))+x2(96)); %N19  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95)))+x2(96)); %N19  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94)];
        B2=x2(96);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');          
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 

        if j==20
 
%Crear carpeta para guardar
             nomap=strcat('\N20_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100)))+x(101)); %N20 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(101,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(101,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=1000;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(101,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100)))+x2(101)); %N20  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100)))+x2(101)); %N20  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100)))+x2(101)); %N20  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99)];
        B2=x2(101);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');        
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==21

%Crear carpeta para guardar
             nomap=strcat('\N21_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((softplus((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105)))+x(106)); %N21 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(106,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(106,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=1000;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(106,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105)))+x2(106)); %N21  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105)))+x2(106)); %N21  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105)))+x2(106)); %N21  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99);... 
           x2(104)];
        B2=x2(106);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98);...
            x2(101) x2(102) x2(103)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)...
            x2(105)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
    if j==22

%Crear carpeta para guardar
             nomap=strcat('\N22_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((softplus((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((softplus((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110)))+x(111)); %N22 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(111,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(111,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(111,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)))+x2(111)); %N22  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)))+x2(111)); %N22  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)))+x2(111)); %N22  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99);... 
           x2(104);x2(109)];
        B2=x2(111);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98);...
            x2(101) x2(102) x2(103); x2(106) x2(107) x2(108)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)...
            x2(105) x2(110)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');        
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==23

%Crear carpeta para guardar
             nomap=strcat('\N23_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((softplus((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((softplus((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((softplus((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
                  +x(114)))*x(115)))+x(116)); %N23 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(116,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(116,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=1000;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(116,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
    +x2(114)))*x2(115)))+x2(116))); %N23  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
    +x2(114)))*x2(115)))+x2(116))); %N23  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
    +x2(114)))*x2(115)))+x2(116))); %N23  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99);... 
           x2(104);x2(109);x2(114)];
        B2=x2(116);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98);...
            x2(101) x2(102) x2(103); x2(106) x2(107) x2(108);...
            x2(111) x2(112) x2(113)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)...
            x2(105) x2(110) x2(115)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end

end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==24

%Crear carpeta para guardar
             nomap=strcat('\N24_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((softplus((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((softplus((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((softplus((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
                  +x(114)))*x(115))+... %N23
                 ((softplus((x(116).*xdatE(:,1))+(x(117).*xdatE(:,2))+(x(118).*xdatE(:,3))...
                  +x(119)))*x(120)))+x(121)); %N24 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(121,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(121,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=1000;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(121,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatE(:,1))+(x2(117).*xdatE(:,2))+(x2(118).*xdatE(:,3))...
    +x2(119)))*x2(120)))+x2(121))); %N24  %peso purelin


R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatT(:,1))+(x2(117).*xdatT(:,2))+(x2(118).*xdatT(:,3))...
    +x2(119)))*x2(120)))+x2(121))); %N24  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatV(:,1))+(x2(117).*xdatV(:,2))+(x2(118).*xdatV(:,3))...
    +x2(119)))*x2(120)))+x2(121))); %N24  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)
       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99);... 
           x2(104);x2(109);x2(114);x2(119)];
        B2=x2(121);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98);...
            x2(101) x2(102) x2(103); x2(106) x2(107) x2(108);...
            x2(111) x2(112) x2(113); x2(116) x2(117) x2(118)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)...
            x2(105) x2(110) x2(115) x2(120)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');       
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==25

%Crear carpeta para guardar
             nomap=strcat('\N25_softplus_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((softplus((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((softplus((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((softplus((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((softplus((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((softplus((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((softplus((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((softplus((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((softplus((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((softplus((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((softplus((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((softplus((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((softplus((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((softplus((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((softplus((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((softplus((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((softplus((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((softplus((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((softplus((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((softplus((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((softplus((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((softplus((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((softplus((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((softplus((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
                  +x(114)))*x(115))+... %N23
                 ((softplus((x(116).*xdatE(:,1))+(x(117).*xdatE(:,2))+(x(118).*xdatE(:,3))...
                  +x(119)))*x(120))+... %N24
                 ((softplus((x(121).*xdatE(:,1))+(x(122).*xdatE(:,2))+(x(123).*xdatE(:,3))...
                  +x(124)))*x(125)))+x(126)); %N25 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(126,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(126,1);
% Vector comparativo del peso en otro estado
% ver2=zeros(12,1);
% Variable que inicia el conteo de iteraciones
Num=1;
% Condición de paro 
C=0;
%Numero maximo de iteraciones
NmaxIt=100;
%Ciclo continuo para la busqueda de las variables
while C==0
% Valores aleatorios iniciales dentro del ciclo para obtener cambio   
% generar números aleatorios N en el inEervalo (a,b) con la fórmula:
% r = a + (b-a).*rand(N,1)
x0=2*rand(126,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((softplus((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatE(:,1))+(x2(117).*xdatE(:,2))+(x2(118).*xdatE(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((softplus((x2(121).*xdatE(:,1))+(x2(122).*xdatE(:,2))+(x2(123).*xdatE(:,3))...
    +x2(124)))*x2(125)))+x2(126))); %N25  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Test
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end
%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((softplus((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatT(:,1))+(x2(117).*xdatT(:,2))+(x2(118).*xdatT(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((softplus((x2(121).*xdatT(:,1))+(x2(122).*xdatT(:,2))+(x2(123).*xdatT(:,3))...
    +x2(124)))*x2(125)))+x2(126))); %N25  %peso purelin

R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.80 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((softplus((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((softplus((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((softplus((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((softplus((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((softplus((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((softplus((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((softplus((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((softplus((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((softplus((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((softplus((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((softplus((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((softplus((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((softplus((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((softplus((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((softplus((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((softplus((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((softplus((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((softplus((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((softplus((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((softplus((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((softplus((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((softplus((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((softplus((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((softplus((x2(116).*xdatV(:,1))+(x2(117).*xdatV(:,2))+(x2(118).*xdatV(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((softplus((x2(121).*xdatV(:,1))+(x2(122).*xdatV(:,2))+(x2(123).*xdatV(:,3))...
    +x2(124)))*x2(125)))+x2(126))); %N25  %peso purelin


R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.80 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.80 && rt<0.999999) && (rv>=0.80 && rv<0.999999)

       if r>=0.99 && r<0.999999
        B1=[x2(4);x2(9);x2(14);x2(19);x2(24);...
           x2(29);x2(34);x2(39);x2(44);x2(49);... 
           x2(54);x2(59);x2(64);x2(69);x2(74);... 
           x2(79);x2(84);x2(89);x2(94);x2(99);... 
           x2(104);x2(109);x2(114);x2(119);x2(124)];
        B2=x2(126);    
        IW=[x2(1) x2(2) x2(3); x2(6) x2(7) x2(8);...
            x2(11) x2(12) x2(13); x2(16) x2(17) x2(18);... 
            x2(21) x2(22) x2(23); x2(26) x2(27) x2(28);...
            x2(31) x2(32) x2(33); x2(36) x2(37) x2(38);...
            x2(41) x2(42) x2(43); x2(46) x2(47) x2(48);...
            x2(51) x2(52) x2(53); x2(56) x2(57) x2(58);...
            x2(61) x2(62) x2(63); x2(66) x2(67) x2(68);...
            x2(71) x2(72) x2(73); x2(76) x2(77) x2(78);...
            x2(81) x2(82) x2(83); x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93); x2(96) x2(97) x2(98);...
            x2(101) x2(102) x2(103); x2(106) x2(107) x2(108);...
            x2(111) x2(112) x2(113); x2(116) x2(117) x2(118);...
            x2(121) x2(122) x2(123)];
        LW=[x2(5) x2(10) x2(15) x2(20) x2(25)...
            x2(30) x2(35) x2(40) x2(45) x2(50)...
            x2(55) x2(60) x2(65) x2(70) x2(75)...
            x2(80) x2(85) x2(90) x2(95) x2(100)...
            x2(105) x2(110) x2(115) x2(120) x2(125)];
        save([nn '\IW' num2str(r) '.txt'],'IW','-ascii');
        save([nn '\LW' num2str(r) '.txt'],'LW','-ascii');
        save([nn '\B1' num2str(r) '.txt'],'B1','-ascii');
        save([nn '\B2' num2str(r) '.txt'],'B2','-ascii'); 
        save([nn '\Y2' num2str(r) '.txt'],'ver','-ascii'); %salida desnormalizada
       end
end
end

 % Condición para detener por número de iteraciones
    if  Num == NmaxIt
        C=1;
   save([nn '\RmaxE' num2str(MaxRE) '.txt'],'MaxRE','-ascii');      
%    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
%    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii'); 
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
end
