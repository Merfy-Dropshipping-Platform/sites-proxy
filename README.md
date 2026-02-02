# Sites Proxy

Единый nginx-прокси для всех сайтов Merfy с wildcard роутингом.

## Архитектура

```
User → *.merfy.ru → Traefik → sites-proxy (nginx) → MinIO
```

Один контейнер обрабатывает все сайты вместо отдельного контейнера на каждый сайт.

## Как это работает

1. Запрос приходит на `{subdomain}.merfy.ru`
2. Nginx извлекает subdomain из Host header
3. Проксирует запрос в MinIO: `merfy-sites/sites/{subdomain}/...`

## Структура файлов

```
sites-proxy/
├── Dockerfile      # Сборка образа
├── nginx.conf      # Конфигурация nginx
└── README.md       # Документация
```

## Деплой через Coolify

1. **Создать Application:**
   - Source: GitHub repo
   - Build Pack: Dockerfile
   - Base Directory: `backend/services/sites-proxy`
   - Port: 80

2. **Настроить домен:**
   - Domain: `*.merfy.ru` (wildcard)
   - SSL: Let's Encrypt с DNS challenge

3. **Traefik приоритеты:**
   ```
   api.merfy.ru      → api-gateway (priority: 100)
   coolify.merfy.ru  → coolify     (priority: 100)
   minio.merfy.ru    → minio       (priority: 100)
   *.merfy.ru        → sites-proxy (priority: 1)
   ```

## Локальная разработка

```bash
# Сборка
docker build -t sites-proxy .

# Запуск
docker run -p 8080:80 sites-proxy

# Тест (с подменой Host header)
curl -H "Host: testsite.merfy.ru" http://localhost:8080/health
```

## Health Check

```bash
curl https://{subdomain}.merfy.ru/health
# → OK
```

## Верификация всех сайтов

```bash
for sub in 013c276102e6 36eb643e8de6 w4ucjfczdqbs 0bfad7211637; do
  echo -n "$sub: "
  curl -sk -o /dev/null -w "%{http_code}" "https://$sub.merfy.ru/"
  echo
done
```

## Frozen сайты

При заморозке сайта (неоплата) Sites Service заменяет `index.html` на страницу "Сайт приостановлен".

## Преимущества

| До | После |
|----|-------|
| 22+ контейнеров | 1 контейнер |
| Зависимость от Coolify Worker | Нет зависимости |
| Деплой через RabbitMQ цепочку | Автоматически при генерации |
| Ручная отладка | IaC в репозитории |
