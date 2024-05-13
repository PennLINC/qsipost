
# Build into a wheel in a stage that has git installed
FROM python:slim AS wheelstage
RUN pip install build
RUN apt-get update && \
    apt-get install -y --no-install-recommends git
COPY . /src/qsipost
RUN python -m build /src/qsipost

FROM pennbbl/qsipost_build:24.4.29

# Install qsipost wheel
COPY --from=wheelstage /src/qsipost/dist/*.whl .
RUN pip install --no-cache-dir $( ls *.whl )

# Precaching fonts, set 'Agg' as default backend for matplotlib
RUN python -c "from matplotlib import font_manager" && \
    sed -i 's/\(backend *: \).*$/\1Agg/g' $( python -c "import matplotlib; print(matplotlib.matplotlib_fname())" )

RUN find $HOME -type d -exec chmod go=u {} + && \
    find $HOME -type f -exec chmod go=u {} +

RUN ldconfig
WORKDIR /tmp/
ENTRYPOINT ["/opt/conda/envs/qsipost/bin/qsipost"]
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="qsipost" \
      org.label-schema.description="qsipost - q Space Images preprocessing tool" \
      org.label-schema.url="http://qsipost.readthedocs.io" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/pennbbl/qsipost" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"