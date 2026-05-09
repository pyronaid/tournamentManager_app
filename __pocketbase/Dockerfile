# ─── Build stage ────────────────────────────────────────────────────────────
FROM golang:1.24-alpine AS builder

WORKDIR /build

# Cache module downloads separately from source changes
COPY go.mod go.sum ./
RUN go mod download

# Copy source and compile a static binary (no CGO needed for PocketBase)
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o extended-pocketbase .

# ─── Runtime stage ──────────────────────────────────────────────────────────
FROM alpine:3.20

# ca-certificates: needed for HTTPS calls to Firebase / external APIs
# tzdata: needed for timezone-aware scheduling
RUN apk add --no-cache ca-certificates tzdata

# Mirror the production setup: dedicated low-privilege user
RUN addgroup -g 1001 pocketbase && \
    adduser -D -u 1001 -G pocketbase pocketbase

WORKDIR /home/pocketbase

COPY --from=builder /build/extended-pocketbase .

# pb_data  → database, migrations, logs  (must be persisted via a volume)
# pb_public → static files served by the GET /{path...} route
RUN mkdir -p pb_data pb_public && \
    chown -R pocketbase:pocketbase /home/pocketbase

USER pocketbase

EXPOSE 8080

VOLUME ["/home/pocketbase/pb_data", "/home/pocketbase/pb_public"]

CMD ["./extended-pocketbase", "serve", "--http=0.0.0.0:8080"]
