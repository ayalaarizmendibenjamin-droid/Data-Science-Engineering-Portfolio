function dnorm=desnormT(Data,xm,xs)
%Función para desnormalizar vectores normalizados
%Data=valor normalizado
%xm=media de los datos
%xs=desviacion estandar de los datos
dnorm=(Data*xs)+xm;
end