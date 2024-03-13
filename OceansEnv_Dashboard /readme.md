## Description
### 공공데이터 기반 해양환경측정망 종합 수질 대시보드 제작을 위한 데이터 크롤러

현재 국내 해양환경측정망의 관측 결과 및 관측소 정보는 공공데이터포털 및 여러 지자체 사이트에서 공개되고 있으나, 전체를 한눈에 확인할 수 있는 매체는 찾아보기 어렵다. 이러한 접근성 부족을 보완하기 위한 프로젝트의 일환으로 공공데이터 API를 크롤링해 수질 데이터 테이블을 생성하는 코드이다. 이는 이후 tableau를 통한 수질 정보 시각화 대시보드로 연계된다.

생성되는 테이블에는 위치 및 시점별로(Row) [수질평가지수(WQI)](https://meis.go.kr/mei/wqi/introduce.do) 및 이의 기준 오염물질 중 표층 용존무기질소(DIN), 용존무기인(DIP), 클로로필(Chl-a)의 심각도(농도)가 기록된다(Column).

코드의 내용과 실행 결과는 [이 페이지](https://colab.research.google.com/drive/1y0D_xqlySsQKg99ZCFMzTucmvUWvA2ys?usp=sharing)에도 공개되어 있으며 이용된 API의 원출처는 다음과 같다.
- 해양환경공단 해양환경측정망 관측서비스 (url: https://www.data.go.kr/data/15059973/openapi.do)
- 해양환경공단 해양환경측정망 정점조회 서비스 (url: https://www.data.go.kr/data/15059966/openapi.do)
- 해양환경공단 해양환경측정망 근해 관측서비스 (url: https://www.data.go.kr/data/15059975/openapi.do)
- 해양환경공단 해양환경측정망 근해 정점조회 서비스 (url: https://www.data.go.kr/data/15059969/openapi.do)

## Environment 

> Python Version 3.10.12 (Google Colaboratory)

## Preresquisite

> import requests
> import json
> import pandas as pd
> import numpy as np
> import folium
> import seaborn as sns
> import matplotlib as plt
> import certifi
> import ssl
> from time import sleep

## Files

`해양환경측정망_크롤링.ipynb` Main (as Jupyter Notebook Script)

`points.csv` Generated Table for locations of observation stations

`data.csv` Generated Table of all observations

## Usages
![대시보드 완성 예시 이미지](OceansEnv_Dashboard /data/dashboard_example.png)
이 코드로 생성된 해양환경측정망 데이터를 활용한 종합 수질 대시보드 결과물은 [이 페이지](https://public.tableau.com/app/profile/sangock.kim/viz/_17033403477040/1_1?publish=yes)에서 확인할 수 있다.
