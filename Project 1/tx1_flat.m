function [tx, bits, gain] = tx1_flat()

tonecoeff = 4;
msgM = 4;
trellis = poly2trellis(7,[171 133]);

fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;

k = log2(msgM);

bits = randi([0 1],1024*k/2,1);
bits_transmit = convenc(bits, trellis);
syms = bi2de(reshape(bits_transmit,k,length(bits_transmit)/k).','left-msb')';
msg = pskmod(syms,msgM);
msglength = length(msg);

carrier = fskmod(tonecoeff*ones(1,msglength),M,fsep,nsamp,Fs);
msgUp = rectpulse(msg,nsamp);

tx = msgUp.*carrier;

gain = std(tx);
tx = tx./gain;

end