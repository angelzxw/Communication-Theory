msgM = 16;
k = log2(msgM);
codeLen = msgM - 1;
messageLen = 10;

syms_max = floor(1024 / (msgM - 1)) * messageLen;

bits = randi([0 1], syms_max * k, 1);
syms = bi2de(reshape(bits, k, length(bits) / k).', 'left-msb')';

enk = comm.RSEncoder(codeLen, messageLen);
dek = comm.RSDecoder(codeLen, messageLen);

encoded = [];
for i = 1:syms_max/messageLen
    syms_current = syms((1+(i-1)*messageLen):i*messageLen);
    encoded = [encoded step(enk, syms_current')'];
end
msg = pskmod(encoded, msgM);

encoded(20) = 12;

decoded = step(dek, encoded')';

biterr(syms, decoded)