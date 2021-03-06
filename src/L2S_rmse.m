function rmse = L2S_rmse(SNReff,per,snrAWGN,perAWGN)

perAWGN_int = interp1(snrAWGN,perAWGN,SNReff,'pchip');

delta_pre = log10(per./perAWGN_int);
delta = delta_pre(isfinite(delta_pre));

MiMk = length(delta);

rmse = sqrt(sum(delta.^2)/MiMk);

end