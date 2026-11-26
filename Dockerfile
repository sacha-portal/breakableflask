# --- Etape 1 : build (deps installees dans un venv) ---
FROM python:3.13-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN python -m venv /venv && /venv/bin/pip install --no-cache-dir -r requirements.txt

# --- Etape 2 : image finale minimale ---
FROM python:3.13-alpine
RUN apk upgrade --no-cache && pip uninstall -y pip && rm -rf /root/.cache \
 && addgroup -S app && adduser -S -G app -H app
WORKDIR /app
COPY --from=builder /venv /venv
COPY --chown=app:app main.py .
ENV PATH="/venv/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN /venv/bin/python -m pip uninstall -y pip || true
USER app
EXPOSE 4000
CMD ["python", "main.py"]