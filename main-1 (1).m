clc
clear all

f_c = 2e9;              % carrier frequency
BW = 1e6;               % bandwidth
No = 2.07e-14*1e-6*BW;  % noise-power
pl = 10^(-101/10);      % path-loss(101 dB)
v = 15;                 % speed of receiver
Td = 5.4e-6;            % delay-spread
Ts = 1/BW;              % symbol-time
fd = v/(3e8)*f_c;       % doppler frequency                       
fdTs = fd*Ts;           % normalized-doppler frequency
L = ceil(Td/Ts);        % number of taps
tau = [0 1 2 3 4 5];    % path-delay
Ncp = L-1;              % cyclic-prefix length
N = (1/(fdTs*10))-Ncp;  % number of samples 
M = 300;                % number of OFDM symbols
Pt = 20:5:60;           % transmit power
E = 10.^(Pt/10)*Ts;     % symbol energy
ofdm_sym = zeros(N,M,length(E));

channel_type = 'r'; % choose channel type: 'a'-awgn channel, 'r'-rayleigh fading channel

for i = 1:length(E)
    P = 1/L*ones(1,L);
    const_qpsk = [1+1i 1-1i -1+1i -1-1i]*(sqrt(E(i))/sqrt(2));
    msg = zeros(N,M);
    for m = 1:M  
        % transmitter
        msg(:,m) = randi([1 4],N,1);
        signal = transmitter(msg,const_qpsk,N,Ncp,m);

        if channel_type=='a'
        % awgn channel
            s = awgnchannel(signal,Ncp,N,No,pl);
            else if channel_type=='r'
        % Rayleigh fading channel
                s = rayleighchannel(signal,tau,fdTs,P,N,Ncp,No,pl,L);
            end
        end
    ofdm_sym(:,m,i) = s;
    end

    % Reciever
    ofdm_rxd = reshape(ofdm_sym(:,:,i),[N*M 1]);
    len_ofdm_rx = length(ofdm_rxd);
    dist = abs(repmat(ofdm_rxd,1,4) - repmat(const_qpsk,len_ofdm_rx,1)).^2;
    [min_val, index] = min(dist,[],2);
    
    % theoretical SER
    SER_theo(i) = 2*qfunc(sqrt(pl*E(i)/No)); 
    % SER
    reshape_msg = reshape(msg,[N*M 1]);
    SER(i) = length(find(reshape_msg ~= index))/length(index);
    % SNR
    SNR(i) = 10*log10(pl*E(i)/No); 
end

sub_car = [10,25,50,75];
for n = 1:length(sub_car)
    scatterplot(ofdm_sym(sub_car(n),:,6))
    title(['Received symbols for subcarrier number =' num2str(sub_car(n))])
end

% plot SER v/s SNR
figure(5)
semilogy(SNR,SER_theo,'b')
hold on
semilogy(SNR,SER,'r')
xlim([-5 50])
ylim([10^-3 10^0])
xlabel('SNR(dB)')
ylabel('SER')
title('SER v/s SNR')
legend('theoretical SER','simulated SER')

% SER v/s Ncp
E = 1e-1;
Ncp = 0:1:L-1;
snr = 10*log10(pl*E/No);
P = 1/L*ones(1,L);
const_qpsk = [1+1i 1-1i -1+1i -1-1i]*(sqrt(E)/sqrt(2));
msg = zeros(N,M);
SER = zeros(1,length(Ncp));
for j = 1:length(Ncp) 
    for m = 1:M  
        % transmitter
        msg(:,m) = randi([1 4],N,1);
        signal = transmitter(msg,const_qpsk,N,Ncp(j),m);

        % Rayleigh fading channel
        s = rayleighchannel(signal,tau,fdTs,P,N,Ncp(j),No,pl,L);
        ofdm_sym(:,m,j) = s;
    end
    % Reciever
    ofdm_rxd = reshape(ofdm_sym(:,:,j),[N*M 1]);
    scatterplot(ofdm_rxd)
    xlim([-0.5e-5,0.5e-5])
    ylim([-0.5e-5,0.5e-5])
    title(['scatterplot of received symbol for Ncp=' num2str(Ncp(j))])
    len_ofdm_rx = length(ofdm_rxd);
    dist = abs(repmat(ofdm_rxd,1,4) - repmat(const_qpsk,len_ofdm_rx,1)).^2;
    [min_val, index] = min(dist,[],2);
  
    %SER
    reshape_msg = reshape(msg,[N*M 1]);
    SER(j) = length(abs(find(reshape_msg ~= index)))/length(index);
end

figure(13)
plot(Ncp,SER)
xlabel('Ncp')
ylabel('SER')
title('Ncp v/s SER')