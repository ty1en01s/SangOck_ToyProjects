clear;clc;clf;

%상품설명서 공정가격 산출 일자(6월 25일) 기준 상품 및 시장 조건
face_value = 10000; %상품 액면가 10,000원
vol1 = 0.2485; vol2 = 0.2859; vol3 = 0.2671; %각 기초자산의 변동성 경험치, vo1: EUROSTOXX50, vol2: S&P500, vol3: HSCEI
rho12 = 0.5274; rho13 = 0.2226; rho23 = 0.1618; %각 기초자산 간 상관계수 경험치
CM = [1 rho12 rho13; rho12 1 rho23; rho13 rho23 1]; M = chol(CM)'; %기초자산의 상관행렬
r = 0.0066; %할인 기준 이자율

open = datenum('2021,07,07'); %개시일, 일 차이를 계산하기 위한 함수
check1 = datenum('2021,11,02'); %1차 평가일부터
check2 = datenum('2022,03,02');
check3 = datenum('2022,06,30');
check4 = datenum('2022,11,02');
check5 = datenum('2023,03,02');
check6 = datenum('2023,07,03');
check7 = datenum('2023,11,02'); 
check8 = datenum('2024,03,04'); %8차 평가일까지
close = datenum('2024,07,02'); %만기평가일
check_day = [check1 - open; check2 - open; check3 - open; check4 - open; ...
    check5 - open; check6 - open; check7 - open; check8 - open; close - open];

coupon = [0.0105 0.0210 0.0315 0.0420 0.0525 0.0630 0.0735 0.0840 0.0945]; %1~8차 조기상환 쿠폰
strike_price1 = [95 93 88 85 80 80 75 75 70]; %1~3(-1), 4~8차 조기상환 조건
strike_price2 = [90 88 82]; %1~3(-2) 조기상환 조건
Kib = 50; %Knock-in 배리어
dummy = 0.0945;

oneyear = 365; dt = 1/oneyear; tot_date = check_day(end); %하루 간격으로 종가 체크
repay_n = length(coupon); %상환되는 경우의 수

payment = zeros(1,repay_n);
for i = 1:repay_n
    payment(i) = face_value*(1+coupon(i));
end

%randn('seed',1); %디버깅용 랜덤시드 고정 기능(비활성화)
S0 = 100;
ns=1.0e5; tot_payoff = 0; %반복 횟수 선언
SP1 = zeros(tot_date+1,1); SP1(1) = S0; %(총 일수+1)만큼의 주가 벡터 선언
SP2 = zeros(tot_date+1,1); SP2(1) = S0;
SP3 = zeros(tot_date+1,1); SP3(1) = S0;

%매 시행마다 반복
for i=1:ns
    w = randn(3,tot_date);
    W = M*w;
    for j = 1:tot_date
        SP1(j+1) = SP1(j)*exp((r-0.5*vol1^2)*dt + vol1*sqrt(dt)*W(1,j)); %Black-Scholes 모형 주가 무작위 생성
        SP2(j+1) = SP2(j)*exp((r-0.5*vol2^2)*dt + vol2*sqrt(dt)*W(2,j));
        SP3(j+1) = SP3(j)*exp((r-0.5*vol3^2)*dt + vol3*sqrt(dt)*W(3,j));
    end
    WP = min(SP1,SP2); %Worst Performer, 가장 낮은 것을 선택하여 조기상환 조건 평가
    WP = min(WP, SP3);
    Price_at_checkday = WP(check_day+1); %자동조기상환 평가일만 고려
    Price_lowest(1) = min(WP(1:check_day(1)+1));
    Price_lowest(2) = min(WP(1:check_day(2)+1));
    Price_lowest(3) = min(WP(1:check_day(3)+1));
    payoff = zeros(1,repay_n);
    repay_event = 1;
    for j=1:repay_n %각각의 조기상환 기준 체크
        if Price_at_checkday(j) >= strike_price1(j) || j <=3 && Price_lowest(j) >= strike_price2(j)  %조기상환이 되면
            payoff(j) = payment(j); %쿠폰을 지급하여 payoff에 기록
            repay_event = 0; %Knock-In 배리어를 체크하지 않아도 된다고 기록
            break %for문을 나감, 이후 조기상환은 체크할 필요 없음
        end
    end
    if repay_event %repay_event에 값이 있으면, 즉 조기상환이 안 되면
        if min(WP) >= Kib
            payoff(end) = face_value * (1+dummy); %배리어를 치지 않은 경우 더미 반영해 지급
        else
            payoff(end) = face_value * (WP(end)/100); %배리어를 치면 손실
        end
    end
    tot_payoff = tot_payoff + payoff; %해당 시행의 최종 상환 결과를 시뮬레이션 전체 결과에 추가
    if rem(i,ns/5) == 0 %총 시행횟수를 5등분한 기준 시행마다
    figure(1);clf;hold on; %각 기초자산의 생성 결과 그래프 제시
    plot(WP,'color', [0.7 0.7 0.7],'LineWidth', 5); %조기상환의 기준이 된 각 시점 강조
    plot(SP1, 'r-', 'LineWidth', 0.3);
    plot(SP2, 'm-', 'LineWidth', 0.3);
    plot(SP3, 'b-', 'LineWidth', 0.3);
    drawnow limitrate
    i/ns*100 + "% done, Est. Nom. P. = " + sum(tot_payoff/i) %완료된 시행 비율, 진행 정도 출력
    end
end
tot_payoff = tot_payoff/ns; %시뮬레이션 전체 결과를 시행 횟수로 나눠 평균

for j = 1:repay_n %시뮬레이션 결과 기록된 평균 상환액을 상환 시점에 따라 할인
    disc_payoff(j) = tot_payoff(j)*exp(-r*check_day(j)*dt);
end
ELS_Price = sum(disc_payoff) %시점별 평균 상환액 현재가치 총합, 공정가치 산출