function [numCorrect] = rx1_flat(sig, bits, gain)

tonecoeff = 4;
msgM = 4;
trellis = poly2trellis(7,[171 133]);

fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;

numCorrect = 0;

carrier = fskmod(tonecoeff*ones(1,1024),M,fsep,nsamp,Fs);
rx = sig.*conj(carrier);
rx = intdump(rx,nsamp);

rxMsg = pskdemod(rx,msgM);

rx1 = de2bi(rxMsg,'left-msb'); % Map Symbols to Bits
rx2 = reshape(rx1.',numel(rx1),1);

rxBits = de2bi(rx2);
rxBits = rxBits(:);
rxBits = vitdec(rxBits, trellis, 34, 'trunc', 'hard');

ber = biterr(rxBits, bits);

if ber == 0
    numCorrect = length(bits);
else 
end

end