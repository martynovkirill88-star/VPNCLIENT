# 🛡️ VPNCLIENT — Умный iOS VPN Клиент (Xray / Sing-box Core)

[![iOS](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)](https://swift.org)
[![Build Status](https://github.com/martynovkirill88-star/VPNCLIENT/actions/workflows/build-ios.yml/badge.svg)](https://github.com/martynovkirill88-star/VPNCLIENT/actions)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Современный нативный клиент VPN для iOS, созданный на **SwiftUI** и **NetworkExtension** (`NEPacketTunnelProvider`) с интеграцией ядра **Sing-box / Xray-core**. 

Спроектирован специально для максимальной скорости, низкого пинга и надежного обхода блокировок и замедлений ТСПУ (включая YouTube, Discord, Instagram) с уникальной системой **Умной Сетевой Маршрутизации (Smart Wi-Fi / LTE Switching)**.

---

## 🌟 Ключевые возможности

### 🚀 1. Умная Сетевая Маршрутизация (Smart Wi-Fi / LTE Auto-Switching)
- **При переходе на мобильную сеть (Cellular / LTE / 5G)**:
  - Автоматически переключает маршрут на группу серверов **`🇷🇺 LTE 1, 2, 3`** (Selectel CDN, Яндекс CDN, Cloudflare SplitHTTP).
  - Обеспечивает мгновенную загрузку превью и видео YouTube на мобильных операторах (Билайн, МТС, МегаФон, Т2).
  - Опция **Автоподключения** при переключении с Wi-Fi на сотовые данные.
- **При переходе на Wi-Fi (домашний / офисный интернет)**:
  - Автоматически запускает параллельный пинг всех доступных нод и переключается на **`⚡ LeastPing`** — зарубежный сервер с наименьшей задержкой (Германия, Нидерланды) без CDN-оверхеда.
  - Опция автоматического коннекта при подключении к известному Wi-Fi.

### ⚡ 2. Поддержка всех современных протоколов
- **VLESS + XTLS Reality** (маскировка под `gateway.icloud.com`, `microsoft.com` с хромоподобным TLS fingerprint).
- **SplitHTTP / XHTTP** (совместимость с российскими CDN-провайдерами Selectel, Яндекс Облако).
- **Hysteria 2 Turbo** (UDP-протокол на базе модифицированного QUIC для нестабильных каналов).
- **gRPC & WebSocket** (Fallback-протоколы).
- **VMess, Trojan, Shadowsocks**.

### 🎨 3. Премиальный Cyber/Dark Glassmorphic UI
- **Центральная пульсирующая кнопка** с динамической неоновой анимацией и тактильной отдачей (`Haptic Feedback`).
- **Спидометр в реальном времени**: раздельные графики входящей и исходящей скорости.
- **Индикатор текущей сети**: отображает статус (`📶 Сотовая сеть • Обход LTE` или `🛜 Wi-Fi • leastPing`).
- **Менеджер подписок**: прямая поддержка ссылок RemnaWave Panel (`https://sub1.chepushkavpn.fun/...`) с User-Agent `Happ/4.8.0`.
- **Прямой обход российских сайтов (Direct Bypass)**: банки, Госуслуги, Яндекс, VK работают напрямую без проксирования и задержек.
- **Встроенный Kill-Switch**: блокировка утечек трафика при обрыве соединения.

---

## 📁 Структура проекта

```text
VPNCLIENT/
├── VPNClientApp/                  # Основное приложение SwiftUI
│   ├── App/                       # Точка входа VPNClientApp.swift
│   ├── Models/                    # Модели: ServerConfig, NetworkType, VPNState, RoutingRule
│   ├── Managers/                  # Менеджеры:
│   │   ├── VPNManager.swift       # Управление NETunnelProviderManager
│   │   ├── NetworkMonitor.swift   # Мониторинг интерфейсов NWPathMonitor
│   │   ├── SmartRoutingManager.swift # Логика переключения LTE CDN <-> Wi-Fi LeastPing
│   │   ├── SubscriptionManager.swift # Загрузка и парсинг подписок RemnaWave
│   │   ├── PingManager.swift      # Параллельный замер сетевого пинга
│   │   └── TrafficStatsManager.swift # Расчет скоростей и точки графиков
│   ├── Views/                     # Экраны и компоненты:
│   │   ├── Dashboard/             # Главный экран со спидометром и кнопкой
│   │   ├── Servers/               # Список нод с фильтрацией (LTE, Wi-Fi, Избранное)
│   │   ├── SmartRouting/          # Настройки умного переключения
│   │   ├── Subscription/          # Управление URL подписки
│   │   ├── Settings/              # DNS, MTU 9000, Bypass RU, Kill-Switch
│   │   └── Components/            # PulseButton, GlassCard, PingIndicator
│   └── Theme/                     # Дизайн-система (AppColors, Glassmorphism)
│
├── PacketTunnel/                  # NetworkExtension (Туннель уровня ядра iOS)
│   ├── PacketTunnelProvider.swift # Обработчик пакетов packetFlow и IPC
│   ├── CoreTunnelBridge.swift     # Мост к Xray / Sing-box TUN стеку
│   └── XrayConfigBuilder.swift    # Динамическая сборка конфига
│
├── Shared/                        # Общий код App Group и IPC
│   ├── SharedConstants.swift      # Идентификаторы App Group и ключи UserDefaults
│   ├── IPCProtocol.swift          # Двусторонний протокол App <-> Tunnel
│   └── ConfigGenerator.swift      # Генератор JSON-конфигураций
│
├── Scripts/                       # Вспомогательные скрипты
│   ├── generate_project.sh        # Генерация .xcodeproj через XcodeGen
│   └── build_xcframework.sh       # Сборка Go core в XCFramework
├── .github/workflows/             # CI/CD: автоматическая сборка на macOS runner
│   └── build-ios.yml
├── project.yml                    # Спецификация для XcodeGen
└── README.md
```

---

## 🛠️ Сборка и запуск на macOS

### Требования
- macOS 14 Sonoma / macOS 15 Sequoia (или новее)
- **Xcode 15** или **Xcode 16** (с установленным iOS 16+ SDK)
- Аккаунт Apple ID (бесплатный личный или платный Apple Developer Program)

### Быстрый старт через XcodeGen

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/martynovkirill88-star/VPNCLIENT.git
   cd VPNCLIENT
   ```

2. Установите `xcodegen` (если еще не установлен):
   ```bash
   brew install xcodegen
   ```

3. Сгенерируйте Xcode-проект:
   ```bash
   xcodegen generate
   ```

4. Откройте сгенерированный проект:
   ```bash
   open VPNCLIENT.xcodeproj
   ```

5. **Настройка подписи (Signing & Capabilities)** в Xcode:
   - Выберите таргет **VPNClientApp** -> вкладка **Signing & Capabilities**.
   - Укажите ваш **Team** (личный Apple ID или Developer Team).
   - В секции **App Groups** убедитесь, что включена группа `group.com.vpnclient.app` (или ваш Bundle ID).
   - Повторите то же самое для таргета **PacketTunnel** (Team должен совпадать).

6. Подключите iPhone по кабелю или выберите симулятор и нажмите **Cmd + R** (Запуск).

---

## 🌐 Настройка подписки (RemnaWave / Happ)

Приложение из коробки поддерживает подписки формата:
```text
https://sub1.chepushkavpn.fun/3qgSvJLYGfqzSv0x
```
Вкладка **Подписка** позволяет:
- Вставить любую ссылку подписки.
- Получать автоматическое обновление узлов при запуске или по свайпу вниз (Pull-to-refresh).
- Автоматически определять теги **`[LTE BYPASS]`** и распределять серверы по умным профилям.

---

## ⚙️ Автоматическая сборка в GitHub Actions

В репозитории настроен рабочий процесс GitHub Actions (`.github/workflows/build-ios.yml`):
- При каждом `push` в ветку `main` проект автоматически собирается на macOS runner.
- Проверяется компиляция Swift-файлов основного приложения и таргета Network Extension.
- Готовый архив `VPNCLIENT.xcarchive` сохраняется в артефактах сборки.

---

## 📄 Лицензия

Распространяется под лицензией MIT.
Разработано для личного использования и приватного доступа к сети.
