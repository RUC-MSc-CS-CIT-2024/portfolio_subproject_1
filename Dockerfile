FROM python:3.13 AS build

WORKDIR /build
COPY ./data .

RUN <<EOF
python data.py
mkdir output
mv -t ./output imdb.backup wi.backup omdb_data.backup
EOF

FROM postgres:17.2 AS final
LABEL org.opencontainers.image.source https://github.com/RUC-MSc-CS-CIT-2024/portfolio_subproject_1

COPY --from=build /build/output /data
COPY ./src /scripts

COPY ./setup.sh docker-entrypoint-initdb.d/
