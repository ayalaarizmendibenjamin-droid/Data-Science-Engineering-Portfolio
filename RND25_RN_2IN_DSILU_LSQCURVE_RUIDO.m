%% Codigo lsqcurvefit Ruido
clear all
clc
%Extracción de datos
BDe=xlsread('LINuevo12.xlsx','C2:D897');
BDs=xlsread('LINuevo12.xlsx','F2:F897');
% Normalización
%N=[4 -4];
 x1m=mean(BDe(:,1)); %media de la entrada 1
 x2m=mean(BDe(:,2)); %media de la entrada 2
 x3m=mean(BDs);      %media de la salida
 x1s=std(BDe(:,1));  %desviaci�n estandar de la entrada 1
 x2s=std(BDe(:,2));  %desviaci�n estandar de la entrada 
 x3s=std(BDs);       %desviaci�n estandar de la salida
%xdata=[minmaxnorm(BDe(:,1),N(1),N(2)),minmaxnorm(BDe(:,2),N(1),N(2))];
 xdata=[normT(BDe(:,1),x1m,x1s),normT(BDe(:,2),x2m,x2s)];
       
%target real   
yreal=BDs;
%numero de elementos del vector
tm=numel(yreal);
%target normalizado
%ydata =minmaxnorm(BDs,N(1),N(2));
 ydata =normT(BDs,x3m,x3s);
% Creación de las bases de datos de test y validación
% Porcentaje de Entrenamiento (restante se toma para test y validación)
% Ent=80; %En porcentaje
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
inE = datasample(sem,vdT,ndE,'Replace',false); %indices aleatorios entrenamiento. Esta cosa sirve para saber la fila del Excel en el que sac� cada dato para entrenamiento (con estos datos se calcula xm y x2m)
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
    xdatE(se,:)=[xdata(inE1(se),1),xdata(inE1(se),2)];
    ydatE(se,1)= ydata(inE1(se)); %salida Entrenamiento normalizada
    yrdatE(se,1)=yreal(inE1(se)); %salida Entrenamiento real
end
for st=1:ndT %ciclo para guadar los datos de test
    xdatT(st,:)=[xdata(inT1(st),1),xdata(inT1(st),2)];
    ydatT(st,1)= ydata(inT1(st)); %salida Test normalizada
    yrdatT(st,1)= yreal(inT1(st)); %salida Test real
end
for sv=1:ndV %ciclo para guadar los datos de validación
    xdatV(sv,:)=[xdata(inV1(sv),1),xdata(inV1(sv),2)];
    ydatV(sv,1)= ydata(inV1(sv)); %salida Test normalizada
    yrdatV(sv,1)= yreal(inV1(sv)); %salida Test real
end


%Borramos variables de extracción
clear BDe BDs

%Ciclo para cambiar a guardar
for j=15:15  
    
    
         if j==1
 
%Crear carpeta para guardar
             nomap=strcat('\2IN_N1_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Entrenamiento
fun = @(x,xdatE) (((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+x(5)); %N1
 
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(5,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(5,1);
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
x0=2*rand(5,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Entrenamiento
R0=(((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+...
    +x2(3)))*x2(4))+x2(5)); %N1

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2)); %Normalizacion
R=desnormT(R0,x3m,x3s); %regularizacion 
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target Entrenamiento
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Entrenamiento
if r>=0.70 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999
 %--------------Test--------------------   
 RT=(((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+x2(5)); %N1

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en Test
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en test
MaxRT=max(valrt); %Valor maximo de r en test

if rt>=0.70 && rt<0.999999
%Guardar grafico de figura postreg test
nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
saveas(gcf,nomgraf2);
end

 %---------------------Validación-------------
RV=(((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+x2(5)); %N1

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en validación
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación

if rv>=0.70 && rv<0.999999
%Guardar grafico de figura postreg validación
nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
saveas(gcf,nomgraf3);
end

% Salvado de valores si cumple con el criterio de test y validacion 
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)

       if r>=0.72 && r<0.999999
        B1=x2(3);
        B2=x2(5);    
        IW=[x2(1) x2(2)];
        LW=x2(4);
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
             nomap=strcat('\2IN_N2_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8)))+x(9)); %N2 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(9,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(9,1);
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
x0=2*rand(9,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8)))+x2(9)); %N2  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Test
if r>=0.80 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Validación (se cambia a los valores de validación con los pesos obtenidos en el Test

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8)))+x2(9)); %N2  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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

 RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8)))+x2(9)); %N2  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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

       if r>=0.87 && r<0.999999
        B1=[x2(3);x2(7)];
        B2=x2(9);    
        IW=[x2(1) x2(2) ; x2(5) x2(6)];
        LW=[x2(4) x2(8)];
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
Num=Num+1;   
end
        end
         if j==3
 
%Crear carpeta para guardar
             nomap=strcat('\2IN_N3_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12)))+x(13)); %N3 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(13,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(13,1);
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
x0=2*rand(13,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12)))+x2(13)); %N3  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2  
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12)))+x2(13)); %N3  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2   
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12)))+x2(13)); %N3  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.92 && r<0.999999
        B1=[x2(3);x2(7);x2(11)];
        B2=x2(13);    
        IW=[x2(1) x2(2) ; x2(5) x2(6);...
            x2(9) x2(10)];
        LW=[x2(4) x2(8) x2(12)];
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
             nomap=strcat('\2IN_N4_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16)))+x(17)); %N4 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(17,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(17,1);
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
x0=2*rand(17,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16)))+x2(17)); %N4  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3  
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16)))+x2(17)); %N4  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3   
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16)))+x2(17)); %N4  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.92 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15)];
        B2=x2(17);    
        IW=[x2(1) x2(2) ; x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14)];
        LW=[x2(4) x2(8) x2(12) x2(16)];
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
             nomap=strcat('\2IN_N5_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20)))+x(21)); %N5 %peso y bia purelin
                                     
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4  
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20)))+x2(21)); %N5  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4   
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20)))+x2(21)); %N5  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4    
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20)))+x2(21)); %N5  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.90 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19)];
        B2=x2(21);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)];
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
             nomap=strcat('\2IN_N6_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24)))+x(25)); %N6 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(25,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(25,1);
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
x0=2*rand(25,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5    
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24)))+x2(25)); %N6  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5     
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24)))+x2(25)); %N6  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5     
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24)))+x2(25)); %N6  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.85 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23)];
        B2=x2(25);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24)];
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
             nomap=strcat('\2IN_N7_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28)))+x(29)); %N7 %peso y bia purelin
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(29,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(29,1);
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
x0=2*rand(29,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28)))+x2(29)); %N7  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28)))+x2(29)); %N7  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28)))+x2(29)); %N7  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.84 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27)];
        B2=x2(29);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28)];
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
             nomap=strcat('\2IN_N8_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32)))+x(33)); %N8 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(33,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(33,1);
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
x0=2*rand(33,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32)))+x2(33)); %N8  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.75 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.75 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32)))+x2(33)); %N8  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.78 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32)))+x2(33)); %N8  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.78 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.78 && rt<0.999999) && (rv>=0.78 && rv<0.999999)
       if r>=0.80 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31)];
        B2=x2(33);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32)];
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
             nomap=strcat('\2IN_N9_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36)))+x(37)); %N9 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(37,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(37,1);
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
x0=2*rand(37,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36)))+x2(37)); %N9  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999

RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36)))+x2(37)); %N9  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36)))+x2(37)); %N9  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
       if r>=0.70 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35)];
        B2=x2(37);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36)];
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
             nomap=strcat('\2IN_N10_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40)))+x(41)); %N10 %peso y bia purelin                        
             
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40)))+x2(41)); %N10  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.70 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40)))+x2(41)); %N10  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40)))+x2(41)); %N10  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.70 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.70 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35); x2(39)];
        B2=x2(41);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)];
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
             nomap=strcat('\2IN_N11_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44)))+x(45)); %N11 %peso y bia purelin 
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(45,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(45,1);
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
x0=2*rand(45,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44)))+x2(45)); %N11  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999
RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44)))+x2(45)); %N11  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44)))+x2(45)); %N11  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
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
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.75 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43)];
        B2=x2(45);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44)];
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
             nomap=strcat('\2IN_N12_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44))+... %N11
                 ((relu((x(45).*xdatE(:,1))+(x(46).*xdatE(:,2))...
                  +x(47)))*x(48)))+x(49)); %N12 %peso y bia purelin 
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(49,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(49,1);
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
x0=2*rand(49,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatE(:,1))+(x2(46).*xdatE(:,2))...
    +x2(47)))*x2(48)))+x2(49)); %N12  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.70 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999

RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatT(:,1))+(x2(46).*xdatT(:,2))...
    +x2(47)))*x2(48)))+x2(49)); %N12  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
 RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatV(:,1))+(x2(46).*xdatV(:,2))...
    +x2(47)))*x2(48)))+x2(49)); %N12  %peso purelin

% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.70 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.70 && r<0.999999
        B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43); x2(47)];
        B2=x2(49);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42); x2(45) x2(46)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44) x2(48)];
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
             nomap=strcat('\2IN_N13_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44))+... %N11
                 ((relu((x(45).*xdatE(:,1))+(x(46).*xdatE(:,2))...
                  +x(47)))*x(48))+... %N12
                 ((relu((x(49).*xdatE(:,1))+(x(50).*xdatE(:,2))...
                  +x(51)))*x(52)))+x(53)); %N13 %peso y bia purelin 
                                       
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(53,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(53,1);
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
x0=2*rand(53,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatE(:,1))+(x2(46).*xdatE(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatE(:,1))+(x2(50).*xdatE(:,2))...
    +x2(51)))*x2(52)))+x2(53)); %N13  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.70 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatT(:,1))+(x2(46).*xdatT(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatT(:,1))+(x2(50).*xdatT(:,2))...
    +x2(51)))*x2(52)))+x2(53)); %N13  %peso purelin


% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatV(:,1))+(x2(46).*xdatV(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatV(:,1))+(x2(50).*xdatV(:,2))...
    +x2(51)))*x2(52)))+x2(53)); %N13  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.70 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.70 && r<0.999999
       B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43); x2(47); x2(51)];
        B2=x2(53);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42); x2(45) x2(46);...
            x2(49) x2(50)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44) x2(48) x2(52)];
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
             nomap=strcat('\2IN_N14_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44))+... %N11
                 ((relu((x(45).*xdatE(:,1))+(x(46).*xdatE(:,2))...
                  +x(47)))*x(48))+... %N12
                 ((relu((x(49).*xdatE(:,1))+(x(50).*xdatE(:,2))...
                  +x(51)))*x(52))+... %N13
                 ((relu((x(53).*xdatE(:,1))+(x(54).*xdatE(:,2))...
                  +x(55)))*x(56)))+x(57)); %N14 %peso y bia purelin
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(57,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(57,1);
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
x0=2*rand(57,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatE(:,1))+(x2(46).*xdatE(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatE(:,1))+(x2(50).*xdatE(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatE(:,1))+(x2(54).*xdatE(:,2))...
    +x2(55)))*x2(56)))+x2(57)); %N14  %peso purelin

% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.70 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatT(:,1))+(x2(46).*xdatT(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatT(:,1))+(x2(50).*xdatT(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatT(:,1))+(x2(54).*xdatT(:,2))...
    +x2(55)))*x2(56)))+x2(57)); %N14  %peso purelin

% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatV(:,1))+(x2(46).*xdatV(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatV(:,1))+(x2(50).*xdatV(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatV(:,1))+(x2(54).*xdatV(:,2))...
    +x2(55)))*x2(56)))+x2(57)); %N14  %peso purelin


% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.70 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.70 && r<0.999999
       B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43); x2(47);x2(51);x2(55)];
        B2=x2(57);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42); x2(45) x2(46);...
            x2(49) x2(50); x2(53) x2(54)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44) x2(48) x2(52) x2(56)];
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
             nomap=strcat('\2IN_N15_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44))+... %N11
                 ((relu((x(45).*xdatE(:,1))+(x(46).*xdatE(:,2))...
                  +x(47)))*x(48))+... %N12
                 ((relu((x(49).*xdatE(:,1))+(x(50).*xdatE(:,2))...
                  +x(51)))*x(52))+... %N13
                 ((relu((x(53).*xdatE(:,1))+(x(54).*xdatE(:,2))...
                  +x(55)))*x(56))+... %N14
                 ((relu((x(57).*xdatE(:,1))+(x(58).*xdatE(:,2))...
                  +x(59)))*x(60)))+x(61)); %N15 %peso y bia purelin
                          
             
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatE(:,1))+(x2(46).*xdatE(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatE(:,1))+(x2(50).*xdatE(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatE(:,1))+(x2(54).*xdatE(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatE(:,1))+(x2(58).*xdatE(:,2))...
    +x2(59)))*x2(60)))+x2(61)); %N15  %peso purelin

%R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
 R=desnormT(R0,x3m,x3s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.70 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.70 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatT(:,1))+(x2(46).*xdatT(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatT(:,1))+(x2(50).*xdatT(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatT(:,1))+(x2(54).*xdatT(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatT(:,1))+(x2(58).*xdatT(:,2))...
    +x2(59)))*x2(60)))+x2(61)); %N15  %peso purelin

%R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));
 R1=desnormT(RT,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.70 && rt<0.999999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatV(:,1))+(x2(46).*xdatV(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatV(:,1))+(x2(50).*xdatV(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatV(:,1))+(x2(54).*xdatV(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatV(:,1))+(x2(58).*xdatV(:,2))...
    +x2(59)))*x2(60)))+x2(61)); %N15  %peso purelin


%R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
 R2=desnormT(RV,x3m,x3s);
% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.70 && rv<0.999999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.70 && rt<0.999999) && (rv>=0.70 && rv<0.999999)
       if r>=0.70 && r<0.999999
       B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43); x2(47);x2(51);x2(55);x2(59)];
        B2=x2(61);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42); x2(45) x2(46);...
            x2(49) x2(50); x2(53) x2(54);...
            x2(57) x2(58)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44) x2(48) x2(52) x2(56) x2(60)];
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
         if j==16
 
%Crear carpeta para guardar
             nomap=strcat('\N16_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))...
                  +x(3)))*x(4))+... %N1
                 ((relu((x(5).*xdatE(:,1))+(x(6).*xdatE(:,2))...
                  +x(7)))*x(8))+...%N2 
                 ((relu((x(9).*xdatE(:,1))+(x(10).*xdatE(:,2))...
                  +x(11)))*x(12))+... %N3
                 ((relu((x(13).*xdatE(:,1))+(x(14).*xdatE(:,2))...
                  +x(15)))*x(16))+... %N4
                 ((relu((x(17).*xdatE(:,1))+(x(18).*xdatE(:,2))...
                  +x(19)))*x(20))+... %N5
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))...
                  +x(23)))*x(24))+... %N6
                 ((relu((x(25).*xdatE(:,1))+(x(26).*xdatE(:,2))...
                  +x(27)))*x(28))+... %N7
                 ((relu((x(29).*xdatE(:,1))+(x(30).*xdatE(:,2))...
                  +x(31)))*x(32))+... %N8
                 ((relu((x(33).*xdatE(:,1))+(x(34).*xdatE(:,2))...
                  +x(35)))*x(36))+... %N9
                 ((relu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))...
                  +x(39)))*x(40))+... %N10
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))...
                  +x(43)))*x(44))+... %N11
                 ((relu((x(45).*xdatE(:,1))+(x(46).*xdatE(:,2))...
                  +x(47)))*x(48))+... %N12
                 ((relu((x(49).*xdatE(:,1))+(x(50).*xdatE(:,2))...
                  +x(51)))*x(52))+... %N13
                 ((relu((x(53).*xdatE(:,1))+(x(54).*xdatE(:,2))...
                  +x(55)))*x(56))+... %N14
                 ((relu((x(57).*xdatE(:,1))+(x(58).*xdatE(:,2))...
                  +x(59)))*x(60))+... %N15
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))...
                  +x(63)))*x(64)))+x(65)); %N16 %peso y bia purelin
                          
             
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
NmaxIt=1000;
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatE(:,1))+(x2(6).*xdatE(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatE(:,1))+(x2(10).*xdatE(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatE(:,1))+(x2(14).*xdatE(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatE(:,1))+(x2(18).*xdatE(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatE(:,1))+(x2(26).*xdatE(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatE(:,1))+(x2(30).*xdatE(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatE(:,1))+(x2(34).*xdatE(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatE(:,1))+(x2(46).*xdatE(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatE(:,1))+(x2(50).*xdatE(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatE(:,1))+(x2(54).*xdatE(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatE(:,1))+(x2(58).*xdatE(:,2))...
    +x2(59)))*x2(60))+... %N15
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))...
    +x2(63)))*x2(64)))+x2(65)); %N16  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.80 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatT(:,1))+(x2(6).*xdatT(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatT(:,1))+(x2(10).*xdatT(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatT(:,1))+(x2(14).*xdatT(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatT(:,1))+(x2(18).*xdatT(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatT(:,1))+(x2(26).*xdatT(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatT(:,1))+(x2(30).*xdatT(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatT(:,1))+(x2(34).*xdatT(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatT(:,1))+(x2(46).*xdatT(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatT(:,1))+(x2(50).*xdatT(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatT(:,1))+(x2(54).*xdatT(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatT(:,1))+(x2(58).*xdatT(:,2))...
    +x2(59)))*x2(60))+... %N15
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))...
    +x2(63)))*x2(64)))+x2(65)); %N16  %peso purelin

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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))...
    +x2(3)))*x2(4))+... %N1
   ((relu((x2(5).*xdatV(:,1))+(x2(6).*xdatV(:,2))...
    +x2(7)))*x2(8))+...%N2 
   ((relu((x2(9).*xdatV(:,1))+(x2(10).*xdatV(:,2))...
    +x2(11)))*x2(12))+... %N3
   ((relu((x2(13).*xdatV(:,1))+(x2(14).*xdatV(:,2))...
    +x2(15)))*x2(16))+... %N4
   ((relu((x2(17).*xdatV(:,1))+(x2(18).*xdatV(:,2))...
    +x2(19)))*x2(20))+... %N5   
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))...
    +x2(23)))*x2(24))+... %N6   
   ((relu((x2(25).*xdatV(:,1))+(x2(26).*xdatV(:,2))...
    +x2(27)))*x2(28))+... %N7
   ((relu((x2(29).*xdatV(:,1))+(x2(30).*xdatV(:,2))...
    +x2(31)))*x2(32))+... %N8
   ((relu((x2(33).*xdatV(:,1))+(x2(34).*xdatV(:,2))...
    +x2(35)))*x2(36))+... %N9
   ((relu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))...
    +x2(39)))*x2(40))+... %N10
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))...
    +x2(43)))*x2(44))+... %N11
   ((relu((x2(45).*xdatV(:,1))+(x2(46).*xdatV(:,2))...
    +x2(47)))*x2(48))+... %N12
   ((relu((x2(49).*xdatV(:,1))+(x2(50).*xdatV(:,2))...
    +x2(51)))*x2(52))+... %N13
   ((relu((x2(53).*xdatV(:,1))+(x2(54).*xdatV(:,2))...
    +x2(55)))*x2(56))+... %N14
   ((relu((x2(57).*xdatV(:,1))+(x2(58).*xdatV(:,2))...
    +x2(59)))*x2(60))+... %N14
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))...
    +x2(63)))*x2(64)))+x2(65)); %N15  %peso purelin


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
       B1=[x2(3);x2(7);x2(11);x2(15);x2(19);...
           x2(23);x2(27);x2(31);x2(35);x2(39);...
           x2(43); x2(47);x2(51);x2(55);x2(59);...
           x2(63)];
        B2=x2(65);    
        IW=[x2(1) x2(2); x2(5) x2(6);...
            x2(9) x2(10); x2(13) x2(14);... 
            x2(17) x2(18); x2(21) x2(22);...
            x2(25) x2(26); x2(29) x2(30);...
            x2(33) x2(34); x2(37) x2(38);...
            x2(41) x2(42); x2(45) x2(46);...
            x2(49) x2(50); x2(53) x2(54);...
            x2(57) x2(58); x2(61) x2(62)];
        LW=[x2(4) x2(8) x2(12) x2(16) x2(20)...
            x2(24) x2(28) x2(32) x2(36) x2(40)...
            x2(44) x2(48) x2(52) x2(56) x2(60)...
            x2(64)];
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
             nomap=strcat('\N17_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
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
NmaxIt=1000;
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
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
             nomap=strcat('\N18_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
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
NmaxIt=1000;
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
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
             nomap=strcat('\N19_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
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
             nomap=strcat('\N20_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
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
             nomap=strcat('\N21_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((relu((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
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
             nomap=strcat('\N22_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((relu((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((relu((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
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
NmaxIt=1000;
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
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
             nomap=strcat('\N23_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((relu((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((relu((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((relu((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
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
             nomap=strcat('\N24_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((relu((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((relu((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((relu((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
                  +x(114)))*x(115))+... %N23
                 ((relu((x(116).*xdatE(:,1))+(x(117).*xdatE(:,2))+(x(118).*xdatE(:,3))...
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatE(:,1))+(x2(117).*xdatE(:,2))+(x2(118).*xdatE(:,3))...
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
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatT(:,1))+(x2(117).*xdatT(:,2))+(x2(118).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatV(:,1))+(x2(117).*xdatV(:,2))+(x2(118).*xdatV(:,3))...
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
             nomap=strcat('\N25_relu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((relu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))...
                  +x(4)))*x(5))+... %N1
                 ((relu((x(6).*xdatE(:,1))+(x(7).*xdatE(:,2))+(x(8).*xdatE(:,3))...
                  +x(9)))*x(10))+...%N2 
                 ((relu((x(11).*xdatE(:,1))+(x(12).*xdatE(:,2))+(x(13).*xdatE(:,3))...
                  +x(14)))*x(15))+... %N3
                 ((relu((x(16).*xdatE(:,1))+(x(17).*xdatE(:,2))+(x(18).*xdatE(:,3))...
                  +x(19)))*x(20))+... %N4
                 ((relu((x(21).*xdatE(:,1))+(x(22).*xdatE(:,2))+(x(23).*xdatE(:,3))...
                  +x(24)))*x(25))+... %N5
                 ((relu((x(26).*xdatE(:,1))+(x(27).*xdatE(:,2))+(x(28).*xdatE(:,3))...
                  +x(29)))*x(30))+... %N6
                 ((relu((x(31).*xdatE(:,1))+(x(32).*xdatE(:,2))+(x(33).*xdatE(:,3))...
                  +x(34)))*x(35))+... %N7
                 ((relu((x(36).*xdatE(:,1))+(x(37).*xdatE(:,2))+(x(38).*xdatE(:,3))...
                  +x(39)))*x(40))+... %N8
                 ((relu((x(41).*xdatE(:,1))+(x(42).*xdatE(:,2))+(x(43).*xdatE(:,3))...
                  +x(44)))*x(45))+... %N9
                 ((relu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))...
                  +x(49)))*x(50))+... %N10
                 ((relu((x(51).*xdatE(:,1))+(x(52).*xdatE(:,2))+(x(53).*xdatE(:,3))...
                  +x(54)))*x(55))+... %N11
                 ((relu((x(56).*xdatE(:,1))+(x(57).*xdatE(:,2))+(x(58).*xdatE(:,3))...
                  +x(59)))*x(60))+... %N12
                 ((relu((x(61).*xdatE(:,1))+(x(62).*xdatE(:,2))+(x(63).*xdatE(:,3))...
                  +x(64)))*x(65))+... %N13
                 ((relu((x(66).*xdatE(:,1))+(x(67).*xdatE(:,2))+(x(68).*xdatE(:,3))...
                  +x(69)))*x(70))+... %N14
                 ((relu((x(71).*xdatE(:,1))+(x(72).*xdatE(:,2))+(x(73).*xdatE(:,3))...
                  +x(74)))*x(75))+... %N15
                 ((relu((x(76).*xdatE(:,1))+(x(77).*xdatE(:,2))+(x(78).*xdatE(:,3))...
                  +x(79)))*x(80))+... %N16
                 ((relu((x(81).*xdatE(:,1))+(x(82).*xdatE(:,2))+(x(83).*xdatE(:,3))...
                  +x(84)))*x(85))+... %N17
                 ((relu((x(86).*xdatE(:,1))+(x(87).*xdatE(:,2))+(x(88).*xdatE(:,3))...
                  +x(89)))*x(90))+... %N18
                 ((relu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))...
                  +x(94)))*x(95))+... %N19
                 ((relu((x(96).*xdatE(:,1))+(x(97).*xdatE(:,2))+(x(98).*xdatE(:,3))...
                  +x(99)))*x(100))+... %N20
                 ((relu((x(101).*xdatE(:,1))+(x(102).*xdatE(:,2))+(x(103).*xdatE(:,3))...
                  +x(104)))*x(105))+... %N21
                 ((relu((x(106).*xdatE(:,1))+(x(107).*xdatE(:,2))+(x(108).*xdatE(:,3))...
                  +x(109)))*x(110))+... %N22
                 ((relu((x(111).*xdatE(:,1))+(x(112).*xdatE(:,2))+(x(113).*xdatE(:,3))...
                  +x(114)))*x(115))+... %N23
                 ((relu((x(116).*xdatE(:,1))+(x(117).*xdatE(:,2))+(x(118).*xdatE(:,3))...
                  +x(119)))*x(120))+... %N24
                 ((relu((x(121).*xdatE(:,1))+(x(122).*xdatE(:,2))+(x(123).*xdatE(:,3))...
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
NmaxIt=1000;
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
R0=((((relu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatE(:,1))+(x2(7).*xdatE(:,2))+(x2(8).*xdatE(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatE(:,1))+(x2(12).*xdatE(:,2))+(x2(13).*xdatE(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatE(:,1))+(x2(17).*xdatE(:,2))+(x2(18).*xdatE(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatE(:,1))+(x2(22).*xdatE(:,2))+(x2(23).*xdatE(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatE(:,1))+(x2(27).*xdatE(:,2))+(x2(28).*xdatE(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatE(:,1))+(x2(32).*xdatE(:,2))+(x2(33).*xdatE(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatE(:,1))+(x2(37).*xdatE(:,2))+(x2(38).*xdatE(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatE(:,1))+(x2(42).*xdatE(:,2))+(x2(43).*xdatE(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatE(:,1))+(x2(52).*xdatE(:,2))+(x2(53).*xdatE(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatE(:,1))+(x2(57).*xdatE(:,2))+(x2(58).*xdatE(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatE(:,1))+(x2(62).*xdatE(:,2))+(x2(63).*xdatE(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatE(:,1))+(x2(67).*xdatE(:,2))+(x2(68).*xdatE(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatE(:,1))+(x2(72).*xdatE(:,2))+(x2(73).*xdatE(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatE(:,1))+(x2(77).*xdatE(:,2))+(x2(78).*xdatE(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatE(:,1))+(x2(82).*xdatE(:,2))+(x2(83).*xdatE(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatE(:,1))+(x2(87).*xdatE(:,2))+(x2(88).*xdatE(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatE(:,1))+(x2(97).*xdatE(:,2))+(x2(98).*xdatE(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatE(:,1))+(x2(102).*xdatE(:,2))+(x2(103).*xdatE(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatE(:,1))+(x2(107).*xdatE(:,2))+(x2(108).*xdatE(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatE(:,1))+(x2(112).*xdatE(:,2))+(x2(113).*xdatE(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatE(:,1))+(x2(117).*xdatE(:,2))+(x2(118).*xdatE(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((relu((x2(121).*xdatE(:,1))+(x2(122).*xdatE(:,2))+(x2(123).*xdatE(:,3))...
    +x2(124)))*x2(125)))+x2(126))); %N25  %peso purelin

R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.99 && r<0.999999
% Guardado del grafico de Test
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end
%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.99 && r<0.999999
 RT=((((relu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatT(:,1))+(x2(7).*xdatT(:,2))+(x2(8).*xdatT(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatT(:,1))+(x2(12).*xdatT(:,2))+(x2(13).*xdatT(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatT(:,1))+(x2(17).*xdatT(:,2))+(x2(18).*xdatT(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatT(:,1))+(x2(22).*xdatT(:,2))+(x2(23).*xdatT(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatT(:,1))+(x2(27).*xdatT(:,2))+(x2(28).*xdatT(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatT(:,1))+(x2(32).*xdatT(:,2))+(x2(33).*xdatT(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatT(:,1))+(x2(37).*xdatT(:,2))+(x2(38).*xdatT(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatT(:,1))+(x2(42).*xdatT(:,2))+(x2(43).*xdatT(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatT(:,1))+(x2(52).*xdatT(:,2))+(x2(53).*xdatT(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatT(:,1))+(x2(57).*xdatT(:,2))+(x2(58).*xdatT(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatT(:,1))+(x2(62).*xdatT(:,2))+(x2(63).*xdatT(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatT(:,1))+(x2(67).*xdatT(:,2))+(x2(68).*xdatT(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatT(:,1))+(x2(72).*xdatT(:,2))+(x2(73).*xdatT(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatT(:,1))+(x2(77).*xdatT(:,2))+(x2(78).*xdatT(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatT(:,1))+(x2(82).*xdatT(:,2))+(x2(83).*xdatT(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatT(:,1))+(x2(87).*xdatT(:,2))+(x2(88).*xdatT(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatT(:,1))+(x2(97).*xdatT(:,2))+(x2(98).*xdatT(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatT(:,1))+(x2(102).*xdatT(:,2))+(x2(103).*xdatT(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatT(:,1))+(x2(107).*xdatT(:,2))+(x2(108).*xdatT(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatT(:,1))+(x2(112).*xdatT(:,2))+(x2(113).*xdatT(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatT(:,1))+(x2(117).*xdatT(:,2))+(x2(118).*xdatT(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((relu((x2(121).*xdatT(:,1))+(x2(122).*xdatT(:,2))+(x2(123).*xdatT(:,3))...
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
  RV=((((relu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))...
    +x2(4)))*x2(5))+... %N1
   ((relu((x2(6).*xdatV(:,1))+(x2(7).*xdatV(:,2))+(x2(8).*xdatV(:,3))...
    +x2(9)))*x2(10))+...%N2 
   ((relu((x2(11).*xdatV(:,1))+(x2(12).*xdatV(:,2))+(x2(13).*xdatV(:,3))...
    +x2(14)))*x2(15))+... %N3
   ((relu((x2(16).*xdatV(:,1))+(x2(17).*xdatV(:,2))+(x2(18).*xdatV(:,3))...
    +x2(19)))*x2(20))+... %N4
   ((relu((x2(21).*xdatV(:,1))+(x2(22).*xdatV(:,2))+(x2(23).*xdatV(:,3))...
    +x2(24)))*x2(25))+... %N5   
   ((relu((x2(26).*xdatV(:,1))+(x2(27).*xdatV(:,2))+(x2(28).*xdatV(:,3))...
    +x2(29)))*x2(30))+... %N6   
   ((relu((x2(31).*xdatV(:,1))+(x2(32).*xdatV(:,2))+(x2(33).*xdatV(:,3))...
    +x2(34)))*x2(35))+... %N7
   ((relu((x2(36).*xdatV(:,1))+(x2(37).*xdatV(:,2))+(x2(38).*xdatV(:,3))...
    +x2(39)))*x2(40))+... %N8
   ((relu((x2(41).*xdatV(:,1))+(x2(42).*xdatV(:,2))+(x2(43).*xdatV(:,3))...
    +x2(44)))*x2(45))+... %N9
   ((relu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))...
    +x2(49)))*x2(50))+... %N10
   ((relu((x2(51).*xdatV(:,1))+(x2(52).*xdatV(:,2))+(x2(53).*xdatV(:,3))...
    +x2(54)))*x2(55))+... %N11
   ((relu((x2(56).*xdatV(:,1))+(x2(57).*xdatV(:,2))+(x2(58).*xdatV(:,3))...
    +x2(59)))*x2(60))+... %N12
   ((relu((x2(61).*xdatV(:,1))+(x2(62).*xdatV(:,2))+(x2(63).*xdatV(:,3))...
    +x2(64)))*x2(65))+... %N13
   ((relu((x2(66).*xdatV(:,1))+(x2(67).*xdatV(:,2))+(x2(68).*xdatV(:,3))...
    +x2(69)))*x2(70))+... %N14
   ((relu((x2(71).*xdatV(:,1))+(x2(72).*xdatV(:,2))+(x2(73).*xdatV(:,3))...
    +x2(74)))*x2(75))+... %N15
   ((relu((x2(76).*xdatV(:,1))+(x2(77).*xdatV(:,2))+(x2(78).*xdatV(:,3))...
    +x2(79)))*x2(80))+... %N16
   ((relu((x2(81).*xdatV(:,1))+(x2(82).*xdatV(:,2))+(x2(83).*xdatV(:,3))...
    +x2(84)))*x2(85))+... %N17
   ((relu((x2(86).*xdatV(:,1))+(x2(87).*xdatV(:,2))+(x2(88).*xdatV(:,3))...
    +x2(89)))*x2(90))+... %N18
   ((relu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))...
    +x2(94)))*x2(95))+... %N19
   ((relu((x2(96).*xdatV(:,1))+(x2(97).*xdatV(:,2))+(x2(98).*xdatV(:,3))...
    +x2(99)))*x2(100))+... %N20
   ((relu((x2(101).*xdatV(:,1))+(x2(102).*xdatV(:,2))+(x2(103).*xdatV(:,3))...
    +x2(104)))*x2(105))+... %N21
   ((relu((x2(106).*xdatV(:,1))+(x2(107).*xdatV(:,2))+(x2(108).*xdatV(:,3))...
    +x2(109)))*x2(110)+... %N22
   ((relu((x2(111).*xdatV(:,1))+(x2(112).*xdatV(:,2))+(x2(113).*xdatV(:,3))...
    +x2(114)))*x2(115))+... %N23
   ((relu((x2(116).*xdatV(:,1))+(x2(117).*xdatV(:,2))+(x2(118).*xdatV(:,3))...
    +x2(119)))*x2(120))+... %N24
   ((relu((x2(121).*xdatV(:,1))+(x2(122).*xdatV(:,2))+(x2(123).*xdatV(:,3))...
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
   save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii'); 
   save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii'); 
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
end
