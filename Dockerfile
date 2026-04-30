# Stage 1: Build Flutter Web
FROM cirrusci/flutter:stable AS build

WORKDIR /app

# Copiar pubspec
COPY pubspec.yaml pubspec.lock ./

# Instalar dependencias
RUN flutter pub get

# Copiar código fuente
COPY . .

# Compilar para web
RUN flutter build web --release

# Stage 2: Servir con nginx
FROM nginx:alpine

# Copiar archivos compilados
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
