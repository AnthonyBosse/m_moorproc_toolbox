function X = sal78(P,T,CND,C1535,M)
%SAL78  SAL78(P,T,CND,C1535,M)
%	FUNCTION SERVES FOR TWO PURPOSES:
%	1:	CONVERT CONDUCTIVITY TO SALINITY (M=0)
%	2:	CONVERT SALINITY TO CONDUCTIVITY (M=1,
%		CND:=SAL)
%	ALGORITHMS RECOMMENDED BY JPOTS USING THE 1978
%	PRACTICAL SALINITY SCALE(IPSS-78) AND IPTS-68
%	FOR TEMPERATURE.
%	SAL78 COMPUTES EITHER 
%		CONDUCTIVITY RATIO
%	OR
%		ABSOLUTE CONDUCTIVITY
%	ACCORDING TO WETHER
%		C1535=1.0 (COND.RAT.)
%	OR
%		C1535=COND. AT S=35 NSU & T=15 DEG C.(ABS.COND.)
%		(IPTS-68)
%	UNITS:
%		PRESSURE        P         DBARS
%		TEMPERATURE     T         DEG.C.
%		SALINITY        S         NSU
%	RETURNS ZERO FOR CND < 0.0005  AND  M=0
%	RETURNS ZERO FOR CND < 0.02    AND  M=1
%	CHECKVALUES:
%		SAL78=1.888091
%	FOR	CND=SAL=40 NSU
%		T=      40 DEG C.
%		P=   10000 DBARS
%		SAL78=39.99999
%	FOR	CND= 1.888091
%		T=      40 DEG C.
%		P=   10000 DBARS
%
%	GETESTET MIT C1535=1.0
%		         S=40.0
%		         T=40.0 GRD C
%		         P=10000 DBAR
%		       CND=1.888091

%	last change: 23/02/93, Christian Mertens

P = P/10 ;

if nargin == 3
	C1535 = 42.914 ;
	M = 0 ;
end

%ZERO SALINITY TRAP
if M == 0 
     zerocnd = find(CND < 5e-4) ; 
else
     zerocnd = find(CND < 0.02) ;
end

%SELECT BRANCH FOR SALINITY (M=0) OR CONDUCT.(M=1)
DT = T - 15.0 ;

if M == 0

     %CONVERT CONDUCTIVITY TO SALINITY
     R = CND/C1535 ;
     RT = R./(rt35(T).*(1.0 + ccoef(P)./(bcoef(T) + acoef(T).*R))) ;
     RT = sqrt(abs(RT)) ;
     %SALINITY RETURN
     X = sal(RT,DT) ;
     X(zerocnd) = zeros(size(zerocnd)) ;
else
     %CONVERT SALINITY TO CONDUCTIVITY
     %FIRST APPROXIMATION
     RT = sqrt(CND/35.0) ;
     SI = sal(RT,DT) ;
     [m,n] = size(CND) ;
     for i=1:m
          for j=1:n
               N = 0 ;
               DELS = 1 ;
               %ITERATE (MAX 10 ITERAT.) TO INVERT SAL POLYNOMIAL
               %FOR sqrt(RT)
               while (DELS > 1.e-4 & N < 10)
                    RT(i,j) = RT(i,j) + (CND(i,j) - SI(i,j))/dsal(RT(i,j),DT(i,j)) ;
                    SI(i,j) = sal(RT(i,j),DT(i,j)) ;
                    N = N + 1 ;
                    DELS = abs(SI(i,j) - CND(i,j)) ;
               end
          end
     end
     %COMPUTE CONDUCTIVITY RATIO
     RTT = rt35(T) .* RT .* RT ;
     AT = acoef(T) ;
     BT = bcoef(T) ;
     CP = ccoef(P) ;
     CP = RTT.*(CP + BT) ;
     BT = BT - RTT.*AT ; 
     R = sqrt(abs(BT.*BT+4.0*AT.*CP)) - BT ;
     %CONDUCTIVITY RETURN
     X = 0.5*C1535*R./AT ;
     X(zerocnd) = zeros(zerocnd) ;
end
