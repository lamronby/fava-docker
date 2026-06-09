ARG BEANCOUNT_VERSION=3.2.0
ARG FAVA_VERSION=v1.30.7
ARG BEANCOUNT_REDS_IMPORTERS_VERSION=main
ARG FAVA_PORTFOLIO_SUMMARY_VERSION=main

FROM debian:trixie AS build_env
ARG BEANCOUNT_VERSION

RUN apt-get update
RUN apt-get install -y build-essential libxml2-dev libxslt-dev curl \
        python3 libpython3-dev python3-pip git python3-venv

RUN python3 -m venv /app
ENV PATH="/app/bin:$PATH"

ADD requirements.txt .
RUN pip install -r requirements.txt
# beancount 3 support in beancount_reds_importers has not yet been released
# in a package
RUN pip install git+https://github.com/redstreet/beancount_reds_importers@8a08853a5839636428ff2bc5cd0fd0a508147560
# fava_portfolio_summary doesn't have a published package
RUN pip install git+https://github.com/PhracturedBlue/fava-portfolio-summary@7d3301619025d735830c389948e5527456050d44

RUN pip uninstall -y pip
RUN find /app -name __pycache__ -exec rm -rf -v {} +

FROM gcr.io/distroless/python3-debian13
COPY --from=build_env /app /app

# Default fava port number
EXPOSE 5000

ENV BEANCOUNT_FILE=""

ENV FAVA_HOST="0.0.0.0"
ENV PATH="/app/bin:$PATH"

ENTRYPOINT ["fava"]
