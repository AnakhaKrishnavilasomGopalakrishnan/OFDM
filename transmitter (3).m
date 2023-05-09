function signal = transmitter(msg,const_qpsk,N,Ncp,m)
symb(:,m) = const_qpsk(msg(:,m));
zk = sqrt(N)*ifft(symb(:,m),N);
signal = [zk(end-Ncp+1:end);zk];
end