# Minz Mahallu Management System (MMS)

**Version 1.0.0** — A Qt 6.8 QML desktop application for Mosque Community Administration.

## Architecture

- **Frontend**: QML / Qt Quick (declarative UI with animations, gradients, flat design)
- **Backend**: C++20 (services, repositories, SQLite database)
- **Build**: CMake + MSVC 2022 + Qt 6.8.0
- **CI/CD**: GitHub Actions (auto-build on push, release on tag)

## Download

Latest build: https://github.com/kuttappu507/minzmahallu/releases

## Build

```bash
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Default Login

- **Username:** `admin`
- **Password:** `admin123`

## License

© 2024 Mahallu Management System. All rights reserved.
