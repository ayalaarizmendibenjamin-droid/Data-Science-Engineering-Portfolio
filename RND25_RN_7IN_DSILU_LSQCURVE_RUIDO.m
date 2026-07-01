%% Codigo lsqcurvefit Ruido
clear all
clc
%Extracción de datos
BDe=xlsread('20241120_Parametros utilizados.xlsx','A3:G898');
BDs=xlsread('20241120_Parametros utilizados.xlsx','I3:I898');
% Normalización
x1m=mean(BDe(:,1)); %media entrada 1
x2m=mean(BDe(:,2)); %media entrada 2
x3m=mean(BDe(:,3)); %media entrada 3
x4m=mean(BDe(:,4)); %media entrada 4
x5m=mean(BDe(:,5)); %media entrada 5
x6m=mean(BDe(:,6)); %media entrada 6
x7m=mean(BDe(:,7)); %media entrada 7
x8m=mean(BDs); %media salida
x1s=std(BDe(:,1)); %desviación estandar entrada 1
x2s=std(BDe(:,2)); %desviación estandar entrada 2
x3s=std(BDe(:,3)); %desviación estandar entrada 3
x4s=std(BDe(:,4)); %desviación estandar entrada 4
x5s=std(BDe(:,5)); %desviación estandar entrada 5
x6s=std(BDe(:,6)); %desviación estandar entrada 6
x7s=std(BDe(:,7)); %desviación estandar entrada 7
x8s=std(BDs); %desviacion estandar salida
% N=[4 -4];
xdata=[normT(BDe(:,1),x1m,x1s),normT(BDe(:,2),x2m,x2s),...
       normT(BDe(:,3),x3m,x3s),normT(BDe(:,4),x4m,x4s),...
       normT(BDe(:,5),x5m,x5s),normT(BDe(:,6),x6m,x6s),...
       normT(BDe(:,7),x7m,x7s)];
% xdata=[minmaxnorm(BDe(:,1),N(1),N(2)),minmaxnorm(BDe(:,2),N(1),N(2)),...
%        minmaxnorm(BDe(:,3),N(1),N(2)),minmaxnorm(BDe(:,4),N(1),N(2)),...
%        minmaxnorm(BDe(:,5),N(1),N(2)),minmaxnorm(BDe(:,6),N(1),N(2)),...
%        minmaxnorm(BDe(:,7),N(1),N(2))];
%target real   
yreal=BDs;
%numero de elementos del vector
tm=numel(yreal);
%target normalizado
ydata=normT(BDs,x8m,x8s);
% ydata =minmaxnorm(BDs,N(1),N(2));
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
    xdatE(se,:)=[xdata(inE1(se),1),xdata(inE1(se),2),xdata(inE1(se),3),xdata(inE1(se),4),...
        xdata(inE1(se),5),xdata(inE1(se),6),xdata(inE1(se),7)];
    ydatE(se,1)= ydata(inE1(se)); %salida Entrenamiento normalizada
    yrdatE(se,1)=yreal(inE1(se)); %salida Entrenamiento real
end
for st=1:ndT %ciclo para guadar los datos de test
    xdatT(st,:)=[xdata(inT1(st),1),xdata(inT1(st),2),xdata(inT1(st),3),xdata(inT1(st),4),...
        xdata(inT1(st),5),xdata(inT1(st),6),xdata(inT1(st),7)];
    ydatT(st,1)= ydata(inT1(st)); %salida Test normalizada
    yrdatT(st,1)= yreal(inT1(st)); %salida Test real
end
for sv=1:ndV %ciclo para guadar los datos de validación
    xdatV(sv,:)=[xdata(inV1(sv),1),xdata(inV1(sv),2),xdata(inV1(sv),3),xdata(inV1(sv),4),...
        xdata(inV1(sv),5),xdata(inV1(sv),6),xdata(inV1(sv),7)];
    ydatV(sv,1)= ydata(inV1(sv)); %salida Test normalizada
    yrdatV(sv,1)= yreal(inV1(sv)); %salida Test real
end


%Borramos variables de extracción
clear BDe BDs

%Ciclo para cambiar a guardar
for j=1:2
    
         if j==1
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N1_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Entrenamiento
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9)))+x(10)); %N1
 
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(10,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(10,1);
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
x0=2*rand(10,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Entrenamiento
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9)))+x2(10)); %N1

R=desnormT(R0,x8m,x8s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target Entrenamiento
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Entrenamiento
if r>=0.85 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.85 && r<0.999999
 %--------------Test--------------------   
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9)))+x2(10)); %N1

R1=desnormT(RT,x8m,x8s);
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
RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9)))+x2(10)); %N1

R2=desnormT(RV,x8m,x8s);
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

       if r>=0.85 && r<0.999999
        B1=[x2(8)];
        B2=x2(10);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7)]; 
        LW=[x2(9)];
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
             nomap=strcat('\7IN_N2_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18)))+x(19));%N2 
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(19,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(19,1);
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
x0=2*rand(19,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18)))+x2(19));%N2

R=desnormT(R0,x8m,x8s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
% Guardado del grafico de Test
if r>=0.85 && r<0.999999
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Validación (se cambia a los valores de validación con los pesos obtenidos en el Test

if r>=0.85 && r<0.999999
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18)))+x2(19));%N2 
  
R1=desnormT(RT,x8m,x8s);
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

 RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18)))+x2(19)); %N2 

R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17)];
        B2=x2(19);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16)]; 
        LW=[x2(9) x2(18)];
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
             nomap=strcat('\7IN_N3_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27)))+x(28)); %N3
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(28,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(28,1);
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
x0=2*rand(28,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27)))+x2(28)); %N3

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27)))+x2(28)); %N3

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27)))+x2(28)); %N3

R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26)];
        B2=x2(28);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25)]; 
        LW=[x2(9) x2(18) x2(27)];
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
             nomap=strcat('\7IN_N4_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36)))+x(37)); %N4
                                     
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
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36)))+x2(37)); %N4

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36)))+x2(37)); %N4
      
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36)))+x2(37)); %N4


R2=desnormT(RV,x8m,x8s);
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
         B1=[x2(8);x2(17);x2(26);x2(35)];
        B2=x2(37);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34)]; 
        LW=[x2(9) x2(18) x2(27) x2(36)];
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
             nomap=strcat('\7IN_N5_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45)))+x(46)); %N5
                                     
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
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45)))+x2(46)); %N5

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45)))+x2(46)); %N5
      
R1=desnormT(RT,x8m,x8s);
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
   RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45)))+x2(46)); %N5

R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44)];
        B2=x2(46);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)];
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
             nomap=strcat('\7IN_N6_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54)))+x(55)); %N6
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(55,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(55,1);
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
x0=2*rand(55,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54)))+x2(55)); %N6; %N6 %peso y bia purelin

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54)))+x2(55)); %N6

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54)))+x2(55)); %N6


R2=desnormT(RV,x8m,x8s);
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
      B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53)];
        B2=x2(55);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54)];
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
             nomap=strcat('\7IN_N7_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63)))+x(64)); %N7
                                     
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(64,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(64,1);
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
x0=2*rand(64,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63)))+x2(64)); %N7

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63)))+x2(64)); %N7

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63)))+x2(64)); %N7


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62)];
        B2=x2(64);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63)];
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
             nomap=strcat('\7IN_N8_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72)))+x(73)); %N8
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(73,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(73,1);
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
x0=2*rand(73,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72)))+x2(73)); %N8

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72)))+x2(73)); %N8

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72)))+x2(73)); %N8


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71)];
        B2=x2(73);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72)];
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
             nomap=strcat('\7IN_N9_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81)))+x(82)); %N9
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(82,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(82,1);
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
x0=2*rand(82,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81)))+x2(82)); %N9
  
R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81)))+x2(82)); %N9  %peso purelin

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81)))+x2(82)); %N9


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80)];
        B2=x2(82);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)];
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
             nomap=strcat('\7IN_N10_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90)))+x(91)); %N10
                          
             
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
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90)))+x2(91)); %N10

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90)))+x2(91)); %N10

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90)))+x2(91)); %N10


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89)];
        B2=x2(91);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90)];
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
             nomap=strcat('\7IN_N11_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99)))+x(100)); %N11
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(100,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(100,1);
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
x0=2*rand(100,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99)))+x2(100)); %N11

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99)))+x2(100)); %N11

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99)))+x2(100)); %N11


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98)];
        B2=x2(100);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97)]; 
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99)];
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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
       if j==12
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N12_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108)))+x(109)); %N12
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(109,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(109,1);
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
x0=2*rand(109,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108)))+x2(109)); %N12

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108)))+x2(109)); %N12

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108)))+x2(109)); %N12


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107)];
        B2=x2(109);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108)];
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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
       if j==13
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N13_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117)))+x(118)); %N13
                          
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(118,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(118,1);
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
x0=2*rand(118,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117)))+x2(118)); %N13

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117)))+x2(118)); %N13

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117)))+x2(118)); %N13


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116)];
        B2=x2(118);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117)];
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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
       if j==14
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N14_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126)))+ x(127)); %N14
                          
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(127,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(127,1);
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
x0=2*rand(127,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126)))+x2(127)); %N14

R=desnormT(R0,x8m,x8s);
% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));

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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126)))+ x2(127)); %N14

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126)))+ x2(127)); %N14


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125)];
        B2=x2(127);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)];
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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==15
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N15_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135)))+x(136)); %N15 %peso y bia purelin
                                                 
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(136,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(136,1);
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
x0=2*rand(136,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135)))+x2(136)); %N15 %peso y bia purelin


R=desnormT(R0,x8m,x8s);
% R=desnorm(R0,max(yrdatE),min(yrdatE),N(1),N(2));

% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.95 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.80 && r<1.1
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135)))+x2(136)); %N15 %peso y bia purelin


R1=desnormT(RT,x8m,x8s);
% R1=desnorm(RT,max(yrdatT),min(yrdatT),N(1),N(2));

% En esta variable se guardan los resultados de R en validación
vert=R1;
%%--------------Comparación de salidas y target en Test
[mt,bt,rt]=postreg(vert,yrdatT);
valrt(Num)=rt; %almacena los datos de r en validación
MaxRT=max(valrt); %Valor maximo de r en validación
    if rt>=0.95 && rt<0.99999
    %Guardar grafico de figura postreg
    nomgraf2= strcat(nn,'\grafT',num2str(r),'.jpg');
    saveas(gcf,nomgraf2);
    end

%------------------VALIDACIÓN--------------------
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135)))+x2(136)); %N15 %peso y bia purelin


R2=desnormT(RV,x8m,x8s);
% R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));

% En esta variable se guardan los resultados de R en validación
verv=R2;
%%--------------Comparación de salidas y target en Test
[mv,bv,rv]=postreg(verv,yrdatV);
valrv(Num)=rv; %almacena los datos de r en validación
MaxRV=max(valrv); %Valor maximo de r en validación
    if rv>=0.95 && rv<0.99999
    %Guardar grafico de figura postreg
    nomgraf3= strcat(nn,'\grafV',num2str(r),'.jpg');
    saveas(gcf,nomgraf3);
    end    

% Salvado de valores si cumple con el criterio de validacion
if (rt>=0.95 && rt<0.99999) && (rv>=0.95 && rv<0.99999)
       if r>=0.98 && r<0.99999
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134)];
        B2=x2(136);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==16
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N16_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144)))+x(145)); %N16 %peso y bia purelin        
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(145,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(145,1);
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
x0=2*rand(145,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144)))+x2(145)); %N16 %peso y bia purelin

R=desnormT(R0,x8m,x8s);
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
  RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144)))+x2(145)); %N16 %peso y bia purelin


R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144)))+x2(145)); %N16 %peso y bia purelin

R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143)];
        B2=x2(145);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==17
 
%Crear carpeta para guardar
             nomap=strcat('\N17_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153)))+x(154)); %N17 %peso y bia purelin        
             
             
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(154,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(154,1);
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
x0=2*rand(154,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153)))+x2(154)); %N17 %peso y bia purelin

R=desnormT(R0,x8m,x8s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.98 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.98 && r<0.999999
  RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153)))+x2(154)); %N17 %peso y bia purelin

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153)))+x2(154)); %N17 %peso y bia purelin


R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152)];
        B2=x2(154);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
         if j==18
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N18_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162)))+x(163)); %N18        
                 
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(163,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(163,1);
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
x0=2*rand(163,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162)))+x2(163)); %N18 %peso y bia purelin


R=desnormT(R0,x8m,x8s);
% En esta variable se guardan los resultados de R
ver=R;
%%--------------Comparación de salidas y target en Test
[m,b,r]=postreg(ver,yrdatE);
valr(Num)=r;
MaxRE=max(valr);
if r>=0.98 && r<0.999999
% Guardado del grafico de Entrenamiento
nomgraf= strcat(nn,'\grafE',num2str(r),'.jpg');
saveas(gcf,nomgraf);
end

%% Test (se cambia a los valores de validación con los pesos obtenidos en el Entrenamiento

if r>=0.98 && r<0.999999
  RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162)))+x2(163)); %N18 %peso y bia purelin
     

R1=desnormT(RT,x8m,x8s);
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
 RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162)))+x2(163)); %N18

R2=desnormT(RV,x8m,x8s);
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
         B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161)];
        B2=x2(163);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end 
        if j==19
 
%Crear carpeta para guardar
             nomap=strcat('\7N_N19_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171)))+x(172)); %N19 %peso y bia purelin  
              
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(172,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(172,1);
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
x0=2*rand(172,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171)))+x2(172)); %N19 %peso y bia purelin


R=desnormT(R0,x8m,x8s);
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
  RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171)))+x2(172)); %N19 %peso y bia purelin


R1=desnormT(RT,x8m,x8s);
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
RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171)))+x2(172)); %N18 %peso y bia purelin

R2=desnormT(RV,x8m,x8s);
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
      B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161) ; x2(170)];
        B2=x2(172);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1;   
end
        end 
        if j==20
 
%Crear carpeta para guardar
             nomap=strcat('\7IN_N20_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180)))+x(181)); %N20 %peso y bia purelin  
                   
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(181,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(181,1);
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
x0=2*rand(181,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180)))+x2(181)); %N20 %peso y bia purelin


R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180)))+x2(181)); %N20 %peso y bia purelin

R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180)))+x2(181)); %N20 %peso y bia purelin

R2=desnormT(RV,x8m,x8s);
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
       B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161); x2(170); x2(179)];
        B2=x2(181);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1
end
        end 
        if j==21

%Crear carpeta para guardar
             nomap=strcat('\7IN_N21_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180))+... %N20
                 ((dSilu((x(181).*xdatE(:,1))+(x(182).*xdatE(:,2))+(x(183).*xdatE(:,3))+(x(184).*xdatE(:,4))+(x(185).*xdatE(:,5))...
                  +(x(186).*xdatE(:,6))+(x(187).*xdatE(:,7))+x(188)))*x(189)))+x(190)); %N21 %peso y bia purelin  
                   
                          
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(190,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(190,1);
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
x0=2*rand(190,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatE(:,1))+(x2(182).*xdatE(:,2))+(x2(183).*xdatE(:,3))+(x2(184).*xdatE(:,4))+(x2(185).*xdatE(:,5))...
      +(x2(186).*xdatE(:,6))+(x2(187).*xdatE(:,7))+x2(188)))*x2(189)))+x2(190)); %N21 %peso y bia purelin  
                   

R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180))+... %N20 %peso y bia purelin
     ((dSilu((x2(181).*xdatT(:,1))+(x2(182).*xdatT(:,2))+(x2(183).*xdatT(:,3))+(x2(184).*xdatT(:,4))+(x2(185).*xdatT(:,5))...
      +(x2(186).*xdatT(:,6))+(x2(187).*xdatT(:,7))+x2(188)))*x2(189)))+x2(190)); %N21 %peso y bia purelin  
       
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatV(:,1))+(x2(182).*xdatV(:,2))+(x2(183).*xdatV(:,3))+(x2(184).*xdatV(:,4))+(x2(185).*xdatV(:,5))...
      +(x2(186).*xdatV(:,6))+(x2(187).*xdatV(:,7))+x2(188)))*x2(189)))+x2(190)); %N21 %peso y bia purelin  
       
R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161); x2(170); x2(179); x2(188)];
        B2=x2(190);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178);...
            x2(181) x2(182) x2(183) x2(184) x2(185) x2(186) x2(187)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180) x2(189)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end  
    if j==22

%Crear carpeta para guardar
             nomap=strcat('\7IN_N22_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180))+... %N20
                 ((dSilu((x(181).*xdatE(:,1))+(x(182).*xdatE(:,2))+(x(183).*xdatE(:,3))+(x(184).*xdatE(:,4))+(x(185).*xdatE(:,5))...
                  +(x(186).*xdatE(:,6))+(x(187).*xdatE(:,7))+x(188)))*x(189))+... %N21 
                 ((dSilu((x(190).*xdatE(:,1))+(x(191).*xdatE(:,2))+(x(192).*xdatE(:,3))+(x(193).*xdatE(:,4))+(x(194).*xdatE(:,5))...
                  +(x(195).*xdatE(:,6))+(x(196).*xdatE(:,7))+x(197)))*x(198)))+x(199)); %N22 %peso y bia purelin  
                   
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(199,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(199,1);
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
x0=2*rand(199,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatE(:,1))+(x2(182).*xdatE(:,2))+(x2(183).*xdatE(:,3))+(x2(184).*xdatE(:,4))+(x2(185).*xdatE(:,5))...
      +(x2(186).*xdatE(:,6))+(x2(187).*xdatE(:,7))+x2(188)))*x2(189))+... %N21
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(196)))*x2(197))+... %N22 
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(197)))*x2(198)))+x2(199)); %N22 %peso y bia purelin  
                                           
R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180))+... %N20 %peso y bia purelin
     ((dSilu((x2(181).*xdatT(:,1))+(x2(182).*xdatT(:,2))+(x2(183).*xdatT(:,3))+(x2(184).*xdatT(:,4))+(x2(185).*xdatT(:,5))...
      +(x2(186).*xdatT(:,6))+(x2(187).*xdatT(:,7))+x2(188)))*x2(189))+... %N21 %peso y bia purelin  
     ((dSilu((x2(190).*xdatT(:,1))+(x2(191).*xdatT(:,2))+(x2(192).*xdatT(:,3))+(x2(193).*xdatT(:,4))+(x2(194).*xdatT(:,5))...
      +(x2(195).*xdatT(:,6))+(x2(196).*xdatT(:,7))+x2(197)))*x2(198)))+x2(199)); %N22 %peso y bia purelin  
        
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatV(:,1))+(x2(182).*xdatV(:,2))+(x2(183).*xdatV(:,3))+(x2(184).*xdatV(:,4))+(x2(185).*xdatV(:,5))...
      +(x2(186).*xdatV(:,6))+(x2(187).*xdatV(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatV(:,1))+(x2(191).*xdatV(:,2))+(x2(192).*xdatV(:,3))+(x2(193).*xdatV(:,4))+(x2(194).*xdatV(:,5))...
      +(x2(195).*xdatV(:,6))+(x2(196).*xdatV(:,7))+x2(197)))*x2(198)))+x2(199)); %N22 %peso y bia purelin    

R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161); x2(170); x2(179); x2(188); x2(197)];
        B2=x2(199);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178);...
            x2(181) x2(182) x2(183) x2(184) x2(185) x2(186) x2(187); x2(190) x2(191) x2(192) x2(193) x2(194) x2(195) x2(196)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180) x2(189) x2(198)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==23

%Crear carpeta para guardar
             nomap=strcat('\7IN_N23_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE)((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180))+... %N20
                 ((dSilu((x(181).*xdatE(:,1))+(x(182).*xdatE(:,2))+(x(183).*xdatE(:,3))+(x(184).*xdatE(:,4))+(x(185).*xdatE(:,5))...
                  +(x(186).*xdatE(:,6))+(x(187).*xdatE(:,7))+x(188)))*x(189))+... %N21 
                 ((dSilu((x(190).*xdatE(:,1))+(x(191).*xdatE(:,2))+(x(192).*xdatE(:,3))+(x(193).*xdatE(:,4))+(x(194).*xdatE(:,5))...
                  +(x(195).*xdatE(:,6))+(x(196).*xdatE(:,7))+x(197)))*x(198))+... %N22
                 ((dSilu((x(199).*xdatE(:,1))+(x(200).*xdatE(:,2))+(x(201).*xdatE(:,3))+(x(202).*xdatE(:,4))+(x(203).*xdatE(:,5))...
                  +(x(204).*xdatE(:,6))+(x(205).*xdatE(:,7))+x(206)))*x(207)))+x(208)); %N23 %peso y bia purelin  
                                
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(208,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(208,1);
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
x0=2*rand(208,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatE(:,1))+(x2(182).*xdatE(:,2))+(x2(183).*xdatE(:,3))+(x2(184).*xdatE(:,4))+(x2(185).*xdatE(:,5))...
      +(x2(186).*xdatE(:,6))+(x2(187).*xdatE(:,7))+x2(188)))*x2(189))+... %N21
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(196)))*x2(197))+... %N22 
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(197)))*x2(198))+... %N22
     ((dSilu((x2(199).*xdatE(:,1))+(x2(200).*xdatE(:,2))+(x2(201).*xdatE(:,3))+(x2(202).*xdatE(:,4))+(x2(203).*xdatE(:,5))...
      +(x2(204).*xdatE(:,6))+(x2(205).*xdatE(:,7))+x2(206)))*x2(207)))+x2(208)); %N23 %peso y bia purelin  
                       
R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180))+... %N20 
     ((dSilu((x2(181).*xdatT(:,1))+(x2(182).*xdatT(:,2))+(x2(183).*xdatT(:,3))+(x2(184).*xdatT(:,4))+(x2(185).*xdatT(:,5))...
      +(x2(186).*xdatT(:,6))+(x2(187).*xdatT(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatT(:,1))+(x2(191).*xdatT(:,2))+(x2(192).*xdatT(:,3))+(x2(193).*xdatT(:,4))+(x2(194).*xdatT(:,5))...
      +(x2(195).*xdatT(:,6))+(x2(196).*xdatT(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatT(:,1))+(x2(200).*xdatT(:,2))+(x2(201).*xdatT(:,3))+(x2(202).*xdatT(:,4))+(x2(203).*xdatT(:,5))...
      +(x2(204).*xdatT(:,6))+(x2(205).*xdatT(:,7))+x2(206)))*x2(207)))+x2(208)); %N23 %peso y bia purelin  
          
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatV(:,1))+(x2(182).*xdatV(:,2))+(x2(183).*xdatV(:,3))+(x2(184).*xdatV(:,4))+(x2(185).*xdatV(:,5))...
      +(x2(186).*xdatV(:,6))+(x2(187).*xdatV(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatV(:,1))+(x2(191).*xdatV(:,2))+(x2(192).*xdatV(:,3))+(x2(193).*xdatV(:,4))+(x2(194).*xdatV(:,5))...
      +(x2(195).*xdatV(:,6))+(x2(196).*xdatV(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatV(:,1))+(x2(200).*xdatV(:,2))+(x2(201).*xdatV(:,3))+(x2(202).*xdatV(:,4))+(x2(203).*xdatV(:,5))...
      +(x2(204).*xdatV(:,6))+(x2(205).*xdatV(:,7))+x2(206)))*x2(207)))+x2(208)); %N23 %peso y bia purelin  
       
R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);...
           x2(53);x2(62);x2(71);x2(80);... 
           x2(89);x2(98);x2(107);x2(116);x2(125);...
           x2(134); x2(143); x2(152); x2(161); x2(170); x2(179); x2(188); x2(197); x2(206)];
        B2=x2(208);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178);...
            x2(181) x2(182) x2(183) x2(184) x2(185) x2(186) x2(187); x2(190) x2(191) x2(192) x2(193) x2(194) x2(195) x2(196);...
            x2(199) x2(200) x2(201) x2(202) x2(203) x2(204) x2(205)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180) x2(189) x2(198) x2(207)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
        if j==24

%Crear carpeta para guardar
             nomap=strcat('\7IN_N24_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180))+... %N20
                 ((dSilu((x(181).*xdatE(:,1))+(x(182).*xdatE(:,2))+(x(183).*xdatE(:,3))+(x(184).*xdatE(:,4))+(x(185).*xdatE(:,5))...
                  +(x(186).*xdatE(:,6))+(x(187).*xdatE(:,7))+x(188)))*x(189))+... %N21 
                 ((dSilu((x(190).*xdatE(:,1))+(x(191).*xdatE(:,2))+(x(192).*xdatE(:,3))+(x(193).*xdatE(:,4))+(x(194).*xdatE(:,5))...
                  +(x(195).*xdatE(:,6))+(x(196).*xdatE(:,7))+x(197)))*x(198))+... %N22
                 ((dSilu((x(199).*xdatE(:,1))+(x(200).*xdatE(:,2))+(x(201).*xdatE(:,3))+(x(202).*xdatE(:,4))+(x(203).*xdatE(:,5))...
                  +(x(204).*xdatE(:,6))+(x(205).*xdatE(:,7))+x(206)))*x(207))+... %N23
                 ((dSilu((x(208).*xdatE(:,1))+(x(209).*xdatE(:,2))+(x(210).*xdatE(:,3))+(x(211).*xdatE(:,4))+(x(212).*xdatE(:,5))...
                  +(x(213).*xdatE(:,6))+(x(214).*xdatE(:,7))+x(215)))*x(216)))+x(217)); %N23 %peso y bia purelin  
                   
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(217,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(217,1);
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
x0=2*rand(217,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatE(:,1))+(x2(182).*xdatE(:,2))+(x2(183).*xdatE(:,3))+(x2(184).*xdatE(:,4))+(x2(185).*xdatE(:,5))...
      +(x2(186).*xdatE(:,6))+(x2(187).*xdatE(:,7))+x2(188)))*x2(189))+... %N21
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(196)))*x2(197))+... %N22 
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(197)))*x2(198))+... %N22
     ((dSilu((x2(199).*xdatE(:,1))+(x2(200).*xdatE(:,2))+(x2(201).*xdatE(:,3))+(x2(202).*xdatE(:,4))+(x2(203).*xdatE(:,5))...
      +(x2(204).*xdatE(:,6))+(x2(205).*xdatE(:,7))+x2(206)))*x2(207))+... %N23
     ((dSilu((x2(208).*xdatE(:,1))+(x2(209).*xdatE(:,2))+(x2(210).*xdatE(:,3))+(x2(211).*xdatE(:,4))+(x2(212).*xdatE(:,5))...
      +(x2(213).*xdatE(:,6))+(x2(214).*xdatE(:,7))+x2(215)))*x2(216)))+x2(217)); %N24 %peso y bia purelin  
                   
R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180))+... %N20 
     ((dSilu((x2(181).*xdatT(:,1))+(x2(182).*xdatT(:,2))+(x2(183).*xdatT(:,3))+(x2(184).*xdatT(:,4))+(x2(185).*xdatT(:,5))...
      +(x2(186).*xdatT(:,6))+(x2(187).*xdatT(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatT(:,1))+(x2(191).*xdatT(:,2))+(x2(192).*xdatT(:,3))+(x2(193).*xdatT(:,4))+(x2(194).*xdatT(:,5))...
      +(x2(195).*xdatT(:,6))+(x2(196).*xdatT(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatT(:,1))+(x2(200).*xdatT(:,2))+(x2(201).*xdatT(:,3))+(x2(202).*xdatT(:,4))+(x2(203).*xdatT(:,5))...
      +(x2(204).*xdatT(:,6))+(x2(205).*xdatT(:,7))+x2(206)))*x2(207))+... %N23 
     ((dSilu((x2(208).*xdatT(:,1))+(x2(209).*xdatT(:,2))+(x2(210).*xdatT(:,3))+(x2(211).*xdatT(:,4))+(x2(212).*xdatT(:,5))...
      +(x2(213).*xdatT(:,6))+(x2(214).*xdatT(:,7))+x2(215)))*x2(216)))+x2(217)); %N24 %peso y bia purelin  
           
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatV(:,1))+(x2(182).*xdatV(:,2))+(x2(183).*xdatV(:,3))+(x2(184).*xdatV(:,4))+(x2(185).*xdatV(:,5))...
      +(x2(186).*xdatV(:,6))+(x2(187).*xdatV(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatV(:,1))+(x2(191).*xdatV(:,2))+(x2(192).*xdatV(:,3))+(x2(193).*xdatV(:,4))+(x2(194).*xdatV(:,5))...
      +(x2(195).*xdatV(:,6))+(x2(196).*xdatV(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatV(:,1))+(x2(200).*xdatV(:,2))+(x2(201).*xdatV(:,3))+(x2(202).*xdatV(:,4))+(x2(203).*xdatV(:,5))...
      +(x2(204).*xdatV(:,6))+(x2(205).*xdatV(:,7))+x2(206)))*x2(207))+... %N23
     ((dSilu((x2(208).*xdatV(:,1))+(x2(209).*xdatV(:,2))+(x2(210).*xdatV(:,3))+(x2(211).*xdatV(:,4))+(x2(212).*xdatV(:,5))...
      +(x2(213).*xdatV(:,6))+(x2(214).*xdatV(:,7))+x2(215)))*x2(216)))+x2(217)); %N24 %peso y bia purelin  
        
R2=desnormT(RV,x8m,x8s);
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);x2(53);x2(62);x2(71);x2(80);...
           x2(89);x2(98);x2(107);x2(116);x2(125);x2(134); x2(143); x2(152); x2(161); x2(170);...
           x2(179); x2(188); x2(197); x2(206); x2(215)];
        B2=x2(217);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178);...
            x2(181) x2(182) x2(183) x2(184) x2(185) x2(186) x2(187); x2(190) x2(191) x2(192) x2(193) x2(194) x2(195) x2(196);...
            x2(199) x2(200) x2(201) x2(202) x2(203) x2(204) x2(205); x2(208) x2(209) x2(210) x2(211) x2(212) x2(213) x2(214)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180) x2(189) x2(198) x2(207) x2(216)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
         if j==25

%Crear carpeta para guardar
             nomap=strcat('\7IN_N25_dSilu_RN_RESULTADOS_LSQ_',strcat(datestr(date)));
             mkdir([pwd,nomap])
             nn=[pwd nomap];
             warning off 

%% Función con pesos como variables  
%Test 
fun = @(x,xdatE) ((((dSilu((x(1).*xdatE(:,1))+(x(2).*xdatE(:,2))+(x(3).*xdatE(:,3))+(x(4).*xdatE(:,4))+(x(5).*xdatE(:,5))...
                  +(x(6).*xdatE(:,6))+(x(7).*xdatE(:,7))+x(8)))*x(9))+... %N1
                 ((dSilu((x(10).*xdatE(:,1))+(x(11).*xdatE(:,2))+(x(12).*xdatE(:,3))+(x(13).*xdatE(:,4))+(x(14).*xdatE(:,5))...
                  +(x(15).*xdatE(:,6))+(x(16).*xdatE(:,7))+x(17)))*x(18))+...%N2 
                 ((dSilu((x(19).*xdatE(:,1))+(x(20).*xdatE(:,2))+(x(21).*xdatE(:,3))+(x(22).*xdatE(:,4))+(x(23).*xdatE(:,5))...
                  +(x(24).*xdatE(:,6))+(x(25).*xdatE(:,7))+x(26)))*x(27))+... %N3
                 ((dSilu((x(28).*xdatE(:,1))+(x(29).*xdatE(:,2))+(x(30).*xdatE(:,3))+(x(31).*xdatE(:,4))+(x(32).*xdatE(:,5))...
                  +(x(33).*xdatE(:,6))+(x(34).*xdatE(:,7))+x(35)))*x(36))+... %N4
                 ((dSilu((x(37).*xdatE(:,1))+(x(38).*xdatE(:,2))+(x(39).*xdatE(:,3))+(x(40).*xdatE(:,4))+(x(41).*xdatE(:,5))...
                  +(x(42).*xdatE(:,6))+(x(43).*xdatE(:,7))+x(44)))*x(45))+... %N5
                 ((dSilu((x(46).*xdatE(:,1))+(x(47).*xdatE(:,2))+(x(48).*xdatE(:,3))+(x(49).*xdatE(:,4))+(x(50).*xdatE(:,5))...
                  +(x(51).*xdatE(:,6))+(x(52).*xdatE(:,7))+x(53)))*x(54))+... %N6
                 ((dSilu((x(55).*xdatE(:,1))+(x(56).*xdatE(:,2))+(x(57).*xdatE(:,3))+(x(58).*xdatE(:,4))+(x(59).*xdatE(:,5))...
                  +(x(60).*xdatE(:,6))+(x(61).*xdatE(:,7))+x(62)))*x(63))+... %N7
                 ((dSilu((x(64).*xdatE(:,1))+(x(65).*xdatE(:,2))+(x(66).*xdatE(:,3))+(x(67).*xdatE(:,4))+(x(68).*xdatE(:,5))...
                  +(x(69).*xdatE(:,6))+(x(70).*xdatE(:,7))+x(71)))*x(72))+... %N8
                 ((dSilu((x(73).*xdatE(:,1))+(x(74).*xdatE(:,2))+(x(75).*xdatE(:,3))+(x(76).*xdatE(:,4))+(x(77).*xdatE(:,5))...
                  +(x(78).*xdatE(:,6))+(x(79).*xdatE(:,7))+x(80)))*x(81))+... %N9
                 ((dSilu((x(82).*xdatE(:,1))+(x(83).*xdatE(:,2))+(x(84).*xdatE(:,3))+(x(85).*xdatE(:,4))+(x(86).*xdatE(:,5))...
                  +(x(87).*xdatE(:,6))+(x(88).*xdatE(:,7))+x(89)))*x(90))+... %N10
                 ((dSilu((x(91).*xdatE(:,1))+(x(92).*xdatE(:,2))+(x(93).*xdatE(:,3))+(x(94).*xdatE(:,4))+(x(95).*xdatE(:,5))...
                  +(x(96).*xdatE(:,6))+(x(97).*xdatE(:,7))+x(98)))*x(99))+... %N11
                 ((dSilu((x(100).*xdatE(:,1))+(x(101).*xdatE(:,2))+(x(102).*xdatE(:,3))+(x(103).*xdatE(:,4))+(x(104).*xdatE(:,5))...
                  +(x(105).*xdatE(:,6))+(x(106).*xdatE(:,7))+x(107)))*x(108))+... %N12
                 ((dSilu((x(109).*xdatE(:,1))+(x(110).*xdatE(:,2))+(x(111).*xdatE(:,3))+(x(112).*xdatE(:,4))+(x(113).*xdatE(:,5))...
                  +(x(114).*xdatE(:,6))+(x(115).*xdatE(:,7))+x(116)))*x(117))+... %N13
                 ((dSilu((x(118).*xdatE(:,1))+(x(119).*xdatE(:,2))+(x(120).*xdatE(:,3))+(x(121).*xdatE(:,4))+(x(122).*xdatE(:,5))...
                  +(x(123).*xdatE(:,6))+(x(124).*xdatE(:,7))+x(125)))*x(126))+... %N14
                 ((dSilu((x(127).*xdatE(:,1))+(x(128).*xdatE(:,2))+(x(129).*xdatE(:,3))+(x(130).*xdatE(:,4))+(x(131).*xdatE(:,5))...
                  +(x(132).*xdatE(:,6))+(x(133).*xdatE(:,7))+x(134)))*x(135))+... %N15 
                 ((dSilu((x(136).*xdatE(:,1))+(x(137).*xdatE(:,2))+(x(138).*xdatE(:,3))+(x(139).*xdatE(:,4))+(x(140).*xdatE(:,5))...
                  +(x(141).*xdatE(:,6))+(x(142).*xdatE(:,7))+x(143)))*x(144))+...); %N16     
                 ((dSilu((x(145).*xdatE(:,1))+(x(146).*xdatE(:,2))+(x(147).*xdatE(:,3))+(x(148).*xdatE(:,4))+(x(149).*xdatE(:,5))...
                  +(x(150).*xdatE(:,6))+(x(151).*xdatE(:,7))+x(152)))*x(153))+... %N17 
                 ((dSilu((x(154).*xdatE(:,1))+(x(155).*xdatE(:,2))+(x(156).*xdatE(:,3))+(x(157).*xdatE(:,4))+(x(158).*xdatE(:,5))...
                  +(x(159).*xdatE(:,6))+(x(160).*xdatE(:,7))+x(161)))*x(162))+... %N18                                                   
                 ((dSilu((x(163).*xdatE(:,1))+(x(164).*xdatE(:,2))+(x(165).*xdatE(:,3))+(x(166).*xdatE(:,4))+(x(167).*xdatE(:,5))...
                  +(x(168).*xdatE(:,6))+(x(169).*xdatE(:,7))+x(170)))*x(171))+... %N19  
                 ((dSilu((x(172).*xdatE(:,1))+(x(173).*xdatE(:,2))+(x(174).*xdatE(:,3))+(x(175).*xdatE(:,4))+(x(176).*xdatE(:,5))...
                  +(x(177).*xdatE(:,6))+(x(178).*xdatE(:,7))+x(179)))*x(180))+... %N20
                 ((dSilu((x(181).*xdatE(:,1))+(x(182).*xdatE(:,2))+(x(183).*xdatE(:,3))+(x(184).*xdatE(:,4))+(x(185).*xdatE(:,5))...
                  +(x(186).*xdatE(:,6))+(x(187).*xdatE(:,7))+x(188)))*x(189))+... %N21 
                 ((dSilu((x(190).*xdatE(:,1))+(x(191).*xdatE(:,2))+(x(192).*xdatE(:,3))+(x(193).*xdatE(:,4))+(x(194).*xdatE(:,5))...
                  +(x(195).*xdatE(:,6))+(x(196).*xdatE(:,7))+x(197)))*x(198))+... %N22
                 ((dSilu((x(199).*xdatE(:,1))+(x(200).*xdatE(:,2))+(x(201).*xdatE(:,3))+(x(202).*xdatE(:,4))+(x(203).*xdatE(:,5))...
                  +(x(204).*xdatE(:,6))+(x(205).*xdatE(:,7))+x(206)))*x(207))+... %N23
                 ((dSilu((x(208).*xdatE(:,1))+(x(209).*xdatE(:,2))+(x(210).*xdatE(:,3))+(x(211).*xdatE(:,4))+(x(212).*xdatE(:,5))...
                  +(x(213).*xdatE(:,6))+(x(214).*xdatE(:,7))+x(215)))*x(216))+... %N24 
                 ((dSilu((x(217).*xdatE(:,1))+(x(218).*xdatE(:,2))+(x(219).*xdatE(:,3))+(x(220).*xdatE(:,4))+(x(221).*xdatE(:,5))...
                  +(x(222).*xdatE(:,6))+(x(223).*xdatE(:,7))+x(224)))*x(225)))+x(226)); %N25 %peso y bia purelin  
                   
% Opcion para llamar al algortimo de Levenberg             
options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');
% Condiciones limite inferior
lb=[];
% Condiciones limite superior
ub=[];
%Valores aleatorios iniciales
x0=2*rand(226,1)-1;
% Vector que registre el valor del peso en un estado
ver=zeros(226,1);
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
x0=2*rand(226,1)-1; %numeros de -1 a 1
%x0=-4+(4+4).*rand(161,1);
% Funcion lsqcurvefit
[x2] = lsqcurvefit(fun,x0,xdatE,ydatE,lb,ub,options);
%% Reconstrucción de la salida aplicando los pesos a la función
%Test
R0=((((dSilu((x2(1).*xdatE(:,1))+(x2(2).*xdatE(:,2))+(x2(3).*xdatE(:,3))+(x2(4).*xdatE(:,4))+(x2(5).*xdatE(:,5))...
      +(x2(6).*xdatE(:,6))+(x2(7).*xdatE(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatE(:,1))+(x2(11).*xdatE(:,2))+(x2(12).*xdatE(:,3))+(x2(13).*xdatE(:,4))+(x2(14).*xdatE(:,5))...
      +(x2(15).*xdatE(:,6))+(x2(16).*xdatE(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatE(:,1))+(x2(20).*xdatE(:,2))+(x2(21).*xdatE(:,3))+(x2(22).*xdatE(:,4))+(x2(23).*xdatE(:,5))...
      +(x2(24).*xdatE(:,6))+(x2(25).*xdatE(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatE(:,1))+(x2(29).*xdatE(:,2))+(x2(30).*xdatE(:,3))+(x2(31).*xdatE(:,4))+(x2(32).*xdatE(:,5))...
      +(x2(33).*xdatE(:,6))+(x2(34).*xdatE(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatE(:,1))+(x2(38).*xdatE(:,2))+(x2(39).*xdatE(:,3))+(x2(40).*xdatE(:,4))+(x2(41).*xdatE(:,5))...
      +(x2(42).*xdatE(:,6))+(x2(43).*xdatE(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatE(:,1))+(x2(47).*xdatE(:,2))+(x2(48).*xdatE(:,3))+(x2(49).*xdatE(:,4))+(x2(50).*xdatE(:,5))...
      +(x2(51).*xdatE(:,6))+(x2(52).*xdatE(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatE(:,1))+(x2(56).*xdatE(:,2))+(x2(57).*xdatE(:,3))+(x2(58).*xdatE(:,4))+(x2(59).*xdatE(:,5))...
      +(x2(60).*xdatE(:,6))+(x2(61).*xdatE(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatE(:,1))+(x2(65).*xdatE(:,2))+(x2(66).*xdatE(:,3))+(x2(67).*xdatE(:,4))+(x2(68).*xdatE(:,5))...
      +(x2(69).*xdatE(:,6))+(x2(70).*xdatE(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatE(:,1))+(x2(74).*xdatE(:,2))+(x2(75).*xdatE(:,3))+(x2(76).*xdatE(:,4))+(x2(77).*xdatE(:,5))...
      +(x2(78).*xdatE(:,6))+(x2(79).*xdatE(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatE(:,1))+(x2(83).*xdatE(:,2))+(x2(84).*xdatE(:,3))+(x2(85).*xdatE(:,4))+(x2(86).*xdatE(:,5))...
      +(x2(87).*xdatE(:,6))+(x2(88).*xdatE(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatE(:,1))+(x2(92).*xdatE(:,2))+(x2(93).*xdatE(:,3))+(x2(94).*xdatE(:,4))+(x2(95).*xdatE(:,5))...
      +(x2(96).*xdatE(:,6))+(x2(97).*xdatE(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatE(:,1))+(x2(101).*xdatE(:,2))+(x2(102).*xdatE(:,3))+(x2(103).*xdatE(:,4))+(x2(104).*xdatE(:,5))...
      +(x2(105).*xdatE(:,6))+(x2(106).*xdatE(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatE(:,1))+(x2(110).*xdatE(:,2))+(x2(111).*xdatE(:,3))+(x2(112).*xdatE(:,4))+(x2(113).*xdatE(:,5))...
      +(x2(114).*xdatE(:,6))+(x2(115).*xdatE(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatE(:,1))+(x2(119).*xdatE(:,2))+(x2(120).*xdatE(:,3))+(x2(121).*xdatE(:,4))+(x2(122).*xdatE(:,5))...
      +(x2(123).*xdatE(:,6))+(x2(124).*xdatE(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatE(:,1))+(x2(128).*xdatE(:,2))+(x2(129).*xdatE(:,3))+(x2(130).*xdatE(:,4))+(x2(131).*xdatE(:,5))...
      +(x2(132).*xdatE(:,6))+(x2(133).*xdatE(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatE(:,1))+(x2(137).*xdatE(:,2))+(x2(138).*xdatE(:,3))+(x2(139).*xdatE(:,4))+(x2(140).*xdatE(:,5))...
      +(x2(141).*xdatE(:,6))+(x2(142).*xdatE(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatE(:,1))+(x2(146).*xdatE(:,2))+(x2(147).*xdatE(:,3))+(x2(148).*xdatE(:,4))+(x2(149).*xdatE(:,5))...
      +(x2(150).*xdatE(:,6))+(x2(151).*xdatE(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatE(:,1))+(x2(155).*xdatE(:,2))+(x2(156).*xdatE(:,3))+(x2(157).*xdatE(:,4))+(x2(158).*xdatE(:,5))...
      +(x2(159).*xdatE(:,6))+(x2(160).*xdatE(:,7))+x2(161)))*x2(162))+... %N18
     ((dSilu((x2(163).*xdatE(:,1))+(x2(164).*xdatE(:,2))+(x2(165).*xdatE(:,3))+(x2(166).*xdatE(:,4))+(x2(167).*xdatE(:,5))...
      +(x2(168).*xdatE(:,6))+(x2(169).*xdatE(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatE(:,1))+(x2(173).*xdatE(:,2))+(x2(174).*xdatE(:,3))+(x2(175).*xdatE(:,4))+(x2(176).*xdatE(:,5))...
      +(x2(177).*xdatE(:,6))+(x2(178).*xdatE(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatE(:,1))+(x2(182).*xdatE(:,2))+(x2(183).*xdatE(:,3))+(x2(184).*xdatE(:,4))+(x2(185).*xdatE(:,5))...
      +(x2(186).*xdatE(:,6))+(x2(187).*xdatE(:,7))+x2(188)))*x2(189))+... %N21
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(196)))*x2(197))+... %N22 
     ((dSilu((x2(190).*xdatE(:,1))+(x2(191).*xdatE(:,2))+(x2(192).*xdatE(:,3))+(x2(193).*xdatE(:,4))+(x2(194).*xdatE(:,5))...
      +(x2(195).*xdatE(:,6))+(x2(196).*xdatE(:,7))+x2(197)))*x2(198))+... %N22
     ((dSilu((x2(199).*xdatE(:,1))+(x2(200).*xdatE(:,2))+(x2(201).*xdatE(:,3))+(x2(202).*xdatE(:,4))+(x2(203).*xdatE(:,5))...
      +(x2(204).*xdatE(:,6))+(x2(205).*xdatE(:,7))+x2(206)))*x2(207))+... %N23
     ((dSilu((x2(208).*xdatE(:,1))+(x2(209).*xdatE(:,2))+(x2(210).*xdatE(:,3))+(x2(211).*xdatE(:,4))+(x2(212).*xdatE(:,5))...
      +(x2(213).*xdatE(:,6))+(x2(214).*xdatE(:,7))+x2(215)))*x2(216))+... %N24 
     ((dSilu((x2(217).*xdatE(:,1))+(x2(218).*xdatE(:,2))+(x2(219).*xdatE(:,3))+(x2(220).*xdatE(:,4))+(x2(221).*xdatE(:,5))...
      +(x2(222).*xdatE(:,6))+(x2(223).*xdatE(:,7))+x2(224)))*x2(225)))+x2(226)); %N25 %peso y bia purelin  
       
R=desnormT(R0,x8m,x8s);
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
 RT=((((dSilu((x2(1).*xdatT(:,1))+(x2(2).*xdatT(:,2))+(x2(3).*xdatT(:,3))+(x2(4).*xdatT(:,4))+(x2(5).*xdatT(:,5))...
      +(x2(6).*xdatT(:,6))+(x2(7).*xdatT(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatT(:,1))+(x2(11).*xdatT(:,2))+(x2(12).*xdatT(:,3))+(x2(13).*xdatT(:,4))+(x2(14).*xdatT(:,5))...
      +(x2(15).*xdatT(:,6))+(x2(16).*xdatT(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatT(:,1))+(x2(20).*xdatT(:,2))+(x2(21).*xdatT(:,3))+(x2(22).*xdatT(:,4))+(x2(23).*xdatT(:,5))...
      +(x2(24).*xdatT(:,6))+(x2(25).*xdatT(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatT(:,1))+(x2(29).*xdatT(:,2))+(x2(30).*xdatT(:,3))+(x2(31).*xdatT(:,4))+(x2(32).*xdatT(:,5))...
      +(x2(33).*xdatT(:,6))+(x2(34).*xdatT(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatT(:,1))+(x2(38).*xdatT(:,2))+(x2(39).*xdatT(:,3))+(x2(40).*xdatT(:,4))+(x2(41).*xdatT(:,5))...
      +(x2(42).*xdatT(:,6))+(x2(43).*xdatT(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatT(:,1))+(x2(47).*xdatT(:,2))+(x2(48).*xdatT(:,3))+(x2(49).*xdatT(:,4))+(x2(50).*xdatT(:,5))...
      +(x2(51).*xdatT(:,6))+(x2(52).*xdatT(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatT(:,1))+(x2(56).*xdatT(:,2))+(x2(57).*xdatT(:,3))+(x2(58).*xdatT(:,4))+(x2(59).*xdatT(:,5))...
      +(x2(60).*xdatT(:,6))+(x2(61).*xdatT(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatT(:,1))+(x2(65).*xdatT(:,2))+(x2(66).*xdatT(:,3))+(x2(67).*xdatT(:,4))+(x2(68).*xdatT(:,5))...
      +(x2(69).*xdatT(:,6))+(x2(70).*xdatT(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatT(:,1))+(x2(74).*xdatT(:,2))+(x2(75).*xdatT(:,3))+(x2(76).*xdatT(:,4))+(x2(77).*xdatT(:,5))...
      +(x2(78).*xdatT(:,6))+(x2(79).*xdatT(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatT(:,1))+(x2(83).*xdatT(:,2))+(x2(84).*xdatT(:,3))+(x2(85).*xdatT(:,4))+(x2(86).*xdatT(:,5))...
      +(x2(87).*xdatT(:,6))+(x2(88).*xdatT(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatT(:,1))+(x2(92).*xdatT(:,2))+(x2(93).*xdatT(:,3))+(x2(94).*xdatT(:,4))+(x2(95).*xdatT(:,5))...
      +(x2(96).*xdatT(:,6))+(x2(97).*xdatT(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatT(:,1))+(x2(101).*xdatT(:,2))+(x2(102).*xdatT(:,3))+(x2(103).*xdatT(:,4))+(x2(104).*xdatT(:,5))...
      +(x2(105).*xdatT(:,6))+(x2(106).*xdatT(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatT(:,1))+(x2(110).*xdatT(:,2))+(x2(111).*xdatT(:,3))+(x2(112).*xdatT(:,4))+(x2(113).*xdatT(:,5))...
      +(x2(114).*xdatT(:,6))+(x2(115).*xdatT(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatT(:,1))+(x2(119).*xdatT(:,2))+(x2(120).*xdatT(:,3))+(x2(121).*xdatT(:,4))+(x2(122).*xdatT(:,5))...
      +(x2(123).*xdatT(:,6))+(x2(124).*xdatT(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatT(:,1))+(x2(128).*xdatT(:,2))+(x2(129).*xdatT(:,3))+(x2(130).*xdatT(:,4))+(x2(131).*xdatT(:,5))...
      +(x2(132).*xdatT(:,6))+(x2(133).*xdatT(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatT(:,1))+(x2(137).*xdatT(:,2))+(x2(138).*xdatT(:,3))+(x2(139).*xdatT(:,4))+(x2(140).*xdatT(:,5))...
      +(x2(141).*xdatT(:,6))+(x2(142).*xdatT(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatT(:,1))+(x2(146).*xdatT(:,2))+(x2(147).*xdatT(:,3))+(x2(148).*xdatT(:,4))+(x2(149).*xdatT(:,5))...
      +(x2(150).*xdatT(:,6))+(x2(151).*xdatT(:,7))+x2(152)))*x2(153))+... %N17
     ((dSilu((x2(154).*xdatT(:,1))+(x2(155).*xdatT(:,2))+(x2(156).*xdatT(:,3))+(x2(157).*xdatT(:,4))+(x2(158).*xdatT(:,5))...
      +(x2(159).*xdatT(:,6))+(x2(160).*xdatT(:,7))+x2(161)))*x2(162))+... %N18 
     ((dSilu((x2(163).*xdatT(:,1))+(x2(164).*xdatT(:,2))+(x2(165).*xdatT(:,3))+(x2(166).*xdatT(:,4))+(x2(167).*xdatT(:,5))...
      +(x2(168).*xdatT(:,6))+(x2(169).*xdatT(:,7))+x2(170)))*x2(171))+... %N19
     ((dSilu((x2(172).*xdatT(:,1))+(x2(173).*xdatT(:,2))+(x2(174).*xdatT(:,3))+(x2(175).*xdatT(:,4))+(x2(176).*xdatT(:,5))...
      +(x2(177).*xdatT(:,6))+(x2(178).*xdatT(:,7))+x2(179)))*x2(180))+... %N20 
     ((dSilu((x2(181).*xdatT(:,1))+(x2(182).*xdatT(:,2))+(x2(183).*xdatT(:,3))+(x2(184).*xdatT(:,4))+(x2(185).*xdatT(:,5))...
      +(x2(186).*xdatT(:,6))+(x2(187).*xdatT(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatT(:,1))+(x2(191).*xdatT(:,2))+(x2(192).*xdatT(:,3))+(x2(193).*xdatT(:,4))+(x2(194).*xdatT(:,5))...
      +(x2(195).*xdatT(:,6))+(x2(196).*xdatT(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatT(:,1))+(x2(200).*xdatT(:,2))+(x2(201).*xdatT(:,3))+(x2(202).*xdatT(:,4))+(x2(203).*xdatT(:,5))...
      +(x2(204).*xdatT(:,6))+(x2(205).*xdatT(:,7))+x2(206)))*x2(207))+... %N23 
     ((dSilu((x2(208).*xdatT(:,1))+(x2(209).*xdatT(:,2))+(x2(210).*xdatT(:,3))+(x2(211).*xdatT(:,4))+(x2(212).*xdatT(:,5))...
      +(x2(213).*xdatT(:,6))+(x2(214).*xdatT(:,7))+x2(215)))*x2(216))+... %N24 %peso y bia purelin  
     ((dSilu((x2(217).*xdatT(:,1))+(x2(218).*xdatT(:,2))+(x2(219).*xdatT(:,3))+(x2(220).*xdatT(:,4))+(x2(221).*xdatT(:,5))...
      +(x2(222).*xdatT(:,6))+(x2(223).*xdatT(:,7))+x2(224)))*x2(225)))+x2(226)); %N25 %peso y bia purelin  
      
R1=desnormT(RT,x8m,x8s);
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
  RV=((((dSilu((x2(1).*xdatV(:,1))+(x2(2).*xdatV(:,2))+(x2(3).*xdatV(:,3))+(x2(4).*xdatV(:,4))+(x2(5).*xdatV(:,5))...
      +(x2(6).*xdatV(:,6))+(x2(7).*xdatV(:,7))+x2(8)))*x2(9))+... %N1
     ((dSilu((x2(10).*xdatV(:,1))+(x2(11).*xdatV(:,2))+(x2(12).*xdatV(:,3))+(x2(13).*xdatV(:,4))+(x2(14).*xdatV(:,5))...
      +(x2(15).*xdatV(:,6))+(x2(16).*xdatV(:,7))+x2(17)))*x2(18))+...%N2 
     ((dSilu((x2(19).*xdatV(:,1))+(x2(20).*xdatV(:,2))+(x2(21).*xdatV(:,3))+(x2(22).*xdatV(:,4))+(x2(23).*xdatV(:,5))...
      +(x2(24).*xdatV(:,6))+(x2(25).*xdatV(:,7))+x2(26)))*x2(27))+... %N3
     ((dSilu((x2(28).*xdatV(:,1))+(x2(29).*xdatV(:,2))+(x2(30).*xdatV(:,3))+(x2(31).*xdatV(:,4))+(x2(32).*xdatV(:,5))...
      +(x2(33).*xdatV(:,6))+(x2(34).*xdatV(:,7))+x2(35)))*x2(36))+... %N4
     ((dSilu((x2(37).*xdatV(:,1))+(x2(38).*xdatV(:,2))+(x2(39).*xdatV(:,3))+(x2(40).*xdatV(:,4))+(x2(41).*xdatV(:,5))...
      +(x2(42).*xdatV(:,6))+(x2(43).*xdatV(:,7))+x2(44)))*x2(45))+... %N5
     ((dSilu((x2(46).*xdatV(:,1))+(x2(47).*xdatV(:,2))+(x2(48).*xdatV(:,3))+(x2(49).*xdatV(:,4))+(x2(50).*xdatV(:,5))...
      +(x2(51).*xdatV(:,6))+(x2(52).*xdatV(:,7))+x2(53)))*x2(54))+... %N6
     ((dSilu((x2(55).*xdatV(:,1))+(x2(56).*xdatV(:,2))+(x2(57).*xdatV(:,3))+(x2(58).*xdatV(:,4))+(x2(59).*xdatV(:,5))...
      +(x2(60).*xdatV(:,6))+(x2(61).*xdatV(:,7))+x2(62)))*x2(63))+... %N7
     ((dSilu((x2(64).*xdatV(:,1))+(x2(65).*xdatV(:,2))+(x2(66).*xdatV(:,3))+(x2(67).*xdatV(:,4))+(x2(68).*xdatV(:,5))...
      +(x2(69).*xdatV(:,6))+(x2(70).*xdatV(:,7))+x2(71)))*x2(72))+... %N8
     ((dSilu((x2(73).*xdatV(:,1))+(x2(74).*xdatV(:,2))+(x2(75).*xdatV(:,3))+(x2(76).*xdatV(:,4))+(x2(77).*xdatV(:,5))...
      +(x2(78).*xdatV(:,6))+(x2(79).*xdatV(:,7))+x2(80)))*x2(81))+... %N9
     ((dSilu((x2(82).*xdatV(:,1))+(x2(83).*xdatV(:,2))+(x2(84).*xdatV(:,3))+(x2(85).*xdatV(:,4))+(x2(86).*xdatV(:,5))...
      +(x2(87).*xdatV(:,6))+(x2(88).*xdatV(:,7))+x2(89)))*x2(90))+... %N10
     ((dSilu((x2(91).*xdatV(:,1))+(x2(92).*xdatV(:,2))+(x2(93).*xdatV(:,3))+(x2(94).*xdatV(:,4))+(x2(95).*xdatV(:,5))...
      +(x2(96).*xdatV(:,6))+(x2(97).*xdatV(:,7))+x2(98)))*x2(99))+... %N11
     ((dSilu((x2(100).*xdatV(:,1))+(x2(101).*xdatV(:,2))+(x2(102).*xdatV(:,3))+(x2(103).*xdatV(:,4))+(x2(104).*xdatV(:,5))...
      +(x2(105).*xdatV(:,6))+(x2(106).*xdatV(:,7))+x2(107)))*x2(108))+... %N12
     ((dSilu((x2(109).*xdatV(:,1))+(x2(110).*xdatV(:,2))+(x2(111).*xdatV(:,3))+(x2(112).*xdatV(:,4))+(x2(113).*xdatV(:,5))...
      +(x2(114).*xdatV(:,6))+(x2(115).*xdatV(:,7))+x2(116)))*x2(117))+... %N13
     ((dSilu((x2(118).*xdatV(:,1))+(x2(119).*xdatV(:,2))+(x2(120).*xdatV(:,3))+(x2(121).*xdatV(:,4))+(x2(122).*xdatV(:,5))...
      +(x2(123).*xdatV(:,6))+(x2(124).*xdatV(:,7))+x2(125)))*x2(126))+... %N14
     ((dSilu((x2(127).*xdatV(:,1))+(x2(128).*xdatV(:,2))+(x2(129).*xdatV(:,3))+(x2(130).*xdatV(:,4))+(x2(131).*xdatV(:,5))...
      +(x2(132).*xdatV(:,6))+(x2(133).*xdatV(:,7))+x2(134)))*x2(135))+... %N15
     ((dSilu((x2(136).*xdatV(:,1))+(x2(137).*xdatV(:,2))+(x2(138).*xdatV(:,3))+(x2(139).*xdatV(:,4))+(x2(140).*xdatV(:,5))...
      +(x2(141).*xdatV(:,6))+(x2(142).*xdatV(:,7))+x2(143)))*x2(144))+... %N16
     ((dSilu((x2(145).*xdatV(:,1))+(x2(146).*xdatV(:,2))+(x2(147).*xdatV(:,3))+(x2(148).*xdatV(:,4))+(x2(149).*xdatV(:,5))...
      +(x2(150).*xdatV(:,6))+(x2(151).*xdatV(:,7))+x2(152)))*x2(153))+... %N17 
     ((dSilu((x2(154).*xdatV(:,1))+(x2(155).*xdatV(:,2))+(x2(156).*xdatV(:,3))+(x2(157).*xdatV(:,4))+(x2(158).*xdatV(:,5))...
      +(x2(159).*xdatV(:,6))+(x2(160).*xdatV(:,7))+x2(161)))*x2(162))+...%N18
     ((dSilu((x2(163).*xdatV(:,1))+(x2(164).*xdatV(:,2))+(x2(165).*xdatV(:,3))+(x2(166).*xdatV(:,4))+(x2(167).*xdatV(:,5))...
      +(x2(168).*xdatV(:,6))+(x2(169).*xdatV(:,7))+x2(170)))*x2(171))+... %N19 
     ((dSilu((x2(172).*xdatV(:,1))+(x2(173).*xdatV(:,2))+(x2(174).*xdatV(:,3))+(x2(175).*xdatV(:,4))+(x2(176).*xdatV(:,5))...
      +(x2(177).*xdatV(:,6))+(x2(178).*xdatV(:,7))+x2(179)))*x2(180))+... %N20
     ((dSilu((x2(181).*xdatV(:,1))+(x2(182).*xdatV(:,2))+(x2(183).*xdatV(:,3))+(x2(184).*xdatV(:,4))+(x2(185).*xdatV(:,5))...
      +(x2(186).*xdatV(:,6))+(x2(187).*xdatV(:,7))+x2(188)))*x2(189))+... %N21 
     ((dSilu((x2(190).*xdatV(:,1))+(x2(191).*xdatV(:,2))+(x2(192).*xdatV(:,3))+(x2(193).*xdatV(:,4))+(x2(194).*xdatV(:,5))...
      +(x2(195).*xdatV(:,6))+(x2(196).*xdatV(:,7))+x2(197)))*x2(198))+... %N22 
     ((dSilu((x2(199).*xdatV(:,1))+(x2(200).*xdatV(:,2))+(x2(201).*xdatV(:,3))+(x2(202).*xdatV(:,4))+(x2(203).*xdatV(:,5))...
      +(x2(204).*xdatV(:,6))+(x2(205).*xdatV(:,7))+x2(206)))*x2(207))+... %N23
     ((dSilu((x2(208).*xdatV(:,1))+(x2(209).*xdatV(:,2))+(x2(210).*xdatV(:,3))+(x2(211).*xdatV(:,4))+(x2(212).*xdatV(:,5))...
      +(x2(213).*xdatV(:,6))+(x2(214).*xdatV(:,7))+x2(215)))*x2(216))+... %N24
     ((dSilu((x2(217).*xdatV(:,1))+(x2(218).*xdatV(:,2))+(x2(219).*xdatV(:,3))+(x2(220).*xdatV(:,4))+(x2(221).*xdatV(:,5))...
      +(x2(222).*xdatV(:,6))+(x2(223).*xdatV(:,7))+x2(224)))*x2(225)))+x2(226)); %N25 %peso y bia purelin  

  
R2=desnormT(RV,x8m,x8s);
%R2=desnorm(RV,max(yrdatV),min(yrdatV),N(1),N(2));
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
        B1=[x2(8);x2(17);x2(26);x2(35);x2(44);x2(53);x2(62);x2(71);x2(80);...
           x2(89);x2(98);x2(107);x2(116);x2(125);x2(134); x2(143); x2(152); x2(161); x2(170);...
           x2(179); x2(188); x2(197); x2(206); x2(215); x2(224)];
        B2=x2(226);    
        IW=[x2(1) x2(2) x2(3) x2(4) x2(5) x2(6) x2(7); x2(10) x2(11) x2(12) x2(13) x2(14) x2(15) x2(16);...
            x2(19) x2(20) x2(21) x2(22) x2(23) x2(24) x2(25); x2(28) x2(29) x2(30) x2(31) x2(32) x2(33) x2(34);... 
            x2(37) x2(38) x2(39) x2(40) x2(41) x2(42) x2(43); x2(46) x2(47) x2(48) x2(49) x2(50) x2(51) x2(52);...
            x2(55) x2(56) x2(57) x2(58) x2(59) x2(60) x2(61); x2(64) x2(65) x2(66) x2(67) x2(68) x2(69) x2(70);...
            x2(73) x2(74) x2(75) x2(76) x2(77) x2(78) x2(79); x2(82) x2(83) x2(84) x2(85) x2(86) x2(87) x2(88);...
            x2(91) x2(92) x2(93) x2(94) x2(95) x2(96) x2(97); x2(100) x2(101) x2(102) x2(103) x2(104) x2(105) x2(106);...
            x2(109) x2(110) x2(111) x2(112) x2(113) x2(114) x2(115); x2(118) x2(119) x2(120) x2(121) x2(122) x2(123) x2(124);...
            x2(127) x2(128) x2(129) x2(130) x2(131) x2(132) x2(133); x2(136) x2(137) x2(138) x2(139) x2(140) x2(141) x2(142);...
            x2(145) x2(146) x2(147) x2(148) x2(149) x2(150) x2(151); x2(154) x2(155) x2(156) x2(157) x2(158) x2(159) x2(160);...
            x2(163) x2(164) x2(165) x2(166) x2(167) x2(168) x2(169); x2(172) x2(173) x2(174) x2(175) x2(176) x2(177) x2(178);...
            x2(181) x2(182) x2(183) x2(184) x2(185) x2(186) x2(187); x2(190) x2(191) x2(192) x2(193) x2(194) x2(195) x2(196);...
            x2(199) x2(200) x2(201) x2(202) x2(203) x2(204) x2(205); x2(208) x2(209) x2(210) x2(211) x2(212) x2(213) x2(214);...
            x2(217) x2(218) x2(219) x2(220) x2(221) x2(222) x2(223)];
        LW=[x2(9) x2(18) x2(27) x2(36) x2(45)...
            x2(54) x2(63) x2(72) x2(81)...
            x2(90) x2(99) x2(108) x2(117) x2(126)...
            x2(135) x2(144) x2(153) x2(162) x2(171) x2(180) x2(189) x2(198) x2(207) x2(216) x2(225)];

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
%    %    save([nn '\RmaxT' num2str(MaxRT) '.txt'],'MaxRT','-ascii');  
%    %    save([nn '\RmaxV' num2str(MaxRV) '.txt'],'MaxRV','-ascii');      
    end     

% Contador de iteaciones
Num=Num+1   
end
        end
end
