function ex=dSilu(data)
num=1+exp(-data)+(data.*exp(-data));
den=((1+exp(-data)).^2);
ex=num./den;
end