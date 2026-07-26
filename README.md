# 📱 App Comercio de Proximidad

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Odoo](https://img.shields.io/badge/Odoo-714B67?style=for-the-badge&logo=odoo&logoColor=white)](https://www.odoo.com/)

Aplicación móvil desarrollada en **Flutter** como parte del **Trabajo de Final de Grado (TFG)** en la **EETAC - Universitat Politècnica de Catalunya (UPC)**. El objetivo principal es promover y dinamizar el comercio local y de proximidad en Barcelona mediante un sistema de fidelización de puntos, integración con el ERP **Odoo** e **Identidad Digital Autosoberana (SSI)**.

---

## ✨ Características Principales

- 🔐 **Autenticación e Identidad Digital (SSI)**:
  - Inicio de sesión tradicional y registro de usuarios.
  - Autenticación avanzada con **Identidad Digital Autosoberana (SSI)** conectada mediante Deep Links a la Wallet App del usuario.
- 🏪 **Catálogo y Búsqueda de Comercios**:
  - Búsqueda en tiempo real por nombre de comercio.
  - Filtros dinámicos por **Ejes Comerciales (Eixos Comercials)** de Barcelona, **Categorías** (Alimentación, Ropa, Restauración, Servicios, etc.) y **Distritos**.
- 🗺️ **Mapas e Interacción**:
  - Visualización interactiva de la ubicación de los comercios mediante **OpenStreetMap** (`flutter_map`).
  - Botón de navegación directa hacia **Google Maps**.
- 🧾 **Historial de Compres i Punts**:
  - Consulta del historial de compras registrado desde la plataforma ERP Odoo con paginación infinita.
  - Visualización del saldo de **Puntos de Fidelidad** acumulados.
- 💳 **Pase Digital y Tarjeta Wallet**:
  - Generación de pases y códigos QR interactivos para identificación en comercios adheridos.

---

## 🛠️ Arquitectura y Tecnologías

La aplicación sigue una arquitectura modular separada por capas (**MVVM / Controller-Service Pattern**):

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK ^3.11.0)
- **Gestión de Estado**: `Provider` (`ChangeNotifier`)
- **Cliente HTTP**: `Dio` (Gestión de peticiones REST, timeouts e interceptores)
- **Almacenamiento Local**: `shared_preferences` para la persistencia segura de tokens JWT y datos de sesión (`TokenManager`).
- **Navegación e Integración de Deep Links**: `app_links` y `url_launcher` para interacción fluida con la Wallet de Identidad Digital (`comercio://login-callback`).
- **Mapas y Coordenadas**: `flutter_map` y `latlong2`.
- **Diseño y Tipografía**: `google_fonts` (Manrope / Noto Serif) y sistema de diseño adaptado a la identidad corporativa.

---

## 📁 Estructura del Proyecto

```text
lib/
├── controller/          # Gestión de estado (AuthController, CommerceController, PurchaseController, NavigationController)
├── models/              # Modelos de datos mutables (UserModel, CommerceModel, PurchaseModel, EixComercialModel)
├── screens/             # Pantallas principales de la aplicación (Home, Search, CommerceDetail, PurchaseHistory, Profile, etc.)
├── services/            # Servicios de comunicación con el Backend REST y Odoo (AuthService, CommerceService, PurchaseService)
├── theme/               # Paleta de colores, tipografías y tema global (AppColors, AppTheme)
├── utils/               # Gestores de utilidad local (TokenManager)
└── widgets/             # Componentes de UI modulares y reutilizables (PurchaseCard, CommerceCard, SearchFilterSheet, CommerceMapView, etc.)
```

---

## 🚀 Configuración e Instalación

### Requisitos Previos

- **Flutter SDK**: ^3.11.0 o superior
- **Dart SDK**: ^3.11.0
- **Dispositivo o Emulador**: Android Studio / Xcode

### Pasos de Instalación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/Pedrorodriguez016/Comercio-de-Proximidad_frontend.git
   cd Comercio-de-Proximidad_frontend
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```