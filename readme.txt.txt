%--------------------------------------------------------------------------
% IEEE 802.11.n Simulation
%
% - OFDM transmitter consisting of packet composer, convolutional encoder,
%   mapping and modulation (IFFT)
% - multi-dimensional multipath channel (ETSI model), remains constant
%   during a packet
% - OFDM receiver consisting of channel estimation, frequency equalisation,
%   demodulation (FFT),demapping (soft decisions) and viterbi decoder
% - antenna transmit diversity
% - calculation of packet error rate and bit error rate
% - channel estimation in receiver
% - continuous/terminated decoding
%
% Versions:
% Andre Noll Barreto,  20.12.13, initial WiSiL version for IEEE 802.11n
%                                based on IEEE 802.11a simulator
%
%
% output results:
%                per: packet error rate
%                ber: bit error rate
%-------------------------------------------------------------------------------

% activities
7/1/2014
- retirada de tx diversity
- limpeza de c�digo
- compara��o de padr�o 802.11a com 802.11n (Marley Vin�cius)
	- cria��o de novos par�metros
	- modifica��o de c�digo (seguindo ordem de execu��o) at� hsr_dtransmitter-> BCC
	- testado com BCC 802.11a e n, sem channel estimation, 20MHz, 40MHz, 1 antena, short-preamble - 15/01/2014


- falta:
	- debugar LDPC
	- LDPC + STBC + 40 MHZ
	- MRC
	- ch est com 802.11a/n, Alamouti e 40MHz
	


ToDo:

- automatizar c�lculos no drate
- c�lculo do tput e Es/N0 efetivos
- estima��o de ru�do
- verificar detec��o do SIGNAl field
- melhorar uso do 'coderate' e 'modulation'
- verificar LDPC, n�o funciona para todos os MCS (rate =1/2)
- verificar composi��o do SIGNAL field para 802.11n
- consertar pilotos de acordo com norma (pilotos mudam a cada s�mbolo e para cada antena)
- time-variant channel within frame
- MIMO
- MIMO + Alamouti
- antenna selection
- beamforming
- frame aggregation
- reverse direction (feedback)
- different MCSs

