function ex=Mish(data)
ex=data.*(tanh(softplus(data)));
end