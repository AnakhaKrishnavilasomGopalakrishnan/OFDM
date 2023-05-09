function s = awgnchannel(signal,Ncp,N,No,pl)
tx_sig = signal.';
awgn = sqrt(No/2)*(randn(size(tx_sig))+1i*randn(size(tx_sig)));
tx_sig = tx_sig * sqrt(pl) + awgn;
tx_sig = tx_sig(Ncp+1:end);
s = fft(tx_sig)/sqrt(N);
end