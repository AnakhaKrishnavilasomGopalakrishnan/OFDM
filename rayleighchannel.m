function s = rayleighchannel(signal,tau,fdTs,P,N,Ncp,No,pl,L)
[r, h] = Fading_Channel(signal, tau, fdTs, P);
tx_sig = r(1:end-L+1);
C = fft(h(1,:),N);
awgn = sqrt(No/2)*(randn(size(tx_sig))+1i*randn(size(tx_sig)));
tx_sig = tx_sig*sqrt(pl) + awgn;
tx_sig = tx_sig(Ncp+1:end);
y = fft(tx_sig)/sqrt(N);
s = y./C.';
end